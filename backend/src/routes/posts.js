const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const Post = require('../models/Post');
const User = require('../models/User');
const { auth, requireUserType } = require('../middleware/auth');
const { getSupabase } = require('../config/database');

// All routes require authentication
router.use(auth);

// @route   POST /api/posts
// @desc    Create a new post (kids only, requires parent approval)
// @access  Private (Kid only)
router.post('/', requireUserType('kid'), [
  body('content').trim().isLength({ min: 1, max: 500 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { content, imageUrl } = req.body;
    
    // Check monitoring level - full monitoring means all posts require approval
    const author = await User.findById(req.user.id);
    if (!author) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const status = author.monitoringLevel === 'full' ? 'pending' : 'approved';
    
    // Create post using Post model
    const post = await Post.create({
      authorId: req.user.id,
      content: content.trim(),
      imageUrl: imageUrl || null,
      status: status,
      likes: [],
      comments: []
    });
    
    // Get author info for response
    const authorProfile = author.profile || {};
    
    res.status(201).json({
      post: {
        id: post.id,
        content: post.content,
        imageUrl: post.imageUrl,
        status: post.status,
        author: {
          id: author.id,
          profile: {
            displayName: authorProfile.displayName || author.email
          }
        },
        createdAt: post.createdAt
      },
      message: status === 'pending' 
        ? 'Post created and pending parent approval' 
        : 'Post created and approved'
    });
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/posts
// @desc    Get approved posts for news feed
// @access  Private
router.get('/', async (req, res) => {
  try {
    const supabase = await getSupabase();
    
    // Get user's friends and children based on user type
    let authorIds = [req.user.id]; // Always include self
    
    if (req.user.userType === 'kid') {
      // Kids see posts from themselves and their friends
      const { data: friendships, error: friendsError } = await supabase
        .from('friendships')
        .select('friend_id')
        .eq('user_id', req.user.id)
        .eq('status', 'accepted');
      
      if (!friendsError && friendships) {
        const friendIds = friendships.map(f => f.friend_id);
        authorIds = [...authorIds, ...friendIds];
      }
    } else {
      // Parents see posts from their children
      const { data: children, error: childrenError } = await supabase
        .from('parent_children')
        .select('child_id')
        .eq('parent_id', req.user.id);
      
      if (!childrenError && children) {
        const childIds = children.map(c => c.child_id);
        authorIds = [...authorIds, ...childIds];
      }
    }
    
    // Get approved posts from these authors
    const { data: postsData, error: postsError } = await supabase
      .from('posts')
      .select('*')
      .eq('status', 'approved')
      .in('author_id', authorIds)
      .order('created_at', { ascending: false })
      .limit(50);
    
    if (postsError) {
      console.error('Error fetching posts:', postsError);
      return res.status(500).json({ error: 'Failed to fetch posts' });
    }
    
    // Get author information for each post
    const postsWithAuthors = [];
    if (postsData) {
      const authorIdsSet = new Set(postsData.map(p => p.author_id));
      const authorIdsArray = Array.from(authorIdsSet);
      
      // Fetch all authors in one query
      const { data: authorsData, error: authorsError } = await supabase
        .from('users')
        .select('id, profile, verification')
        .in('id', authorIdsArray);
      
      const authorsMap = new Map();
      if (!authorsError && authorsData) {
        authorsData.forEach(author => {
          authorsMap.set(author.id, author);
        });
      }
      
      // Combine posts with author info
      for (const postData of postsData) {
        const author = authorsMap.get(postData.author_id);
        const authorProfile = author?.profile || {};
        
        postsWithAuthors.push({
          id: postData.id,
          content: postData.content,
          imageUrl: postData.image_url,
          status: postData.status,
          likes: postData.likes || [],
          comments: postData.comments || [],
          author: {
            id: author?.id || postData.author_id,
            profile: {
              displayName: authorProfile.displayName || 'Unknown',
              firstName: authorProfile.firstName,
              lastName: authorProfile.lastName
            },
            verification: author?.verification || { parentVerified: false, schoolVerified: false }
          },
          createdAt: postData.created_at,
          updatedAt: postData.updated_at
        });
      }
    }
    
    res.json({ posts: postsWithAuthors });
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/posts/pending
// @desc    Get pending posts for parent approval
// @access  Private (Parent only)
router.get('/pending', requireUserType('parent'), async (req, res) => {
  try {
    const supabase = await getSupabase();
    
    // Get parent's children
    const { data: children, error: childrenError } = await supabase
      .from('parent_children')
      .select('child_id')
      .eq('parent_id', req.user.id);
    
    if (childrenError) {
      console.error('Error fetching children:', childrenError);
      return res.status(500).json({ error: 'Failed to fetch children' });
    }
    
    const childIds = children ? children.map(c => c.child_id) : [];
    
    if (childIds.length === 0) {
      return res.json({ posts: [] });
    }
    
    // Get pending posts from parent's children
    const { data: postsData, error: postsError } = await supabase
      .from('posts')
      .select('*')
      .eq('status', 'pending')
      .in('author_id', childIds)
      .order('created_at', { ascending: false });
    
    if (postsError) {
      console.error('Error fetching pending posts:', postsError);
      return res.status(500).json({ error: 'Failed to fetch posts' });
    }
    
    // Get author information for each post
    const postsWithAuthors = [];
    if (postsData) {
      const authorIdsSet = new Set(postsData.map(p => p.author_id));
      const authorIdsArray = Array.from(authorIdsSet);
      
      // Fetch all authors in one query
      const { data: authorsData, error: authorsError } = await supabase
        .from('users')
        .select('id, profile')
        .in('id', authorIdsArray);
      
      const authorsMap = new Map();
      if (!authorsError && authorsData) {
        authorsData.forEach(author => {
          authorsMap.set(author.id, author);
        });
      }
      
      // Combine posts with author info
      for (const postData of postsData) {
        const author = authorsMap.get(postData.author_id);
        const authorProfile = author?.profile || {};
        
        postsWithAuthors.push({
          id: postData.id,
          content: postData.content,
          imageUrl: postData.image_url,
          status: postData.status,
          author: {
            id: author?.id || postData.author_id,
            profile: {
              displayName: authorProfile.displayName || 'Unknown'
            }
          },
          createdAt: postData.created_at
        });
      }
    }
    
    res.json({ posts: postsWithAuthors });
  } catch (error) {
    console.error('Error fetching pending posts:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   PUT /api/posts/:postId/approve
// @desc    Approve or reject a post (parents only)
// @access  Private (Parent only)
router.put('/:postId/approve', requireUserType('parent'), [
  body('action').isIn(['approve', 'reject']),
  body('reason').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { postId } = req.params;
    const { action, reason } = req.body;
    
    const supabase = await getSupabase();
    
    // Get the post
    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    // Verify parent has access to this post (child is author)
    const { data: parentChild, error: relationError } = await supabase
      .from('parent_children')
      .select('child_id')
      .eq('parent_id', req.user.id)
      .eq('child_id', post.authorId)
      .single();
    
    if (relationError || !parentChild) {
      return res.status(403).json({ error: 'No access to this post' });
    }
    
    // Update post status
    if (action === 'approve') {
      post.status = 'approved';
      post.moderatedBy = req.user.id;
      post.moderatedAt = new Date();
      post.rejectionReason = null;
    } else if (action === 'reject') {
      post.status = 'rejected';
      post.rejectionReason = reason || 'Post rejected by parent';
      post.moderatedBy = req.user.id;
      post.moderatedAt = new Date();
    }
    
    await post.save();
    
    res.json({
      message: `Post ${action}d successfully`,
      post: {
        id: post.id,
        status: post.status,
        moderatedBy: post.moderatedBy,
        moderatedAt: post.moderatedAt,
        rejectionReason: post.rejectionReason
      }
    });
  } catch (error) {
    console.error('Error approving/rejecting post:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/posts/:postId/like
// @desc    Like or unlike a post (kids only)
// @access  Private (Kid only)
router.post('/:postId/like', requireUserType('kid'), async (req, res) => {
  try {
    const { postId } = req.params;
    const post = await Post.findById(postId);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    if (post.status !== 'approved') {
      return res.status(403).json({ error: 'Post not approved' });
    }
    
    const userId = req.user.id;
    const likes = post.likes || [];
    const likeIndex = likes.findIndex(likeId => likeId === userId);
    
    if (likeIndex > -1) {
      // Unlike - remove from array
      likes.splice(likeIndex, 1);
    } else {
      // Like - add to array
      likes.push(userId);
    }
    
    post.likes = likes;
    await post.save();
    
    res.json({
      liked: likeIndex === -1,
      likesCount: likes.length
    });
  } catch (error) {
    console.error('Error liking/unliking post:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/posts/:postId/comment
// @desc    Add a comment to a post (kids only)
// @access  Private (Kid only)
router.post('/:postId/comment', requireUserType('kid'), [
  body('content').trim().isLength({ min: 1, max: 200 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { postId } = req.params;
    const { content } = req.body;
    
    const post = await Post.findById(postId);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    if (post.status !== 'approved') {
      return res.status(403).json({ error: 'Post not approved' });
    }
    
    // Get author info for the comment
    const author = await User.findById(req.user.id);
    const authorProfile = author?.profile || {};
    
    // Add comment to post
    const comments = post.comments || [];
    const newComment = {
      id: require('crypto').randomUUID(),
      author: {
        id: req.user.id,
        profile: {
          displayName: authorProfile.displayName || req.user.email
        }
      },
      content: content.trim(),
      createdAt: new Date().toISOString()
    };
    
    comments.push(newComment);
    post.comments = comments;
    await post.save();
    
    res.status(201).json({
      comment: {
        id: newComment.id,
        content: newComment.content,
        author: newComment.author,
        createdAt: newComment.createdAt
      }
    });
  } catch (error) {
    console.error('Error adding comment:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

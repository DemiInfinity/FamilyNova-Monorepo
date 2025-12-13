const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const Post = require('../models/Post');
const User = require('../models/User');
const Comment = require('../models/Comment');
const Reaction = require('../models/Reaction');
const { auth, requireUserType } = require('../middleware/auth');
const { getSupabase } = require('../config/database');

// All routes require authentication
router.use(auth);

// @route   POST /api/posts
// @desc    Create a new post (kids or parents)
// @access  Private
router.post('/', [
  body('content').trim().isLength({ min: 1, max: 500 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { content, imageUrl, visibleToChildren } = req.body;
    
    const author = await User.findById(req.user.id);
    if (!author) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Determine status and visibility based on user type
    let status, visibleToChildrenValue, visibleToAdultsValue, approvedAdultsValue;
    
    if (author.userType === 'kid') {
      // Child posts: require parent approval, only parent can see by default
      status = author.monitoringLevel === 'full' ? 'pending' : 'approved';
      visibleToChildrenValue = true; // Not applicable for kids, but set for consistency
      visibleToAdultsValue = false; // Only parent can see child posts by default
      approvedAdultsValue = []; // No approved adults initially
    } else if (author.userType === 'parent') {
      // Parent posts: auto-approved, visible to children by default unless toggled
      status = 'approved';
      visibleToChildrenValue = visibleToChildren !== undefined ? visibleToChildren : true;
      visibleToAdultsValue = true; // Adults can see other adult posts
      approvedAdultsValue = [];
    } else {
      return res.status(403).json({ error: 'Invalid user type for posting' });
    }
    
    // Create post using Post model
    const post = await Post.create({
      authorId: req.user.id,
      content: content.trim(),
      imageUrl: imageUrl || null,
      status: status,
      visibleToChildren: visibleToChildrenValue,
      visibleToAdults: visibleToAdultsValue,
      approvedAdults: approvedAdultsValue,
      likes: [], // Keep for backward compatibility, but reactions table is primary
      comments: [] // Keep for backward compatibility, but comments table is primary
    });
    
    // Get author info for response
    const authorProfile = author.profile || {};
    
    // Format createdAt as ISO8601 string
    const createdAt = post.createdAt instanceof Date 
      ? post.createdAt.toISOString() 
      : (post.createdAt || new Date().toISOString());
    
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
        createdAt: createdAt
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
// @desc    Get approved posts for news feed with visibility filtering, or posts by a specific user if userId query param is provided
// @access  Private
router.get('/', async (req, res) => {
  try {
    const supabase = await getSupabase();
    const { userId } = req.query;
    
    // If userId is provided, return all approved posts by that user (for profile views)
    if (userId) {
      const { data: userPostsData, error: userPostsError } = await supabase
        .from('posts')
        .select('*')
        .eq('author_id', userId)
        .eq('status', 'approved')
        .order('created_at', { ascending: false })
        .limit(100);
      
      if (userPostsError) {
        console.error('Error fetching user posts:', userPostsError);
        return res.status(500).json({ error: 'Failed to fetch user posts' });
      }
      
      // Get author information
      const author = await User.findById(userId);
      if (!author) {
        return res.status(404).json({ error: 'User not found' });
      }
      
      const authorProfile = author.profile || {};
      const postIds = userPostsData ? userPostsData.map(p => p.id) : [];
      
      // Fetch comments and reactions for these posts
      const { data: commentsData } = await supabase
        .from('comments')
        .select('*')
        .in('post_id', postIds)
        .order('created_at', { ascending: true });
      
      const { data: reactionsData } = await supabase
        .from('reactions')
        .select('*')
        .in('post_id', postIds);
      
      // Group comments and reactions by post
      const commentsByPost = new Map();
      if (commentsData) {
        for (const comment of commentsData) {
          if (!commentsByPost.has(comment.post_id)) {
            commentsByPost.set(comment.post_id, []);
          }
          commentsByPost.get(comment.post_id).push({
            id: comment.id,
            content: comment.content,
            author: { id: comment.author_id },
            createdAt: comment.created_at instanceof Date ? comment.created_at.toISOString() : comment.created_at
          });
        }
      }
      
      const reactionsByPost = new Map();
      if (reactionsData) {
        for (const reaction of reactionsData) {
          if (!reactionsByPost.has(reaction.post_id)) {
            reactionsByPost.set(reaction.post_id, []);
          }
          reactionsByPost.get(reaction.post_id).push(reaction.user_id);
        }
      }
      
      // Format posts with author info
      const postsWithAuthors = (userPostsData || []).map(postData => {
        const postReactions = reactionsByPost.get(postData.id) || [];
        const postComments = commentsByPost.get(postData.id) || [];
        const isLiked = postReactions.includes(req.user.id);
        
        const createdAt = postData.created_at instanceof Date
          ? postData.created_at.toISOString()
          : (postData.created_at || new Date().toISOString());
        
        return {
          id: postData.id,
          content: postData.content,
          imageUrl: postData.image_url,
          status: postData.status,
          likes: postReactions,
          comments: postComments,
          author: {
            id: author.id,
            profile: {
              displayName: authorProfile.displayName || 'Unknown',
              avatar: authorProfile.avatar
            }
          },
          createdAt: createdAt
        };
      });
      
      return res.json({ posts: postsWithAuthors });
    }
    
    // Get current user's type and relationships
    const currentUser = await User.findById(req.user.id);
    if (!currentUser) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Get all approved posts first (we'll filter by visibility rules)
    const { data: allPostsData, error: postsError } = await supabase
      .from('posts')
      .select('*')
      .eq('status', 'approved')
      .order('created_at', { ascending: false })
      .limit(100); // Get more posts to filter from
    
    if (postsError) {
      console.error('Error fetching posts:', postsError);
      return res.status(500).json({ error: 'Failed to fetch posts' });
    }
    
    // Get relationships for filtering
    let childIds = [];
    let friendIds = [];
    let parentId = null;
    let approvedAdultsForChildPosts = [];
    
    if (currentUser.userType === 'kid') {
      // Get friends (other kids)
      const { data: friendships, error: friendsError } = await supabase
        .from('friendships')
        .select('friend_id')
        .eq('user_id', req.user.id)
        .eq('status', 'accepted');
      
      if (!friendsError && friendships) {
        friendIds = friendships.map(f => f.friend_id);
      }
      
      // Get parent ID
      const { data: parentChild, error: parentError } = await supabase
        .from('parent_children')
        .select('parent_id')
        .eq('child_id', req.user.id)
        .single();
      
      if (!parentError && parentChild) {
        parentId = parentChild.parent_id;
      }
    } else if (currentUser.userType === 'parent') {
      // Get children
      const { data: children, error: childrenError } = await supabase
        .from('parent_children')
        .select('child_id')
        .eq('parent_id', req.user.id);
      
      if (!childrenError && children) {
        childIds = children.map(c => c.child_id);
      }
    }
    
    // Get all unique author IDs to batch fetch their user types
    const authorIdsSet = new Set(allPostsData ? allPostsData.map(p => p.author_id) : []);
    const authorIdsArray = Array.from(authorIdsSet);
    
    // Batch fetch all authors
    const { data: authorsData, error: authorsError } = authorIdsArray.length > 0
      ? await supabase
          .from('users')
          .select('id, user_type')
          .in('id', authorIdsArray)
      : { data: [], error: null };
    
    if (authorsError) {
      console.error('Error fetching authors:', authorsError);
      return res.status(500).json({ error: 'Failed to fetch authors' });
    }
    
    // Create map of author ID to user type
    const authorTypeMap = new Map();
    if (authorsData) {
      authorsData.forEach(author => {
        authorTypeMap.set(author.id, author.user_type);
      });
    }
    
    // Filter posts based on visibility rules
    const filteredPosts = [];
    
    if (allPostsData) {
      for (const postData of allPostsData) {
        const postAuthorId = postData.author_id;
        const visibleToChildren = postData.visible_to_children !== undefined ? postData.visible_to_children : true;
        const visibleToAdults = postData.visible_to_adults !== undefined ? postData.visible_to_adults : false;
        const approvedAdults = postData.approved_adults || [];
        
        // Get author user type from map
        const authorType = authorTypeMap.get(postAuthorId);
        if (!authorType) continue;
        
        let canSeePost = false;
        
        if (currentUser.userType === 'kid') {
          // Kids can see:
          // 1. Their own posts
          // 2. Their friends' posts (other kids)
          // 3. Parent posts where visible_to_children = true (only their own parent)
          if (postAuthorId === req.user.id) {
            canSeePost = true;
          } else if (authorType === 'kid' && friendIds.includes(postAuthorId)) {
            canSeePost = true;
          } else if (authorType === 'parent' && visibleToChildren && postAuthorId === parentId) {
            canSeePost = true;
          }
        } else if (currentUser.userType === 'parent') {
          // Parents can see:
          // 1. Their own posts
          // 2. Their children's posts (always visible to parent)
          // 3. Other adult/parent posts (where visible_to_adults = true)
          // 4. Other children's posts (where visible_to_adults = true AND they're in approved_adults)
          if (postAuthorId === req.user.id) {
            canSeePost = true;
          } else if (authorType === 'kid' && childIds.includes(postAuthorId)) {
            // Parent can always see their own children's posts
            canSeePost = true;
          } else if (authorType === 'parent' && visibleToAdults) {
            // Other parent posts visible to adults
            canSeePost = true;
          } else if (authorType === 'kid' && visibleToAdults && approvedAdults.includes(req.user.id)) {
            // Other children's posts if approved
            canSeePost = true;
          }
        }
        
        if (canSeePost) {
          filteredPosts.push(postData);
        }
      }
    }
    
    // Limit to 50 posts after filtering
    const postsData = filteredPosts.slice(0, 50);
    
    // Get author information for each post (profile and verification)
    const postsWithAuthors = [];
    if (postsData) {
      const postAuthorIdsSet = new Set(postsData.map(p => p.author_id));
      const postAuthorIdsArray = Array.from(postAuthorIdsSet);
      
      // Fetch all authors with profile and verification info
      const { data: authorsWithProfile, error: authorsProfileError } = await supabase
        .from('users')
        .select('id, profile, verification')
        .in('id', postAuthorIdsArray);
      
      const authorsMap = new Map();
      if (!authorsProfileError && authorsWithProfile) {
        authorsWithProfile.forEach(author => {
          authorsMap.set(author.id, author);
        });
      }
      
      // Get all post IDs to fetch comments and reactions
      const postIds = postsData.map(p => p.id);
      
      // Fetch comments for all posts
      const { data: commentsData, error: commentsError } = await supabase
        .from('comments')
        .select('*')
        .in('post_id', postIds)
        .order('created_at', { ascending: true });
      
      // Get author IDs for comments
      const commentAuthorIds = commentsData ? [...new Set(commentsData.map(c => c.author_id))] : [];
      
      // Fetch comment authors
      const { data: commentAuthorsData, error: commentAuthorsError } = commentAuthorIds.length > 0
        ? await supabase
            .from('users')
            .select('id, profile')
            .in('id', commentAuthorIds)
        : { data: [], error: null };
      
      const commentAuthorsMap = new Map();
      if (!commentAuthorsError && commentAuthorsData) {
        commentAuthorsData.forEach(author => {
          commentAuthorsMap.set(author.id, author);
        });
      }
      
      // Fetch reactions for all posts
      const { data: reactionsData, error: reactionsError } = await supabase
        .from('reactions')
        .select('*')
        .in('post_id', postIds);
      
      // Group comments and reactions by post ID
      const commentsByPost = new Map();
      if (!commentsError && commentsData) {
        for (const comment of commentsData) {
          if (!commentsByPost.has(comment.post_id)) {
            commentsByPost.set(comment.post_id, []);
          }
          const author = commentAuthorsMap.get(comment.author_id);
          const authorProfile = author?.profile || {};
          // Format createdAt as ISO8601 string
          const commentCreatedAt = comment.created_at instanceof Date
            ? comment.created_at.toISOString()
            : (comment.created_at || new Date().toISOString());
          
          commentsByPost.get(comment.post_id).push({
            id: comment.id,
            content: comment.content,
            author: {
              id: comment.author_id,
              profile: {
                displayName: authorProfile.displayName || 'Unknown'
              }
            },
            createdAt: commentCreatedAt
          });
        }
      }
      
      const reactionsByPost = new Map();
      const userReactionsByPost = new Map();
      if (!reactionsError && reactionsData) {
        for (const reaction of reactionsData) {
          if (!reactionsByPost.has(reaction.post_id)) {
            reactionsByPost.set(reaction.post_id, []);
          }
          reactionsByPost.get(reaction.post_id).push(reaction.user_id);
          
          // Track user's reactions
          if (reaction.user_id === req.user.id) {
            if (!userReactionsByPost.has(reaction.post_id)) {
              userReactionsByPost.set(reaction.post_id, []);
            }
            userReactionsByPost.get(reaction.post_id).push(reaction.reaction_type);
          }
        }
      }
      
      // Combine posts with author info, comments, and reactions
      for (const postData of postsData) {
        const author = authorsMap.get(postData.author_id);
        const authorProfile = author?.profile || {};
        const postComments = commentsByPost.get(postData.id) || [];
        const postReactions = reactionsByPost.get(postData.id) || [];
        const userReactions = userReactionsByPost.get(postData.id) || [];
        
        // Get all reactions for this post grouped by type
        const postReactionsData = reactionsData ? reactionsData.filter(r => r.post_id === postData.id) : [];
        const reactionsByType = {};
        postReactionsData.forEach(r => {
          if (!reactionsByType[r.reaction_type]) {
            reactionsByType[r.reaction_type] = [];
          }
          reactionsByType[r.reaction_type].push(r.user_id);
        });
        
        // Check if user has liked this post
        const isLiked = userReactions.includes('like');
        
        // Format timestamps as ISO8601 strings
        const createdAt = postData.created_at instanceof Date
          ? postData.created_at.toISOString()
          : (postData.created_at || new Date().toISOString());
        
        const updatedAt = postData.updated_at instanceof Date
          ? postData.updated_at.toISOString()
          : (postData.updated_at || new Date().toISOString());
        
        postsWithAuthors.push({
          id: postData.id,
          content: postData.content,
          imageUrl: postData.image_url,
          status: postData.status,
          likes: reactionsByType.like || [], // Like reactions for backward compatibility
          comments: postComments,
          reactions: reactionsByType, // All reactions grouped by type
          isLiked: isLiked,
          author: {
            id: author?.id || postData.author_id,
            profile: {
              displayName: authorProfile.displayName || 'Unknown',
              firstName: authorProfile.firstName,
              lastName: authorProfile.lastName,
              avatar: authorProfile.avatar
            },
            verification: author?.verification || { parentVerified: false, schoolVerified: false }
          },
          createdAt: createdAt,
          updatedAt: updatedAt
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
// @desc    Like or unlike a post (kids and parents)
// @access  Private
router.post('/:postId/like', async (req, res) => {
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
    const result = await Reaction.toggle(postId, userId, 'like', '❤️');
    
    // Get updated like count
    const allReactions = await Reaction.findByPostId(postId);
    const likesCount = allReactions.filter(r => r.reactionType === 'like').length;
    
    res.json({
      liked: result.action === 'added',
      likesCount: likesCount
    });
  } catch (error) {
    console.error('Error liking/unliking post:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/posts/:postId/reaction
// @desc    Add or remove a reaction to a post (kids and parents)
// @access  Private
router.post('/:postId/reaction', [
  body('reactionType').isIn(['like', 'love', 'laugh', 'wow', 'sad', 'angry']),
  body('emoji').notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { postId } = req.params;
    const { reactionType, emoji } = req.body;
    const post = await Post.findById(postId);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    if (post.status !== 'approved') {
      return res.status(403).json({ error: 'Post not approved' });
    }
    
    const userId = req.user.id;
    const result = await Reaction.toggle(postId, userId, reactionType, emoji);
    
    // Get all reactions for this post
    const allReactions = await Reaction.findByPostId(postId);
    const reactionsByType = {};
    allReactions.forEach(r => {
      if (!reactionsByType[r.reactionType]) {
        reactionsByType[r.reactionType] = [];
      }
      reactionsByType[r.reactionType].push(r.userId);
    });
    
    res.json({
      action: result.action,
      reaction: result.reaction ? {
        type: result.reaction.reactionType,
        emoji: result.reaction.emoji
      } : null,
      reactions: reactionsByType
    });
  } catch (error) {
    console.error('Error adding/removing reaction:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/posts/:postId/comment
// @desc    Add a comment to a post (kids and parents)
// @access  Private
router.post('/:postId/comment', [
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
    
    // Create comment in comments table
    const comment = await Comment.create({
      postId: postId,
      authorId: req.user.id,
      content: content.trim()
    });
    
    // Format createdAt as ISO8601 string
    const createdAt = comment.createdAt instanceof Date 
      ? comment.createdAt.toISOString() 
      : (comment.createdAt || new Date().toISOString());
    
    res.status(201).json({
      comment: {
        id: comment.id,
        content: comment.content,
        author: {
          id: req.user.id,
          profile: {
            displayName: authorProfile.displayName || req.user.email
          }
        },
        createdAt: createdAt
      }
    });
  } catch (error) {
    console.error('Error adding comment:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   PUT /api/posts/:postId/approve-adult
// @desc    Approve an adult to see a child's post (parent only)
// @access  Private (Parent only)
router.put('/:postId/approve-adult', requireUserType('parent'), [
  body('adultId').notEmpty().withMessage('Adult ID is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { postId } = req.params;
    const { adultId } = req.body;
    
    const supabase = await getSupabase();
    
    // Get the post
    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    // Get post author
    const author = await User.findById(post.authorId);
    if (!author || author.userType !== 'kid') {
      return res.status(400).json({ error: 'Post must be from a child' });
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
    
    // Verify adultId is actually an adult
    const adult = await User.findById(adultId);
    if (!adult || adult.userType !== 'parent') {
      return res.status(400).json({ error: 'Invalid adult ID' });
    }
    
    // Update post's approved_adults array
    const approvedAdults = post.approvedAdults || [];
    if (!approvedAdults.includes(adultId)) {
      approvedAdults.push(adultId);
      post.approvedAdults = approvedAdults;
      post.visibleToAdults = true; // Enable visibility to adults
      await post.save();
    }
    
    res.json({
      message: 'Adult approved to see child post',
      post: {
        id: post.id,
        approvedAdults: post.approvedAdults
      }
    });
  } catch (error) {
    console.error('Error approving adult:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   DELETE /api/posts/:postId
// @desc    Delete a post (only by the author)
// @access  Private
router.delete('/:postId', async (req, res) => {
  try {
    const { postId } = req.params;
    
    // Get the post
    const post = await Post.findById(postId);
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    // Verify the user is the author of the post (or parent deleting child's post)
    const isAuthor = post.authorId === req.user.id;
    let isParentOfAuthor = false;
    
    if (!isAuthor) {
      // Check if user is parent of the author
      const author = await User.findById(post.authorId);
      if (author && author.userType === 'kid' && req.user.userType === 'parent') {
        const { data: parentChild } = await supabase
          .from('parent_children')
          .select('child_id')
          .eq('parent_id', req.user.id)
          .eq('child_id', post.authorId)
          .single();
        isParentOfAuthor = parentChild !== null;
      }
    }
    
    if (!isAuthor && !isParentOfAuthor) {
      return res.status(403).json({ error: 'You can only delete your own posts' });
    }
    
    // Delete the post (cascade will delete comments and reactions)
    await Post.deleteById(postId);
    
    res.json({ 
      message: 'Post deleted successfully',
      postId: postId
    });
  } catch (error) {
    console.error('Error deleting post:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

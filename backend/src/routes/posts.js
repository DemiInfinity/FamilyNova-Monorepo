const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const Post = require('../models/Post');
const User = require('../models/User');
const auth = require('../middleware/auth');
const { requireUserType } = require('../middleware/auth');

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
    const author = await User.findById(req.user._id);
    const status = author.monitoringLevel === 'full' ? 'pending' : 'approved';
    
    const post = new Post({
      author: req.user._id,
      content,
      imageUrl: imageUrl || null,
      status: status // Full monitoring = pending, partial = auto-approved
    });
    
    // If auto-approved, set approved by system
    if (status === 'approved') {
      post.approvedBy = req.user._id; // System approval
      post.approvedAt = new Date();
    }
    
    await post.save();
    
    // Populate author info
    await post.populate('author', 'profile displayName');
    
    res.status(201).json({
      post: {
        id: post._id,
        content: post.content,
        imageUrl: post.imageUrl,
        status: post.status,
        author: {
          id: post.author._id,
          displayName: post.author.profile.displayName
        },
        createdAt: post.createdAt
      },
      message: 'Post created and pending parent approval'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/posts
// @desc    Get approved posts for news feed
// @access  Private
router.get('/', async (req, res) => {
  try {
    // Get approved posts from friends and self
    const user = await User.findById(req.user._id);
    
    let query = { status: 'approved' };
    
    if (req.user.userType === 'kid') {
      // Kids see posts from themselves and their friends
      query.author = { $in: [req.user._id, ...user.friends] };
    } else {
      // Parents see posts from their children
      query.author = { $in: user.children };
    }
    
    const posts = await Post.find(query)
      .populate('author', 'profile displayName verification')
      .populate('likes', 'profile displayName')
      .sort({ createdAt: -1 })
      .limit(50);
    
    res.json({ posts });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/posts/pending
// @desc    Get pending posts for parent approval
// @access  Private (Parent only)
router.get('/pending', requireUserType('parent'), async (req, res) => {
  try {
    const parent = await User.findById(req.user._id);
    
    // Get pending posts from parent's children
    const posts = await Post.find({
      author: { $in: parent.children },
      status: 'pending'
    })
      .populate('author', 'profile displayName')
      .sort({ createdAt: -1 });
    
    res.json({ posts });
  } catch (error) {
    console.error(error);
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
    
    const post = await Post.findById(postId).populate('author');
    
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }
    
    // Verify parent has access to this post (child is author)
    const parent = await User.findById(req.user._id);
    if (!parent.children.includes(post.author._id)) {
      return res.status(403).json({ error: 'No access to this post' });
    }
    
    if (action === 'approve') {
      post.status = 'approved';
      post.approvedBy = req.user._id;
      post.approvedAt = new Date();
    } else if (action === 'reject') {
      post.status = 'rejected';
      post.rejectedReason = reason || 'Post rejected by parent';
    }
    
    await post.save();
    
    res.json({
      message: `Post ${action}d successfully`,
      post: {
        id: post._id,
        status: post.status,
        approvedBy: post.approvedBy,
        approvedAt: post.approvedAt,
        rejectedReason: post.rejectedReason
      }
    });
  } catch (error) {
    console.error(error);
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
    
    const userId = req.user._id.toString();
    const likeIndex = post.likes.findIndex(
      likeId => likeId.toString() === userId
    );
    
    if (likeIndex > -1) {
      // Unlike
      post.likes.splice(likeIndex, 1);
    } else {
      // Like
      post.likes.push(req.user._id);
    }
    
    await post.save();
    
    res.json({
      liked: likeIndex === -1,
      likesCount: post.likes.length
    });
  } catch (error) {
    console.error(error);
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
    
    post.comments.push({
      author: req.user._id,
      content
    });
    
    await post.save();
    
    // Populate the new comment
    const newComment = post.comments[post.comments.length - 1];
    await newComment.populate('author', 'profile displayName');
    
    res.status(201).json({
      comment: {
        id: newComment._id,
        content: newComment.content,
        author: {
          id: newComment.author._id,
          displayName: newComment.author.profile.displayName
        },
        createdAt: newComment.createdAt
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;


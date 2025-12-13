const express = require('express');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');

const router = express.Router();

// All routes require authentication and kid user type
router.use(auth);
router.use(requireUserType('kid'));

// @route   GET /api/kids/profile
// @desc    Get kid's profile
// @access  Private (Kid only)
router.get('/profile', async (req, res) => {
  try {
    const user = await User.findById(req.user._id)
      .select('-password')
      .populate('friends', 'profile displayName')
      .populate('parentAccount', 'profile email');
    
    res.json({ user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/kids/friends
// @desc    Get kid's friends list
// @access  Private (Kid only)
router.get('/friends', async (req, res) => {
  try {
    const user = await User.findById(req.user._id).populate('friends', 'profile verification');
    const friends = user.friends.map(friend => ({
      id: friend._id,
      displayName: friend.profile.displayName,
      avatar: friend.profile.avatar,
      isVerified: friend.isFullyVerified()
    }));
    
    res.json({ friends });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;


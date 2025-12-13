const express = require('express');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');

const router = express.Router();

// All routes require authentication
router.use(auth);

// @route   POST /api/friends/request
// @desc    Send friend request (kids only)
// @access  Private (Kid only)
router.post('/request', requireUserType('kid'), async (req, res) => {
  try {
    const { friendId } = req.body;
    
    if (!friendId) {
      return res.status(400).json({ error: 'Friend ID is required' });
    }
    
    const friend = await User.findById(friendId);
    if (!friend || friend.userType !== 'kid') {
      return res.status(404).json({ error: 'Friend not found' });
    }
    
    // Check if already friends
    if (req.user.friends.includes(friendId)) {
      return res.status(400).json({ error: 'Already friends' });
    }
    
    // Add friend (in real app, this would be a request system)
    req.user.friends.push(friendId);
    friend.friends.push(req.user._id);
    
    await req.user.save();
    await friend.save();
    
    // Auto-connect parents if both kids are verified
    if (req.user.isFullyVerified() && friend.isFullyVerified()) {
      if (req.user.parentAccount && friend.parentAccount) {
        const parent1 = await User.findById(req.user.parentAccount);
        const parent2 = await User.findById(friend.parentAccount);
        
        // Check if parents are already connected
        const alreadyConnected = parent1.parentConnections.some(
          conn => conn.parent.toString() === parent2._id.toString()
        );
        
        if (!alreadyConnected) {
          parent1.parentConnections.push({ parent: parent2._id });
          parent2.parentConnections.push({ parent: parent1._id });
          await parent1.save();
          await parent2.save();
        }
      }
    }
    
    res.json({ 
      message: 'Friend added successfully',
      friend: {
        id: friend._id,
        displayName: friend.profile.displayName,
        avatar: friend.profile.avatar
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/friends/search
// @desc    Search for friends (kids only)
// @access  Private (Kid only)
router.get('/search', requireUserType('kid'), async (req, res) => {
  try {
    const { query } = req.query;
    
    if (!query || query.length < 2) {
      return res.status(400).json({ error: 'Search query must be at least 2 characters' });
    }
    
    const users = await User.find({
      userType: 'kid',
      _id: { $ne: req.user._id },
      isActive: true,
      $or: [
        { 'profile.displayName': { $regex: query, $options: 'i' } },
        { 'profile.firstName': { $regex: query, $options: 'i' } },
        { 'profile.lastName': { $regex: query, $options: 'i' } }
      ]
    })
    .select('profile verification')
    .limit(20);
    
    const results = users.map(user => ({
      id: user._id,
      displayName: user.profile.displayName,
      avatar: user.profile.avatar,
      isVerified: user.isFullyVerified(),
      isFriend: req.user.friends.includes(user._id)
    }));
    
    res.json({ results });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;


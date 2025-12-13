const express = require('express');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');
const { getSupabase } = require('../config/database');

const router = express.Router();

// All routes require authentication and kid user type
router.use(auth);
router.use(requireUserType('kid'));

// @route   GET /api/kids/profile
// @desc    Get kid's profile
// @access  Private (Kid only)
router.get('/profile', async (req, res) => {
  try {
    const supabase = await getSupabase();
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Get friends
    const { data: friendships, error: friendsError } = await supabase
      .from('friendships')
      .select('friend_id')
      .eq('user_id', req.user.id)
      .eq('status', 'accepted');
    
    const friendIds = friendships ? friendships.map(f => f.friend_id) : [];
    
    let friends = [];
    if (friendIds.length > 0) {
      const { data: friendsData, error: friendsDataError } = await supabase
        .from('users')
        .select('id, profile, verification')
        .in('id', friendIds);
      
      if (!friendsDataError && friendsData) {
        friends = friendsData.map(friend => {
          const profile = friend.profile || {};
          return {
            id: friend.id,
            profile: {
              displayName: profile.displayName || 'Unknown',
              avatar: profile.avatar
            },
            verification: friend.verification || { parentVerified: false, schoolVerified: false }
          };
        });
      }
    }
    
    // Get parent account if exists
    let parentAccount = null;
    if (user.parentAccount) {
      const parent = await User.findById(user.parentAccount);
      if (parent) {
        const parentProfile = parent.profile || {};
        parentAccount = {
          id: parent.id,
          profile: {
            displayName: parentProfile.displayName || parent.email
          },
          email: parent.email
        };
      }
    }
    
    res.json({ 
      user: {
        id: user.id,
        email: user.email,
        profile: user.profile,
        verification: user.verification,
        monitoringLevel: user.monitoringLevel,
        friends: friends,
        parentAccount: parentAccount
      }
    });
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/kids/friends
// @desc    Get kid's friends list
// @access  Private (Kid only)
router.get('/friends', async (req, res) => {
  try {
    const supabase = await getSupabase();
    
    // Get accepted friendships
    const { data: friendships, error: friendsError } = await supabase
      .from('friendships')
      .select('friend_id')
      .eq('user_id', req.user.id)
      .eq('status', 'accepted');
    
    if (friendsError) {
      console.error('Error fetching friendships:', friendsError);
      return res.status(500).json({ error: 'Failed to fetch friends' });
    }
    
    const friendIds = friendships ? friendships.map(f => f.friend_id) : [];
    
    if (friendIds.length === 0) {
      return res.json({ friends: [] });
    }
    
    // Fetch friend profiles
    const { data: friendsData, error: friendsDataError } = await supabase
      .from('users')
      .select('id, profile, verification')
      .in('id', friendIds);
    
    if (friendsDataError) {
      console.error('Error fetching friend profiles:', friendsDataError);
      return res.status(500).json({ error: 'Failed to fetch friend profiles' });
    }
    
    const friends = (friendsData || []).map(friend => {
      const profile = friend.profile || {};
      const isVerified = friend.verification?.parentVerified && friend.verification?.schoolVerified;
      
      return {
        id: friend.id,
        profile: {
          displayName: profile.displayName || 'Unknown',
          avatar: profile.avatar
        },
        verification: friend.verification || { parentVerified: false, schoolVerified: false },
        isVerified: isVerified || false
      };
    });
    
    res.json({ friends });
  } catch (error) {
    console.error('Error fetching friends:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

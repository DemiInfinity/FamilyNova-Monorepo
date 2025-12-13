const express = require('express');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');
const FriendCode = require('../models/FriendCode');
const { getSupabase } = require('../config/database');

const router = express.Router();

// All routes require authentication
router.use(auth);

// @route   GET /api/friends/my-code
// @desc    Get or generate user's friend code (kids and parents)
// @access  Private
router.get('/my-code', requireUserType('kid', 'parent'), async (req, res) => {
  try {
    // Generate or get existing friend code
    const friendCode = await FriendCode.generateCode(req.user.id);
    
    res.json({
      code: friendCode.code,
      expiresAt: friendCode.expiresAt,
      createdAt: friendCode.createdAt
    });
  } catch (error) {
    console.error('Error generating friend code:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/friends/add-by-code
// @desc    Add friend using friend code (kids and parents)
// @access  Private
router.post('/add-by-code', requireUserType('kid', 'parent'), async (req, res) => {
  try {
    const { code } = req.body;
    const supabase = await getSupabase();
    
    if (!code || code.length !== 8) {
      return res.status(400).json({ error: 'Invalid friend code format' });
    }
    
    // Find friend by code
    const friendCode = await FriendCode.findByCode(code.toUpperCase());
    
    if (!friendCode) {
      return res.status(404).json({ error: 'Friend code not found' });
    }
    
    if (friendCode.isExpired()) {
      return res.status(400).json({ error: 'Friend code has expired' });
    }
    
    const friendId = friendCode.userId;
    
    // Can't add yourself
    if (friendId === req.user.id) {
      return res.status(400).json({ error: 'Cannot add yourself as a friend' });
    }
    
    // Get friend user
    const friend = await User.findById(friendId);
    if (!friend) {
      return res.status(404).json({ error: 'Friend not found' });
    }
    
    // Parents can only add other parents as friends, kids can only add other kids
    if (req.user.userType === 'parent' && friend.userType !== 'parent') {
      return res.status(403).json({ error: 'Parents can only add other parents as friends' });
    }
    if (req.user.userType === 'kid' && friend.userType !== 'kid') {
      return res.status(403).json({ error: 'Kids can only add other kids as friends' });
    }
    
    // Check if already friends
    const { data: existingFriendship, error: friendCheckError } = await supabase
      .from('friendships')
      .select('*')
      .or(`and(user_id.eq.${req.user.id},friend_id.eq.${friendId}),and(user_id.eq.${friendId},friend_id.eq.${req.user.id})`)
      .single();
    
    if (!friendCheckError && existingFriendship) {
      if (existingFriendship.status === 'accepted') {
        return res.status(400).json({ error: 'Already friends' });
      } else if (existingFriendship.status === 'pending') {
        // Auto-accept if pending
        await supabase
          .from('friendships')
          .update({ status: 'accepted' })
          .or(`and(user_id.eq.${req.user.id},friend_id.eq.${friendId}),and(user_id.eq.${friendId},friend_id.eq.${req.user.id})`);
      }
    } else {
      // Create friendship (auto-accept when using friend code)
      const { error: friendshipError } = await supabase
        .from('friendships')
        .insert({
          user_id: req.user.id,
          friend_id: friendId,
          status: 'accepted'
        });
      
      if (friendshipError) {
        console.error('Error creating friendship:', friendshipError);
        return res.status(500).json({ error: 'Failed to add friend' });
      }
      
      // Also create reverse friendship
      await supabase
        .from('friendships')
        .upsert({
          user_id: friendId,
          friend_id: req.user.id,
          status: 'accepted'
        }, {
          onConflict: 'user_id,friend_id'
        });
    }
    
    // Auto-connect parents if both kids are verified
    const currentUser = await User.findById(req.user.id);
    const friendUser = await User.findById(friendId);
    
    if (currentUser && friendUser && currentUser.isFullyVerified() && friendUser.isFullyVerified()) {
      if (currentUser.parentAccount && friendUser.parentAccount) {
        // Check if parents are already connected
        const { data: existingConnection, error: connError } = await supabase
          .from('parent_connections')
          .select('*')
          .or(`and(parent1_id.eq.${currentUser.parentAccount},parent2_id.eq.${friendUser.parentAccount}),and(parent1_id.eq.${friendUser.parentAccount},parent2_id.eq.${currentUser.parentAccount})`)
          .single();
        
        if (connError || !existingConnection) {
          // Create parent connection
          await supabase
            .from('parent_connections')
            .insert({
              parent1_id: currentUser.parentAccount,
              parent2_id: friendUser.parentAccount
            });
        }
      }
    }
    
    const friendProfile = friendUser.profile || {};
    
    res.json({ 
      message: 'Friend added successfully',
      friend: {
        id: friendUser.id,
        profile: {
          displayName: friendProfile.displayName || friendUser.email,
          avatar: friendProfile.avatar
        },
        isVerified: friendUser.isFullyVerified()
      }
    });
  } catch (error) {
    console.error('Error adding friend by code:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/friends/request
// @desc    Send friend request (kids and parents)
// @access  Private
router.post('/request', requireUserType('kid', 'parent'), async (req, res) => {
  try {
    const { friendId } = req.body;
    const supabase = await getSupabase();
    
    if (!friendId) {
      return res.status(400).json({ error: 'Friend ID is required' });
    }
    
    const friend = await User.findById(friendId);
    if (!friend) {
      return res.status(404).json({ error: 'Friend not found' });
    }
    
    // Parents can only add other parents as friends, kids can only add other kids
    if (req.user.userType === 'parent' && friend.userType !== 'parent') {
      return res.status(403).json({ error: 'Parents can only add other parents as friends' });
    }
    if (req.user.userType === 'kid' && friend.userType !== 'kid') {
      return res.status(403).json({ error: 'Kids can only add other kids as friends' });
    }
    
    // Check if already friends
    const { data: existingFriendship, error: friendCheckError } = await supabase
      .from('friendships')
      .select('*')
      .or(`and(user_id.eq.${req.user.id},friend_id.eq.${friendId}),and(user_id.eq.${friendId},friend_id.eq.${req.user.id})`)
      .single();
    
    if (!friendCheckError && existingFriendship) {
      if (existingFriendship.status === 'accepted') {
        return res.status(400).json({ error: 'Already friends' });
      } else if (existingFriendship.status === 'pending') {
        return res.status(400).json({ error: 'Friend request already pending' });
      }
    }
    
    // Create or update friendship
    const { data: friendship, error: friendshipError } = await supabase
      .from('friendships')
      .upsert({
        user_id: req.user.id,
        friend_id: friendId,
        status: 'pending'
      }, {
        onConflict: 'user_id,friend_id'
      })
      .select()
      .single();
    
    if (friendshipError) {
      console.error('Error creating friendship:', friendshipError);
      return res.status(500).json({ error: 'Failed to send friend request' });
    }
    
    // Auto-connect parents if both kids are verified
    const currentUser = await User.findById(req.user.id);
    const friendUser = await User.findById(friendId);
    
    if (currentUser && friendUser && currentUser.isFullyVerified() && friendUser.isFullyVerified()) {
      if (currentUser.parentAccount && friendUser.parentAccount) {
        // Check if parents are already connected
        const { data: existingConnection, error: connError } = await supabase
          .from('parent_connections')
          .select('*')
          .or(`and(parent1_id.eq.${currentUser.parentAccount},parent2_id.eq.${friendUser.parentAccount}),and(parent1_id.eq.${friendUser.parentAccount},parent2_id.eq.${currentUser.parentAccount})`)
          .single();
        
        if (connError || !existingConnection) {
          // Create parent connection
          await supabase
            .from('parent_connections')
            .insert({
              parent1_id: currentUser.parentAccount,
              parent2_id: friendUser.parentAccount
            });
        }
      }
    }
    
    const friendProfile = friendUser.profile || {};
    
    res.json({ 
      message: 'Friend request sent successfully',
      friend: {
        id: friendUser.id,
        profile: {
          displayName: friendProfile.displayName || friendUser.email,
          avatar: friendProfile.avatar
        },
        isVerified: friendUser.isFullyVerified()
      }
    });
  } catch (error) {
    console.error('Error sending friend request:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/friends/accept
// @desc    Accept friend request (kids and parents)
// @access  Private
router.post('/accept', requireUserType('kid', 'parent'), async (req, res) => {
  try {
    const { friendId } = req.body;
    const supabase = await getSupabase();
    
    if (!friendId) {
      return res.status(400).json({ error: 'Friend ID is required' });
    }
    
    // Update friendship status to accepted
    const { data: friendship, error: friendshipError } = await supabase
      .from('friendships')
      .update({ status: 'accepted' })
      .or(`and(user_id.eq.${req.user.id},friend_id.eq.${friendId}),and(user_id.eq.${friendId},friend_id.eq.${req.user.id})`)
      .select()
      .single();
    
    if (friendshipError || !friendship) {
      return res.status(404).json({ error: 'Friend request not found' });
    }
    
    const friend = await User.findById(friendId);
    if (!friend) {
      return res.status(404).json({ error: 'Friend not found' });
    }
    
    const friendProfile = friend.profile || {};
    
    res.json({ 
      message: 'Friend request accepted',
      friend: {
        id: friend.id,
        profile: {
          displayName: friendProfile.displayName || friend.email,
          avatar: friendProfile.avatar
        },
        isVerified: friend.isFullyVerified()
      }
    });
  } catch (error) {
    console.error('Error accepting friend request:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/friends/search
// @desc    Search for friends (kids and parents)
// @access  Private
router.get('/search', requireUserType('kid', 'parent'), async (req, res) => {
  try {
    const { query: searchQuery } = req.query;
    const supabase = await getSupabase();
    
    if (!searchQuery || searchQuery.length < 2) {
      return res.status(400).json({ error: 'Search query must be at least 2 characters' });
    }
    
    // Get current user's friends
    const { data: friendships, error: friendsError } = await supabase
      .from('friendships')
      .select('friend_id')
      .eq('user_id', req.user.id)
      .eq('status', 'accepted');
    
    const friendIds = friendships ? friendships.map(f => f.friend_id) : [];
    
    // Search for users matching the query
    // Note: Supabase doesn't support full-text search on JSONB easily, so we'll fetch all users and filter
    // Parents can search for other parents, kids can search for other kids
    const userTypeFilter = req.user.userType === 'parent' ? 'parent' : 'kid';
    const { data: usersData, error: usersError } = await supabase
      .from('users')
      .select('id, profile, verification')
      .eq('user_type', userTypeFilter)
      .eq('is_active', true)
      .neq('id', req.user.id);
    
    if (usersError) {
      console.error('Error searching users:', usersError);
      return res.status(500).json({ error: 'Failed to search users' });
    }
    
    // Filter by search query (case-insensitive)
    const searchLower = searchQuery.toLowerCase();
    const results = (usersData || [])
      .filter(user => {
        const profile = user.profile || {};
        const displayName = (profile.displayName || '').toLowerCase();
        const firstName = (profile.firstName || '').toLowerCase();
        const lastName = (profile.lastName || '').toLowerCase();
        
        return displayName.includes(searchLower) || 
               firstName.includes(searchLower) || 
               lastName.includes(searchLower);
      })
      .slice(0, 20)
      .map(user => {
        const profile = user.profile || {};
        const isVerified = user.verification?.parentVerified && user.verification?.schoolVerified;
        
        return {
          id: user.id,
          profile: {
            displayName: profile.displayName || 'Unknown',
            avatar: profile.avatar
          },
          isVerified: isVerified || false,
          isFriend: friendIds.includes(user.id)
        };
      });
    
    res.json({ results });
  } catch (error) {
    console.error('Error searching friends:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/friends/requests
// @desc    Get pending friend requests (kids and parents)
// @access  Private
router.get('/requests', requireUserType('kid', 'parent'), async (req, res) => {
  try {
    const supabase = await getSupabase();
    
    // Get pending friend requests where current user is the receiver
    const { data: friendships, error: friendsError } = await supabase
      .from('friendships')
      .select('user_id, friend_id, created_at')
      .eq('friend_id', req.user.id)
      .eq('status', 'pending');
    
    if (friendsError) {
      console.error('Error fetching friend requests:', friendsError);
      return res.status(500).json({ error: 'Failed to fetch friend requests' });
    }
    
    if (!friendships || friendships.length === 0) {
      return res.json({ requests: [] });
    }
    
    // Get user IDs who sent requests
    const requesterIds = friendships.map(f => f.user_id);
    
    // Fetch requester profiles
    const { data: requestersData, error: requestersError } = await supabase
      .from('users')
      .select('id, profile, email')
      .in('id', requesterIds);
    
    if (requestersError) {
      console.error('Error fetching requester profiles:', requestersError);
      return res.status(500).json({ error: 'Failed to fetch requester profiles' });
    }
    
    // Format requests
    const requests = (friendships || []).map(friendship => {
      const requester = requestersData?.find(u => u.id === friendship.user_id);
      const profile = requester?.profile || {};
      
      return {
        id: `${friendship.user_id}_${friendship.friend_id}`,
        from: {
          id: requester?.id || friendship.user_id,
          profile: {
            displayName: profile.displayName || requester?.email || 'Unknown',
            avatar: profile.avatar
          }
        },
        status: 'pending',
        createdAt: friendship.created_at || new Date().toISOString()
      };
    });
    
    res.json({ requests });
  } catch (error) {
    console.error('Error fetching friend requests:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/friends
// @desc    Get friends list (kids and parents)
// @access  Private
router.get('/', requireUserType('kid', 'parent'), async (req, res) => {
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

const express = require('express');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');
const FriendCode = require('../models/FriendCode');
const { getSupabase } = require('../config/database');
const { asyncHandler, createError } = require('../middleware/errorHandler');
const { getUserById, validateUserTypeInteraction } = require('../utils/routeHelpers');

const router = express.Router();

// All routes require authentication
router.use(auth);

// @route   GET /api/friends/my-code
// @desc    Get or generate user's friend code (kids and parents)
// @access  Private
router.get('/my-code', requireUserType('kid', 'parent'), asyncHandler(async (req, res) => {
  // Generate or get existing friend code
  const friendCode = await FriendCode.generateCode(req.user.id);
  
  res.json({
    code: friendCode.code,
    expiresAt: friendCode.expiresAt,
    createdAt: friendCode.createdAt
  });
}));

// @route   POST /api/friends/add-by-code
// @desc    Add friend using friend code (kids and parents)
// @access  Private
router.post('/add-by-code', requireUserType('kid', 'parent'), asyncHandler(async (req, res) => {
  const { code } = req.body;
  const supabase = getSupabase();
  
  if (!code || code.length !== 8) {
    throw createError('Invalid friend code format', 400, 'INVALID_FRIEND_CODE');
  }
  
  // Find friend by code
  const friendCode = await FriendCode.findByCode(code.toUpperCase());
  
  if (!friendCode) {
    throw createError('Friend code not found', 404, 'FRIEND_CODE_NOT_FOUND');
  }
  
  if (friendCode.isExpired()) {
    throw createError('Friend code has expired', 400, 'FRIEND_CODE_EXPIRED');
  }
  
  const friendId = friendCode.userId;
  
  // Can't add yourself
  if (friendId === req.user.id) {
    throw createError('Cannot add yourself as a friend', 400, 'CANNOT_ADD_SELF');
  }
  
  // Get friend user with validation
  const friend = await getUserById(friendId, 'Friend not found');
  
  // Validate user type compatibility
  validateUserTypeInteraction(req.user.userType, friend.userType, 'add as friend');
  
  // Check if already friends - use transaction-like approach to prevent race conditions
  const { data: existingFriendships, error: friendCheckError } = await supabase
    .from('friendships')
    .select('*')
    .or(`and(user_id.eq.${req.user.id},friend_id.eq.${friendId}),and(user_id.eq.${friendId},friend_id.eq.${req.user.id})`);
  
  if (friendCheckError && friendCheckError.code !== 'PGRST116') { // PGRST116 = no rows returned
    console.error('Error checking friendship:', friendCheckError);
    throw createError('Failed to verify friendship status', 500, 'FRIENDSHIP_CHECK_FAILED');
  }
  
  if (existingFriendships && existingFriendships.length > 0) {
    const existingFriendship = existingFriendships[0];
    if (existingFriendship.status === 'accepted') {
      throw createError('Already friends', 400, 'ALREADY_FRIENDS');
    } else if (existingFriendship.status === 'pending') {
      // Auto-accept if pending - use atomic update to avoid race condition
      const { data: updatedFriendship, error: updateError } = await supabase
        .from('friendships')
        .update({ status: 'accepted' })
        .eq('id', existingFriendship.id)
        .eq('status', 'pending')
        .select()
        .single();
      
      if (updateError || !updatedFriendship) {
        console.error('Error updating friendship:', updateError);
        throw createError('Failed to accept friendship', 500, 'FRIENDSHIP_UPDATE_FAILED');
      }
    }
  } else {
    // Create friendship (auto-accept when using friend code)
    // Use unique constraint to prevent duplicates
    const { data: newFriendship, error: friendshipError } = await supabase
      .from('friendships')
      .insert({
        user_id: req.user.id,
        friend_id: friendId,
        status: 'accepted'
      })
      .select()
      .single();
    
    if (friendshipError) {
      console.error('Error creating friendship:', friendshipError);
      throw createError('Failed to add friend', 500, 'FRIENDSHIP_CREATION_FAILED');
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
}));

// @route   POST /api/friends/request
// @desc    Send friend request (kids and parents)
// @access  Private
router.post('/request', requireUserType('kid', 'parent'), asyncHandler(async (req, res) => {
  const { friendId } = req.body;
  const supabase = getSupabase();
    
  if (!friendId) {
    throw createError('Friend ID is required', 400, 'FRIEND_ID_REQUIRED');
  }
  
  const friend = await User.findById(friendId);
  if (!friend) {
    throw createError('Friend not found', 404, 'FRIEND_NOT_FOUND');
  }
  
  // Parents can only add other parents as friends, kids can only add other kids
  if (req.user.userType === 'parent' && friend.userType !== 'parent') {
    throw createError('Parents can only add other parents as friends', 403, 'USER_TYPE_MISMATCH');
  }
  if (req.user.userType === 'kid' && friend.userType !== 'kid') {
    throw createError('Kids can only add other kids as friends', 403, 'USER_TYPE_MISMATCH');
  }
    
    // Check if already friends
    const { data: existingFriendship, error: friendCheckError } = await supabase
      .from('friendships')
      .select('*')
      .or(`and(user_id.eq.${req.user.id},friend_id.eq.${friendId}),and(user_id.eq.${friendId},friend_id.eq.${req.user.id})`)
      .single();
    
  if (!friendCheckError && existingFriendship) {
    if (existingFriendship.status === 'accepted') {
      throw createError('Already friends', 400, 'ALREADY_FRIENDS');
    } else if (existingFriendship.status === 'pending') {
      throw createError('Friend request already pending', 400, 'REQUEST_PENDING');
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
    throw createError('Failed to send friend request', 500, 'FRIENDSHIP_CREATION_FAILED');
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
}));

// @route   POST /api/friends/accept
// @desc    Accept friend request (kids and parents)
// @access  Private
router.post('/accept', requireUserType('kid', 'parent'), asyncHandler(async (req, res) => {
  const { friendId } = req.body;
  const supabase = getSupabase();
  
  if (!friendId) {
    throw createError('Friend ID is required', 400, 'FRIEND_ID_REQUIRED');
  }
  
  // Update friendship status to accepted
  const { data: friendship, error: friendshipError } = await supabase
    .from('friendships')
    .update({ status: 'accepted' })
    .or(`and(user_id.eq.${req.user.id},friend_id.eq.${friendId}),and(user_id.eq.${friendId},friend_id.eq.${req.user.id})`)
    .select()
    .single();
  
  if (friendshipError || !friendship) {
    throw createError('Friend request not found', 404, 'FRIEND_REQUEST_NOT_FOUND');
  }
  
  const friend = await User.findById(friendId);
  if (!friend) {
    throw createError('Friend not found', 404, 'FRIEND_NOT_FOUND');
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
}));

// @route   GET /api/friends/search
// @desc    Search for friends (kids and parents)
// @access  Private
router.get('/search', requireUserType('kid', 'parent'), asyncHandler(async (req, res) => {
  const { query: searchQuery } = req.query;
  const supabase = getSupabase();
  
  if (!searchQuery || searchQuery.length < 2) {
    throw createError('Search query must be at least 2 characters', 400, 'INVALID_SEARCH_QUERY');
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
    throw createError('Failed to search users', 500, 'SEARCH_FAILED');
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
}));

// @route   GET /api/friends/requests
// @desc    Get pending friend requests (kids and parents)
// @access  Private
router.get('/requests', requireUserType('kid', 'parent'), asyncHandler(async (req, res) => {
  const supabase = getSupabase();
  
  // Get pending friend requests where current user is the receiver
  const { data: friendships, error: friendsError } = await supabase
    .from('friendships')
    .select('user_id, friend_id, created_at')
    .eq('friend_id', req.user.id)
    .eq('status', 'pending');
  
  if (friendsError) {
    console.error('Error fetching friend requests:', friendsError);
    throw createError('Failed to fetch friend requests', 500, 'FETCH_REQUESTS_FAILED');
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
    throw createError('Failed to fetch requester profiles', 500, 'FETCH_PROFILES_FAILED');
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
}));

// @route   GET /api/friends
// @desc    Get friends list (kids and parents)
// @access  Private
router.get('/', requireUserType('kid', 'parent'), asyncHandler(async (req, res) => {
  const supabase = getSupabase();
  
  // Get accepted friendships
  const { data: friendships, error: friendsError } = await supabase
    .from('friendships')
    .select('friend_id')
    .eq('user_id', req.user.id)
    .eq('status', 'accepted');
  
  if (friendsError) {
    console.error('Error fetching friendships:', friendsError);
    throw createError('Failed to fetch friends', 500, 'FETCH_FRIENDS_FAILED');
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
    throw createError('Failed to fetch friend profiles', 500, 'FETCH_PROFILES_FAILED');
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
}));

module.exports = router;

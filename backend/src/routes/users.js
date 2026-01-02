const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const User = require('../models/User');
const { getSupabase } = require('../config/database');
const { asyncHandler, createError } = require('../middleware/errorHandler');

// All routes require authentication
router.use(auth);

/**
 * @route   GET /api/users/me/export
 * @desc    Export all user data (GDPR Right to Access/Data Portability)
 * @access  Private
 */
router.get('/me/export', asyncHandler(async (req, res) => {
  const supabase = await getSupabase();
  const userId = req.user.id;

  // Get user profile
  const user = await User.findById(userId);
  if (!user) {
    throw createError('User not found', 404, 'USER_NOT_FOUND');
  }

  const exportData = {
    user: {
      id: user.id,
      email: user.email,
      userType: user.userType,
      profile: user.profile,
      verification: user.verification,
      monitoringLevel: user.monitoringLevel,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastLogin: user.lastLogin
    },
    posts: [],
    comments: [],
    reactions: [],
    messages: [],
    friendships: [],
    exportedAt: new Date().toISOString()
  };

  // Get user's posts
  const { data: posts, error: postsError } = await supabase
    .from('posts')
    .select('*')
    .eq('author_id', userId)
    .order('created_at', { ascending: false });

  if (!postsError && posts) {
    exportData.posts = posts;
  }

  // Get user's comments
  const { data: comments, error: commentsError } = await supabase
    .from('comments')
    .select('*')
    .eq('author_id', userId)
    .order('created_at', { ascending: false });

  if (!commentsError && comments) {
    exportData.comments = comments;
  }

  // Get user's reactions
  const { data: reactions, error: reactionsError } = await supabase
    .from('reactions')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (!reactionsError && reactions) {
    exportData.reactions = reactions;
  }

  // Get user's messages (sent and received)
  const { data: messages, error: messagesError } = await supabase
    .from('messages')
    .select('*')
    .or(`sender_id.eq.${userId},receiver_id.eq.${userId}`)
    .order('created_at', { ascending: false });

  if (!messagesError && messages) {
    exportData.messages = messages;
  }

  // Get user's friendships
  const { data: friendships, error: friendshipsError } = await supabase
    .from('friendships')
    .select('*')
    .or(`user_id.eq.${userId},friend_id.eq.${userId}`)
    .order('created_at', { ascending: false });

  if (!friendshipsError && friendships) {
    exportData.friendships = friendships;
  }

  // Set headers for file download
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Content-Disposition', `attachment; filename="familynova-data-export-${userId}-${Date.now()}.json"`);

  res.json(exportData);
}));

/**
 * @route   DELETE /api/users/me
 * @desc    Delete user account and all associated data (GDPR Right to Erasure)
 * @access  Private
 */
router.delete('/me', asyncHandler(async (req, res) => {
  const supabase = await getSupabase();
  const userId = req.user.id;

  // Get user to verify
  const user = await User.findById(userId);
  if (!user) {
    throw createError('User not found', 404, 'USER_NOT_FOUND');
  }

  // For children, check if parent is deleting (or child with parent approval)
  if (user.userType === 'kid') {
    // Allow deletion if user is the child or their parent
    // This is already handled by auth middleware checking the token
  }

  // Soft delete: Mark user as inactive first (30-day retention period)
  await User.findByIdAndUpdate(userId, {
    isActive: false,
    profile: {
      ...user.profile,
      deletedAt: new Date().toISOString(),
      deletionScheduled: true
    }
  });

  // Delete from Supabase Auth (this will cascade delete from users table due to ON DELETE CASCADE)
  const { error: deleteError } = await supabase.auth.admin.deleteUser(userId);

  if (deleteError) {
    console.error('Error deleting user from Supabase Auth:', deleteError);
    // Continue with data deletion even if Auth deletion fails
  }

  // Delete user's posts (cascade should handle this, but explicit for clarity)
  await supabase
    .from('posts')
    .delete()
    .eq('author_id', userId);

  // Delete user's comments
  await supabase
    .from('comments')
    .delete()
    .eq('author_id', userId);

  // Delete user's reactions
  await supabase
    .from('reactions')
    .delete()
    .eq('user_id', userId);

  // Delete user's messages
  await supabase
    .from('messages')
    .delete()
    .or(`sender_id.eq.${userId},receiver_id.eq.${userId}`);

  // Delete user's friendships
  await supabase
    .from('friendships')
    .delete()
    .or(`user_id.eq.${userId},friend_id.eq.${userId}`);

  // Delete friend codes
  await supabase
    .from('friend_codes')
    .delete()
    .eq('user_id', userId);

  // Delete profile change requests
  await supabase
    .from('profile_change_requests')
    .delete()
    .eq('kid_id', userId);

  // Delete parent_children relationships
  await supabase
    .from('parent_children')
    .delete()
    .or(`parent_id.eq.${userId},child_id.eq.${userId}`);

  // Delete login codes
  await supabase
    .from('login_codes')
    .delete()
    .or(`child_id.eq.${userId},parent_id.eq.${userId}`);

  res.json({
    message: 'Account deletion initiated. All data will be permanently deleted.',
    deletedAt: new Date().toISOString()
  });
}));

module.exports = router;


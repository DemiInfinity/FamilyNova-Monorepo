const { getSupabase } = require('../config/database');
const { createError } = require('../middleware/errorHandler');

// Data retention policies (in days)
const RETENTION_POLICIES = {
  login_codes: 1, // 1 day
  friend_codes: 1, // 1 day
  profile_change_requests: 30, // 30 days
  deleted_users: 90, // 90 days (soft delete retention)
  old_posts: 365, // 1 year (posts older than this can be archived)
  old_messages: 180, // 6 months
  audit_logs: 730, // 2 years
};

/**
 * Clean up expired data based on retention policies
 */
async function cleanupExpiredData() {
  const supabase = getSupabase();
  const now = new Date();
  const errors = [];

  try {
    // Clean up expired login codes
    const loginCodesExpiry = new Date(now);
    loginCodesExpiry.setDate(loginCodesExpiry.getDate() - RETENTION_POLICIES.login_codes);
    
    const { error: loginCodesError } = await supabase
      .from('login_codes')
      .delete()
      .lt('created_at', loginCodesExpiry.toISOString());
    
    if (loginCodesError) {
      errors.push({ table: 'login_codes', error: loginCodesError });
    }

    // Clean up expired friend codes
    const friendCodesExpiry = new Date(now);
    friendCodesExpiry.setDate(friendCodesExpiry.getDate() - RETENTION_POLICIES.friend_codes);
    
    const { error: friendCodesError } = await supabase
      .from('friend_codes')
      .delete()
      .lt('created_at', friendCodesExpiry.toISOString());
    
    if (friendCodesError) {
      errors.push({ table: 'friend_codes', error: friendCodesError });
    }

    // Clean up old profile change requests
    const profileChangeExpiry = new Date(now);
    profileChangeExpiry.setDate(profileChangeExpiry.getDate() - RETENTION_POLICIES.profile_change_requests);
    
    const { error: profileChangeError } = await supabase
      .from('profile_change_requests')
      .delete()
      .lt('created_at', profileChangeExpiry.toISOString())
      .eq('status', 'approved'); // Only delete approved requests
    
    if (profileChangeError) {
      errors.push({ table: 'profile_change_requests', error: profileChangeError });
    }

    // Archive old posts (mark as archived instead of deleting)
    const oldPostsExpiry = new Date(now);
    oldPostsExpiry.setDate(oldPostsExpiry.getDate() - RETENTION_POLICIES.old_posts);
    
    const { error: oldPostsError } = await supabase
      .from('posts')
      .update({ status: 'archived' })
      .lt('created_at', oldPostsExpiry.toISOString())
      .eq('status', 'published');
    
    if (oldPostsError) {
      errors.push({ table: 'posts', error: oldPostsError });
    }

    // Clean up old messages (only if both users agree or account deleted)
    const oldMessagesExpiry = new Date(now);
    oldMessagesExpiry.setDate(oldMessagesExpiry.getDate() - RETENTION_POLICIES.old_messages);
    
    // This would need additional logic to check user preferences
    // For now, we'll just log that this should be done
    console.log('Old messages cleanup would run here (requires user consent check)');

    return {
      success: errors.length === 0,
      errors: errors.length > 0 ? errors : null,
      timestamp: now.toISOString()
    };
  } catch (error) {
    console.error('Data retention cleanup failed:', error);
    throw createError('Data retention cleanup failed', 500, 'RETENTION_CLEANUP_FAILED', error);
  }
}

/**
 * Get data retention statistics
 */
async function getRetentionStats() {
  const supabase = getSupabase();
  const now = new Date();

  const stats = {};

  try {
    // Count expired login codes
    const loginCodesExpiry = new Date(now);
    loginCodesExpiry.setDate(loginCodesExpiry.getDate() - RETENTION_POLICIES.login_codes);
    
    const { count: expiredLoginCodes } = await supabase
      .from('login_codes')
      .select('*', { count: 'exact', head: true })
      .lt('created_at', loginCodesExpiry.toISOString());

    stats.expiredLoginCodes = expiredLoginCodes || 0;

    // Count expired friend codes
    const friendCodesExpiry = new Date(now);
    friendCodesExpiry.setDate(friendCodesExpiry.getDate() - RETENTION_POLICIES.friend_codes);
    
    const { count: expiredFriendCodes } = await supabase
      .from('friend_codes')
      .select('*', { count: 'exact', head: true })
      .lt('created_at', friendCodesExpiry.toISOString());

    stats.expiredFriendCodes = expiredFriendCodes || 0;

    // Count old posts
    const oldPostsExpiry = new Date(now);
    oldPostsExpiry.setDate(oldPostsExpiry.getDate() - RETENTION_POLICIES.old_posts);
    
    const { count: oldPosts } = await supabase
      .from('posts')
      .select('*', { count: 'exact', head: true })
      .lt('created_at', oldPostsExpiry.toISOString())
      .eq('status', 'published');

    stats.oldPosts = oldPosts || 0;

    return stats;
  } catch (error) {
    console.error('Failed to get retention stats:', error);
    throw createError('Failed to get retention stats', 500, 'RETENTION_STATS_FAILED', error);
  }
}

module.exports = {
  cleanupExpiredData,
  getRetentionStats,
  RETENTION_POLICIES
};


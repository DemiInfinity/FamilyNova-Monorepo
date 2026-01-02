/**
 * Common route helper functions to reduce code duplication
 */

const { getSupabase } = require('../config/database');
const User = require('../models/User');
const { createError } = require('../middleware/errorHandler');
const { requireNotNull, safeGet } = require('../middleware/validation');

/**
 * Get user by ID with null check
 */
async function getUserById(userId, errorMessage = 'User not found') {
  const user = await User.findById(requireNotNull(userId, 'userId'));
  if (!user) {
    throw createError(errorMessage, 404, 'USER_NOT_FOUND');
  }
  return user;
}

/**
 * Verify friendship between two users
 */
async function verifyFriendship(userId1, userId2) {
  const supabase = getSupabase();
  
  const { data: friendship, error } = await supabase
    .from('friendships')
    .select('*')
    .or(`and(user_id.eq.${userId1},friend_id.eq.${userId2}),and(user_id.eq.${userId2},friend_id.eq.${userId1})`)
    .eq('status', 'accepted')
    .single();
  
  if (error && error.code !== 'PGRST116') {
    throw createError('Failed to verify friendship', 500, 'FRIENDSHIP_VERIFY_FAILED');
  }
  
  return friendship !== null;
}

/**
 * Check if user types are compatible for interaction
 */
function validateUserTypeInteraction(user1Type, user2Type, operation = 'interact') {
  if (user1Type === 'parent' && user2Type !== 'parent') {
    throw createError(`Parents can only ${operation} with other parents`, 403, 'USER_TYPE_MISMATCH');
  }
  if (user1Type === 'kid' && user2Type !== 'kid') {
    throw createError(`Kids can only ${operation} with other kids`, 403, 'USER_TYPE_MISMATCH');
  }
}

/**
 * Format post response with author info
 */
function formatPostResponse(post, author, currentUserId = null) {
  const authorProfile = safeGet(author, 'profile', {});
  const postReactions = safeGet(post, 'reactions', []);
  const postComments = safeGet(post, 'comments', []);
  const isLiked = currentUserId ? postReactions.includes(currentUserId) : false;
  
  const createdAt = post.created_at instanceof Date
    ? post.created_at.toISOString()
    : (post.created_at || new Date().toISOString());
  
  return {
    id: post.id,
    content: post.content,
    imageUrl: safeGet(post, 'image_url'),
    status: post.status,
    likes: postReactions,
    comments: postComments,
    author: {
      id: author.id,
      profile: {
        displayName: safeGet(authorProfile, 'displayName', 'Unknown'),
        avatar: safeGet(authorProfile, 'avatar')
      }
    },
    createdAt,
    isLiked
  };
}

/**
 * Format comment response with author info
 */
function formatCommentResponse(comment, author) {
  const authorProfile = safeGet(author, 'profile', {});
  
  const createdAt = comment.created_at instanceof Date
    ? comment.created_at.toISOString()
    : (comment.created_at || new Date().toISOString());
  
  return {
    id: comment.id,
    content: comment.content,
    author: {
      id: author.id,
      profile: {
        displayName: safeGet(authorProfile, 'displayName', 'Unknown')
      }
    },
    createdAt
  };
}

/**
 * Format message response
 */
function formatMessageResponse(message) {
  const createdAt = message.created_at instanceof Date
    ? message.created_at.toISOString()
    : (message.created_at || new Date().toISOString());
  
  return {
    id: message.id,
    senderId: message.sender_id,
    receiverId: message.receiver_id,
    content: message.content,
    createdAt
  };
}

/**
 * Get pagination parameters from request
 */
function getPaginationParams(req, defaultLimit = 50, maxLimit = 100) {
  const page = Math.max(1, parseInt(safeGet(req.query, 'page', '1'), 10));
  const limit = Math.min(maxLimit, Math.max(1, parseInt(safeGet(req.query, 'limit', String(defaultLimit)), 10)));
  const offset = (page - 1) * limit;
  
  return { page, limit, offset };
}

/**
 * Format paginated response
 */
function formatPaginatedResponse(data, page, limit, total) {
  return {
    data,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
      hasNext: page * limit < total,
      hasPrev: page > 1
    }
  };
}

module.exports = {
  getUserById,
  verifyFriendship,
  validateUserTypeInteraction,
  formatPostResponse,
  formatCommentResponse,
  formatMessageResponse,
  getPaginationParams,
  formatPaginatedResponse
};


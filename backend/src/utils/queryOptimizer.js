const { getSupabase } = require('../config/database');
const cache = require('./cache');

/**
 * Optimize post queries to avoid N+1 problems
 * Fetches posts with all related data in a single query
 */
async function getPostsWithAuthors(userId = null, limit = 50, offset = 0) {
  const cacheKey = `posts:${userId || 'all'}:${limit}:${offset}`;
  const cached = cache.get(cacheKey);
  if (cached) {
    return cached;
  }

  const supabase = getSupabase();
  
  let query = supabase
    .from('posts')
    .select(`
      *,
      author:users!posts_author_id_fkey (
        id,
        email,
        profile,
        verification
      )
    `)
    .eq('status', 'approved')
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (userId) {
    query = query.eq('author_id', userId);
  }

  const { data: posts, error } = await query;

  if (error) {
    throw error;
  }

  // Fetch comments and reactions in batch
  if (posts && posts.length > 0) {
    const postIds = posts.map(p => p.id);
    
    // Get all comments for these posts
    const { data: comments } = await supabase
      .from('comments')
      .select(`
        *,
        author:users!comments_author_id_fkey (
          id,
          profile
        )
      `)
      .in('post_id', postIds);

    // Get all reactions for these posts
    const { data: reactions } = await supabase
      .from('reactions')
      .select('*')
      .in('post_id', postIds);

    // Group comments and reactions by post_id
    const commentsByPost = {};
    const reactionsByPost = {};
    
    comments?.forEach(comment => {
      if (!commentsByPost[comment.post_id]) {
        commentsByPost[comment.post_id] = [];
      }
      commentsByPost[comment.post_id].push(comment);
    });
    
    reactions?.forEach(reaction => {
      if (!reactionsByPost[reaction.post_id]) {
        reactionsByPost[reaction.post_id] = [];
      }
      reactionsByPost[reaction.post_id].push(reaction);
    });

    // Attach comments and reactions to posts
    posts.forEach(post => {
      post.comments = commentsByPost[post.id] || [];
      post.likes = reactionsByPost[post.id]?.filter(r => r.reaction_type === 'like') || [];
      post.reactions = reactionsByPost[post.id] || [];
    });
  }

  // Cache for 2 minutes
  cache.set(cacheKey, posts, 2 * 60 * 1000);
  
  return posts;
}

/**
 * Get user with profile in a single query
 */
async function getUserWithProfile(userId) {
  const cacheKey = `user:${userId}`;
  const cached = cache.get(cacheKey);
  if (cached) {
    return cached;
  }

  const supabase = getSupabase();
  
  const { data: user, error } = await supabase
    .from('users')
    .select('*')
    .eq('id', userId)
    .single();

  if (error) {
    throw error;
  }

  // Cache for 5 minutes
  cache.set(cacheKey, user, 5 * 60 * 1000);
  
  return user;
}

/**
 * Get friends with profiles in a single query
 */
async function getFriendsWithProfiles(userId) {
  const cacheKey = `friends:${userId}`;
  const cached = cache.get(cacheKey);
  if (cached) {
    return cached;
  }

  const supabase = getSupabase();
  
  // Get friendships
  const { data: friendships, error } = await supabase
    .from('friendships')
    .select(`
      *,
      friend:users!friendships_friend_id_fkey (
        id,
        email,
        profile,
        verification
      ),
      user:users!friendships_user_id_fkey (
        id,
        email,
        profile,
        verification
      )
    `)
    .or(`user_id.eq.${userId},friend_id.eq.${userId}`)
    .eq('status', 'accepted');

  if (error) {
    throw error;
  }

  // Transform to get friend objects
  const friends = friendships.map(friendship => {
    const friend = friendship.user_id === userId 
      ? friendship.friend 
      : friendship.user;
    return {
      ...friend,
      friendshipId: friendship.id,
      createdAt: friendship.created_at
    };
  });

  // Cache for 3 minutes
  cache.set(cacheKey, friends, 3 * 60 * 1000);
  
  return friends;
}

module.exports = {
  getPostsWithAuthors,
  getUserWithProfile,
  getFriendsWithProfiles
};


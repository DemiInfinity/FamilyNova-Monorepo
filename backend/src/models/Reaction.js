const { getSupabase } = require('../config/database');

class Reaction {
  constructor(data) {
    this.id = data.id;
    this.postId = data.post_id;
    this.userId = data.user_id;
    this.reactionType = data.reaction_type;
    this.emoji = data.emoji;
    this.createdAt = data.created_at;
  }

  static async findByPostId(postId) {
    const supabase = await getSupabase();
    const { data, error } = await supabase
      .from('reactions')
      .select('*')
      .eq('post_id', postId);

    if (error) throw error;
    return data ? data.map(r => new Reaction(r)) : [];
  }

  static async findByPostAndUser(postId, userId) {
    const supabase = await getSupabase();
    const { data, error } = await supabase
      .from('reactions')
      .select('*')
      .eq('post_id', postId)
      .eq('user_id', userId);

    if (error) throw error;
    return data ? data.map(r => new Reaction(r)) : [];
  }

  static async create(reactionData) {
    const supabase = await getSupabase();
    const dbData = {
      post_id: reactionData.postId,
      user_id: reactionData.userId,
      reaction_type: reactionData.reactionType,
      emoji: reactionData.emoji
    };

    const { data, error } = await supabase
      .from('reactions')
      .insert(dbData)
      .select()
      .single();

    if (error) {
      // Handle unique constraint violation (user already has this reaction type)
      if (error.code === '23505') {
        // Try to delete and recreate
        await this.delete(reactionData.postId, reactionData.userId, reactionData.reactionType);
        const { data: newData, error: newError } = await supabase
          .from('reactions')
          .insert(dbData)
          .select()
          .single();
        if (newError) throw newError;
        return new Reaction(newData);
      }
      throw error;
    }
    return new Reaction(data);
  }

  static async delete(postId, userId, reactionType) {
    const supabase = await getSupabase();
    const { error } = await supabase
      .from('reactions')
      .delete()
      .eq('post_id', postId)
      .eq('user_id', userId)
      .eq('reaction_type', reactionType);

    if (error) throw error;
    return true;
  }

  static async toggle(postId, userId, reactionType, emoji) {
    const supabase = await getSupabase();
    
    // Check if reaction exists
    const { data: existing, error } = await supabase
      .from('reactions')
      .select('*')
      .eq('post_id', postId)
      .eq('user_id', userId)
      .eq('reaction_type', reactionType)
      .maybeSingle();

    if (error && error.code !== 'PGRST116') { // PGRST116 is "not found" which is fine
      throw error;
    }

    if (existing) {
      // Delete existing reaction
      await this.delete(postId, userId, reactionType);
      return { action: 'removed', reaction: null };
    } else {
      // Create new reaction
      const reaction = await this.create({ postId, userId, reactionType, emoji });
      return { action: 'added', reaction };
    }
  }
}

module.exports = Reaction;


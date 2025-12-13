const { getSupabase } = require('../config/database');

class Comment {
  constructor(data) {
    this.id = data.id;
    this.postId = data.post_id;
    this.authorId = data.author_id;
    this.content = data.content;
    this.createdAt = data.created_at;
    this.updatedAt = data.updated_at;
  }

  static async findByPostId(postId) {
    const supabase = await getSupabase();
    const { data, error } = await supabase
      .from('comments')
      .select('*')
      .eq('post_id', postId)
      .order('created_at', { ascending: true });

    if (error) throw error;
    return data ? data.map(c => new Comment(c)) : [];
  }

  static async create(commentData) {
    const supabase = await getSupabase();
    const dbData = {
      post_id: commentData.postId,
      author_id: commentData.authorId,
      content: commentData.content
    };

    const { data, error } = await supabase
      .from('comments')
      .insert(dbData)
      .select()
      .single();

    if (error) throw error;
    return new Comment(data);
  }

  static async findById(id) {
    const supabase = await getSupabase();
    const { data, error } = await supabase
      .from('comments')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) return null;
    return new Comment(data);
  }
}

module.exports = Comment;


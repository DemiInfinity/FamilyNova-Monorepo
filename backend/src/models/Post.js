const { getSupabase } = require('../config/database');

class Post {
  constructor(data) {
    this.id = data.id;
    this.authorId = data.author_id;
    this.content = data.content;
    this.imageUrl = data.image_url;
    this.likes = data.likes || [];
    this.comments = data.comments || [];
    this.status = data.status || 'pending';
    this.moderatedBy = data.moderated_by;
    this.moderatedAt = data.moderated_at;
    this.rejectionReason = data.rejection_reason;
    this.createdAt = data.created_at;
    this.updatedAt = data.updated_at;
  }

  static async findById(id) {
    const supabase = getSupabase();
    const { data, error } = await supabase
      .from('posts')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) return null;
    return new Post(data);
  }

  static async find(filter = {}) {
    const supabase = getSupabase();
    let query = supabase.from('posts').select('*');

    if (filter.authorId) query = query.eq('author_id', filter.authorId);
    if (filter.status) query = query.eq('status', filter.status);

    query = query.order('created_at', { ascending: false });

    const { data, error } = await query;
    if (error) throw error;
    return data ? data.map(p => new Post(p)) : [];
  }

  static async create(postData) {
    const supabase = getSupabase();
    const dbData = {
      author_id: postData.authorId,
      content: postData.content,
      image_url: postData.imageUrl || null,
      status: postData.status || 'pending',
      likes: postData.likes || [],
      comments: postData.comments || []
    };

    const { data, error } = await supabase
      .from('posts')
      .insert(dbData)
      .select()
      .single();

    if (error) throw error;
    return new Post(data);
  }

  async save() {
    const supabase = getSupabase();
    const dbData = {
      content: this.content,
      image_url: this.imageUrl,
      likes: this.likes,
      comments: this.comments,
      status: this.status,
      moderated_by: this.moderatedBy,
      moderated_at: this.moderatedAt,
      rejection_reason: this.rejectionReason
    };

    const { data, error } = await supabase
      .from('posts')
      .update(dbData)
      .eq('id', this.id)
      .select()
      .single();

    if (error) throw error;
    Object.assign(this, new Post(data));
    return this;
  }
}

module.exports = Post;

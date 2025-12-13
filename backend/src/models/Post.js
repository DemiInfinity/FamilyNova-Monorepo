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
    this.visibleToChildren = data.visible_to_children !== undefined ? data.visible_to_children : true;
    this.visibleToAdults = data.visible_to_adults !== undefined ? data.visible_to_adults : false;
    this.approvedAdults = data.approved_adults || [];
    this.createdAt = data.created_at;
    this.updatedAt = data.updated_at;
  }

  static async findById(id) {
    const supabase = await getSupabase();
    const { data, error } = await supabase
      .from('posts')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) return null;
    return new Post(data);
  }

  static async find(filter = {}) {
    const supabase = await getSupabase();
    let query = supabase.from('posts').select('*');

    if (filter.authorId) query = query.eq('author_id', filter.authorId);
    if (filter.status) query = query.eq('status', filter.status);

    query = query.order('created_at', { ascending: false });

    const { data, error } = await query;
    if (error) throw error;
    return data ? data.map(p => new Post(p)) : [];
  }

  static async create(postData) {
    const supabase = await getSupabase();
    
    // Ensure author_id is set
    if (!postData.authorId) {
      throw new Error('authorId is required');
    }
    
    const now = new Date().toISOString();
    const dbData = {
      author_id: postData.authorId,
      content: postData.content,
      image_url: postData.imageUrl || null,
      status: postData.status || 'pending',
      likes: postData.likes || [],
      comments: postData.comments || [],
      visible_to_children: postData.visibleToChildren !== undefined ? postData.visibleToChildren : true,
      visible_to_adults: postData.visibleToAdults !== undefined ? postData.visibleToAdults : false,
      approved_adults: postData.approvedAdults || [],
      created_at: now,
      updated_at: now
    };

    const { data, error } = await supabase
      .from('posts')
      .insert(dbData)
      .select()
      .single();

    if (error) {
      console.error('Error creating post:', error);
      throw error;
    }
    
    return new Post(data);
  }

  async save() {
    const supabase = await getSupabase();
    const dbData = {
      content: this.content,
      image_url: this.imageUrl,
      likes: this.likes || [],
      comments: this.comments || [],
      status: this.status,
      moderated_by: this.moderatedBy || null,
      moderated_at: this.moderatedAt ? this.moderatedAt.toISOString() : null,
      rejection_reason: this.rejectionReason || null,
      visible_to_children: this.visibleToChildren !== undefined ? this.visibleToChildren : true,
      visible_to_adults: this.visibleToAdults !== undefined ? this.visibleToAdults : false,
      approved_adults: this.approvedAdults || [],
      updated_at: new Date().toISOString()
    };

    const { data, error } = await supabase
      .from('posts')
      .update(dbData)
      .eq('id', this.id)
      .select()
      .single();

    if (error) {
      console.error('Error saving post:', error);
      throw error;
    }
    Object.assign(this, new Post(data));
    return this;
  }

  static async deleteById(id) {
    const supabase = await getSupabase();
    const { error } = await supabase
      .from('posts')
      .delete()
      .eq('id', id);

    if (error) {
      console.error('Error deleting post:', error);
      throw error;
    }
    return true;
  }
}

module.exports = Post;

const { getSupabase } = require('../config/database');

class Message {
  constructor(data) {
    this.id = data.id;
    this.senderId = data.sender_id;
    this.receiverId = data.receiver_id;
    this.content = data.content;
    this.status = data.status || 'pending';
    this.moderatedBy = data.moderated_by;
    this.moderatedAt = data.moderated_at;
    this.createdAt = data.created_at;
    this.updatedAt = data.updated_at;
  }

  static async findById(id) {
    const supabase = await getSupabase();
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) return null;
    return new Message(data);
  }

  static async find(filter = {}) {
    const supabase = await getSupabase();
    let query = supabase.from('messages').select('*');

    if (filter.senderId) query = query.eq('sender_id', filter.senderId);
    if (filter.receiverId) query = query.eq('receiver_id', filter.receiverId);
    if (filter.status) query = query.eq('status', filter.status);

    const { data, error } = await query;
    if (error) throw error;
    return data ? data.map(m => new Message(m)) : [];
  }

  static async create(messageData) {
    const supabase = await getSupabase();
    const dbData = {
      sender_id: messageData.senderId,
      receiver_id: messageData.receiverId,
      content: messageData.content,
      status: messageData.status || 'pending'
    };

    const { data, error } = await supabase
      .from('messages')
      .insert(dbData)
      .select()
      .single();

    if (error) throw error;
    return new Message(data);
  }

  async save() {
    const supabase = await getSupabase();
    const dbData = {
      content: this.content,
      status: this.status,
      moderated_by: this.moderatedBy,
      moderated_at: this.moderatedAt
    };

    const { data, error } = await supabase
      .from('messages')
      .update(dbData)
      .eq('id', this.id)
      .select()
      .single();

    if (error) throw error;
    Object.assign(this, new Message(data));
    return this;
  }
}

module.exports = Message;

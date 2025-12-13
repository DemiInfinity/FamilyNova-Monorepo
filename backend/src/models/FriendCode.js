const { getSupabase } = require('../config/database');
const crypto = require('crypto');

class FriendCode {
  constructor(data) {
    this.id = data.id;
    this.userId = data.user_id;
    this.code = data.code;
    this.expiresAt = data.expires_at;
    this.createdAt = data.created_at;
    this.updatedAt = data.updated_at;
  }

  static async findByUserId(userId) {
    const supabase = await getSupabase();
    const { data, error } = await supabase
      .from('friend_codes')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error || !data) return null;
    return new FriendCode(data);
  }

  static async findByCode(code) {
    const supabase = await getSupabase();
    const { data, error } = await supabase
      .from('friend_codes')
      .select('*')
      .eq('code', code.toUpperCase())
      .single();

    if (error || !data) return null;
    return new FriendCode(data);
  }

  static async generateCode(userId) {
    const supabase = await getSupabase();
    
    // Check if user already has a code
    const existing = await this.findByUserId(userId);
    if (existing && (!existing.expiresAt || new Date(existing.expiresAt) > new Date())) {
      return existing;
    }

    // Generate a unique 8-character alphanumeric code
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed similar-looking chars (0, O, I, 1)
    let code = '';
    let isUnique = false;
    let attempts = 0;
    const maxAttempts = 100;

    while (!isUnique && attempts < maxAttempts) {
      code = '';
      for (let i = 0; i < 8; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
      }

      // Check if code exists
      const { data: existingCode, error } = await supabase
        .from('friend_codes')
        .select('id')
        .eq('code', code)
        .single();

      if (error && error.code === 'PGRST116') { // No rows returned
        isUnique = true;
      } else if (!existingCode) {
        isUnique = true;
      }
      attempts++;
    }

    if (!isUnique) {
      throw new Error('Failed to generate unique friend code');
    }

    // Set expiration to 1 year from now (or null for no expiration)
    const expiresAt = new Date();
    expiresAt.setFullYear(expiresAt.getFullYear() + 1);

    // Create or update friend code
    const { data, error } = await supabase
      .from('friend_codes')
      .upsert({
        user_id: userId,
        code: code,
        expires_at: expiresAt.toISOString()
      }, {
        onConflict: 'user_id'
      })
      .select()
      .single();

    if (error) throw error;
    return new FriendCode(data);
  }

  isExpired() {
    if (!this.expiresAt) return false;
    return new Date(this.expiresAt) < new Date();
  }

  async save() {
    const supabase = await getSupabase();
    const { data, error } = await supabase
      .from('friend_codes')
      .update({
        code: this.code,
        expires_at: this.expiresAt
      })
      .eq('id', this.id)
      .select()
      .single();

    if (error) throw error;
    Object.assign(this, new FriendCode(data));
    return this;
  }
}

module.exports = FriendCode;


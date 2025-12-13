const { getSupabase } = require('../config/database');

class ProfileChangeRequest {
  constructor(data) {
    this.id = data.id;
    this.kidId = data.kid_id;
    this.requestedChanges = data.requested_changes || {};
    this.currentProfile = data.current_profile || {};
    this.status = data.status || 'pending';
    this.reviewedBy = data.reviewed_by;
    this.reviewedAt = data.reviewed_at;
    this.reason = data.reason;
    this.requestedAt = data.requested_at;
  }

  static async findById(id) {
    const supabase = getSupabase();
    const { data, error } = await supabase
      .from('profile_change_requests')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) return null;
    return new ProfileChangeRequest(data);
  }

  static async find(filter = {}) {
    const supabase = getSupabase();
    let query = supabase.from('profile_change_requests').select('*');

    if (filter.kidId) {
      if (Array.isArray(filter.kidId)) {
        query = query.in('kid_id', filter.kidId);
      } else {
        query = query.eq('kid_id', filter.kidId);
      }
    }
    if (filter.status) query = query.eq('status', filter.status);

    query = query.order('requested_at', { ascending: false });

    const { data, error } = await query;
    if (error) throw error;
    return data ? data.map(r => new ProfileChangeRequest(r)) : [];
  }

  static async create(requestData) {
    const supabase = getSupabase();
    const dbData = {
      kid_id: requestData.kidId,
      requested_changes: requestData.requestedChanges,
      current_profile: requestData.currentProfile,
      status: 'pending'
    };

    const { data, error } = await supabase
      .from('profile_change_requests')
      .insert(dbData)
      .select()
      .single();

    if (error) throw error;
    return new ProfileChangeRequest(data);
  }

  async save() {
    const supabase = getSupabase();
    const dbData = {
      requested_changes: this.requestedChanges,
      current_profile: this.currentProfile,
      status: this.status,
      reviewed_by: this.reviewedBy,
      reviewed_at: this.reviewedAt,
      reason: this.reason
    };

    const { data, error } = await supabase
      .from('profile_change_requests')
      .update(dbData)
      .eq('id', this.id)
      .select()
      .single();

    if (error) throw error;
    Object.assign(this, new ProfileChangeRequest(data));
    return this;
  }
}

module.exports = ProfileChangeRequest;

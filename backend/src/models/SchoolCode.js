const { getSupabase } = require('../config/database');

class SchoolCode {
  constructor(data) {
    this.id = data.id;
    this.code = data.code;
    this.schoolId = data.school_id;
    this.gradeLevel = data.grade_level;
    this.generatedBy = data.generated_by;
    this.generatedAt = data.generated_at;
    this.expiresAt = data.expires_at;
    this.usedBy = data.used_by;
    this.usedAt = data.used_at;
  }

  static async findByCode(code) {
    const supabase = getSupabase();
    const { data, error } = await supabase
      .from('school_codes')
      .select('*')
      .eq('code', code.toUpperCase())
      .single();

    if (error || !data) return null;
    return new SchoolCode(data);
  }

  static async find(filter = {}) {
    const supabase = getSupabase();
    let query = supabase.from('school_codes').select('*');

    if (filter.schoolId) query = query.eq('school_id', filter.schoolId);
    if (filter.usedBy) query = query.eq('used_by', filter.usedBy);

    query = query.order('generated_at', { ascending: false });

    const { data, error } = await query;
    if (error) throw error;
    return data ? data.map(c => new SchoolCode(c)) : [];
  }

  static async generateCode(schoolId, gradeLevel, generatedBy) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let code = '';
    let isUnique = false;
    const supabase = getSupabase();

    while (!isUnique) {
      code = '';
      for (let i = 0; i < 6; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
      }

      // Check if code exists
      const { data: existing } = await supabase
        .from('school_codes')
        .select('id')
        .eq('code', code)
        .single();

      if (!existing) {
        isUnique = true;
      }
    }

    // Create code with 30-day expiration
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30);

    const dbData = {
      code: code,
      school_id: schoolId,
      grade_level: gradeLevel,
      generated_by: generatedBy,
      expires_at: expiresAt.toISOString()
    };

    const { data, error } = await supabase
      .from('school_codes')
      .insert(dbData)
      .select()
      .single();

    if (error) throw error;
    return new SchoolCode(data);
  }

  async markAsUsed(userId) {
    const supabase = getSupabase();
    const { data, error } = await supabase
      .from('school_codes')
      .update({
        used_by: userId,
        used_at: new Date().toISOString()
      })
      .eq('id', this.id)
      .select()
      .single();

    if (error) throw error;
    Object.assign(this, new SchoolCode(data));
    return this;
  }

  isExpired() {
    return new Date(this.expiresAt) < new Date();
  }

  isUsed() {
    return !!this.usedBy;
  }
}

module.exports = SchoolCode;

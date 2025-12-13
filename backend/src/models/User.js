const { getSupabase } = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  constructor(data) {
    this.id = data.id;
    this.email = data.email;
    this.password = data.password;
    this.userType = data.user_type;
    this.profile = data.profile || {};
    this.schoolAccount = data.school_account_id;
    this.monitoringLevel = data.monitoring_level || 'full';
    this.verification = data.verification || { parentVerified: false, schoolVerified: false };
    this.parentAccount = data.parent_account_id;
    this.isActive = data.is_active !== false;
    this.lastLogin = data.last_login;
    this.createdAt = data.created_at;
    this.updatedAt = data.updated_at;
  }

  // Convert to database format
  toDBFormat() {
    return {
      email: this.email,
      password: this.password,
      user_type: this.userType,
      profile: this.profile,
      school_account_id: this.schoolAccount,
      monitoring_level: this.monitoringLevel,
      verification: this.verification,
      parent_account_id: this.parentAccount,
      is_active: this.isActive,
      last_login: this.lastLogin
    };
  }

  // Static methods for database operations
  static async findById(id) {
    const supabase = getSupabase();
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', id)
      .single();
    
    if (error || !data) return null;
    return new User(data);
  }

  static async findByEmail(email) {
    const supabase = getSupabase();
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email.toLowerCase().trim())
      .single();
    
    if (error || !data) return null;
    return new User(data);
  }

  static async create(userData) {
    const supabase = getSupabase();
    
    // Hash password
    const hashedPassword = await bcrypt.hash(userData.password, 10);
    
    const dbData = {
      email: userData.email.toLowerCase().trim(),
      password: hashedPassword,
      user_type: userData.userType,
      profile: userData.profile || {},
      monitoring_level: userData.monitoringLevel || 'full',
      verification: userData.verification || { parentVerified: false, schoolVerified: false },
      parent_account_id: userData.parentAccount || null,
      school_account_id: userData.schoolAccount || null,
      is_active: true
    };

    const { data, error } = await supabase
      .from('users')
      .insert(dbData)
      .select()
      .single();

    if (error) throw error;
    return new User(data);
  }

  async save() {
    const supabase = getSupabase();
    const dbData = this.toDBFormat();
    
    const { data, error } = await supabase
      .from('users')
      .update(dbData)
      .eq('id', this.id)
      .select()
      .single();

    if (error) throw error;
    Object.assign(this, new User(data));
    return this;
  }

  async comparePassword(candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
  }

  isFullyVerified() {
    if (this.userType === 'kid') {
      return this.verification?.parentVerified && this.verification?.schoolVerified;
    }
    return true;
  }

  static async findByIdAndUpdate(id, updateData) {
    const supabase = getSupabase();
    
    // Convert update data to database format
    const dbUpdate = {};
    if (updateData.profile !== undefined) dbUpdate.profile = updateData.profile;
    if (updateData.monitoringLevel !== undefined) dbUpdate.monitoring_level = updateData.monitoringLevel;
    if (updateData.verification !== undefined) dbUpdate.verification = updateData.verification;
    if (updateData.isActive !== undefined) dbUpdate.is_active = updateData.isActive;
    if (updateData.lastLogin !== undefined) dbUpdate.last_login = updateData.lastLogin;
    
    const { data, error } = await supabase
      .from('users')
      .update(dbUpdate)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data ? new User(data) : null;
  }

  static async findOne(filter) {
    // Support both { email: ... } and { _id: ... } formats
    if (filter.email) {
      return await this.findByEmail(filter.email);
    }
    if (filter._id || filter.id) {
      return await this.findById(filter._id || filter.id);
    }
    return null;
  }

  static async find(filter = {}) {
    const supabase = getSupabase();
    let query = supabase.from('users').select('*');
    
    if (filter.userType) query = query.eq('user_type', filter.userType);
    if (filter.parentAccount) query = query.eq('parent_account_id', filter.parentAccount);
    if (filter.isActive !== undefined) query = query.eq('is_active', filter.isActive);
    
    const { data, error } = await query;
    if (error) throw error;
    return data ? data.map(u => new User(u)) : [];
  }
}

module.exports = User;

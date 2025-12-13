const { getSupabase } = require('../config/database');
const bcrypt = require('bcryptjs');

class School {
  constructor(data) {
    this.id = data.id;
    this.name = data.name;
    this.email = data.email;
    this.password = data.password;
    this.address = data.address;
    this.contactPerson = data.contact_person;
    this.phone = data.phone;
    this.website = data.website;
    this.isVerified = data.is_verified || false;
    this.verifiedBy = data.verified_by;
    this.verifiedAt = data.verified_at;
    this.createdAt = data.created_at;
    this.updatedAt = data.updated_at;
  }

  static async findById(id) {
    const supabase = getSupabase();
    const { data, error } = await supabase
      .from('schools')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) return null;
    return new School(data);
  }

  static async findByEmail(email) {
    const supabase = getSupabase();
    const { data, error } = await supabase
      .from('schools')
      .select('*')
      .eq('email', email.toLowerCase().trim())
      .single();

    if (error || !data) return null;
    return new School(data);
  }

  static async create(schoolData) {
    const supabase = getSupabase();
    const hashedPassword = await bcrypt.hash(schoolData.password, 10);

    const dbData = {
      name: schoolData.name,
      email: schoolData.email.toLowerCase().trim(),
      password: hashedPassword,
      address: schoolData.address || null,
      contact_person: schoolData.contactPerson || null,
      phone: schoolData.phone || null,
      website: schoolData.website || null,
      is_verified: false
    };

    const { data, error } = await supabase
      .from('schools')
      .insert(dbData)
      .select()
      .single();

    if (error) throw error;
    return new School(data);
  }

  async comparePassword(candidatePassword) {
    if (!this.password) return false;
    return await bcrypt.compare(candidatePassword, this.password);
  }

  async save() {
    const supabase = getSupabase();
    const dbData = {
      name: this.name,
      email: this.email,
      address: this.address,
      contact_person: this.contactPerson,
      phone: this.phone,
      website: this.website,
      is_verified: this.isVerified,
      verified_by: this.verifiedBy,
      verified_at: this.verifiedAt
    };

    if (this.password) {
      dbData.password = await bcrypt.hash(this.password, 10);
    }

    const { data, error } = await supabase
      .from('schools')
      .update(dbData)
      .eq('id', this.id)
      .select()
      .single();

    if (error) throw error;
    Object.assign(this, new School(data));
    return this;
  }
}

module.exports = School;

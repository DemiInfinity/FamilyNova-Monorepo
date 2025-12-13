const { getSupabase } = require('../config/database');

class EducationContent {
  constructor(data) {
    this.id = data.id;
    this.schoolId = data.school_id;
    this.title = data.title;
    this.description = data.description;
    this.contentType = data.content_type;
    this.gradeLevel = data.grade_level;
    this.subject = data.subject;
    this.contentUrl = data.content_url;
    this.dueDate = data.due_date;
    this.attachments = data.attachments || [];
    this.createdAt = data.created_at;
    this.updatedAt = data.updated_at;
  }

  static async findById(id) {
    const supabase = getSupabase();
    const { data, error } = await supabase
      .from('education_content')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) return null;
    return new EducationContent(data);
  }

  static async find(filter = {}) {
    const supabase = getSupabase();
    let query = supabase.from('education_content').select('*');

    if (filter.schoolId) query = query.eq('school_id', filter.schoolId);
    if (filter.contentType) query = query.eq('content_type', filter.contentType);
    if (filter.gradeLevel) query = query.eq('grade_level', filter.gradeLevel);

    query = query.order('created_at', { ascending: false });

    const { data, error } = await query;
    if (error) throw error;
    return data ? data.map(e => new EducationContent(e)) : [];
  }

  static async create(contentData) {
    const supabase = getSupabase();
    const dbData = {
      school_id: contentData.schoolId,
      title: contentData.title,
      description: contentData.description || null,
      content_type: contentData.contentType,
      grade_level: contentData.gradeLevel,
      subject: contentData.subject,
      content_url: contentData.contentUrl || null,
      due_date: contentData.dueDate || null,
      attachments: contentData.attachments || []
    };

    const { data, error } = await supabase
      .from('education_content')
      .insert(dbData)
      .select()
      .single();

    if (error) throw error;
    return new EducationContent(data);
  }

  async save() {
    const supabase = getSupabase();
    const dbData = {
      title: this.title,
      description: this.description,
      content_type: this.contentType,
      grade_level: this.gradeLevel,
      subject: this.subject,
      content_url: this.contentUrl,
      due_date: this.dueDate,
      attachments: this.attachments
    };

    const { data, error } = await supabase
      .from('education_content')
      .update(dbData)
      .eq('id', this.id)
      .select()
      .single();

    if (error) throw error;
    Object.assign(this, new EducationContent(data));
    return this;
  }
}

module.exports = EducationContent;

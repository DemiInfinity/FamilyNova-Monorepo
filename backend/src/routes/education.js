const express = require('express');
const { body, validationResult } = require('express-validator');
const EducationContent = require('../models/EducationContent');
const School = require('../models/School');
const User = require('../models/User');
const { auth, requireUserType } = require('../middleware/auth');
const { getSupabase } = require('../config/database');

const router = express.Router();

// @route   POST /api/education
// @desc    Create education content (schools only - requires school auth middleware)
// @access  Private (School only)
router.post('/', [
  body('title').trim().notEmpty(),
  body('contentType').isIn(['homework', 'lesson', 'quiz', 'resource']),
  body('grade').trim().notEmpty(),
  body('subject').trim().notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    // TODO: Add school authentication middleware
    // For now, we'll use a schoolId from body (should come from auth token)
    const { schoolId, title, description, contentType, grade, subject, dueDate, attachments } = req.body;
    
    if (!schoolId) {
      return res.status(401).json({ error: 'School authentication required' });
    }
    
    const school = await School.findById(schoolId);
    if (!school) {
      return res.status(404).json({ error: 'School not found' });
    }
    
    const content = await EducationContent.create({
      schoolId: schoolId,
      title: title.trim(),
      description: description || null,
      contentType: contentType,
      gradeLevel: grade,
      subject: subject.trim(),
      dueDate: dueDate ? new Date(dueDate).toISOString() : null,
      attachments: attachments || []
    });
    
    res.status(201).json({
      message: 'Education content created successfully',
      content: {
        id: content.id,
        title: content.title,
        contentType: content.contentType,
        grade: content.gradeLevel,
        subject: content.subject,
        dueDate: content.dueDate,
        createdAt: content.createdAt
      }
    });
  } catch (error) {
    console.error('Error creating education content:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/education
// @desc    Get education content for current user (kids) or their children (parents)
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const supabase = await getSupabase();
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    let gradeLevels = [];
    let userIds = [req.user.id];
    
    if (req.user.userType === 'kid') {
      // Kids see content assigned to their grade
      if (user.profile?.grade) {
        gradeLevels.push(user.profile.grade);
      }
    } else if (req.user.userType === 'parent') {
      // Parents see content for their children's grades
      const { data: children, error: childrenError } = await supabase
        .from('parent_children')
        .select('child_id')
        .eq('parent_id', req.user.id);
      
      if (!childrenError && children) {
        const childIds = children.map(c => c.child_id);
        userIds = [...userIds, ...childIds];
        
        // Get children's profiles to get their grades
        const { data: childrenData, error: childrenDataError } = await supabase
          .from('users')
          .select('id, profile')
          .in('id', childIds);
        
        if (!childrenDataError && childrenData) {
          const grades = new Set();
          childrenData.forEach(child => {
            if (child.profile?.grade) {
              grades.add(child.profile.grade);
            }
          });
          gradeLevels = Array.from(grades);
        }
      }
    }
    
    // Build query
    let query = supabase.from('education_content').select('*');
    
    if (gradeLevels.length > 0) {
      query = query.in('grade_level', gradeLevels);
    }
    
    query = query.order('due_date', { ascending: true, nullsFirst: false })
                 .order('created_at', { ascending: false });
    
    const { data: contentData, error: contentError } = await query;
    
    if (contentError) {
      console.error('Error fetching education content:', contentError);
      return res.status(500).json({ error: 'Failed to fetch content' });
    }
    
    // Get school info for each content item
    const schoolIds = new Set();
    if (contentData) {
      contentData.forEach(item => {
        if (item.school_id) schoolIds.add(item.school_id);
      });
    }
    
    const schoolsMap = new Map();
    if (schoolIds.size > 0) {
      const { data: schoolsData, error: schoolsError } = await supabase
        .from('schools')
        .select('id, name')
        .in('id', Array.from(schoolIds));
      
      if (!schoolsError && schoolsData) {
        schoolsData.forEach(school => {
          schoolsMap.set(school.id, school);
        });
      }
    }
    
    // Format content with school info
    const content = (contentData || []).map(item => {
      const school = schoolsMap.get(item.school_id);
      
      return {
        id: item.id,
        title: item.title,
        description: item.description,
        contentType: item.content_type,
        grade: item.grade_level,
        subject: item.subject,
        contentUrl: item.content_url,
        dueDate: item.due_date,
        attachments: item.attachments || [],
        school: school ? {
          id: school.id,
          name: school.name
        } : null,
        createdAt: item.created_at,
        updatedAt: item.updated_at
      };
    });
    
    res.json({ content });
  } catch (error) {
    console.error('Error fetching education content:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/education/:contentId
// @desc    Get specific education content
// @access  Private
router.get('/:contentId', auth, async (req, res) => {
  try {
    const content = await EducationContent.findById(req.params.contentId);
    
    if (!content) {
      return res.status(404).json({ error: 'Content not found' });
    }
    
    // Get school info
    const school = await School.findById(content.schoolId);
    
    const formattedContent = {
      id: content.id,
      title: content.title,
      description: content.description,
      contentType: content.contentType,
      grade: content.gradeLevel,
      subject: content.subject,
      contentUrl: content.contentUrl,
      dueDate: content.dueDate,
      attachments: content.attachments || [],
      school: school ? {
        id: school.id,
        name: school.name
      } : null,
      createdAt: content.createdAt,
      updatedAt: content.updatedAt
    };
    
    res.json({ content: formattedContent });
  } catch (error) {
    console.error('Error fetching education content:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/education/:contentId/complete
// @desc    Mark education content as completed (kids only)
// @access  Private (Kid only)
router.post('/:contentId/complete', auth, requireUserType('kid'), [
  body('submission.content').optional().trim(),
  body('submission.attachments').optional().isArray()
], async (req, res) => {
  try {
    const { contentId } = req.params;
    const { submission } = req.body;
    
    const content = await EducationContent.findById(contentId);
    if (!content) {
      return res.status(404).json({ error: 'Content not found' });
    }
    
    // Note: The education_content table doesn't have a completedBy field in the schema
    // We would need to add this or use a separate table for completions
    // For now, we'll return success but note that completion tracking needs to be implemented
    
    res.json({
      message: 'Content marked as completed',
      note: 'Completion tracking will be implemented with a separate completions table'
    });
  } catch (error) {
    console.error('Error completing content:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

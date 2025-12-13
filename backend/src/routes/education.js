const express = require('express');
const { body, validationResult } = require('express-validator');
const EducationContent = require('../models/EducationContent');
const School = require('../models/School');
const User = require('../models/User');
const { auth, requireUserType } = require('../middleware/auth');

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
    const { schoolId, title, description, contentType, grade, subject, dueDate, attachments, assignedTo } = req.body;
    
    if (!schoolId) {
      return res.status(401).json({ error: 'School authentication required' });
    }
    
    const school = await School.findById(schoolId);
    if (!school) {
      return res.status(404).json({ error: 'School not found' });
    }
    
    const content = new EducationContent({
      school: schoolId,
      title,
      description,
      contentType,
      grade,
      subject,
      dueDate: dueDate ? new Date(dueDate) : undefined,
      attachments: attachments || [],
      assignedTo: assignedTo || []
    });
    
    await content.save();
    
    res.status(201).json({
      message: 'Education content created successfully',
      content: {
        id: content._id,
        title: content.title,
        contentType: content.contentType,
        grade: content.grade,
        subject: content.subject,
        dueDate: content.dueDate,
        createdAt: content.createdAt
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/education
// @desc    Get education content for current user (kids) or their children (parents)
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    let query = { isActive: true };
    
    if (req.user.userType === 'kid') {
      // Kids see content assigned to their grade
      query.grade = user.profile.grade;
      // Or if assigned specifically to them
      query.$or = [
        { grade: user.profile.grade },
        { assignedTo: req.user._id }
      ];
    } else if (req.user.userType === 'parent') {
      // Parents see content for their children's grades
      const children = await User.find({ _id: { $in: user.children } });
      const grades = [...new Set(children.map(c => c.profile.grade).filter(Boolean))];
      const childIds = children.map(c => c._id);
      
      query.$or = [
        { grade: { $in: grades } },
        { assignedTo: { $in: childIds } }
      ];
    }
    
    const content = await EducationContent.find(query)
      .populate('school', 'name')
      .populate('assignedTo', 'profile.displayName')
      .sort({ dueDate: 1, createdAt: -1 });
    
    res.json({ content });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/education/:contentId
// @desc    Get specific education content
// @access  Private
router.get('/:contentId', auth, async (req, res) => {
  try {
    const content = await EducationContent.findById(req.params.contentId)
      .populate('school', 'name')
      .populate('assignedTo', 'profile.displayName')
      .populate('completedBy.user', 'profile.displayName');
    
    if (!content) {
      return res.status(404).json({ error: 'Content not found' });
    }
    
    res.json({ content });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/education/:contentId/complete
// @desc    Mark education content as completed (kids only)
// @access  Private (Kid only)
router.post('/:contentId/complete', requireUserType('kid'), [
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
    
    // Check if already completed
    const alreadyCompleted = content.completedBy.some(
      completion => completion.user.toString() === req.user._id.toString()
    );
    
    if (alreadyCompleted) {
      return res.status(400).json({ error: 'Already completed' });
    }
    
    content.completedBy.push({
      user: req.user._id,
      submission: submission || {}
    });
    
    await content.save();
    
    res.json({
      message: 'Content marked as completed',
      completion: content.completedBy[content.completedBy.length - 1]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;


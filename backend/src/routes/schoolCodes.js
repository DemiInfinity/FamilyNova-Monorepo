const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, requireUserType } = require('../middleware/auth');
const SchoolCode = require('../models/SchoolCode');
const School = require('../models/School');
const User = require('../models/User');

const router = express.Router();

// @route   POST /api/school-codes/generate
// @desc    Generate a school code for a child (schools only)
// @access  Private (School only - requires school auth)
router.post('/generate', [
  body('grade').trim().notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    // TODO: Add school authentication middleware
    // For now, we'll use schoolId from body (should come from auth token)
    const { schoolId, grade } = req.body;
    
    if (!schoolId) {
      return res.status(401).json({ error: 'School authentication required' });
    }
    
    const school = await School.findById(schoolId);
    if (!school) {
      return res.status(404).json({ error: 'School not found' });
    }
    
    // Create new code
    const code = new SchoolCode({
      school: schoolId,
      generatedBy: schoolId,
      grade
    });
    
    await code.save();
    
    res.status(201).json({
      message: 'School code generated successfully',
      code: {
        id: code._id,
        code: code.code,
        grade: code.grade,
        expiresAt: code.expiresAt,
        createdAt: code.createdAt
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/school-codes
// @desc    Get all codes for a school
// @access  Private (School only)
router.get('/', async (req, res) => {
  try {
    // TODO: Get schoolId from auth token
    const { schoolId } = req.query;
    
    if (!schoolId) {
      return res.status(401).json({ error: 'School authentication required' });
    }
    
    const codes = await SchoolCode.find({
      school: schoolId,
      isActive: true
    })
      .populate('assignedTo', 'profile.displayName email')
      .sort({ createdAt: -1 });
    
    res.json({ codes });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/school-codes/validate
// @desc    Validate and use a school code (kids only)
// @access  Private (Kid only)
router.post('/validate', auth, requireUserType('kid'), [
  body('code').trim().notEmpty().isLength({ min: 6, max: 6 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { code } = req.body;
    const userId = req.user._id;
    
    // Find code
    const schoolCode = await SchoolCode.findOne({
      code: code.toUpperCase(),
      isActive: true
    }).populate('school');
    
    if (!schoolCode) {
      return res.status(404).json({ error: 'Invalid code' });
    }
    
    // Check if code is expired
    if (schoolCode.expiresAt < new Date()) {
      return res.status(400).json({ error: 'Code has expired' });
    }
    
    // Check if code is already used
    if (schoolCode.assignedTo) {
      return res.status(400).json({ error: 'Code has already been used' });
    }
    
    // Verify user is a kid
    const user = await User.findById(userId);
    if (user.userType !== 'kid') {
      return res.status(403).json({ error: 'Only kids can use school codes' });
    }
    
    // Assign code to user
    schoolCode.assignedTo = userId;
    schoolCode.usedAt = new Date();
    await schoolCode.save();
    
    // Update user's school info
    user.schoolAccount = schoolCode.school._id;
    user.profile.school = schoolCode.school.name;
    user.profile.grade = schoolCode.grade;
    user.verification.schoolVerified = true;
    user.verification.verifiedAt = new Date();
    
    // Add user to school's students list
    const school = await School.findById(schoolCode.school._id);
    if (!school.students.includes(userId)) {
      school.students.push(userId);
      await school.save();
    }
    
    await user.save();
    
    // Calculate monitoring level based on age
    let monitoringLevel = 'full';
    if (user.profile.dateOfBirth) {
      const age = calculateAge(user.profile.dateOfBirth);
      monitoringLevel = age >= 13 ? 'partial' : 'full';
    }
    user.monitoringLevel = monitoringLevel;
    await user.save();
    
    res.json({
      message: 'School code validated successfully',
      school: {
        id: school._id,
        name: school.name
      },
      user: {
        schoolVerified: user.verification.schoolVerified,
        monitoringLevel: user.monitoringLevel
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Helper function to calculate age
function calculateAge(dateOfBirth) {
  const today = new Date();
  const birthDate = new Date(dateOfBirth);
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
}

module.exports = router;


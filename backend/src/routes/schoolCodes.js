const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, requireUserType } = require('../middleware/auth');
const SchoolCode = require('../models/SchoolCode');
const School = require('../models/School');
const User = require('../models/User');
const { getSupabase } = require('../config/database');

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
    
    // Generate code using SchoolCode model
    const code = await SchoolCode.generateCode(schoolId, grade, schoolId);
    
    res.status(201).json({
      message: 'School code generated successfully',
      code: {
        id: code.id,
        code: code.code,
        grade: code.gradeLevel,
        expiresAt: code.expiresAt,
        createdAt: code.generatedAt
      }
    });
  } catch (error) {
    console.error('Error generating school code:', error);
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
      schoolId: schoolId
    });
    
    // Get user info for codes that have been used
    const usedByIds = codes.filter(c => c.usedBy).map(c => c.usedBy);
    const usersMap = new Map();
    
    if (usedByIds.length > 0) {
      const supabase = await getSupabase();
      const { data: usersData, error: usersError } = await supabase
        .from('users')
        .select('id, profile, email')
        .in('id', usedByIds);
      
      if (!usersError && usersData) {
        usersData.forEach(user => {
          usersMap.set(user.id, user);
        });
      }
    }
    
    const formattedCodes = codes.map(code => {
      const user = code.usedBy ? usersMap.get(code.usedBy) : null;
      const userProfile = user?.profile || {};
      
      return {
        id: code.id,
        code: code.code,
        grade: code.gradeLevel,
        expiresAt: code.expiresAt,
        usedBy: code.usedBy ? {
          id: user?.id || code.usedBy,
          profile: {
            displayName: userProfile.displayName || user?.email || 'Unknown'
          },
          email: user?.email
        } : null,
        usedAt: code.usedAt,
        createdAt: code.generatedAt
      };
    });
    
    res.json({ codes: formattedCodes });
  } catch (error) {
    console.error('Error fetching school codes:', error);
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
    const userId = req.user.id;
    
    // Find code
    const schoolCode = await SchoolCode.findByCode(code.toUpperCase());
    
    if (!schoolCode) {
      return res.status(404).json({ error: 'Invalid code' });
    }
    
    // Check if code is expired
    if (schoolCode.isExpired()) {
      return res.status(400).json({ error: 'Code has expired' });
    }
    
    // Check if code is already used
    if (schoolCode.isUsed()) {
      return res.status(400).json({ error: 'Code has already been used' });
    }
    
    // Verify user is a kid
    const user = await User.findById(userId);
    if (user.userType !== 'kid') {
      return res.status(403).json({ error: 'Only kids can use school codes' });
    }
    
    // Get school info
    const school = await School.findById(schoolCode.schoolId);
    if (!school) {
      return res.status(404).json({ error: 'School not found' });
    }
    
    // Mark code as used
    await schoolCode.markAsUsed(userId);
    
    // Update user's school info
    const profile = { ...user.profile };
    profile.school = school.name;
    profile.grade = schoolCode.gradeLevel;
    
    const verification = { ...user.verification };
    verification.schoolVerified = true;
    
    await User.findByIdAndUpdate(userId, {
      schoolAccount: schoolCode.schoolId,
      profile: profile,
      verification: verification
    });
    
    // Calculate monitoring level based on age
    let monitoringLevel = 'full';
    if (profile.dateOfBirth) {
      const age = calculateAge(profile.dateOfBirth);
      monitoringLevel = age >= 13 ? 'partial' : 'full';
    }
    
    await User.findByIdAndUpdate(userId, { monitoringLevel: monitoringLevel });
    
    res.json({
      message: 'School code validated successfully',
      school: {
        id: school.id,
        name: school.name
      },
      user: {
        schoolVerified: true,
        monitoringLevel: monitoringLevel
      }
    });
  } catch (error) {
    console.error('Error validating school code:', error);
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

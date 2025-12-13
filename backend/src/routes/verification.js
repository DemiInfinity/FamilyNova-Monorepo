const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');

const router = express.Router();

// All routes require authentication
router.use(auth);

// @route   POST /api/verification/parent
// @desc    Verify a child account (parents only)
// @access  Private (Parent only)
router.post('/parent', requireUserType('parent'), [
  body('childId').notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { childId } = req.body;
    
    const child = await User.findById(childId);
    if (!child || child.userType !== 'kid') {
      return res.status(404).json({ error: 'Child not found' });
    }
    
    // Link parent to child
    child.parentAccount = req.user._id;
    child.verification.parentVerified = true;
    child.verification.verifiedAt = new Date();
    
    // Add child to parent's children list
    if (!req.user.children.includes(childId)) {
      req.user.children.push(childId);
      await req.user.save();
    }
    
    await child.save();
    
    res.json({
      message: 'Child verified successfully',
      child: {
        id: child._id,
        profile: child.profile,
        verification: child.verification
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/verification/school
// @desc    Verify a child account (school verification - would be admin/school endpoint)
// @access  Private (Admin/School only - simplified for now)
router.post('/school', [
  body('childId').notEmpty(),
  body('schoolCode').notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    // In production, this would verify school credentials
    const { childId, schoolCode } = req.body;
    
    const child = await User.findById(childId);
    if (!child || child.userType !== 'kid') {
      return res.status(404).json({ error: 'Child not found' });
    }
    
    // Simplified: In production, verify schoolCode against database
    child.verification.schoolVerified = true;
    if (!child.verification.verifiedAt) {
      child.verification.verifiedAt = new Date();
    }
    
    await child.save();
    
    res.json({
      message: 'School verification completed',
      child: {
        id: child._id,
        profile: child.profile,
        verification: child.verification,
        isFullyVerified: child.isFullyVerified()
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;


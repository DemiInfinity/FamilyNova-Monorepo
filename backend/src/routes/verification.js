const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');
const { getSupabase } = require('../config/database');

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
    const supabase = await getSupabase();
    
    const child = await User.findById(childId);
    if (!child || child.userType !== 'kid') {
      return res.status(404).json({ error: 'Child not found' });
    }
    
    // Link parent to child in parent_children table
    const { error: relationError } = await supabase
      .from('parent_children')
      .upsert({
        parent_id: req.user.id,
        child_id: childId
      }, {
        onConflict: 'parent_id,child_id'
      });
    
    if (relationError) {
      console.error('Error creating parent-child relation:', relationError);
      return res.status(500).json({ error: 'Failed to link parent and child' });
    }
    
    // Update child's verification and parent account
    const verification = { ...child.verification };
    verification.parentVerified = true;
    
    await User.findByIdAndUpdate(childId, {
      parentAccount: req.user.id,
      verification: verification
    });
    
    // Get updated child
    const updatedChild = await User.findById(childId);
    
    res.json({
      message: 'Child verified successfully',
      child: {
        id: updatedChild.id,
        profile: updatedChild.profile,
        verification: updatedChild.verification
      }
    });
  } catch (error) {
    console.error('Error verifying child:', error);
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
    // This should use the school code validation endpoint instead
    const verification = { ...child.verification };
    verification.schoolVerified = true;
    
    await User.findByIdAndUpdate(childId, {
      verification: verification
    });
    
    const updatedChild = await User.findById(childId);
    
    res.json({
      message: 'School verification completed',
      child: {
        id: updatedChild.id,
        profile: updatedChild.profile,
        verification: updatedChild.verification,
        isFullyVerified: updatedChild.isFullyVerified()
      }
    });
  } catch (error) {
    console.error('Error verifying school:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

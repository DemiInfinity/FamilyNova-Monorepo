const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, requireUserType } = require('../middleware/auth');
const ProfileChangeRequest = require('../models/ProfileChangeRequest');
const User = require('../models/User');

const router = express.Router();

// All routes require authentication
router.use(auth);

// @route   POST /api/profile-changes/request
// @desc    Request a profile change (kids only)
// @access  Private (Kid only)
router.post('/request', requireUserType('kid'), [
  body('displayName').optional().trim(),
  body('avatar').optional().trim(),
  body('school').optional().trim(),
  body('grade').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { displayName, avatar, school, grade } = req.body;
    
    // Get current profile
    const child = await User.findById(req.user._id);
    if (!child || !child.parentAccount) {
      return res.status(400).json({ error: 'No parent account linked' });
    }
    
    // Build changes object
    const changes = {};
    const oldValues = {};
    
    if (displayName !== undefined && displayName !== child.profile.displayName) {
      changes.displayName = displayName;
      oldValues.oldDisplayName = child.profile.displayName;
    }
    if (avatar !== undefined && avatar !== child.profile.avatar) {
      changes.avatar = avatar;
      oldValues.oldAvatar = child.profile.avatar;
    }
    if (school !== undefined && school !== child.profile.school) {
      changes.school = school;
      oldValues.oldSchool = child.profile.school;
    }
    if (grade !== undefined && grade !== child.profile.grade) {
      changes.grade = grade;
      oldValues.oldGrade = child.profile.grade;
    }
    
    if (Object.keys(changes).length === 0) {
      return res.status(400).json({ error: 'No changes detected' });
    }
    
    // Check for existing pending request
    const existingRequest = await ProfileChangeRequest.findOne({
      child: req.user._id,
      status: 'pending'
    });
    
    if (existingRequest) {
      return res.status(400).json({ error: 'You already have a pending profile change request' });
    }
    
    // Create change request
    const changeRequest = new ProfileChangeRequest({
      child: req.user._id,
      parent: child.parentAccount,
      changes: { ...changes, ...oldValues },
      status: 'pending'
    });
    
    await changeRequest.save();
    
    res.status(201).json({
      message: 'Profile change request submitted for parent approval',
      request: {
        id: changeRequest._id,
        changes: changeRequest.changes,
        status: changeRequest.status,
        createdAt: changeRequest.createdAt
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/profile-changes/pending
// @desc    Get pending profile change requests (parents only)
// @access  Private (Parent only)
router.get('/pending', requireUserType('parent'), async (req, res) => {
  try {
    const requests = await ProfileChangeRequest.find({
      parent: req.user._id,
      status: 'pending'
    })
      .populate('child', 'profile email')
      .sort({ createdAt: -1 });
    
    res.json({ requests });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   PUT /api/profile-changes/:requestId/approve
// @desc    Approve or reject a profile change request (parents only)
// @access  Private (Parent only)
router.put('/:requestId/approve', requireUserType('parent'), [
  body('action').isIn(['approve', 'reject']),
  body('reason').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { requestId } = req.params;
    const { action, reason } = req.body;
    
    const request = await ProfileChangeRequest.findById(requestId)
      .populate('child');
    
    if (!request) {
      return res.status(404).json({ error: 'Request not found' });
    }
    
    if (request.parent.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Not authorized' });
    }
    
    if (request.status !== 'pending') {
      return res.status(400).json({ error: 'Request already processed' });
    }
    
    if (action === 'approve') {
      // Apply changes to child's profile
      const child = await User.findById(request.child._id);
      if (request.changes.displayName) {
        child.profile.displayName = request.changes.displayName;
      }
      if (request.changes.avatar) {
        child.profile.avatar = request.changes.avatar;
      }
      if (request.changes.school) {
        child.profile.school = request.changes.school;
      }
      if (request.changes.grade) {
        child.profile.grade = request.changes.grade;
      }
      await child.save();
      
      request.status = 'approved';
      request.reviewedBy = req.user._id;
      request.reviewedAt = new Date();
    } else {
      request.status = 'rejected';
      request.reviewedBy = req.user._id;
      request.reviewedAt = new Date();
      request.rejectionReason = reason || 'Rejected by parent';
    }
    
    await request.save();
    
    res.json({
      message: `Profile change request ${action}d`,
      request: {
        id: request._id,
        status: request.status,
        reviewedAt: request.reviewedAt
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;


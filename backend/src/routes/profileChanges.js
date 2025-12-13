const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, requireUserType } = require('../middleware/auth');
const ProfileChangeRequest = require('../models/ProfileChangeRequest');
const User = require('../models/User');
const { getSupabase } = require('../config/database');

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
    const child = await User.findById(req.user.id);
    if (!child || !child.parentAccount) {
      return res.status(400).json({ error: 'No parent account linked' });
    }
    
    // Build changes object
    const changes = {};
    const currentProfile = { ...child.profile };
    
    if (displayName !== undefined && displayName !== child.profile?.displayName) {
      changes.displayName = displayName;
    }
    if (avatar !== undefined && avatar !== child.profile?.avatar) {
      changes.avatar = avatar;
    }
    if (school !== undefined && school !== child.profile?.school) {
      changes.school = school;
    }
    if (grade !== undefined && grade !== child.profile?.grade) {
      changes.grade = grade;
    }
    
    if (Object.keys(changes).length === 0) {
      return res.status(400).json({ error: 'No changes detected' });
    }
    
    // Check for existing pending request
    const existingRequests = await ProfileChangeRequest.find({
      kidId: req.user.id,
      status: 'pending'
    });
    
    if (existingRequests.length > 0) {
      return res.status(400).json({ error: 'You already have a pending profile change request' });
    }
    
    // Create change request
    const changeRequest = await ProfileChangeRequest.create({
      kidId: req.user.id,
      requestedChanges: changes,
      currentProfile: currentProfile,
      status: 'pending'
    });
    
    res.status(201).json({
      message: 'Profile change request submitted for parent approval',
      request: {
        id: changeRequest.id,
        requestedChanges: changeRequest.requestedChanges,
        currentProfile: changeRequest.currentProfile,
        status: changeRequest.status,
        requestedAt: changeRequest.requestedAt
      }
    });
  } catch (error) {
    console.error('Error creating profile change request:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/profile-changes/pending
// @desc    Get pending profile change requests (parents only)
// @access  Private (Parent only)
router.get('/pending', requireUserType('parent'), async (req, res) => {
  try {
    const supabase = await getSupabase();
    
    // Get parent's children
    const { data: children, error: childrenError } = await supabase
      .from('parent_children')
      .select('child_id')
      .eq('parent_id', req.user.id);
    
    if (childrenError) {
      console.error('Error fetching children:', childrenError);
      return res.status(500).json({ error: 'Failed to fetch children' });
    }
    
    const childIds = children ? children.map(c => c.child_id) : [];
    
    if (childIds.length === 0) {
      return res.json({ requests: [] });
    }
    
    // Get pending requests for these children
    const requests = await ProfileChangeRequest.find({
      kidId: childIds, // Pass array directly - model will handle it
      status: 'pending'
    });
    
    // Get child profiles
    const { data: childrenData, error: childrenDataError } = await supabase
      .from('users')
      .select('id, profile, email')
      .in('id', childIds);
    
    const childrenMap = new Map();
    if (!childrenDataError && childrenData) {
      childrenData.forEach(child => {
        childrenMap.set(child.id, child);
      });
    }
    
    // Format requests with child info
    const formattedRequests = requests.map(request => {
      const child = childrenMap.get(request.kidId);
      const childProfile = child?.profile || {};
      
      return {
        id: request.id,
        kid: {
          id: child?.id || request.kidId,
          profile: {
            displayName: childProfile.displayName || 'Unknown',
            email: child?.email
          }
        },
        requestedChanges: request.requestedChanges,
        currentProfile: request.currentProfile,
        status: request.status,
        requestedAt: request.requestedAt
      };
    });
    
    res.json({ requests: formattedRequests });
  } catch (error) {
    console.error('Error fetching pending requests:', error);
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
    const supabase = await getSupabase();
    
    const request = await ProfileChangeRequest.findById(requestId);
    
    if (!request) {
      return res.status(404).json({ error: 'Request not found' });
    }
    
    // Verify parent has access to this request
    const { data: parentChild, error: relationError } = await supabase
      .from('parent_children')
      .select('child_id')
      .eq('parent_id', req.user.id)
      .eq('child_id', request.kidId)
      .single();
    
    if (relationError || !parentChild) {
      return res.status(403).json({ error: 'Not authorized' });
    }
    
    if (request.status !== 'pending') {
      return res.status(400).json({ error: 'Request already processed' });
    }
    
    if (action === 'approve') {
      // Apply changes to child's profile
      const child = await User.findById(request.kidId);
      if (!child) {
        return res.status(404).json({ error: 'Child not found' });
      }
      
      const profile = { ...child.profile };
      if (request.requestedChanges.displayName) {
        profile.displayName = request.requestedChanges.displayName;
      }
      if (request.requestedChanges.avatar) {
        profile.avatar = request.requestedChanges.avatar;
      }
      if (request.requestedChanges.school) {
        profile.school = request.requestedChanges.school;
      }
      if (request.requestedChanges.grade) {
        profile.grade = request.requestedChanges.grade;
      }
      
      await User.findByIdAndUpdate(request.kidId, { profile: profile });
      
      request.status = 'approved';
      request.reviewedBy = req.user.id;
      request.reviewedAt = new Date();
    } else {
      request.status = 'rejected';
      request.reviewedBy = req.user.id;
      request.reviewedAt = new Date();
      request.reason = reason || 'Rejected by parent';
    }
    
    await request.save();
    
    res.json({
      message: `Profile change request ${action}d`,
      request: {
        id: request.id,
        status: request.status,
        reviewedAt: request.reviewedAt,
        reason: request.reason
      }
    });
  } catch (error) {
    console.error('Error approving/rejecting request:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

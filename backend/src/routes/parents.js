const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');
const Message = require('../models/Message');

const router = express.Router();

// All routes require authentication and parent user type
router.use(auth);
router.use(requireUserType('parent'));

// @route   GET /api/parents/dashboard
// @desc    Get parent dashboard data
// @access  Private (Parent only)
router.get('/dashboard', async (req, res) => {
  try {
    const parent = await User.findById(req.user._id)
      .populate('children', 'profile verification friends lastLogin')
      .populate('parentConnections.parent', 'profile email');
    
    // Get recent activity from children
    // For partial monitoring, only show flagged messages
    // For full monitoring, show all messages
    const children = await User.find({ _id: { $in: parent.children } });
    const fullMonitoringChildren = children
      .filter(c => c.monitoringLevel === 'full')
      .map(c => c._id);
    
    let messageQuery = {
      $or: [
        { sender: { $in: parent.children } },
        { receiver: { $in: parent.children } }
      ]
    };
    
    // For partial monitoring kids, only show messages that need attention
    const partialMonitoringChildren = children
      .filter(c => c.monitoringLevel === 'partial')
      .map(c => c._id);
    
    if (partialMonitoringChildren.length > 0) {
      messageQuery.$or = [
        { sender: { $in: fullMonitoringChildren } },
        { receiver: { $in: fullMonitoringChildren } },
        { sender: { $in: partialMonitoringChildren }, flagged: true },
        { receiver: { $in: partialMonitoringChildren }, flagged: true }
      ];
    }
    
    const childrenActivity = await Message.find(messageQuery)
    .sort({ createdAt: -1 })
    .limit(20)
    .populate('sender receiver', 'profile displayName monitoringLevel');
    
    res.json({
      parent: {
        id: parent._id,
        profile: parent.profile,
        children: parent.children,
        parentConnections: parent.parentConnections
      },
      recentActivity: childrenActivity
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/parents/children/:childId
// @desc    Get specific child's activity
// @access  Private (Parent only)
router.get('/children/:childId', async (req, res) => {
  try {
    const { childId } = req.params;
    
    // Verify child belongs to parent
    const parent = await User.findById(req.user._id);
    if (!parent.children.includes(childId)) {
      return res.status(403).json({ error: 'Child not found' });
    }
    
    const child = await User.findById(childId)
      .populate('friends', 'profile displayName verification');
    
    const messages = await Message.find({
      $or: [
        { sender: childId },
        { receiver: childId }
      ]
    })
    .sort({ createdAt: -1 })
    .limit(50)
    .populate('sender receiver', 'profile displayName');
    
    res.json({
      child: {
        id: child._id,
        profile: child.profile,
        verification: child.verification,
        friends: child.friends,
        lastLogin: child.lastLogin
      },
      messages
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/parents/children/create
// @desc    Create a child account (parents only)
// @access  Private (Parent only)
router.post('/children/create', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('firstName').trim().notEmpty(),
  body('lastName').trim().notEmpty(),
  body('displayName').optional().trim(),
  body('dateOfBirth').optional().isISO8601(),
  body('school').optional().trim(),
  body('grade').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { email, password, firstName, lastName, displayName, dateOfBirth, school, grade } = req.body;
    
    // Check if user exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'Email already in use' });
    }
    
    // Calculate monitoring level based on age
    let monitoringLevel = 'full'; // Default to full monitoring
    if (dateOfBirth) {
      const birthDate = new Date(dateOfBirth);
      const today = new Date();
      let age = today.getFullYear() - birthDate.getFullYear();
      const monthDiff = today.getMonth() - birthDate.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
        age--;
      }
      monitoringLevel = age >= 13 ? 'partial' : 'full';
    }
    
    // Create child account
    const child = new User({
      email,
      password,
      userType: 'kid',
      profile: {
        firstName,
        lastName,
        displayName: displayName || `${firstName} ${lastName}`,
        dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : undefined,
        school,
        grade
      },
      parentAccount: req.user._id,
      monitoringLevel: monitoringLevel,
      verification: {
        parentVerified: true, // Auto-verified since parent is creating it
        verifiedAt: new Date()
      }
    });
    
    await child.save();
    
    // Add child to parent's children list
    req.user.children.push(child._id);
    await req.user.save();
    
    res.status(201).json({
      message: 'Child account created successfully',
      child: {
        id: child._id,
        email: child.email,
        profile: child.profile,
        verification: child.verification
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/parents/connections
// @desc    Get parent connections (parents of child's friends)
// @access  Private (Parent only)
router.get('/connections', async (req, res) => {
  try {
    const parent = await User.findById(req.user._id)
      .populate('parentConnections.parent', 'profile email children');
    
    res.json({
      connections: parent.parentConnections.map(conn => ({
        parent: {
          id: conn.parent._id,
          profile: conn.parent.profile,
          email: conn.parent.email
        },
        connectedAt: conn.connectedAt
      }))
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;


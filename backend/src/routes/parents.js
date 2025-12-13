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
    const { getSupabase } = require('../config/database');
    const supabase = await getSupabase();
    
    // Get parent user
    const parent = await User.findById(req.user.id);
    if (!parent) {
      return res.status(404).json({ error: 'Parent not found' });
    }
    
    // Get children from parent_children table
    const { data: parentChildren, error: childrenError } = await supabase
      .from('parent_children')
      .select('child_id')
      .eq('parent_id', req.user.id);

    if (childrenError) {
      console.error('Error fetching children:', childrenError);
      return res.status(500).json({ error: 'Failed to fetch children' });
    }

    const childIds = parentChildren.map(pc => pc.child_id);
    
    // Fetch children user profiles
    const children = [];
    if (childIds.length > 0) {
      const { data: childrenData, error: childrenDataError } = await supabase
        .from('users')
        .select('*')
        .in('id', childIds);

      if (childrenDataError) {
        console.error('Error fetching children data:', childrenDataError);
      } else {
        for (const childData of childrenData || []) {
          const child = new User(childData);
          children.push({
            id: child.id,
            profile: child.profile,
            verification: child.verification,
            lastLogin: child.lastLogin ? new Date(child.lastLogin).toISOString() : null
          });
        }
      }
    }
    
    // Get recent activity from children (simplified for now)
    // TODO: Implement message fetching with proper monitoring levels
    
    res.json({
      parent: {
        id: parent.id,
        profile: parent.profile,
        children: children,
        parentConnections: [] // TODO: Implement parent connections
      },
      recentActivity: [] // TODO: Implement recent activity
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
    const { getSupabase } = require('../config/database');
    const supabase = await getSupabase();
    
    // Check if user exists
    const existingUser = await User.findByEmail(email);
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
    
    // 1. Create child account in Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email: email.toLowerCase().trim(),
      password: password,
      email_confirm: true // Auto-confirm email
    });

    if (authError) {
      console.error('Supabase Auth error:', authError);
      return res.status(400).json({ error: authError.message || 'Failed to create user' });
    }

    if (!authData.user) {
      return res.status(500).json({ error: 'Failed to create user account' });
    }
    
    // 2. Create child profile in our users table
    const child = await User.create({
      id: authData.user.id, // Use Supabase Auth user ID
      email: authData.user.email,
      userType: 'kid',
      profile: {
        firstName,
        lastName,
        displayName: displayName || `${firstName} ${lastName}`,
        dateOfBirth: dateOfBirth ? new Date(dateOfBirth).toISOString() : undefined,
        school,
        grade
      },
      parentAccount: req.user.id,
      monitoringLevel: monitoringLevel,
      verification: {
        parentVerified: true, // Auto-verified since parent is creating it
        schoolVerified: false
      }
    });
    
    // 3. Add parent-child relationship in parent_children table
    const { error: relationError } = await supabase
      .from('parent_children')
      .insert({
        parent_id: req.user.id,
        child_id: child.id
      });

    if (relationError) {
      console.error('Error creating parent-child relationship:', relationError);
      // Try to clean up the created user
      await supabase.auth.admin.deleteUser(child.id);
      return res.status(500).json({ error: 'Failed to link child to parent' });
    }
    
    res.status(201).json({
      message: 'Child account created successfully',
      child: {
        id: child.id,
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


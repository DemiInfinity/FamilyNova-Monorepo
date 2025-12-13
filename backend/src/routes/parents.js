const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');

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
    const { getSupabase } = require('../config/database');
    const supabase = await getSupabase();
    
    // Verify child belongs to parent
    const { data: parentChild, error: relationError } = await supabase
      .from('parent_children')
      .select('child_id')
      .eq('parent_id', req.user.id)
      .eq('child_id', childId)
      .single();

    if (relationError || !parentChild) {
      return res.status(403).json({ error: 'Child not found or not linked to this parent' });
    }
    
    // Get child user
    const child = await User.findById(childId);
    if (!child) {
      return res.status(404).json({ error: 'Child not found' });
    }
    
    // Get child's friends
    const { data: friendships, error: friendsError } = await supabase
      .from('friendships')
      .select('friend_id')
      .eq('user_id', childId)
      .eq('status', 'accepted');

    const friendIds = friendships ? friendships.map(f => f.friend_id) : [];
    const friends = [];
    if (friendIds.length > 0) {
      const { data: friendsData } = await supabase
        .from('users')
        .select('id, profile, verification')
        .in('id', friendIds);
      
      if (friendsData) {
        for (const friendData of friendsData) {
          friends.push({
            id: friendData.id,
            profile: friendData.profile,
            verification: friendData.verification
          });
        }
      }
    }
    
    // Get messages (simplified for now - TODO: implement Message model)
    const { data: messagesData, error: messagesError } = await supabase
      .from('messages')
      .select('*')
      .or(`sender_id.eq.${childId},receiver_id.eq.${childId}`)
      .order('created_at', { ascending: false })
      .limit(50);

    const messages = messagesData || [];
    
    res.json({
      child: {
        id: child.id,
        email: child.email, // Include email for login information
        profile: child.profile,
        verification: child.verification,
        friends: friends,
        lastLogin: child.lastLogin ? new Date(child.lastLogin).toISOString() : null
      },
      messages: messages
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
    const { getSupabase } = require('../config/database');
    const supabase = await getSupabase();
    
    // Get parent connections
    const { data: connections, error: connectionsError } = await supabase
      .from('parent_connections')
      .select('parent1_id, parent2_id, connected_at')
      .or(`parent1_id.eq.${req.user.id},parent2_id.eq.${req.user.id}`);

    if (connectionsError) {
      console.error('Error fetching parent connections:', connectionsError);
      return res.status(500).json({ error: 'Failed to fetch connections' });
    }

    const connectionsList = [];
    for (const conn of connections || []) {
      // Get the other parent's ID (not the current user)
      const otherParentId = conn.parent1_id === req.user.id ? conn.parent2_id : conn.parent1_id;
      
      // Fetch the other parent's profile
      const otherParent = await User.findById(otherParentId);
      if (otherParent) {
        connectionsList.push({
          parent: {
            id: otherParent.id,
            profile: otherParent.profile,
            email: otherParent.email
          },
          connectedAt: conn.connected_at
        });
      }
    }
    
    res.json({
      connections: connectionsList
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/parents/children/:childId/login-code
// @desc    Generate a temporary login code for child (QR code login)
// @access  Private (Parent only)
router.post('/children/:childId/login-code', async (req, res) => {
  try {
    const { childId } = req.params;
    const { getSupabase } = require('../config/database');
    const supabase = await getSupabase();
    
    // Verify child belongs to parent
    const { data: parentChild, error: relationError } = await supabase
      .from('parent_children')
      .select('child_id')
      .eq('parent_id', req.user.id)
      .eq('child_id', childId)
      .single();

    if (relationError || !parentChild) {
      return res.status(403).json({ error: 'Child not found or not linked to this parent' });
    }
    
    // Generate a unique 6-digit code
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes from now
    
    // Store the login code in a temporary table (or use Redis in production)
    // For now, we'll store it in a simple in-memory cache or database table
    // In production, use Redis with expiration
    
    // Create a login_codes table entry (you'll need to add this to schema.sql)
    const { error: codeError } = await supabase
      .from('login_codes')
      .insert({
        code: code,
        child_id: childId,
        parent_id: req.user.id,
        expires_at: expiresAt.toISOString(),
        used: false
      });

    if (codeError) {
      console.error('Error creating login code:', codeError);
      return res.status(500).json({ error: 'Failed to generate login code' });
    }
    
    res.json({
      code: code,
      expiresAt: expiresAt.toISOString()
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;


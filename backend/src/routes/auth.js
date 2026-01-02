const express = require('express');
const { body, validationResult } = require('express-validator');
const { getSupabase } = require('../config/database');
const User = require('../models/User');
const { auth } = require('../middleware/auth');
const constants = require('../config/constants');
const { asyncHandler, createError } = require('../middleware/errorHandler');

const router = express.Router();

// @route   POST /api/auth/register
// @desc    Register a new user (kid or parent) using Supabase Auth
// @access  Public
router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: constants.MIN_PASSWORD_LENGTH, max: constants.MAX_PASSWORD_LENGTH })
    .withMessage(`Password must be between ${constants.MIN_PASSWORD_LENGTH} and ${constants.MAX_PASSWORD_LENGTH} characters`),
  body('userType').isIn(['kid', 'parent']),
  body('firstName').trim().notEmpty(),
  body('lastName').trim().notEmpty()
], asyncHandler(async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password, userType, firstName, lastName, displayName } = req.body;
    const supabase = getSupabase();

    // Check if user already exists in our users table
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Create user in Supabase Auth using admin API
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email: email.toLowerCase().trim(),
      password: password,
      email_confirm: true // Auto-confirm email (you can change this based on your needs)
    });

    if (authError) {
      console.error('Supabase Auth error:', authError);
      return res.status(400).json({ error: authError.message || 'Failed to create user' });
    }

    if (!authData.user) {
      return res.status(500).json({ error: 'Failed to create user account' });
    }

    // Create user profile in our users table
    try {
      const user = await User.create({
        id: authData.user.id, // Use Supabase Auth user ID
        email: authData.user.email,
        userType,
        profile: {
          firstName,
          lastName,
          displayName: displayName || `${firstName} ${lastName}`
        }
      });

      // Sign in to get session tokens
      // Note: We need to use a client instance with anon key for sign-in
      const { createClient } = require('@supabase/supabase-js');
      const anonKey = process.env.SUPABASE_ANON_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
      const supabaseClient = createClient(process.env.SUPABASE_URL, anonKey);
      
      const { data: signInData, error: signInError } = await supabaseClient.auth.signInWithPassword({
        email: email.toLowerCase().trim(),
        password: password
      });

      if (signInError || !signInData.session) {
        // If sign-in fails, user is created but we return the auth user ID
        // User will need to sign in manually
        return res.status(201).json({
          message: 'User created successfully. Please sign in.',
          user: {
            id: user.id,
            email: user.email,
            userType: user.userType,
            profile: user.profile,
            verification: user.verification
          }
        });
      }

      res.status(201).json({
        session: {
          access_token: signInData.session.access_token,
          refresh_token: signInData.session.refresh_token,
          expires_in: signInData.session.expires_in,
          expires_at: signInData.session.expires_at
        },
        user: {
          id: user.id,
          email: user.email,
          userType: user.userType,
          profile: user.profile,
          verification: user.verification
        }
      });
    } catch (profileError) {
      // If profile creation fails, try to delete the auth user
      await supabase.auth.admin.deleteUser(authData.user.id);
      console.error('Profile creation error:', profileError);
      return res.status(500).json({ error: 'Failed to create user profile' });
    }
}));

// @route   POST /api/auth/login
// @desc    Login user using Supabase Auth
// @access  Public
router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password } = req.body;
    
    // Use anon key for client-side auth operations
    const { createClient } = require('@supabase/supabase-js');
    const anonKey = process.env.SUPABASE_ANON_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
    const supabaseClient = createClient(process.env.SUPABASE_URL, anonKey);

    // Sign in with Supabase Auth
    const { data: authData, error: authError } = await supabaseClient.auth.signInWithPassword({
      email: email.toLowerCase().trim(),
      password: password
    });

    if (authError || !authData.user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Get user profile from our users table
    const user = await User.findById(authData.user.id);
    if (!user) {
      return res.status(404).json({ error: 'User profile not found' });
    }

    // Update last login
    await User.findByIdAndUpdate(user.id, { lastLogin: new Date() });

    res.json({
      session: {
        access_token: authData.session.access_token,
        refresh_token: authData.session.refresh_token,
        expires_in: authData.session.expires_in,
        expires_at: authData.session.expires_at
      },
      user: {
        id: user.id,
        email: user.email,
        userType: user.userType,
        profile: user.profile,
        verification: user.verification,
        isFullyVerified: user.isFullyVerified()
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error during login' });
  }
});

// @route   POST /api/auth/refresh
// @desc    Refresh access token using refresh token
// @access  Public
router.post('/refresh', [
  body('refresh_token').notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { refresh_token } = req.body;
    
    // Use anon key for client-side auth operations
    const { createClient } = require('@supabase/supabase-js');
    const anonKey = process.env.SUPABASE_ANON_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
    const supabaseClient = createClient(process.env.SUPABASE_URL, anonKey);

    const { data, error } = await supabaseClient.auth.refreshSession({
      refresh_token
    });

    if (error || !data.session) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    res.json({
      session: {
        access_token: data.session.access_token,
        refresh_token: data.session.refresh_token,
        expires_in: data.session.expires_in,
        expires_at: data.session.expires_at
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error during token refresh' });
  }
});

// @route   POST /api/auth/logout
// @desc    Logout user (revoke session)
// @access  Private
router.post('/logout', auth, async (req, res) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (token) {
      // Use anon key for client-side auth operations
      const { createClient } = require('@supabase/supabase-js');
      const anonKey = process.env.SUPABASE_ANON_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
      const supabaseClient = createClient(process.env.SUPABASE_URL, anonKey);
      
      // Sign out the user
      await supabaseClient.auth.signOut();
    }

    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error during logout' });
  }
});

// @route   GET /api/auth/me
// @desc    Get current user
// @access  Private
router.get('/me', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json({
      user: {
        id: user.id,
        email: user.email,
        userType: user.userType,
        profile: user.profile,
        verification: user.verification,
        isFullyVerified: user.isFullyVerified()
        // TODO: Add children and friends once relationships are implemented
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/auth/login-code
// @desc    Login using a QR code login code
// @access  Public
router.post('/login-code', [
  body('code').isLength({ min: 6, max: 6 }).isNumeric()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { code } = req.body;
    const { getSupabase } = require('../config/database');
    const supabase = await getSupabase();
    
    // Find the login code
    const { data: loginCodeData, error: codeError } = await supabase
      .from('login_codes')
      .select('*')
      .eq('code', code)
      .eq('used', false)
      .single();

    if (codeError || !loginCodeData) {
      return res.status(400).json({ error: 'Invalid or expired login code' });
    }
    
    // Check if code has expired
    const expiresAt = new Date(loginCodeData.expires_at);
    if (expiresAt < new Date()) {
      return res.status(400).json({ error: 'Login code has expired' });
    }
    
    // Get the child user
    const child = await User.findById(loginCodeData.child_id);
    if (!child) {
      return res.status(404).json({ error: 'Child account not found' });
    }
    
    // Mark code as used
    await supabase
      .from('login_codes')
      .update({ used: true, used_at: new Date().toISOString() })
      .eq('id', loginCodeData.id);
    
    // Get the child's Supabase Auth user
    const { data: authUser, error: authUserError } = await supabase.auth.admin.getUserById(child.id);
    
    if (authUserError || !authUser.user) {
      console.error('Error getting auth user:', authUserError);
      return res.status(500).json({ error: 'Failed to create session' });
    }
    
    // Create a session using Supabase Admin API
    // We'll use generateLink to create a magic link, then extract the token
    // Or we can create a custom JWT token for the user
    
    // For now, we'll create a session by generating a link and extracting the token
    // Actually, the best approach is to use Supabase's session creation via admin API
    // But since we need a proper session, let's create a custom JWT token
    
    // Use Supabase's JWT creation (via admin API)
    // The access_token should be a valid Supabase JWT token
    // For now, we'll return the user ID as a token and the client will need to handle it
    // In production, you'd want to use Supabase's proper session management
    
    // Create a proper Supabase JWT token using the JWT secret
    // This is the most reliable way to create a session token for code-based login
    const jwt = require('jsonwebtoken');
    
    // Get JWT secret from environment (Supabase JWT secret, not service role key)
    // This should be set in Supabase project settings -> API -> JWT Secret
    const jwtSecret = process.env.SUPABASE_JWT_SECRET;
    
    if (!jwtSecret) {
      console.error('SUPABASE_JWT_SECRET not configured. Cannot create session token for code-based login.');
      return res.status(500).json({ error: 'Server configuration error: JWT secret not found' });
    }
    
    // Create a Supabase-compatible JWT token
    // Supabase JWT format: { aud: 'authenticated', exp: timestamp, sub: user_id, ... }
    const now = Math.floor(Date.now() / 1000);
    const expiresIn = 3600; // 1 hour
    
    try {
      const accessToken = jwt.sign(
        {
          aud: 'authenticated',
          exp: now + expiresIn,
          iat: now,
          sub: child.id,
          email: child.email,
          role: 'authenticated',
          app_metadata: {},
          user_metadata: {}
        },
        jwtSecret,
        { algorithm: 'HS256' }
      );
      
      // Validate token format (should have 3 parts: header.payload.signature)
      const tokenParts = accessToken.split('.');
      if (tokenParts.length !== 3) {
        console.error('Created JWT token has invalid format:', tokenParts.length, 'parts');
        return res.status(500).json({ error: 'Failed to create valid session token' });
      }
      
      console.log('✅ Created JWT token for user:', child.id);
      console.log('   Token length:', accessToken.length);
      console.log('   Token parts:', tokenParts.length);
      console.log('   Token preview:', accessToken.substring(0, 50) + '...');
      
      // Update last login
      await User.findByIdAndUpdate(child.id, { lastLogin: new Date() });
      
      res.json({
        session: {
          access_token: accessToken,
          refresh_token: null, // Code-based login doesn't provide refresh token
          expires_in: expiresIn,
          expires_at: now + expiresIn
        },
        user: {
          id: child.id,
          email: child.email,
          userType: child.userType
        }
      });
      return;
    } catch (jwtError) {
      console.error('Error creating JWT token:', jwtError);
      return res.status(500).json({ error: 'Failed to create session token: ' + jwtError.message });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

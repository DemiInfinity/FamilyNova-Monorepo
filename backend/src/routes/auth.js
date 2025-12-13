const express = require('express');
const { body, validationResult } = require('express-validator');
const { getSupabase } = require('../config/database');
const User = require('../models/User');
const { auth } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/auth/register
// @desc    Register a new user (kid or parent) using Supabase Auth
// @access  Public
router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('userType').isIn(['kid', 'parent']),
  body('firstName').trim().notEmpty(),
  body('lastName').trim().notEmpty()
], async (req, res) => {
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
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error during registration' });
  }
});

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

module.exports = router;

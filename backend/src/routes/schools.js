const express = require('express');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const School = require('../models/School');
const User = require('../models/User');

const router = express.Router();

// Generate JWT token for schools
const generateToken = (schoolId) => {
  return jwt.sign({ schoolId }, process.env.JWT_SECRET || process.env.SUPABASE_JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d'
  });
};

// @route   POST /api/schools/register
// @desc    Register a new school
// @access  Public
router.post('/register', [
  body('name').trim().notEmpty(),
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('address').optional(),
  body('phone').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { name, email, password, address, phone, website } = req.body;
    
    // Check if school exists
    const existingSchool = await School.findByEmail(email);
    if (existingSchool) {
      return res.status(400).json({ error: 'School with this email already exists' });
    }
    
    // Check by name
    const { getSupabase } = require('../config/database');
    const supabase = await getSupabase();
    const { data: existingByName } = await supabase
      .from('schools')
      .select('id')
      .eq('name', name)
      .single();
    
    if (existingByName) {
      return res.status(400).json({ error: 'School with this name already exists' });
    }
    
    // Create school
    const school = await School.create({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password: password,
      address: address || null,
      contactPerson: null,
      phone: phone || null,
      website: website || null
    });
    
    const token = generateToken(school.id);
    
    res.status(201).json({
      token,
      school: {
        id: school.id,
        name: school.name,
        email: school.email,
        isVerified: school.isVerified
      }
    });
  } catch (error) {
    console.error('Error registering school:', error);
    res.status(500).json({ error: 'Server error during registration' });
  }
});

// @route   POST /api/schools/login
// @desc    Login school
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
    
    // Find school
    const school = await School.findByEmail(email);
    if (!school) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // Check password
    const isMatch = await school.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const token = generateToken(school.id);
    
    res.json({
      token,
      school: {
        id: school.id,
        name: school.name,
        email: school.email,
        isVerified: school.isVerified
      }
    });
  } catch (error) {
    console.error('Error logging in school:', error);
    res.status(500).json({ error: 'Server error during login' });
  }
});

module.exports = router;

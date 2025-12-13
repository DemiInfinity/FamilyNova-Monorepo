const express = require('express');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const School = require('../models/School');
const User = require('../models/User');

const router = express.Router();

// Generate JWT token for schools
const generateToken = (schoolId) => {
  return jwt.sign({ schoolId }, process.env.JWT_SECRET, {
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
  body('address.city').optional().trim(),
  body('address.state').optional().trim(),
  body('phone').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { name, email, password, address, phone, website, grades } = req.body;
    
    // Check if school exists
    const existingSchool = await School.findOne({ 
      $or: [{ email }, { name }] 
    });
    if (existingSchool) {
      return res.status(400).json({ error: 'School already exists' });
    }
    
    // Create school
    const school = new School({
      name,
      email,
      password,
      address: address || {},
      phone,
      website,
      grades: grades || []
    });
    
    await school.save();
    
    const token = generateToken(school._id);
    
    res.status(201).json({
      token,
      school: {
        id: school._id,
        name: school.name,
        email: school.email,
        isVerified: school.isVerified
      }
    });
  } catch (error) {
    console.error(error);
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
    const school = await School.findOne({ email });
    if (!school) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // Check password
    const isMatch = await school.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const token = generateToken(school._id);
    
    res.json({
      token,
      school: {
        id: school._id,
        name: school.name,
        email: school.email,
        isVerified: school.isVerified
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error during login' });
  }
});

module.exports = router;


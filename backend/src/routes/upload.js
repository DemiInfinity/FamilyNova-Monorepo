const express = require('express');
const multer = require('multer');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');
const { getSupabase } = require('../config/database');
const { ensureStorageBucket } = require('../utils/storage');

const router = express.Router();

// Configure multer for memory storage (we'll upload directly to Supabase)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    // Accept only images
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  }
});

// All routes require authentication
router.use(auth);

// @route   POST /api/upload/profile-picture
// @desc    Upload profile picture (avatar)
// @access  Private
router.post('/profile-picture', requireUserType('kid'), upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image file provided' });
    }

    const supabase = await getSupabase();
    const userId = req.user.id;
    
    // Ensure storage bucket exists
    const bucketCheck = await ensureStorageBucket();
    if (!bucketCheck.success) {
      console.error('Storage bucket check failed:', bucketCheck.error);
      return res.status(500).json({ 
        error: 'Storage bucket not available. Please contact support or create the bucket manually in Supabase Dashboard.',
        details: 'Bucket name: user-profiles'
      });
    }
    
    // Generate unique filename: userId/avatar-timestamp.jpg
    const timestamp = Date.now();
    const fileExtension = req.file.originalname.split('.').pop() || 'jpg';
    const fileName = `${userId}/avatar-${timestamp}.${fileExtension}`;
    const bucketName = 'user-profiles';

    // Upload to Supabase Storage
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from(bucketName)
      .upload(fileName, req.file.buffer, {
        contentType: req.file.mimetype,
        upsert: true // Replace if exists
      });

    if (uploadError) {
      console.error('Error uploading to Supabase Storage:', uploadError);
      return res.status(500).json({ error: 'Failed to upload image' });
    }

    // Get signed URL (valid for 1 year for profile images)
    const { data: signedUrlData, error: signedUrlError } = await supabase.storage
      .from(bucketName)
      .createSignedUrl(fileName, 31536000); // 1 year in seconds

    if (signedUrlError) {
      console.error('Error creating signed URL:', signedUrlError);
      return res.status(500).json({ error: 'Failed to generate image URL' });
    }

    const imageUrl = signedUrlData.signedUrl;

    // Update user profile with avatar URL
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const profile = user.profile || {};
    profile.avatar = imageUrl;

    user.profile = profile;
    await user.save();

    res.json({
      message: 'Profile picture uploaded successfully',
      avatarUrl: imageUrl
    });
  } catch (error) {
    console.error('Error uploading profile picture:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/upload/banner
// @desc    Upload profile banner
// @access  Private
router.post('/banner', requireUserType('kid'), upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image file provided' });
    }

    const supabase = await getSupabase();
    const userId = req.user.id;
    
    // Ensure storage bucket exists
    const bucketCheck = await ensureStorageBucket();
    if (!bucketCheck.success) {
      console.error('Storage bucket check failed:', bucketCheck.error);
      return res.status(500).json({ 
        error: 'Storage bucket not available. Please contact support or create the bucket manually in Supabase Dashboard.',
        details: 'Bucket name: user-profiles'
      });
    }
    
    // Generate unique filename: userId/banner-timestamp.jpg
    const timestamp = Date.now();
    const fileExtension = req.file.originalname.split('.').pop() || 'jpg';
    const fileName = `${userId}/banner-${timestamp}.${fileExtension}`;
    const bucketName = 'user-profiles';

    // Upload to Supabase Storage
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from(bucketName)
      .upload(fileName, req.file.buffer, {
        contentType: req.file.mimetype,
        upsert: true // Replace if exists
      });

    if (uploadError) {
      console.error('Error uploading to Supabase Storage:', uploadError);
      return res.status(500).json({ error: 'Failed to upload image' });
    }

    // Get signed URL (valid for 1 year for profile images)
    const { data: signedUrlData, error: signedUrlError } = await supabase.storage
      .from(bucketName)
      .createSignedUrl(fileName, 31536000); // 1 year in seconds

    if (signedUrlError) {
      console.error('Error creating signed URL:', signedUrlError);
      return res.status(500).json({ error: 'Failed to generate image URL' });
    }

    const imageUrl = signedUrlData.signedUrl;

    // Update user profile with banner URL
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const profile = user.profile || {};
    profile.banner = imageUrl;

    user.profile = profile;
    await user.save();

    res.json({
      message: 'Banner uploaded successfully',
      bannerUrl: imageUrl
    });
  } catch (error) {
    console.error('Error uploading banner:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/upload/post-image
// @desc    Upload image for a post
// @access  Private
router.post('/post-image', requireUserType('kid'), upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image file provided' });
    }

    const supabase = await getSupabase();
    const userId = req.user.id;
    
    // Ensure storage bucket exists
    const bucketCheck = await ensureStorageBucket();
    if (!bucketCheck.success) {
      console.error('Storage bucket check failed:', bucketCheck.error);
      return res.status(500).json({ 
        error: 'Storage bucket not available. Please contact support or create the bucket manually in Supabase Dashboard.',
        details: 'Bucket name: user-profiles'
      });
    }
    
    // Generate unique filename: userId/posts/post-timestamp.jpg
    const timestamp = Date.now();
    const fileExtension = req.file.originalname.split('.').pop() || 'jpg';
    const fileName = `${userId}/posts/post-${timestamp}.${fileExtension}`;
    const bucketName = 'user-profiles'; // Using same bucket, organized by folder

    // Upload to Supabase Storage
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from(bucketName)
      .upload(fileName, req.file.buffer, {
        contentType: req.file.mimetype,
        upsert: false
      });

    if (uploadError) {
      console.error('Error uploading to Supabase Storage:', uploadError);
      return res.status(500).json({ error: 'Failed to upload image' });
    }

    // Get signed URL (valid for 1 year for profile images)
    const { data: signedUrlData, error: signedUrlError } = await supabase.storage
      .from(bucketName)
      .createSignedUrl(fileName, 31536000); // 1 year in seconds

    if (signedUrlError) {
      console.error('Error creating signed URL:', signedUrlError);
      return res.status(500).json({ error: 'Failed to generate image URL' });
    }

    const imageUrl = signedUrlData.signedUrl;

    res.json({
      message: 'Image uploaded successfully',
      imageUrl: imageUrl
    });
  } catch (error) {
    console.error('Error uploading post image:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;


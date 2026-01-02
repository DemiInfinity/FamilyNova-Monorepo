const express = require('express');
const multer = require('multer');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');
const { getSupabase } = require('../config/database');
const { ensureStorageBucket } = require('../utils/storage');
const constants = require('../config/constants');
const { asyncHandler, createError } = require('../middleware/errorHandler');

const router = express.Router();

// File type validation using magic numbers (file signatures)
const validateFileType = (buffer) => {
  // Check file signature (magic numbers)
  const signatures = {
    'image/jpeg': [0xFF, 0xD8, 0xFF],
    'image/png': [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
    'image/gif': [0x47, 0x49, 0x46, 0x38],
    'image/webp': [0x52, 0x49, 0x46, 0x46] // RIFF header, need to check further
  };

  if (!buffer || buffer.length < 8) {
    return false;
  }

  // Check JPEG
  if (buffer[0] === 0xFF && buffer[1] === 0xD8 && buffer[2] === 0xFF) {
    return 'image/jpeg';
  }

  // Check PNG
  if (buffer[0] === 0x89 && buffer[1] === 0x50 && buffer[2] === 0x4E && buffer[3] === 0x47) {
    return 'image/png';
  }

  // Check GIF
  if (buffer[0] === 0x47 && buffer[1] === 0x49 && buffer[2] === 0x46 && buffer[3] === 0x38) {
    return 'image/gif';
  }

  // Check WebP (RIFF...WEBP)
  if (buffer[0] === 0x52 && buffer[1] === 0x49 && buffer[2] === 0x46 && buffer[3] === 0x46) {
    if (buffer.length >= 12) {
      const webpHeader = buffer.toString('ascii', 8, 12);
      if (webpHeader === 'WEBP') {
        return 'image/webp';
      }
    }
  }

  return false;
};

// Configure multer for memory storage (we'll upload directly to Supabase)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: constants.MAX_FILE_SIZE
  },
  fileFilter: (req, file, cb) => {
    // Initial MIME type check
    if (!constants.ALLOWED_IMAGE_TYPES.includes(file.mimetype)) {
      return cb(new Error('Only image files are allowed (JPEG, PNG, GIF, WebP)'), false);
    }
    cb(null, true);
  }
});

// All routes require authentication
router.use(auth);

// @route   POST /api/upload/profile-picture
// @desc    Upload profile picture (avatar)
// @access  Private
router.post('/profile-picture', requireUserType('kid', 'parent'), upload.single('image'), asyncHandler(async (req, res) => {
  if (!req.file) {
    throw createError('No image file provided', 400, 'NO_FILE');
  }

  // Validate file type using magic numbers
  const detectedType = validateFileType(req.file.buffer);
  if (!detectedType || !constants.ALLOWED_IMAGE_TYPES.includes(detectedType)) {
    throw createError('Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed.', 400, 'INVALID_FILE_TYPE');
  }

  // Verify MIME type matches detected type
  if (req.file.mimetype !== detectedType) {
    console.warn(`MIME type mismatch: declared ${req.file.mimetype}, detected ${detectedType}`);
    // Use detected type for security
    req.file.mimetype = detectedType;
  }

  const supabase = await getSupabase();
  const userId = req.user.id;
  
  // Ensure storage bucket exists
  const bucketCheck = await ensureStorageBucket();
  if (!bucketCheck.success) {
    throw createError(
      'Storage bucket not available. Please contact support.',
      500,
      'STORAGE_UNAVAILABLE',
      { bucketName: 'user-profiles' }
    );
  }
  
  // Generate unique filename: userId/avatar-timestamp.jpg
  const timestamp = Date.now();
  const fileExtension = detectedType.split('/')[1] || 'jpg';
  const fileName = `${userId}/avatar-${timestamp}.${fileExtension}`;
  const bucketName = 'user-profiles';

  // Upload to Supabase Storage
  const { data: uploadData, error: uploadError } = await supabase.storage
    .from(bucketName)
    .upload(fileName, req.file.buffer, {
      contentType: detectedType,
      upsert: true // Replace if exists
    });

  if (uploadError) {
    console.error('Error uploading to Supabase Storage:', uploadError);
    throw createError('Failed to upload image', 500, 'UPLOAD_FAILED');
  }

  // Get signed URL (valid for 1 year for profile images)
  const { data: signedUrlData, error: signedUrlError } = await supabase.storage
    .from(bucketName)
    .createSignedUrl(fileName, constants.ONE_YEAR_SECONDS);

  if (signedUrlError) {
    console.error('Error creating signed URL:', signedUrlError);
    throw createError('Failed to generate image URL', 500, 'URL_GENERATION_FAILED');
  }

  const imageUrl = signedUrlData.signedUrl;

  // Update user profile with avatar URL
  const user = await User.findById(userId);
  if (!user) {
    throw createError('User not found', 404, 'USER_NOT_FOUND');
  }

  const profile = user.profile || {};
  profile.avatar = imageUrl;

  user.profile = profile;
  await user.save();

  res.json({
    message: 'Profile picture uploaded successfully',
    avatarUrl: imageUrl
  });
}));

// @route   POST /api/upload/banner
// @desc    Upload profile banner
// @access  Private
router.post('/banner', requireUserType('kid', 'parent'), upload.single('image'), asyncHandler(async (req, res) => {
  if (!req.file) {
    throw createError('No image file provided', 400, 'NO_FILE');
  }

  // Validate file type using magic numbers
  const detectedType = validateFileType(req.file.buffer);
  if (!detectedType || !constants.ALLOWED_IMAGE_TYPES.includes(detectedType)) {
    throw createError('Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed.', 400, 'INVALID_FILE_TYPE');
  }

  // Verify MIME type matches detected type
  if (req.file.mimetype !== detectedType) {
    console.warn(`MIME type mismatch: declared ${req.file.mimetype}, detected ${detectedType}`);
    req.file.mimetype = detectedType;
  }

  const supabase = await getSupabase();
  const userId = req.user.id;
  
  // Ensure storage bucket exists
  const bucketCheck = await ensureStorageBucket();
  if (!bucketCheck.success) {
    throw createError(
      'Storage bucket not available. Please contact support.',
      500,
      'STORAGE_UNAVAILABLE',
      { bucketName: 'user-profiles' }
    );
  }
  
  // Generate unique filename: userId/banner-timestamp.jpg
  const timestamp = Date.now();
  const fileExtension = detectedType.split('/')[1] || 'jpg';
  const fileName = `${userId}/banner-${timestamp}.${fileExtension}`;
  const bucketName = 'user-profiles';

  // Upload to Supabase Storage
  const { data: uploadData, error: uploadError } = await supabase.storage
    .from(bucketName)
    .upload(fileName, req.file.buffer, {
      contentType: detectedType,
      upsert: true // Replace if exists
    });

  if (uploadError) {
    console.error('Error uploading to Supabase Storage:', uploadError);
    throw createError('Failed to upload image', 500, 'UPLOAD_FAILED');
  }

  // Get signed URL (valid for 1 year for profile images)
  const { data: signedUrlData, error: signedUrlError } = await supabase.storage
    .from(bucketName)
    .createSignedUrl(fileName, constants.ONE_YEAR_SECONDS);

  if (signedUrlError) {
    console.error('Error creating signed URL:', signedUrlError);
    throw createError('Failed to generate image URL', 500, 'URL_GENERATION_FAILED');
  }

  const imageUrl = signedUrlData.signedUrl;

  // Update user profile with banner URL
  const user = await User.findById(userId);
  if (!user) {
    throw createError('User not found', 404, 'USER_NOT_FOUND');
  }

  const profile = user.profile || {};
  profile.banner = imageUrl;

  user.profile = profile;
  await user.save();

  res.json({
    message: 'Banner uploaded successfully',
    bannerUrl: imageUrl
  });
}));

// @route   POST /api/upload/post-image
// @desc    Upload image for a post
// @access  Private
router.post('/post-image', requireUserType('kid', 'parent'), upload.single('image'), asyncHandler(async (req, res) => {
  if (!req.file) {
    throw createError('No image file provided', 400, 'NO_FILE');
  }

  // Validate file type using magic numbers
  const detectedType = validateFileType(req.file.buffer);
  if (!detectedType || !constants.ALLOWED_IMAGE_TYPES.includes(detectedType)) {
    throw createError('Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed.', 400, 'INVALID_FILE_TYPE');
  }

  // Verify MIME type matches detected type
  if (req.file.mimetype !== detectedType) {
    console.warn(`MIME type mismatch: declared ${req.file.mimetype}, detected ${detectedType}`);
    req.file.mimetype = detectedType;
  }

  const supabase = await getSupabase();
  const userId = req.user.id;
  
  // Ensure storage bucket exists
  const bucketCheck = await ensureStorageBucket();
  if (!bucketCheck.success) {
    throw createError(
      'Storage bucket not available. Please contact support.',
      500,
      'STORAGE_UNAVAILABLE',
      { bucketName: 'user-profiles' }
    );
  }
  
  // Generate unique filename: userId/posts/post-timestamp.jpg
  const timestamp = Date.now();
  const fileExtension = detectedType.split('/')[1] || 'jpg';
  const fileName = `${userId}/posts/post-${timestamp}.${fileExtension}`;
  const bucketName = 'user-profiles'; // Using same bucket, organized by folder

  // Upload to Supabase Storage
  const { data: uploadData, error: uploadError } = await supabase.storage
    .from(bucketName)
    .upload(fileName, req.file.buffer, {
      contentType: detectedType,
      upsert: false
    });

  if (uploadError) {
    console.error('Error uploading to Supabase Storage:', uploadError);
    throw createError('Failed to upload image', 500, 'UPLOAD_FAILED');
  }

  // Get signed URL (valid for 1 year for profile images)
  const { data: signedUrlData, error: signedUrlError } = await supabase.storage
    .from(bucketName)
    .createSignedUrl(fileName, constants.ONE_YEAR_SECONDS);

  if (signedUrlError) {
    console.error('Error creating signed URL:', signedUrlError);
    throw createError('Failed to generate image URL', 500, 'URL_GENERATION_FAILED');
  }

  const imageUrl = signedUrlData.signedUrl;

  res.json({
    message: 'Image uploaded successfully',
    imageUrl: imageUrl
  });
}));

module.exports = router;


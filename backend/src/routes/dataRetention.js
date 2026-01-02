const express = require('express');
const { auth, requireUserType } = require('../middleware/auth');
const { createError, asyncHandler } = require('../middleware/errorHandler');
const { cleanupExpiredData, getRetentionStats, RETENTION_POLICIES } = require('../utils/dataRetention');

const router = express.Router();

// Admin only routes
router.use(auth);
router.use(requireUserType('parent')); // Only parents/admins can manage retention

// @route   POST /api/data-retention/cleanup
// @desc    Manually trigger data retention cleanup
// @access  Private (Admin/Parent only)
router.post('/cleanup', asyncHandler(async (req, res) => {
  const result = await cleanupExpiredData();
  
  res.json({
    message: 'Data retention cleanup completed',
    success: result.success,
    errors: result.errors,
    timestamp: result.timestamp
  });
}));

// @route   GET /api/data-retention/stats
// @desc    Get data retention statistics
// @access  Private (Admin/Parent only)
router.get('/stats', asyncHandler(async (req, res) => {
  const stats = await getRetentionStats();
  
  res.json({
    stats: stats,
    policies: RETENTION_POLICIES
  });
}));

module.exports = router;


const express = require('express');
const { auth, requireUserType } = require('../middleware/auth');
const { createError, asyncHandler } = require('../middleware/errorHandler');
const { getSupabase } = require('../config/database');
const { body, validationResult } = require('express-validator');

const router = express.Router();

router.use(auth);

// @route   GET /api/consent/status
// @desc    Get user's consent status
// @access  Private
router.get('/status', requireUserType('kid', 'parent'), asyncHandler(async (req, res) => {
  const supabase = getSupabase();
  const userId = req.user.id;

  const { data: consent, error } = await supabase
    .from('consents')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(1)
    .single();

  if (error && error.code !== 'PGRST116') { // PGRST116 = no rows returned
    throw createError('Failed to fetch consent status', 500, 'CONSENT_FETCH_FAILED');
  }

  res.json({
    consent: consent || null,
    hasConsented: consent ? consent.status === 'accepted' : false,
    lastUpdated: consent?.updated_at || null
  });
}));

// @route   POST /api/consent
// @desc    Record user consent
// @access  Private
router.post('/', requireUserType('kid', 'parent'), [
  body('consentType').isIn(['data_processing', 'marketing', 'analytics', 'cookies']).withMessage('Invalid consent type'),
  body('status').isIn(['accepted', 'rejected', 'withdrawn']).withMessage('Invalid consent status')
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw createError('Validation failed', 400, 'VALIDATION_ERROR', errors.array());
  }

  const supabase = getSupabase();
  const userId = req.user.id;
  const { consentType, status, purpose, legalBasis } = req.body;

  // Check if consent already exists
  const { data: existingConsent } = await supabase
    .from('consents')
    .select('*')
    .eq('user_id', userId)
    .eq('consent_type', consentType)
    .order('created_at', { ascending: false })
    .limit(1)
    .single();

  if (existingConsent && existingConsent.status === status) {
    return res.json({
      message: 'Consent already recorded',
      consent: existingConsent
    });
  }

  // Create new consent record
  const { data: consent, error } = await supabase
    .from('consents')
    .insert({
      user_id: userId,
      consent_type: consentType,
      status: status,
      purpose: purpose || `User ${status} consent for ${consentType}`,
      legal_basis: legalBasis || 'consent',
      ip_address: req.ip,
      user_agent: req.get('user-agent')
    })
    .select()
    .single();

  if (error) {
    throw createError('Failed to record consent', 500, 'CONSENT_RECORD_FAILED');
  }

  res.status(201).json({
    message: 'Consent recorded successfully',
    consent: consent
  });
}));

// @route   PUT /api/consent/:consentId/withdraw
// @desc    Withdraw consent
// @access  Private
router.put('/:consentId/withdraw', requireUserType('kid', 'parent'), asyncHandler(async (req, res) => {
  const supabase = getSupabase();
  const userId = req.user.id;
  const { consentId } = req.params;

  // Verify consent belongs to user
  const { data: consent, error: fetchError } = await supabase
    .from('consents')
    .select('*')
    .eq('id', consentId)
    .eq('user_id', userId)
    .single();

  if (fetchError || !consent) {
    throw createError('Consent not found', 404, 'CONSENT_NOT_FOUND');
  }

  // Update consent status to withdrawn
  const { data: updatedConsent, error: updateError } = await supabase
    .from('consents')
    .update({
      status: 'withdrawn',
      withdrawn_at: new Date().toISOString()
    })
    .eq('id', consentId)
    .select()
    .single();

  if (updateError) {
    throw createError('Failed to withdraw consent', 500, 'CONSENT_WITHDRAW_FAILED');
  }

  res.json({
    message: 'Consent withdrawn successfully',
    consent: updatedConsent
  });
}));

// @route   GET /api/consent/history
// @desc    Get user's consent history
// @access  Private
router.get('/history', requireUserType('kid', 'parent'), asyncHandler(async (req, res) => {
  const supabase = getSupabase();
  const userId = req.user.id;

  const { data: consents, error } = await supabase
    .from('consents')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) {
    throw createError('Failed to fetch consent history', 500, 'CONSENT_HISTORY_FAILED');
  }

  res.json({
    consents: consents || [],
    count: consents?.length || 0
  });
}));

module.exports = router;


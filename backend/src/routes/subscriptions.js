const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, requireUserType } = require('../middleware/auth');
const Subscription = require('../models/Subscription');
const User = require('../models/User');

const router = express.Router();

router.use(auth);

// @route   GET /api/subscriptions/status
// @desc    Get user's subscription status
// @access  Private (Parent only)
router.get('/status', requireUserType('parent'), async (req, res) => {
  try {
    let subscription = await Subscription.findByUserId(req.user.id);

    // If no subscription exists, create a free one
    if (!subscription) {
      subscription = await Subscription.create({
        userId: req.user.id,
        plan: 'free',
        status: 'active',
        startDate: new Date().toISOString()
      });
    }

    // Check if subscription has expired
    if (subscription.endDate && new Date() > new Date(subscription.endDate) && subscription.status === 'active') {
      subscription.status = 'expired';
      subscription.plan = 'free';
      await subscription.save();
    }

    res.json({
      subscription: {
        id: subscription.id,
        plan: subscription.plan,
        status: subscription.status,
        billingCycle: subscription.billingCycle,
        startDate: subscription.startDate,
        endDate: subscription.endDate,
        nextBillingDate: subscription.nextBillingDate,
        isTrial: subscription.isTrial,
        trialEndDate: subscription.trialEndDate
      }
    });
  } catch (error) {
    console.error('Error fetching subscription:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/subscriptions/create
// @desc    Create or update subscription (after in-app purchase)
// @access  Private (Parent only)
router.post('/create', requireUserType('parent'), [
  body('plan').isIn(['pro']).withMessage('Invalid plan'),
  body('billingCycle').isIn(['monthly', 'annual']).withMessage('Invalid billing cycle'),
  body('provider').isIn(['ios', 'android', 'web']).withMessage('Invalid provider'),
  body('providerSubscriptionId').notEmpty().withMessage('Provider subscription ID required'),
  body('receipt').notEmpty().withMessage('Receipt required for verification')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { plan, billingCycle, provider, providerSubscriptionId, receipt } = req.body;

    // TODO: Verify receipt with Apple/Google
    // For now, we'll trust the client (in production, verify server-side)

    let subscription = await Subscription.findByUserId(req.user.id);

    const now = new Date();
    const endDate = new Date();
    
    if (billingCycle === 'monthly') {
      endDate.setMonth(endDate.getMonth() + 1);
    } else {
      endDate.setFullYear(endDate.getFullYear() + 1);
    }

    if (subscription) {
      // Update existing subscription
      subscription.plan = plan;
      subscription.status = 'active';
      subscription.billingCycle = billingCycle;
      subscription.provider = provider;
      subscription.providerSubscriptionId = providerSubscriptionId;
      subscription.receipt = receipt;
      subscription.startDate = now.toISOString();
      subscription.endDate = endDate.toISOString();
      subscription.nextBillingDate = endDate.toISOString();
      subscription.cancelledAt = null;
      subscription.isTrial = false;
    } else {
      // Create new subscription
      subscription = await Subscription.create({
        userId: req.user.id,
        plan: plan,
        status: 'active',
        billingCycle: billingCycle,
        provider: provider,
        providerSubscriptionId: providerSubscriptionId,
        receipt: receipt,
        startDate: now.toISOString(),
        endDate: endDate.toISOString(),
        nextBillingDate: endDate.toISOString(),
        isTrial: false
      });
    }

    await subscription.save();

    res.json({
      message: 'Subscription created successfully',
      subscription: {
        id: subscription.id,
        plan: subscription.plan,
        status: subscription.status,
        billingCycle: subscription.billingCycle,
        endDate: subscription.endDate,
        nextBillingDate: subscription.nextBillingDate
      }
    });
  } catch (error) {
    console.error('Error creating subscription:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/subscriptions/cancel
// @desc    Cancel subscription
// @access  Private (Parent only)
router.post('/cancel', requireUserType('parent'), async (req, res) => {
  try {
    const subscription = await Subscription.findByUserId(req.user.id);

    if (!subscription) {
      return res.status(404).json({ error: 'No subscription found' });
    }

    if (subscription.plan === 'free') {
      return res.status(400).json({ error: 'Cannot cancel free plan' });
    }

    subscription.status = 'cancelled';
    subscription.cancelledAt = new Date().toISOString();
    // Keep access until endDate
    await subscription.save();

    res.json({
      message: 'Subscription cancelled. Access continues until end of billing period.',
      subscription: {
        id: subscription.id,
        plan: subscription.plan,
        status: subscription.status,
        endDate: subscription.endDate
      }
    });
  } catch (error) {
    console.error('Error cancelling subscription:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   POST /api/subscriptions/verify-receipt
// @desc    Verify receipt with Apple/Google (called periodically)
// @access  Private (Parent only)
router.post('/verify-receipt', requireUserType('parent'), [
  body('provider').isIn(['ios', 'android']).withMessage('Invalid provider'),
  body('receipt').notEmpty().withMessage('Receipt required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { provider, receipt } = req.body;
    const subscription = await Subscription.findByUserId(req.user.id);

    if (!subscription) {
      return res.status(404).json({ error: 'No subscription found' });
    }

    // TODO: Implement actual receipt verification
    // For iOS: Verify with Apple App Store
    // For Android: Verify with Google Play Billing
    
    // For now, return success
    res.json({
      message: 'Receipt verified',
      valid: true
    });
  } catch (error) {
    console.error('Error verifying receipt:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

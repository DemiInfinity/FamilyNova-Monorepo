const mongoose = require('mongoose');

const subscriptionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true // One subscription per user
  },
  plan: {
    type: String,
    enum: ['free', 'pro'],
    default: 'free'
  },
  status: {
    type: String,
    enum: ['active', 'cancelled', 'expired', 'trial'],
    default: 'active'
  },
  billingCycle: {
    type: String,
    enum: ['monthly', 'annual'],
    default: 'monthly'
  },
  startDate: {
    type: Date,
    default: Date.now
  },
  endDate: Date,
  nextBillingDate: Date,
  cancelledAt: Date,
  // Payment provider information
  provider: {
    type: String,
    enum: ['ios', 'android', 'web'],
    default: null
  },
  providerSubscriptionId: String, // StoreKit subscription ID or Google Play purchase token
  receipt: String, // Store receipt for verification
  // Trial information
  isTrial: {
    type: Boolean,
    default: false
  },
  trialEndDate: Date
}, {
  timestamps: true
});

// Index for efficient queries
subscriptionSchema.index({ user: 1 });
subscriptionSchema.index({ status: 1 });
subscriptionSchema.index({ endDate: 1 });

module.exports = mongoose.model('Subscription', subscriptionSchema);


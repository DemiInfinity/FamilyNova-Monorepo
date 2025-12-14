const express = require('express');
const { getSupabase } = require('../config/database');
const User = require('../models/User');

const router = express.Router();

// Webhook endpoint for Supabase database changes
// This should be called by Supabase when a new friendship is created
// Configure in Supabase Dashboard: Database > Webhooks > New Webhook
// URL: https://your-api-url.com/api/webhooks/friend-request
// Event: INSERT on friendships table
// Filter: status = 'pending'

// @route   POST /api/webhooks/friend-request
// @desc    Webhook triggered when a new friend request is created
// @access  Public (should be secured with webhook secret in production)
router.post('/friend-request', async (req, res) => {
  try {
    // Supabase webhook payload structure
    const { type, table, record, old_record } = req.body;
    
    // Only process INSERT events for pending friend requests
    if (type !== 'INSERT' || table !== 'friendships' || record.status !== 'pending') {
      return res.status(200).json({ message: 'Event not relevant' });
    }
    
    const friendId = record.friend_id; // The user who should receive the notification
    const requesterId = record.user_id; // The user who sent the request
    
    console.log(`[Webhook] Friend request created: ${requesterId} -> ${friendId}`);
    
    // Get requester's profile for notification
    const requester = await User.findById(requesterId);
    if (!requester) {
      console.error(`[Webhook] Requester not found: ${requesterId}`);
      return res.status(200).json({ message: 'Requester not found' });
    }
    
    const requesterProfile = requester.profile || {};
    const requesterName = requesterProfile.displayName || requester.email;
    
    // TODO: Send push notification to friendId
    // For now, we'll need to:
    // 1. Store FCM/APNS tokens in the database
    // 2. Send push notification using Firebase Cloud Messaging or Apple Push Notification Service
    // 3. The app will receive the notification and can refresh friend requests
    
    console.log(`[Webhook] Would send push notification to ${friendId} about friend request from ${requesterName}`);
    
    // Return success immediately (don't wait for push notification)
    res.status(200).json({ 
      message: 'Webhook processed',
      friendId,
      requesterName
    });
  } catch (error) {
    console.error('[Webhook] Error processing friend request webhook:', error);
    // Return 200 to prevent Supabase from retrying
    res.status(200).json({ error: 'Webhook processing failed' });
  }
});

module.exports = router;


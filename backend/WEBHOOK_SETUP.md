# Webhook Setup for Friend Requests

Instead of constantly polling for friend requests, we use Supabase database webhooks to get real-time notifications when friend requests are created.

## Setup Instructions

### 1. Configure Supabase Database Webhook

1. Go to your Supabase Dashboard
2. Navigate to **Database** > **Webhooks**
3. Click **New Webhook**
4. Configure the webhook:
   - **Name**: Friend Request Webhook
   - **Table**: `friendships`
   - **Events**: Select **INSERT**
   - **HTTP Request**:
     - **URL**: `https://your-api-url.com/api/webhooks/friend-request`
     - **Method**: POST
     - **HTTP Headers**: (Optional) Add a secret header for security:
       ```
       X-Webhook-Secret: your-secret-key-here
       ```
   - **Filter**: Add a filter to only trigger for pending requests:
     ```sql
     status = 'pending'
     ```

### 2. Update Webhook Endpoint Security (Recommended)

In `backend/src/routes/webhooks.js`, add webhook secret verification:

```javascript
// Add at the top of the webhook handler
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET;
const providedSecret = req.headers['x-webhook-secret'];

if (WEBHOOK_SECRET && providedSecret !== WEBHOOK_SECRET) {
  return res.status(401).json({ error: 'Unauthorized' });
}
```

### 3. Push Notifications (Future Enhancement)

Currently, the webhook logs the event. To send push notifications:

1. Store FCM/APNS tokens in the database when users log in
2. When webhook fires, look up the recipient's push token
3. Send push notification using Firebase Cloud Messaging or Apple Push Notification Service
4. The app will receive the notification and can refresh friend requests

### 4. Fallback Polling

The iOS app still polls every 30 seconds as a fallback, but this is much more efficient than the previous 4-second interval. Once push notifications are implemented, polling can be reduced further or eliminated.

## Benefits

- **Real-time**: Friend requests are detected immediately when created
- **Efficient**: No constant polling, only triggered on actual events
- **Scalable**: Works well even with many users
- **Battery-friendly**: Reduces unnecessary network requests on mobile devices

## Testing

To test the webhook:

1. Send a friend request via the API
2. Check your server logs for the webhook event
3. Verify the webhook endpoint receives the payload correctly


# Postman Testing Instructions for Parents Dashboard

## Quick Setup

1. **Import the Collection**
   - Open Postman
   - Click "Import" button
   - Select `postman_test_parents_dashboard.json`
   - The collection will be imported with 3 requests

2. **Set Environment Variables**
   - In Postman, click on "Environments" (left sidebar)
   - Create a new environment or use "Globals"
   - Set these variables:
     - `base_url`: Your backend URL 
       - **Production**: `https://family-nova-monorepo.vercel.app`
       - **Local**: `http://localhost:3000`
     - `auth_token`: Leave empty (will be auto-filled after login)

3. **Update Login Credentials**
   - Open the "1. Login as Parent (Get Token)" request
   - In the Body tab, replace:
     - `YOUR_PARENT_EMAIL@example.com` with your actual parent email
     - `YOUR_PASSWORD` with your actual password

## Running the Tests

### Step 1: Login
1. Select "1. Login as Parent (Get Token)"
2. Click "Send"
3. Check the response - you should get a token
4. The token will be automatically saved to `auth_token` variable

### Step 2: Get Dashboard
1. Select "2. Get Parents Dashboard"
2. Click "Send"
3. Check the **Console** (View → Show Postman Console) for detailed logs
4. The test script will log:
   - Parent ID
   - Number of children found
   - Details of each child (ID, name, avatar, school, grade, verification status)
   - Full response JSON

### Step 3: Check Profile (Alternative)
1. Select "3. Check Parent Children Table (Direct DB Query)"
2. Click "Send"
3. Compare the children array with the dashboard response

## What to Look For

### If Children Are Empty:
- Check backend logs for:
  - `[Dashboard] Fetching children for parent: [parent-id]`
  - `[Dashboard] Found X parent_children relationships`
  - `[Dashboard] No children in parent_children table, checking parent_account_id...`
  - `[Dashboard] Found X children via parent_account_id`

### Common Issues:

1. **No Token**: Make sure Step 1 (Login) completed successfully
2. **401 Unauthorized**: Token expired or invalid - re-run Step 1
3. **403 Forbidden**: User is not a parent type - check user_type in database
4. **Empty Children Array**: 
   - Check if `parent_children` table has entries for this parent
   - Check if children have `parent_account_id` set to parent's ID
   - Check backend console logs for detailed debugging info

## Expected Response Format

```json
{
  "parent": {
    "id": "parent-uuid",
    "profile": {
      "firstName": "...",
      "lastName": "...",
      "displayName": "...",
      "avatar": "..."
    },
    "children": [
      {
        "id": "child-uuid",
        "profile": {
          "displayName": "Child Name",
          "avatar": "url-or-null",
          "school": "School Name",
          "grade": "Grade Level"
        },
        "verification": {
          "parentVerified": true,
          "schoolVerified": false
        },
        "lastLogin": "2024-01-01T00:00:00.000Z"
      }
    ],
    "parentConnections": []
  },
  "recentActivity": []
}
```

## Debugging Tips

1. **Check Backend Logs**: The endpoint has extensive logging. Look for:
   - `[Dashboard] Fetching children for parent: ...`
   - `[Dashboard] Found X parent_children relationships`
   - `[Dashboard] Returning X children for parent ...`

2. **Verify Database**:
   - Check `parent_children` table: `SELECT * FROM parent_children WHERE parent_id = 'your-parent-id';`
   - Check `users` table: `SELECT id, parent_account_id, user_type FROM users WHERE parent_account_id = 'your-parent-id';`

3. **Check Token**: 
   - In Postman, go to the "Authorization" tab of the dashboard request
   - Make sure it shows `Bearer {{auth_token}}`
   - The token should be a JWT (three parts separated by dots)

4. **Test with Different Parent Account**: 
   - Try logging in with a different parent account
   - See if the issue is account-specific or global


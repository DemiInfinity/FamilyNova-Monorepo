# Supabase Auth Migration Guide

The authentication system has been migrated from custom JWT to Supabase Auth.

## What Changed

### Before (Custom JWT)
- Passwords hashed with bcrypt and stored in `users` table
- Custom JWT tokens generated with `jsonwebtoken`
- Manual password verification

### After (Supabase Auth)
- Passwords managed by Supabase Auth (stored in `auth.users`)
- Supabase session tokens (access_token + refresh_token)
- Automatic password hashing and verification
- Built-in email verification support
- Password reset flows available

## Key Changes

### 1. Database Schema
- `users.id` now references `auth.users(id)` (Supabase Auth user ID)
- `password` field is optional (kept for backward compatibility but not used)
- Users must be created in Supabase Auth first, then profile created in `users` table

### 2. Authentication Routes

#### Registration (`POST /api/auth/register`)
- Creates user in Supabase Auth using `supabase.auth.admin.createUser()`
- Then creates profile in `users` table with the Auth user ID
- Returns Supabase session tokens instead of custom JWT

#### Login (`POST /api/auth/login`)
- Uses `supabase.auth.signInWithPassword()`
- Returns Supabase session tokens
- Still fetches user profile from `users` table

#### New: Token Refresh (`POST /api/auth/refresh`)
- Allows refreshing access tokens using refresh tokens
- Uses `supabase.auth.refreshSession()`

#### New: Logout (`POST /api/auth/logout`)
- Revokes the current session
- Uses `supabase.auth.signOut()`

### 3. Middleware
- `auth` middleware now verifies Supabase tokens using `supabase.auth.getUser()`
- Still fetches user profile from `users` table
- Maintains backward compatibility with `req.user._id`

### 4. User Model
- `create()` method no longer hashes passwords (handled by Supabase Auth)
- `comparePassword()` method deprecated (throws error if called)
- User ID must be provided (from Supabase Auth)

## API Response Changes

### Registration/Login Response
```json
{
  "session": {
    "access_token": "...",
    "refresh_token": "...",
    "expires_in": 3600,
    "expires_at": 1234567890
  },
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "userType": "parent",
    "profile": {...},
    "verification": {...}
  }
}
```

### Using the Tokens
- Send `access_token` in `Authorization: Bearer <token>` header
- Use `refresh_token` to get new access tokens when they expire
- Tokens expire after the time specified in `expires_in` (usually 3600 seconds)

## Mobile App Updates Required

### iOS Apps
Update `ApiService.swift` to:
1. Store `access_token` and `refresh_token` from session
2. Use `access_token` in `Authorization` header
3. Implement token refresh when `access_token` expires
4. Handle 401 responses by refreshing token

### Android Apps
Update `ApiClient.java` to:
1. Store session tokens
2. Use `access_token` in requests
3. Implement token refresh logic
4. Handle token expiration

## Environment Variables

Ensure these are set in your `.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key  # For admin operations
SUPABASE_ANON_KEY=your_anon_key  # For client operations
```

**Important**: The `SUPABASE_SERVICE_ROLE_KEY` is required for:
- Creating users via `admin.createUser()`
- Other admin operations

The `SUPABASE_ANON_KEY` is used for:
- Regular sign-in operations
- Token verification

## Migration Steps for Existing Users

If you have existing users with bcrypt passwords:

1. **Option 1**: Force password reset
   - Users must reset their password through Supabase Auth
   - This will create them in `auth.users` table

2. **Option 2**: Migrate passwords (if possible)
   - Export existing users
   - Create them in Supabase Auth with same passwords
   - Link `users.id` to `auth.users.id`

3. **Option 3**: One-time migration script
   - Create script to migrate existing users
   - Hash passwords match Supabase Auth format (if compatible)

## Testing

Test the new auth flow:

```bash
# Register
curl -X POST https://family-nova-monorepo.vercel.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123456",
    "userType": "parent",
    "firstName": "Test",
    "lastName": "User"
  }'

# Login
curl -X POST https://family-nova-monorepo.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123456"
  }'

# Use access_token
curl https://family-nova-monorepo.vercel.app/api/auth/me \
  -H "Authorization: Bearer <access_token>"
```

## Benefits

✅ **Security**: Supabase handles password security best practices
✅ **Email Verification**: Built-in support
✅ **Password Reset**: Ready to implement
✅ **OAuth**: Can add Google, Apple, etc. easily
✅ **Session Management**: Automatic token refresh
✅ **Rate Limiting**: Built-in protection
✅ **Audit Logs**: Supabase tracks auth events

## Next Steps

1. Update mobile apps to use new session tokens
2. Implement token refresh logic in apps
3. Add email verification flow (optional)
4. Add password reset functionality
5. Consider adding OAuth providers


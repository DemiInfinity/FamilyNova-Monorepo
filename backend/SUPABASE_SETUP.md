# Supabase Backend Setup

## ✅ Completed

1. **Dependencies Updated**
   - Removed `mongoose`
   - Added `@supabase/supabase-js` and `pg`
   - Dependencies installed successfully

2. **Database Connection**
   - Updated `src/config/database.js` to use Supabase client
   - Connection uses `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY`

3. **Database Schema**
   - Created `src/db/schema.sql` with all required tables:
     - users
     - schools
     - messages
     - posts
     - profile_change_requests
     - education_content
     - school_codes
     - subscriptions
     - parent_children (junction table)
     - friendships (junction table)
     - parent_connections (junction table)

4. **User Model**
   - Converted from Mongoose to Supabase-based class model
   - Methods: `findById`, `findByEmail`, `create`, `save`, `comparePassword`, `isFullyVerified`
   - Static methods: `findByIdAndUpdate`, `find`, `findOne`

5. **Auth Routes & Middleware**
   - Updated to use new User model
   - JWT token generation uses `userId` from decoded token
   - Backward compatibility: `req.user._id` maps to `req.user.id`

6. **Environment Variables**
   - Created `.env.example` with all required Supabase credentials
   - Your actual `.env` file should contain the provided credentials

## ⚠️ Next Steps Required

### 1. Run Database Schema
Execute the SQL schema in your Supabase dashboard:
1. Go to https://supabase.com/dashboard
2. Select your project
3. Navigate to **SQL Editor**
4. Copy and paste contents of `src/db/schema.sql`
5. Click **Run**

### 2. Update Remaining Models
The following models still need conversion from Mongoose to Supabase:
- [ ] `Message.js`
- [ ] `Post.js`
- [ ] `School.js`
- [ ] `ProfileChangeRequest.js`
- [ ] `EducationContent.js`
- [ ] `SchoolCode.js`
- [ ] `Subscription.js`

### 3. Update Routes
All routes need to be updated to use Supabase queries:
- [ ] `routes/parents.js` - Update all User queries
- [ ] `routes/messages.js` - Convert Message model and queries
- [ ] `routes/posts.js` - Convert Post model and queries
- [ ] `routes/schools.js` - Convert School model and queries
- [ ] `routes/profileChanges.js` - Convert ProfileChangeRequest model
- [ ] `routes/education.js` - Convert EducationContent model
- [ ] `routes/schoolCodes.js` - Convert SchoolCode model
- [ ] `routes/subscriptions.js` - Convert Subscription model
- [ ] `routes/friends.js` - Update friendship queries
- [ ] `routes/verification.js` - Update verification queries
- [ ] `routes/kids.js` - Update kid-specific queries

### 4. Update Relationship Queries
Many routes use Mongoose `.populate()` which needs to be replaced with Supabase joins:
- Parent-children relationships
- Friend relationships
- School relationships
- Message sender/receiver relationships

### 5. Test API Endpoints
After conversion, test all endpoints:
- Authentication (register, login, me)
- User management
- Messages
- Posts
- Schools
- Subscriptions

## Environment Variables

Your `.env` file should contain:

```env
SUPABASE_URL=https://gchzrdozswfiisjusknx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_JWT_SECRET=fODiW8XB6yV2Cj8RMTz34LanzWqlvrDVASjVznqAIN55Vy93b8aY1Hyz9+q3NG9CDZPguIdGieBl6n6l7EBl7Q==
JWT_SECRET=fODiW8XB6yV2Cj8RMTz34LanzWqlvrDVASjVznqAIN55Vy93b8aY1Hyz9+q3NG9CDZPguIdGieBl6n6l7EBl7Q==
PORT=3000
```

## Key Differences: Mongoose → Supabase

### Queries
```javascript
// Mongoose
User.findById(id)
User.findOne({ email })
user.save()

// Supabase
User.findById(id)
User.findByEmail(email)
await user.save()
```

### Relationships
```javascript
// Mongoose
.populate('children')
.populate('friends')

// Supabase
// Use joins or separate queries
const { data } = await supabase
  .from('parent_children')
  .select('*, child:users!child_id(*)')
  .eq('parent_id', parentId)
```

### IDs
- Mongoose uses `_id` (ObjectId)
- Supabase uses `id` (UUID)
- Backward compatibility: `req.user._id` maps to `req.user.id`

## Testing

After setup, test the connection:

```bash
cd backend
npm start
```

Check the console for:
```
✅ Supabase Connected: https://gchzrdozswfiisjusknx.supabase.co
🚀 FamilyNova API server running on port 3000
```

Then test an endpoint:
```bash
curl http://localhost:3000/api/health
```


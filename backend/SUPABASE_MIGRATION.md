# Supabase Migration Guide

This document explains how to migrate from MongoDB to Supabase (PostgreSQL).

## Setup Steps

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Create Database Schema

Run the SQL schema in `src/db/schema.sql` in your Supabase SQL Editor:

1. Go to your Supabase dashboard
2. Navigate to SQL Editor
3. Copy and paste the contents of `src/db/schema.sql`
4. Execute the SQL

### 3. Configure Environment Variables

Copy `.env.example` to `.env` and fill in your Supabase credentials:

```bash
cp .env.example .env
```

Update the `.env` file with your Supabase credentials.

### 4. Update Models

All models have been converted from Mongoose to use Supabase client. The User model is already updated as an example.

### 5. Update Routes

Routes need to be updated to use the new Supabase-based models instead of Mongoose models.

## Key Changes

### Database Connection
- **Before**: `mongoose.connect()`
- **After**: `createClient()` from `@supabase/supabase-js`

### Models
- **Before**: Mongoose schemas with `.save()`, `.find()`, etc.
- **After**: Class-based models with static methods using Supabase client

### Queries
- **Before**: Mongoose query syntax
- **After**: Supabase query builder syntax

## Migration Status

- ✅ Database connection updated
- ✅ User model converted
- ⚠️ Other models need conversion (Message, Post, School, etc.)
- ⚠️ Routes need updating to use new models

## Next Steps

1. Convert remaining models (Message, Post, School, Subscription, etc.)
2. Update all route handlers to use Supabase queries
3. Test all API endpoints
4. Migrate existing data (if any)


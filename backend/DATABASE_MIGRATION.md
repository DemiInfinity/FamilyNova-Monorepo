# Database Migration Guide

## Fix Password Column Constraint

The `users` table has a NOT NULL constraint on the `password` column, but since we're using Supabase Auth, passwords are stored in `auth.users`, not in our `public.users` table.

### Run this SQL in Supabase SQL Editor:

```sql
-- Make password column nullable in users table
ALTER TABLE users ALTER COLUMN password DROP NOT NULL;
```

### Steps:

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Create a new query
4. Paste the SQL above
5. Run the query

This will allow the `password` column to be NULL, which is correct since Supabase Auth handles passwords separately.

## Verify the Change

After running the migration, verify with:

```sql
SELECT column_name, is_nullable, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'password';
```

The `is_nullable` should be `YES`.


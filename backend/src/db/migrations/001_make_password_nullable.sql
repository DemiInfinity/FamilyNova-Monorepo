-- Migration: Make password column nullable in users table
-- This is needed because Supabase Auth handles passwords, not our users table

-- Make password nullable (if it's not already)
ALTER TABLE users ALTER COLUMN password DROP NOT NULL;

-- Also ensure schools.password can be nullable if needed (though schools still use passwords)
-- Schools table password should remain NOT NULL as they don't use Supabase Auth


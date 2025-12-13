-- Migration: Setup Supabase Storage Bucket for User Profiles
-- This migration sets up the storage bucket for user profile images (avatar and banner)
-- Run this in Supabase SQL Editor after creating the bucket in the Storage section

-- Note: Storage buckets must be created manually in Supabase Dashboard:
-- 1. Go to Storage section in Supabase Dashboard
-- 2. Click "New bucket"
-- 3. Name: "user-profiles"
-- 4. Public: No (Private bucket - images accessed via signed URLs)
-- 5. File size limit: 5MB
-- 6. Allowed MIME types: image/jpeg, image/png, image/gif, image/webp

-- Storage policies (run these after creating the bucket):
-- Allow authenticated users to upload their own files
CREATE POLICY "Users can upload their own profile images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'user-profiles' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to update their own files
CREATE POLICY "Users can update their own profile images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'user-profiles' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to delete their own files
CREATE POLICY "Users can delete their own profile images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'user-profiles' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to read their own files and files from their friends
CREATE POLICY "Authenticated users can read profile images"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'user-profiles');


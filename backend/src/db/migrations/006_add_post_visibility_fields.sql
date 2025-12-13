-- Migration: Add visibility/privacy fields to posts table
-- This allows parents to control who can see their posts and child posts

-- Add visibility fields to posts table
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS visible_to_children BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS visible_to_adults BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS approved_adults JSONB DEFAULT '[]';

-- Add comment explaining the fields
COMMENT ON COLUMN posts.visible_to_children IS 'For parent posts: whether children can see this post (default: true)';
COMMENT ON COLUMN posts.visible_to_adults IS 'For child posts: whether other adults (besides parent) can see this post (default: false)';
COMMENT ON COLUMN posts.approved_adults IS 'Array of user IDs of adults approved by parent to see child posts';

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_posts_author_visibility ON posts(author_id, visible_to_children, visible_to_adults);


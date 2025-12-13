-- Migration: Create separate tables for comments and reactions
-- This improves querying, indexing, and data integrity

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    author_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL CHECK (char_length(content) >= 1 AND char_length(content) <= 200),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Reactions table (for emoji reactions)
CREATE TABLE IF NOT EXISTS reactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    reaction_type VARCHAR(20) NOT NULL CHECK (reaction_type IN ('like', 'love', 'laugh', 'wow', 'sad', 'angry')),
    emoji VARCHAR(10) NOT NULL, -- Store the actual emoji
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(post_id, user_id, reaction_type) -- One reaction type per user per post
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_author_id ON comments(author_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at);
CREATE INDEX IF NOT EXISTS idx_reactions_post_id ON reactions(post_id);
CREATE INDEX IF NOT EXISTS idx_reactions_user_id ON reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_reactions_post_user ON reactions(post_id, user_id);

-- Migrate existing comments from posts.comments JSONB to comments table
-- This is a one-time migration for existing data
DO $$
DECLARE
    post_record RECORD;
    comment_record JSONB;
BEGIN
    FOR post_record IN SELECT id, comments FROM posts WHERE comments IS NOT NULL AND jsonb_array_length(comments) > 0
    LOOP
        FOR comment_record IN SELECT * FROM jsonb_array_elements(post_record.comments)
        LOOP
            INSERT INTO comments (id, post_id, author_id, content, created_at)
            VALUES (
                (comment_record->>'id')::UUID,
                post_record.id,
                (comment_record->'author'->>'id')::UUID,
                comment_record->>'content',
                COALESCE((comment_record->>'createdAt')::TIMESTAMP, NOW())
            )
            ON CONFLICT (id) DO NOTHING; -- Skip if already exists
        END LOOP;
    END LOOP;
END $$;

-- Migrate existing likes from posts.likes JSONB to reactions table
-- Convert likes to 'like' reaction type
DO $$
DECLARE
    post_record RECORD;
    like_user_id UUID;
BEGIN
    FOR post_record IN SELECT id, likes FROM posts WHERE likes IS NOT NULL AND jsonb_array_length(likes) > 0
    LOOP
        FOR like_user_id IN SELECT jsonb_array_elements_text(post_record.likes)::UUID
        LOOP
            INSERT INTO reactions (post_id, user_id, reaction_type, emoji, created_at)
            VALUES (post_record.id, like_user_id, 'like', '❤️', NOW())
            ON CONFLICT (post_id, user_id, reaction_type) DO NOTHING; -- Skip if already exists
        END LOOP;
    END LOOP;
END $$;

-- Add trigger to update updated_at for comments
CREATE TRIGGER update_comments_updated_at
    BEFORE UPDATE ON comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


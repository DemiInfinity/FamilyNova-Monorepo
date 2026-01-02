-- Performance optimization indexes
-- These indexes improve query performance for common operations

-- Posts indexes
CREATE INDEX IF NOT EXISTS idx_posts_author_id ON posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_status ON posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_status_created_at ON posts(status, created_at DESC);

-- Comments indexes
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_author_id ON comments(author_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_post_created ON comments(post_id, created_at DESC);

-- Reactions indexes
CREATE INDEX IF NOT EXISTS idx_reactions_post_id ON reactions(post_id);
CREATE INDEX IF NOT EXISTS idx_reactions_user_id ON reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_reactions_post_user ON reactions(post_id, user_id);

-- Messages indexes
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(sender_id, receiver_id, created_at DESC);

-- Friendships indexes
CREATE INDEX IF NOT EXISTS idx_friendships_user_id ON friendships(user_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_id ON friendships(friend_id);
CREATE INDEX IF NOT EXISTS idx_friendships_status ON friendships(status);
CREATE INDEX IF NOT EXISTS idx_friendships_user_status ON friendships(user_id, status);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_status ON friendships(friend_id, status);

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
CREATE INDEX IF NOT EXISTS idx_users_parent_account ON users(parent_account_id);
CREATE INDEX IF NOT EXISTS idx_users_school_account ON users(school_account_id);

-- Parent children indexes
CREATE INDEX IF NOT EXISTS idx_parent_children_parent ON parent_children(parent_id);
CREATE INDEX IF NOT EXISTS idx_parent_children_child ON parent_children(child_id);

-- Friend codes indexes
CREATE INDEX IF NOT EXISTS idx_friend_codes_code ON friend_codes(code);
CREATE INDEX IF NOT EXISTS idx_friend_codes_user_id ON friend_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_friend_codes_expires ON friend_codes(expires_at);

-- Login codes indexes
CREATE INDEX IF NOT EXISTS idx_login_codes_code ON login_codes(code);
CREATE INDEX IF NOT EXISTS idx_login_codes_child_id ON login_codes(child_id);
CREATE INDEX IF NOT EXISTS idx_login_codes_expires ON login_codes(expires_at);

-- Consents indexes (already created in 004, but ensure they exist)
CREATE INDEX IF NOT EXISTS idx_consents_user_id ON consents(user_id);
CREATE INDEX IF NOT EXISTS idx_consents_consent_type ON consents(consent_type);
CREATE INDEX IF NOT EXISTS idx_consents_status ON consents(status);
CREATE INDEX IF NOT EXISTS idx_consents_created_at ON consents(created_at);

-- Profile change requests indexes
CREATE INDEX IF NOT EXISTS idx_profile_changes_kid_id ON profile_change_requests(kid_id);
CREATE INDEX IF NOT EXISTS idx_profile_changes_status ON profile_change_requests(status);
CREATE INDEX IF NOT EXISTS idx_profile_changes_created_at ON profile_change_requests(requested_at);

-- Education content indexes
CREATE INDEX IF NOT EXISTS idx_education_school_id ON education_content(school_id);
CREATE INDEX IF NOT EXISTS idx_education_grade_level ON education_content(grade_level);
CREATE INDEX IF NOT EXISTS idx_education_content_type ON education_content(content_type);

-- School codes indexes
CREATE INDEX IF NOT EXISTS idx_school_codes_code ON school_codes(code);
CREATE INDEX IF NOT EXISTS idx_school_codes_school_id ON school_codes(school_id);
CREATE INDEX IF NOT EXISTS idx_school_codes_expires ON school_codes(expires_at);

-- Subscriptions indexes
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_end_date ON subscriptions(end_date);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_posts_author_status_created ON posts(author_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_participants_created ON messages(sender_id, receiver_id, created_at DESC);

-- Analyze tables after creating indexes
ANALYZE posts;
ANALYZE comments;
ANALYZE reactions;
ANALYZE messages;
ANALYZE friendships;
ANALYZE users;


-- Create friend_codes table for easy friend connections
CREATE TABLE IF NOT EXISTS friend_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    code VARCHAR(8) UNIQUE NOT NULL,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_friend_codes_code ON friend_codes(code);
CREATE INDEX IF NOT EXISTS idx_friend_codes_user ON friend_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_friend_codes_expires ON friend_codes(expires_at);

-- Trigger to auto-update updated_at
CREATE TRIGGER update_friend_codes_updated_at BEFORE UPDATE ON friend_codes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


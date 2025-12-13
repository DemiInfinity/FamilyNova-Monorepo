-- Migration: Create login_codes table for QR code login
-- Run this in your Supabase SQL Editor

-- Login codes table (for QR code login)
CREATE TABLE IF NOT EXISTS login_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(6) UNIQUE NOT NULL,
    child_id UUID REFERENCES users(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES users(id) ON DELETE CASCADE,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT false,
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for login codes
CREATE INDEX IF NOT EXISTS idx_login_codes_code ON login_codes(code);
CREATE INDEX IF NOT EXISTS idx_login_codes_expires ON login_codes(expires_at);
CREATE INDEX IF NOT EXISTS idx_login_codes_child ON login_codes(child_id);
CREATE INDEX IF NOT EXISTS idx_login_codes_used ON login_codes(used);


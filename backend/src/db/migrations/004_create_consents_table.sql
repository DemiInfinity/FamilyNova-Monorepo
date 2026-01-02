-- Create consents table for GDPR compliance
CREATE TABLE IF NOT EXISTS consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    consent_type VARCHAR(50) NOT NULL CHECK (consent_type IN ('data_processing', 'marketing', 'analytics', 'cookies')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('accepted', 'rejected', 'withdrawn')),
    purpose TEXT,
    legal_basis VARCHAR(50) DEFAULT 'consent',
    ip_address VARCHAR(45),
    user_agent TEXT,
    withdrawn_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_consents_user_id ON consents(user_id);
CREATE INDEX IF NOT EXISTS idx_consents_consent_type ON consents(consent_type);
CREATE INDEX IF NOT EXISTS idx_consents_status ON consents(status);
CREATE INDEX IF NOT EXISTS idx_consents_created_at ON consents(created_at);

-- Add comment
COMMENT ON TABLE consents IS 'Stores user consent records for GDPR compliance';


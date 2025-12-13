const { getSupabase } = require('../config/database');
const User = require('../models/User');
const { createClient } = require('@supabase/supabase-js');

const auth = async (req, res, next) => {
  try {
    let token = req.header('Authorization');
    
    // Handle different Authorization header formats
    if (token) {
      // Remove 'Bearer ' prefix if present
      token = token.replace(/^Bearer\s+/i, '').trim();
    }
    
    if (!token || token.length === 0) {
      return res.status(401).json({ error: 'No token, authorization denied' });
    }
    
    // Basic JWT format validation (should have 3 parts separated by dots)
    const tokenParts = token.split('.');
    if (tokenParts.length !== 3) {
      console.error('❌ Invalid JWT format - token has', tokenParts.length, 'parts (expected 3)');
      console.error('Token length:', token.length);
      console.error('Token preview (first 100 chars):', token.substring(0, 100));
      console.error('Token preview (last 50 chars):', token.substring(Math.max(0, token.length - 50)));
      console.error('Token contains newlines:', token.includes('\n'));
      console.error('Token contains spaces:', token.includes(' '));
      console.error('Full token (for debugging):', JSON.stringify(token));
      return res.status(401).json({ 
        error: 'Invalid token format',
        details: `Token has ${tokenParts.length} segments instead of 3. Please log in again.`
      });
    }

    // Use anon key for token verification (getUser is a client-side operation)
    const supabaseUrl = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
    const anonKey = process.env.SUPABASE_ANON_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
    
    if (!supabaseUrl || !anonKey) {
      console.error('Missing Supabase credentials for auth verification');
      return res.status(500).json({ error: 'Server configuration error' });
    }
    
    // Create a client with anon key for token verification
    const supabaseClient = createClient(supabaseUrl, anonKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false
      }
    });
    
    // Verify the token with Supabase Auth
    const { data: { user: authUser }, error } = await supabaseClient.auth.getUser(token);
    
    if (error || !authUser) {
      console.error('Token verification error:', error?.message || 'No user found');
      console.error('Token length:', token.length);
      console.error('Token preview:', token.substring(0, 50) + '...');
      return res.status(401).json({ error: 'Token is not valid' });
    }

    // Get user profile from our users table
    const user = await User.findById(authUser.id);
    
    if (!user || !user.isActive) {
      return res.status(401).json({ error: 'User not found or inactive' });
    }

    // Attach user to request
    req.user = {
      id: user.id,
      _id: user.id, // For backward compatibility
      email: user.email,
      userType: user.userType,
      profile: user.profile,
      verification: user.verification,
      monitoringLevel: user.monitoringLevel,
      isActive: user.isActive
    };
    
    // Also attach the Supabase auth user for reference
    req.authUser = authUser;
    
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(401).json({ error: 'Token is not valid' });
  }
};

const requireUserType = (...userTypes) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }
    
    if (!userTypes.includes(req.user.userType)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    
    next();
  };
};

module.exports = { auth, requireUserType };

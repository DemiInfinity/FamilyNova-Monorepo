const { getSupabase } = require('../config/database');
const User = require('../models/User');
const { createClient } = require('@supabase/supabase-js');

const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ error: 'No token, authorization denied' });
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

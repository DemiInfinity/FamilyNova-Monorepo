const crypto = require('crypto');

// CSRF token storage (in production, use Redis or session store)
const tokenStore = new Map();

// Generate CSRF token
function generateToken() {
  return crypto.randomBytes(32).toString('hex');
}

// CSRF protection middleware
function csrfProtection(req, res, next) {
  // Skip CSRF for GET, HEAD, OPTIONS requests
  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
    return next();
  }

  // Skip CSRF for API endpoints (they use token auth)
  if (req.path.startsWith('/api/')) {
    // Only apply CSRF to web endpoints (non-API)
    if (req.path.startsWith('/api/auth/') || req.path.startsWith('/api/webhooks/')) {
      return next();
    }
    // For web form submissions, check CSRF token
    if (req.path.includes('/web/') || req.path.includes('/schools/')) {
      const token = req.headers['x-csrf-token'] || req.body._csrf;
      const sessionToken = req.headers['x-session-token'] || req.cookies?.sessionToken;
      
      if (!sessionToken || !tokenStore.has(sessionToken)) {
        return res.status(403).json({ error: 'Invalid session' });
      }
      
      const storedToken = tokenStore.get(sessionToken);
      if (token !== storedToken) {
        return res.status(403).json({ error: 'Invalid CSRF token' });
      }
    }
    return next();
  }

  // For web routes, require CSRF token
  const token = req.headers['x-csrf-token'] || req.body._csrf;
  const sessionToken = req.headers['x-session-token'] || req.cookies?.sessionToken;
  
  if (!sessionToken) {
    return res.status(403).json({ error: 'Session required' });
  }
  
  if (!tokenStore.has(sessionToken)) {
    return res.status(403).json({ error: 'Invalid session' });
  }
  
  const storedToken = tokenStore.get(sessionToken);
  if (token !== storedToken) {
    return res.status(403).json({ error: 'Invalid CSRF token' });
  }
  
  next();
}

// Middleware to generate and attach CSRF token
function csrfToken(req, res, next) {
  const sessionToken = req.headers['x-session-token'] || req.cookies?.sessionToken || generateToken();
  
  if (!tokenStore.has(sessionToken)) {
    tokenStore.set(sessionToken, generateToken());
  }
  
  const csrfToken = tokenStore.get(sessionToken);
  
  // Attach token to response
  res.locals.csrfToken = csrfToken;
  res.cookie('csrfToken', csrfToken, {
    httpOnly: false, // Must be accessible to JavaScript
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict'
  });
  
  // Add to response header
  res.setHeader('X-CSRF-Token', csrfToken);
  
  next();
}

// Cleanup old tokens (run periodically)
function cleanupTokens() {
  // In production, implement token expiration
  // For now, just limit size
  if (tokenStore.size > 10000) {
    const entries = Array.from(tokenStore.entries());
    const toDelete = entries.slice(0, 5000);
    toDelete.forEach(([key]) => tokenStore.delete(key));
  }
}

// Run cleanup every hour
setInterval(cleanupTokens, 60 * 60 * 1000);

module.exports = {
  csrfProtection,
  csrfToken,
  generateToken
};


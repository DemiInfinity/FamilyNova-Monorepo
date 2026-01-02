const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const { connectDB } = require('./config/database');
const { decryptMiddleware } = require('./utils/encryption');
const { initializeStorage } = require('./utils/storage');
const { apiLimiter, authLimiter, uploadLimiter, messageLimiter } = require('./middleware/rateLimiter');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Trust proxy - Required for Vercel/serverless environments
// This allows Express to correctly identify client IPs from X-Forwarded-For headers
app.set('trust proxy', true);

// Connect to Supabase (async, but don't block serverless startup)
// In Vercel, connections are lazy-loaded per request
if (process.env.VERCEL !== '1' && !process.env.VERCEL_ENV) {
  connectDB().then(() => {
    // Initialize storage bucket after DB connection
    initializeStorage().catch(err => {
      console.warn('Storage initialization failed:', err.message);
    });
  });
} else {
  // In serverless, initialize on first request
  connectDB().catch(err => {
    console.error('Initial Supabase connection failed (will retry per request):', err);
  });
}

// Serve static files from public directory
app.use(express.static(path.join(__dirname, '../public')));

// Security: Configure CORS with allowed origins
const allowedOrigins = process.env.CORS_ORIGIN 
  ? process.env.CORS_ORIGIN.split(',').map(origin => origin.trim())
  : (process.env.NODE_ENV === 'production' ? [] : ['http://localhost:3000', 'http://localhost:3001']);

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) {
      return callback(null, true);
    }
    
    if (allowedOrigins.length === 0 || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Security: Configure Helmet with proper headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"], // Allow inline styles for landing page
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
    },
  },
  hsts: {
    maxAge: 31536000, // 1 year
    includeSubDomains: true,
    preload: true
  },
  frameguard: { action: 'deny' },
  noSniff: true,
  xssFilter: true
}));

// Request logging
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

// Body parsing with size limits
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting - apply general limiter to all API routes
app.use('/api/', apiLimiter);

// Decrypt middleware - must be after body parsing
app.use(decryptMiddleware);

// Root route - serve the landing page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Routes with specific rate limiters
app.use('/api/auth', authLimiter, require('./routes/auth'));
app.use('/api/upload', uploadLimiter, require('./routes/upload'));
app.use('/api/messages', messageLimiter, require('./routes/messages'));

// Other routes (use general apiLimiter)
app.use('/api/kids', require('./routes/kids'));
app.use('/api/parents', require('./routes/parents'));
app.use('/api/friends', require('./routes/friends'));
app.use('/api/posts', require('./routes/posts'));
app.use('/api/profile-changes', require('./routes/profileChanges'));
app.use('/api/schools', require('./routes/schools'));
app.use('/api/school-codes', require('./routes/schoolCodes'));
app.use('/api/education', require('./routes/education'));
app.use('/api/verification', require('./routes/verification'));
app.use('/api/subscriptions', require('./routes/subscriptions'));
app.use('/api/webhooks', require('./routes/webhooks'));
app.use('/api/users', require('./routes/users')); // GDPR routes
app.use('/api/consent', require('./routes/consent')); // Consent management
app.use('/api/data-retention', require('./routes/dataRetention')); // Data retention

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'FamilyNova API is running',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Centralized error handler
const { errorHandler } = require('./middleware/errorHandler');
app.use(errorHandler);

// Only start server if not in Vercel environment
// Vercel will handle the serverless function invocation
if (process.env.VERCEL !== '1' && !process.env.VERCEL_ENV) {
  app.listen(PORT, () => {
    console.log(`🚀 FamilyNova API server running on port ${PORT}`);
    console.log(`📡 Environment: ${process.env.NODE_ENV || 'development'}`);
  });
}

module.exports = app;


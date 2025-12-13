const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const { connectDB } = require('./config/database');
const { decryptMiddleware } = require('./utils/encryption');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Connect to Supabase (async, but don't block serverless startup)
// In Vercel, connections are lazy-loaded per request
if (process.env.VERCEL !== '1' && !process.env.VERCEL_ENV) {
  connectDB();
} else {
  // In serverless, initialize on first request
  connectDB().catch(err => {
    console.error('Initial Supabase connection failed (will retry per request):', err);
  });
}

// Serve static files from public directory
app.use(express.static(path.join(__dirname, '../public')));

// Middleware
app.use(helmet({
  contentSecurityPolicy: false // Allow inline styles for the landing page
}));
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Decrypt middleware - must be after body parsing
app.use(decryptMiddleware);

// Root route - serve the landing page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/kids', require('./routes/kids'));
app.use('/api/parents', require('./routes/parents'));
app.use('/api/friends', require('./routes/friends'));
app.use('/api/messages', require('./routes/messages'));
app.use('/api/posts', require('./routes/posts'));
app.use('/api/profile-changes', require('./routes/profileChanges'));
app.use('/api/schools', require('./routes/schools'));
app.use('/api/school-codes', require('./routes/schoolCodes'));
app.use('/api/education', require('./routes/education'));
app.use('/api/verification', require('./routes/verification'));
app.use('/api/subscriptions', require('./routes/subscriptions'));

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

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Only start server if not in Vercel environment
// Vercel will handle the serverless function invocation
if (process.env.VERCEL !== '1' && !process.env.VERCEL_ENV) {
  app.listen(PORT, () => {
    console.log(`🚀 FamilyNova API server running on port ${PORT}`);
    console.log(`📡 Environment: ${process.env.NODE_ENV || 'development'}`);
  });
}

module.exports = app;


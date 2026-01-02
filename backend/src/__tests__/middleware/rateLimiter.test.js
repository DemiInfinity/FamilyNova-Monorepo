const request = require('supertest');
const express = require('express');

describe('Rate Limiter Middleware', () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    
    // Import rate limiters
    const { apiLimiter, authLimiter } = require('../../middleware/rateLimiter');
    
    app.get('/api/test', apiLimiter, (req, res) => {
      res.json({ message: 'success' });
    });

    app.post('/api/auth/test', authLimiter, (req, res) => {
      res.json({ message: 'auth success' });
    });
  });

  test('should allow requests within limit', async () => {
    const response = await request(app)
      .get('/api/test')
      .expect(200);
    
    expect(response.body.message).toBe('success');
  });

  test('should enforce rate limits', async () => {
    // Make requests up to the limit
    for (let i = 0; i < 100; i++) {
      await request(app).get('/api/test');
    }

    // Next request should be rate limited
    const response = await request(app)
      .get('/api/test')
      .expect(429);
    
    expect(response.body.error).toBeDefined();
  });

  test('auth limiter should have stricter limits', async () => {
    // Make 5 requests (limit)
    for (let i = 0; i < 5; i++) {
      await request(app).post('/api/auth/test').expect(200);
    }

    // Next request should be rate limited
    const response = await request(app)
      .post('/api/auth/test')
      .expect(429);
    
    expect(response.body.error).toBeDefined();
  });
});


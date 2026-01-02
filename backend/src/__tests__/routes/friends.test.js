const request = require('supertest');
const express = require('express');

// Mock dependencies
jest.mock('../../config/database', () => ({
  getSupabase: jest.fn(() => ({
    from: jest.fn(() => ({
      select: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      update: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      or: jest.fn().mockReturnThis(),
      single: jest.fn()
    }))
  }))
}));

jest.mock('../../middleware/auth', () => ({
  auth: (req, res, next) => {
    req.user = { id: 'test-user-id', userType: 'kid' };
    next();
  },
  requireUserType: () => (req, res, next) => next()
}));

describe('Friends Routes', () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use('/api/friends', require('../../routes/friends'));
    app.use(require('../../middleware/errorHandler').errorHandler);
  });

  describe('POST /api/friends/add-by-code', () => {
    test('should reject invalid friend code format', async () => {
      const response = await request(app)
        .post('/api/friends/add-by-code')
        .send({
          code: '123' // Too short
        })
        .expect(400);
      
      expect(response.body.error).toContain('Invalid friend code format');
    });

    test('should reject empty friend code', async () => {
      const response = await request(app)
        .post('/api/friends/add-by-code')
        .send({
          code: ''
        })
        .expect(400);
      
      expect(response.body.error).toContain('Invalid friend code format');
    });
  });
});


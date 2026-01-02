const request = require('supertest');
const express = require('express');

// Mock dependencies
jest.mock('../../config/database', () => ({
  getSupabase: jest.fn(() => ({
    from: jest.fn(() => ({
      select: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      update: jest.fn().mockReturnThis(),
      delete: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      in: jest.fn().mockReturnThis(),
      order: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
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

describe('Posts Routes', () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use('/api/posts', require('../../routes/posts'));
    app.use(require('../../middleware/errorHandler').errorHandler);
  });

  describe('POST /api/posts', () => {
    test('should reject post with empty content', async () => {
      const response = await request(app)
        .post('/api/posts')
        .send({
          content: ''
        })
        .expect(400);
      
      expect(response.body.code).toBe('VALIDATION_ERROR');
    });

    test('should reject post with content too long', async () => {
      const longContent = 'a'.repeat(501);
      const response = await request(app)
        .post('/api/posts')
        .send({
          content: longContent
        })
        .expect(400);
      
      expect(response.body.code).toBe('VALIDATION_ERROR');
    });
  });

  describe('GET /api/posts', () => {
    test('should return posts list', async () => {
      // Mock Supabase response
      const { getSupabase } = require('../../config/database');
      const mockSupabase = getSupabase();
      mockSupabase.from().select().eq().order().limit().mockResolvedValue({
        data: [],
        error: null
      });

      const response = await request(app)
        .get('/api/posts')
        .expect(200);
      
      expect(response.body).toHaveProperty('posts');
    });
  });
});


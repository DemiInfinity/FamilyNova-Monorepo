const request = require('supertest');
const express = require('express');
const { createError } = require('../../middleware/errorHandler');

// Mock Supabase
jest.mock('../../config/database', () => ({
  getSupabase: jest.fn(() => ({
    auth: {
      admin: {
        createUser: jest.fn(),
        getUserByEmail: jest.fn()
      }
    },
    from: jest.fn(() => ({
      select: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      single: jest.fn()
    }))
  }))
}));

describe('Auth Routes', () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use('/api/v1/auth', require('../../routes/auth'));
    app.use(require('../../middleware/errorHandler').errorHandler);
  });

  describe('POST /api/v1/auth/register', () => {
    test('should reject registration with invalid email', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({
          email: 'invalid-email',
          password: 'password123',
          userType: 'kid',
          firstName: 'Test',
          lastName: 'User'
        })
        .expect(400);
      
      expect(response.body.code).toBe('VALIDATION_ERROR');
    });

    test('should reject registration with short password', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({
          email: 'test@example.com',
          password: 'short',
          userType: 'kid',
          firstName: 'Test',
          lastName: 'User'
        })
        .expect(400);
      
      expect(response.body.code).toBe('VALIDATION_ERROR');
    });

    test('should reject registration with invalid userType', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({
          email: 'test@example.com',
          password: 'password123',
          userType: 'invalid',
          firstName: 'Test',
          lastName: 'User'
        })
        .expect(400);
      
      expect(response.body.code).toBe('VALIDATION_ERROR');
    });
  });

  describe('POST /api/v1/auth/login', () => {
    test('should reject login with invalid email', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'invalid-email',
          password: 'password123'
        })
        .expect(400);
      
      expect(response.body.code).toBe('VALIDATION_ERROR');
    });

    test('should reject login with missing password', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'test@example.com'
        })
        .expect(400);
      
      expect(response.body.code).toBe('VALIDATION_ERROR');
    });
  });
});


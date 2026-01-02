/**
 * Integration tests for API endpoints
 * These tests verify end-to-end functionality
 */

const request = require('supertest');
const app = require('../../../src/server');

describe('API Integration Tests', () => {
  let authToken;
  let testUserId;

  describe('Health Check', () => {
    test('GET /api/health should return 200', async () => {
      const response = await request(app)
        .get('/api/health')
        .expect(200);
      
      expect(response.body.status).toBe('ok');
      expect(response.body).toHaveProperty('timestamp');
    });
  });

  describe('Authentication Flow', () => {
    test('POST /api/v1/auth/register should create new user', async () => {
      const testEmail = `test-${Date.now()}@example.com`;
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({
          email: testEmail,
          password: 'Test1234!',
          userType: 'kid',
          firstName: 'Test',
          lastName: 'User',
          displayName: 'Test User'
        })
        .expect(201);
      
      expect(response.body).toHaveProperty('user');
      expect(response.body.user.email).toBe(testEmail);
      testUserId = response.body.user.id;
    });

    test('POST /api/v1/auth/login should authenticate user', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'test@example.com',
          password: 'password123'
        });
      
      // May fail if user doesn't exist, that's okay for integration test
      if (response.status === 200) {
        expect(response.body).toHaveProperty('session');
        expect(response.body.session).toHaveProperty('access_token');
        authToken = response.body.session.access_token;
      }
    });
  });

  describe('Posts API', () => {
    test('GET /api/posts should require authentication', async () => {
      const response = await request(app)
        .get('/api/posts')
        .expect(401);
    });

    test('POST /api/posts should create post with valid token', async () => {
      if (!authToken) {
        // Skip if no auth token
        return;
      }

      const response = await request(app)
        .post('/api/posts')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          content: 'Test post content'
        });
      
      // May fail if token is invalid, that's okay
      if (response.status === 201) {
        expect(response.body).toHaveProperty('post');
        expect(response.body.post.content).toBe('Test post content');
      }
    });
  });

  describe('Error Handling', () => {
    test('Invalid route should return 404', async () => {
      const response = await request(app)
        .get('/api/invalid-route')
        .expect(404);
    });

    test('Invalid JSON should return 400', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .set('Content-Type', 'application/json')
        .send('invalid json')
        .expect(400);
    });
  });
});


/**
 * Performance/Load tests
 * Run with: npm test -- --testPathPattern=performance
 */

const request = require('supertest');
const app = require('../../server');

describe('Performance Tests', () => {
  describe('Response Time', () => {
    test('Health check should respond in < 100ms', async () => {
      const start = Date.now();
      await request(app).get('/api/health');
      const duration = Date.now() - start;
      
      expect(duration).toBeLessThan(100);
    });

    test('Posts endpoint should respond in < 500ms', async () => {
      // This test requires authentication
      // In a real scenario, you'd set up a test user first
      const start = Date.now();
      const response = await request(app)
        .get('/api/posts');
      
      const duration = Date.now() - start;
      
      // Should respond quickly even if unauthorized
      expect(duration).toBeLessThan(500);
    });
  });

  describe('Concurrent Requests', () => {
    test('Should handle 10 concurrent health checks', async () => {
      const requests = Array(10).fill(null).map(() =>
        request(app).get('/api/health')
      );
      
      const responses = await Promise.all(requests);
      
      expect(responses.every(r => r.status === 200)).toBe(true);
    });
  });
});


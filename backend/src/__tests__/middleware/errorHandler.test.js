const { createError, errorHandler } = require('../../middleware/errorHandler');
const express = require('express');
const request = require('supertest');

describe('Error Handler', () => {
  describe('createError', () => {
    test('should create error with default status 500', () => {
      const error = createError('Test error');
      expect(error.message).toBe('Test error');
      expect(error.status).toBe(500);
      expect(error.code).toBe('SERVER_ERROR');
    });

    test('should create error with custom status and code', () => {
      const error = createError('Not found', 404, 'NOT_FOUND');
      expect(error.message).toBe('Not found');
      expect(error.status).toBe(404);
      expect(error.code).toBe('NOT_FOUND');
    });

    test('should create error with details', () => {
      const details = { field: 'email', reason: 'invalid' };
      const error = createError('Validation failed', 400, 'VALIDATION_ERROR', details);
      expect(error.details).toEqual(details);
    });
  });

  describe('errorHandler middleware', () => {
    let app;

    beforeEach(() => {
      app = express();
      app.use(express.json());
    });

    test('should handle errors with status code', async () => {
      app.get('/test', (req, res, next) => {
        next(createError('Not found', 404, 'NOT_FOUND'));
      });
      app.use(errorHandler);

      const response = await request(app)
        .get('/test')
        .expect(404);
      
      expect(response.body.status).toBe(404);
      expect(response.body.code).toBe('NOT_FOUND');
      expect(response.body.message).toBe('Not found');
    });

    test('should hide stack trace in production', async () => {
      process.env.NODE_ENV = 'production';
      
      app.get('/test', (req, res, next) => {
        next(createError('Server error', 500));
      });
      app.use(errorHandler);

      const response = await request(app)
        .get('/test')
        .expect(500);
      
      expect(response.body.stack).toBeUndefined();
      
      process.env.NODE_ENV = 'test';
    });

    test('should show stack trace in development', async () => {
      process.env.NODE_ENV = 'development';
      
      app.get('/test', (req, res, next) => {
        next(createError('Server error', 500));
      });
      app.use(errorHandler);

      const response = await request(app)
        .get('/test')
        .expect(500);
      
      expect(response.body.stack).toBeDefined();
      
      process.env.NODE_ENV = 'test';
    });

    test('should include details in error response', async () => {
      const details = { field: 'email' };
      app.get('/test', (req, res, next) => {
        next(createError('Validation failed', 400, 'VALIDATION_ERROR', details));
      });
      app.use(errorHandler);

      const response = await request(app)
        .get('/test')
        .expect(400);
      
      expect(response.body.details).toEqual(details);
    });
  });
});


/**
 * Centralized error handler middleware
 * Standardizes error responses and prevents information disclosure
 */

function errorHandler(err, req, res, next) {
  // Log error details (full stack in development, sanitized in production)
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  if (isDevelopment) {
    console.error('Error details:', {
      message: err.message,
      stack: err.stack,
      path: req.path,
      method: req.method,
      timestamp: new Date().toISOString()
    });
  } else {
    // Production: Log sanitized error (no stack traces, no sensitive data)
    console.error('Error:', {
      message: err.message,
      path: req.path,
      method: req.method,
      statusCode: err.status || 500,
      timestamp: new Date().toISOString()
    });
  }

  // Determine status code
  const statusCode = err.status || err.statusCode || 500;

  // Standardized error response format
  const errorResponse = {
    error: {
      message: statusCode >= 500 && !isDevelopment
        ? 'Internal server error'
        : err.message || 'An error occurred',
      code: err.code || 'INTERNAL_ERROR',
      timestamp: new Date().toISOString()
    }
  };

  // Include stack trace only in development
  if (isDevelopment && err.stack) {
    errorResponse.error.stack = err.stack;
  }

  // Include additional error details in development
  if (isDevelopment && err.details) {
    errorResponse.error.details = err.details;
  }

  res.status(statusCode).json(errorResponse);
}

/**
 * Creates a standardized error object
 */
function createError(message, statusCode = 500, code = null, details = null) {
  const error = new Error(message);
  error.status = statusCode;
  error.statusCode = statusCode;
  if (code) error.code = code;
  if (details) error.details = details;
  return error;
}

/**
 * Async error wrapper - catches errors in async route handlers
 */
function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

module.exports = {
  errorHandler,
  createError,
  asyncHandler
};


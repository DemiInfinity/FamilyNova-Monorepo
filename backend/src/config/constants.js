/**
 * Application constants
 * Centralized configuration values
 */

module.exports = {
  // Time constants (in milliseconds)
  ONE_SECOND: 1000,
  ONE_MINUTE: 60 * 1000,
  ONE_HOUR: 60 * 60 * 1000,
  ONE_DAY: 24 * 60 * 60 * 1000,
  ONE_WEEK: 7 * 24 * 60 * 60 * 1000,
  ONE_YEAR: 365 * 24 * 60 * 60 * 1000,

  // Time constants (in seconds)
  ONE_YEAR_SECONDS: 31536000, // Used for signed URL expiration

  // Content limits
  MAX_POST_LENGTH: 500,
  MAX_COMMENT_LENGTH: 200,
  MAX_MESSAGE_LENGTH: 1000,
  MIN_PASSWORD_LENGTH: 8, // Updated from 6 for better security
  MAX_PASSWORD_LENGTH: 128,

  // File upload limits
  MAX_FILE_SIZE: 5 * 1024 * 1024, // 5MB
  MAX_FILE_SIZE_MB: 5,
  ALLOWED_IMAGE_TYPES: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'],

  // Rate limiting
  RATE_LIMIT_WINDOW_MS: 15 * 60 * 1000, // 15 minutes
  RATE_LIMIT_MAX_REQUESTS: 100,
  RATE_LIMIT_AUTH_MAX: 5,
  RATE_LIMIT_UPLOAD_MAX: 10,
  RATE_LIMIT_UPLOAD_WINDOW_MS: 60 * 60 * 1000, // 1 hour
  RATE_LIMIT_MESSAGE_MAX: 50,

  // Data retention
  DATA_RETENTION_DAYS: 30, // Soft delete retention period
  INACTIVE_ACCOUNT_DAYS: 365, // Delete inactive accounts after 1 year

  // Friend codes
  FRIEND_CODE_LENGTH: 8,
  FRIEND_CODE_EXPIRY_HOURS: 24,

  // Login codes
  LOGIN_CODE_LENGTH: 6,
  LOGIN_CODE_EXPIRY_MINUTES: 10,

  // Pagination
  DEFAULT_PAGE_SIZE: 50,
  MAX_PAGE_SIZE: 100,

  // Cache expiration
  CACHE_EXPIRATION_MS: 5 * 60 * 1000, // 5 minutes
};


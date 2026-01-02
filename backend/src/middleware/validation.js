const { body, param, query, validationResult } = require('express-validator');
const { createError } = require('./errorHandler');

/**
 * Standard validation middleware
 */
function validate(validations) {
  return async (req, res, next) => {
    // Run all validations
    await Promise.all(validations.map(validation => validation.run(req)));
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw createError('Validation failed', 400, 'VALIDATION_ERROR', errors.array());
    }
    
    next();
  };
}

/**
 * Common validation rules
 */
const commonValidations = {
  uuid: (field = 'id') => param(field).isUUID().withMessage(`${field} must be a valid UUID`),
  email: (field = 'email') => body(field).isEmail().normalizeEmail().withMessage('Invalid email address'),
  password: (field = 'password') => body(field)
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, and one number'),
  optionalString: (field, maxLength = 500) => body(field)
    .optional()
    .trim()
    .isLength({ max: maxLength })
    .withMessage(`${field} must be less than ${maxLength} characters`),
  requiredString: (field, minLength = 1, maxLength = 500) => body(field)
    .trim()
    .isLength({ min: minLength, max: maxLength })
    .withMessage(`${field} must be between ${minLength} and ${maxLength} characters`),
  userType: () => body('userType').isIn(['kid', 'parent']).withMessage('Invalid user type'),
  postContent: () => body('content')
    .trim()
    .isLength({ min: 1, max: 500 })
    .withMessage('Post content must be between 1 and 500 characters'),
  commentContent: () => body('content')
    .trim()
    .isLength({ min: 1, max: 200 })
    .withMessage('Comment content must be between 1 and 200 characters'),
  messageContent: () => body('content')
    .trim()
    .isLength({ min: 1, max: 1000 })
    .withMessage('Message content must be between 1 and 1000 characters'),
  friendCode: () => body('code')
    .trim()
    .isLength({ min: 8, max: 8 })
    .matches(/^[A-Z0-9]+$/)
    .withMessage('Friend code must be exactly 8 alphanumeric characters'),
  url: (field = 'url') => body(field)
    .optional()
    .isURL()
    .withMessage(`${field} must be a valid URL`),
  boolean: (field) => body(field)
    .optional()
    .isBoolean()
    .withMessage(`${field} must be a boolean`),
  date: (field) => body(field)
    .optional()
    .isISO8601()
    .withMessage(`${field} must be a valid ISO 8601 date`)
};

/**
 * Null check helper
 */
function requireNotNull(value, fieldName) {
  if (value === null || value === undefined) {
    throw createError(`${fieldName} is required`, 400, 'MISSING_REQUIRED_FIELD');
  }
  return value;
}

/**
 * Safe access helper with null checks
 */
function safeGet(obj, path, defaultValue = null) {
  const keys = path.split('.');
  let current = obj;
  
  for (const key of keys) {
    if (current === null || current === undefined) {
      return defaultValue;
    }
    current = current[key];
  }
  
  return current !== null && current !== undefined ? current : defaultValue;
}

module.exports = {
  validate,
  commonValidations,
  requireNotNull,
  safeGet
};


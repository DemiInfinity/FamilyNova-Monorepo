const crypto = require('crypto');

// Encryption key - should be stored in environment variables
// In production, use a strong random key: crypto.randomBytes(32).toString('hex')
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || crypto.randomBytes(32);
const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 16; // 16 bytes for AES
const AUTH_TAG_LENGTH = 16; // 16 bytes for GCM

/**
 * Encrypts data using AES-256-CBC
 * @param {string} text - Plain text to encrypt
 * @returns {string} - Encrypted data in format: iv:encryptedData (base64)
 */
function encrypt(text) {
  try {
    // Ensure encryption key is 32 bytes (256 bits)
    let key;
    if (ENCRYPTION_KEY.length === 64 && /^[0-9a-fA-F]+$/.test(ENCRYPTION_KEY)) {
      // Hex string, convert to buffer
      key = Buffer.from(ENCRYPTION_KEY, 'hex');
    } else {
      // String key, hash to 32 bytes
      key = crypto.createHash('sha256').update(String(ENCRYPTION_KEY)).digest();
    }
    
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
    
    let encrypted = cipher.update(text, 'utf8');
    encrypted = Buffer.concat([encrypted, cipher.final()]);
    
    // Combine IV and encrypted data
    const combined = Buffer.concat([iv, encrypted]);
    
    // Return format: iv:encryptedData (both base64)
    return `${iv.toString('base64')}:${combined.toString('base64')}`;
  } catch (error) {
    console.error('Encryption error:', error);
    throw new Error('Encryption failed');
  }
}

/**
 * Decrypts data using AES-256-CBC
 * @param {string} encryptedData - Encrypted data in format: iv:encryptedData (base64)
 * @returns {string} - Decrypted plain text
 */
function decrypt(encryptedData) {
  try {
    // Ensure encryption key is 32 bytes (256 bits)
    let key;
    if (ENCRYPTION_KEY.length === 64 && /^[0-9a-fA-F]+$/.test(ENCRYPTION_KEY)) {
      // Hex string, convert to buffer
      key = Buffer.from(ENCRYPTION_KEY, 'hex');
    } else {
      // String key, hash to 32 bytes
      key = crypto.createHash('sha256').update(String(ENCRYPTION_KEY)).digest();
    }
    
    const parts = encryptedData.split(':');
    if (parts.length !== 2) {
      throw new Error('Invalid encrypted data format');
    }
    
    const iv = Buffer.from(parts[0], 'base64');
    const encrypted = parts[1]; // Encrypted data is already base64, decode it
    const encryptedBuffer = Buffer.from(encrypted, 'base64');
    
    // The encrypted buffer contains IV + encrypted data, extract just encrypted part
    const actualEncrypted = encryptedBuffer.slice(IV_LENGTH);
    
    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    
    let decrypted = decipher.update(encrypted, null, 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  } catch (error) {
    console.error('Decryption error:', error);
    throw new Error('Decryption failed - invalid or corrupted data');
  }
}

/**
 * Middleware to decrypt request body if it's encrypted
 */
function decryptMiddleware(req, res, next) {
  // Only decrypt for auth routes
  if (req.path.startsWith('/api/auth/register') || req.path.startsWith('/api/auth/login')) {
    // Check if body contains encrypted data
    if (req.body && req.body.encrypted) {
      try {
        const decryptedData = decrypt(req.body.encrypted);
        req.body = JSON.parse(decryptedData);
        req.body._wasEncrypted = true; // Flag to know it was decrypted
      } catch (error) {
        return res.status(400).json({ error: 'Failed to decrypt request data' });
      }
    }
  }
  next();
}

/**
 * Encrypt response data (optional - for sensitive responses)
 */
function encryptResponse(data) {
  const jsonString = JSON.stringify(data);
  return {
    encrypted: encrypt(jsonString)
  };
}

module.exports = {
  encrypt,
  decrypt,
  decryptMiddleware,
  encryptResponse
};


const crypto = require('crypto');

// Encryption key - MUST be set in environment variables
// Generate a key with: crypto.randomBytes(32).toString('hex')
// NO DEFAULT KEY - application will fail if encryption is used without key (security requirement)
const ALGORITHM = 'aes-256-cbc'; // Using CBC for compatibility with mobile apps
const IV_LENGTH = 16; // 16 bytes for AES

/**
 * Get encryption key and validate it
 * Throws error only when encryption is actually needed
 */
function getEncryptionKey() {
  const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY;
  
  if (!ENCRYPTION_KEY) {
    throw new Error(
      'ENCRYPTION_KEY environment variable is required. ' +
      'Generate a key with: crypto.randomBytes(32).toString("hex") ' +
      'and add it to your Vercel environment variables.'
    );
  }

  if (ENCRYPTION_KEY.length < 32) {
    throw new Error(
      'ENCRYPTION_KEY must be at least 32 characters long. ' +
      'For hex keys, use 64 characters (32 bytes).'
    );
  }
  
  return ENCRYPTION_KEY;
}

/**
 * Encrypts data using AES-256-CBC
 * @param {string} text - Plain text to encrypt
 * @returns {string} - Encrypted data in format: iv:encryptedData (base64)
 */
function encrypt(text) {
  try {
    const ENCRYPTION_KEY = getEncryptionKey();
    
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
    const ENCRYPTION_KEY = getEncryptionKey();
    
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
    const combined = Buffer.from(parts[1], 'base64');
    
    // Extract encrypted data (remove IV from combined)
    const encrypted = combined.slice(IV_LENGTH);
    
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
      const encryptedValue = req.body.encrypted;
      const hasOtherFields = Object.keys(req.body).some(key => key !== 'encrypted');
      
      try {
        // Validate encrypted data format
        if (typeof encryptedValue !== 'string' || !encryptedValue.includes(':')) {
          console.warn('[Decrypt] Invalid encrypted data format');
          // If body only has encrypted field, return error
          // Otherwise, treat as unencrypted and continue
          if (!hasOtherFields) {
            return res.status(400).json({ error: 'Invalid encrypted data format' });
          }
          delete req.body.encrypted;
          return next();
        }
        
        const decryptedData = decrypt(encryptedValue);
        const parsedData = JSON.parse(decryptedData);
        
        // Replace body with decrypted data
        req.body = parsedData;
        req.body._wasEncrypted = true; // Flag to know it was decrypted
      } catch (error) {
        // If decryption fails and body only has encrypted field, return error
        // This means the client intended to send encrypted data but it's invalid
        if (!hasOtherFields) {
          const errorType = error.code === 'ERR_OSSL_BAD_DECRYPT' 
            ? 'Encryption key mismatch or corrupted data' 
            : 'Invalid encrypted data format';
          
          console.error('[Decrypt] Decryption failed for encrypted-only request:', {
            error: error.message,
            errorCode: error.code,
            errorType: errorType,
            encryptedLength: encryptedValue?.length || 0,
            hasEncryptionKey: !!process.env.ENCRYPTION_KEY,
            encryptionKeyLength: process.env.ENCRYPTION_KEY?.length || 0
          });
          
          return res.status(400).json({ 
            error: 'Failed to decrypt request data',
            details: errorType,
            hint: 'Please ensure the ENCRYPTION_KEY environment variable matches between the client and server.'
          });
        }
        
        // If there are other fields, treat as unencrypted request
        console.warn('[Decrypt] Decryption failed but other fields present, treating as unencrypted:', error.message);
        delete req.body.encrypted;
        // Continue with unencrypted data
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


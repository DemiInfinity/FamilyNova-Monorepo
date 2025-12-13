# Encryption Setup Guide

All login and registration requests are now encrypted using AES-256-CBC before being sent to the backend.

## Backend Setup

### 1. Generate Encryption Key

Generate a secure 32-byte (64 hex characters) encryption key:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 2. Set Environment Variable

Add to your `.env` file:

```env
ENCRYPTION_KEY=your-generated-64-character-hex-key-here
```

**Important**: This key must be the same across:
- Backend `.env` file
- iOS apps (stored in `Encryption.swift`)
- Android apps (stored in `Encryption.java`)

## Mobile App Setup

### iOS Apps

1. **Update Encryption Key** in:
   - `apps/ios-kids/FamilyNovaKids/Utils/Encryption.swift`
   - `apps/ios-parent/FamilyNovaParent/Utils/Encryption.swift`

   Replace the default key with your generated key:
   ```swift
   private static let encryptionKey: String = "your-64-character-hex-key-here"
   ```

2. **For Production**: Store the key securely in:
   - Keychain Services
   - Or use environment variables during build

### Android Apps

1. **Update Encryption Key** in:
   - `apps/android-kids/app/src/main/java/com/example/familynova/utils/Encryption.java`
   - `apps/android-parent/app/src/main/java/com/example/familynovaparent/utils/Encryption.java`

   Replace the default key:
   ```java
   private static final String ENCRYPTION_KEY = "your-64-character-hex-key-here";
   ```

2. **For Production**: Store the key securely in:
   - Android Keystore
   - Or use BuildConfig with ProGuard/R8 obfuscation

## How It Works

### Request Flow

1. **Client Side**:
   - User enters email/password
   - App creates JSON: `{ "email": "...", "password": "..." }`
   - App encrypts JSON string using AES-256-CBC
   - App sends: `{ "encrypted": "iv:encryptedData" }`

2. **Backend Side**:
   - Middleware detects `encrypted` field in request body
   - Decrypts the data
   - Parses JSON and processes normally
   - Response is sent normally (not encrypted)

### Encryption Format

- **Algorithm**: AES-256-CBC
- **Format**: `iv:encryptedData` (both base64 encoded)
- **IV**: 16 random bytes (generated per request)
- **Key**: 32 bytes (256 bits)

## Security Notes

1. **HTTPS is Still Required**: This encryption is in addition to HTTPS/TLS, not a replacement
2. **Key Management**: The encryption key must be kept secret and consistent across all clients
3. **Key Rotation**: If you need to rotate keys, you'll need to update all clients simultaneously
4. **Production**: Never commit encryption keys to version control

## Testing

Test encryption/decryption:

```bash
# Backend test
node -e "
const { encrypt, decrypt } = require('./backend/src/utils/encryption');
const test = '{\"email\":\"test@example.com\",\"password\":\"test123\"}';
const encrypted = encrypt(test);
console.log('Encrypted:', encrypted);
console.log('Decrypted:', decrypt(encrypted));
"
```

## Current Implementation Status

✅ **Backend**: Encryption/decryption middleware implemented
✅ **iOS Parent**: Registration encrypted
✅ **iOS Parent**: Login encrypted
⏳ **iOS Kids**: Login needs encryption (AuthManager updated)
⏳ **Android Kids**: Login/Registration need encryption integration
⏳ **Android Parent**: Login/Registration need encryption integration

## Next Steps

1. Update iOS Kids `AuthManager.login()` to use encryption (already done)
2. Update Android login activities to encrypt requests
3. Update Android registration activities to encrypt requests
4. Test end-to-end encryption flow
5. Store encryption keys securely in production


# Production Configuration Setup Guide

This guide will help you configure all applications for production deployment.

## 📋 Overview

Production configuration involves:
1. Backend environment variables
2. API URL configuration in all mobile apps
3. Web app configuration
4. CORS settings
5. Encryption key synchronization

---

## 🔧 Step 1: Backend Production Configuration

### 1.1 Create Production Environment File

```bash
cd backend
cp .env.production.example .env.production
```

### 1.2 Fill in Production Values

Edit `backend/.env.production` with your actual values:

```env
# Supabase (Production)
SUPABASE_URL=https://your-production-project.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-production-service-role-key
SUPABASE_JWT_SECRET=your-production-jwt-secret

# Encryption Key (MUST match all clients)
ENCRYPTION_KEY=your-64-character-hex-key

# CORS (Production domains only)
CORS_ORIGIN=https://app.familynova.com,https://www.familynova.com

# API URL
API_URL=https://api.familynova.com/api

NODE_ENV=production
PORT=3000
```

### 1.3 Generate Encryption Key

The encryption key must be the same across all clients:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

**Important:** Save this key securely and use it in ALL apps (iOS, Android, Web).

---

## 📱 Step 2: iOS Apps Configuration

### 2.1 iOS Kids App

**File:** `apps/ios-kids/FamilyNovaKids/Services/ApiService.swift`

Update the base URL:

```swift
private let baseURL = "https://api.familynova.com/api"  // Production URL
```

**File:** `apps/ios-kids/FamilyNovaKids/Utils/Encryption.swift`

Ensure encryption key matches backend:

```swift
private static let ENCRYPTION_KEY = "your-64-character-hex-key"  // Must match backend
```

### 2.2 iOS Parent App

**File:** `apps/ios-parent/FamilyNovaParent/Services/ApiService.swift`

Update the base URL:

```swift
private let baseURL = "https://api.familynova.com/api"  // Production URL
```

**File:** `apps/ios-parent/FamilyNovaParent/Utils/Encryption.swift`

Ensure encryption key matches backend.

---

## 🤖 Step 3: Android Apps Configuration

### 3.1 Android Kids App

**File:** `apps/android-kids/app/src/main/java/com/nova/kids/services/ApiService.kt`

Update the base URL:

```kotlin
private const val BASE_URL = "https://api.familynova.com/api"  // Production URL
```

**File:** `apps/android-kids/app/src/main/java/com/nova/kids/utils/Encryption.kt`

Ensure encryption key matches backend.

### 3.2 Android Parent App

**File:** `apps/android-parent/app/src/main/java/com/nova/parent/services/ApiService.kt`

Update the base URL:

```kotlin
private const val BASE_URL = "https://api.familynova.com/api"  // Production URL
```

**File:** `apps/android-parent/app/src/main/java/com/nova/parent/utils/Encryption.kt`

Ensure encryption key matches backend.

---

## 🌐 Step 4: Web App Configuration

**File:** `apps/web/next.config.js`

Update API URL:

```javascript
const nextConfig = {
  reactStrictMode: true,
  env: {
    API_URL: process.env.API_URL || 'https://api.familynova.com/api',
  },
}
```

**File:** `apps/web/.env.production`

Create production environment file:

```env
API_URL=https://api.familynova.com/api
NEXT_PUBLIC_API_URL=https://api.familynova.com/api
```

---

## 🔐 Step 5: Encryption Key Synchronization

**CRITICAL:** The encryption key must be identical across:
- ✅ Backend (`ENCRYPTION_KEY`)
- ✅ iOS Kids App (`Encryption.swift`)
- ✅ iOS Parent App (`Encryption.swift`)
- ✅ Android Kids App (`Encryption.kt`)
- ✅ Android Parent App (`Encryption.kt`)
- ✅ Web App (if using encryption)

**How to Sync:**
1. Generate one key using the command above
2. Update all files with the same key
3. Test encryption/decryption works across all platforms

---

## 🌍 Step 6: CORS Configuration

### Backend CORS Settings

**File:** `backend/src/server.js`

Ensure CORS is configured for production:

```javascript
app.use(cors({
  origin: NODE_ENV === 'production' 
    ? CORS_ORIGIN.split(',')  // Array of allowed origins
    : '*',  // Development only
  credentials: true
}));
```

**Allowed Origins (Production):**
- `https://app.familynova.com`
- `https://www.familynova.com`
- `https://familynova.com`

---

## ✅ Step 7: Verification Checklist

Before deploying to production, verify:

- [ ] Backend `.env.production` configured
- [ ] iOS Kids app API URL updated
- [ ] iOS Parent app API URL updated
- [ ] Android Kids app API URL updated
- [ ] Android Parent app API URL updated
- [ ] Web app API URL updated
- [ ] Encryption key synchronized across all apps
- [ ] CORS configured for production domains
- [ ] SSL/TLS certificates configured
- [ ] Domain DNS configured
- [ ] Supabase production project configured
- [ ] All environment variables set in deployment platform (Vercel, etc.)

---

## 🚀 Step 8: Deployment

### Backend Deployment (Vercel)

1. **Set Environment Variables in Vercel:**
   - Go to Vercel Dashboard → Your Project → Settings → Environment Variables
   - Add all variables from `.env.production`
   - Set for "Production" environment

2. **Deploy:**
   ```bash
   cd backend
   vercel --prod
   ```

3. **Verify:**
   ```bash
   curl https://your-api-domain.com/api/health
   ```

### Mobile Apps Deployment

1. **Build Production Versions:**
   - iOS: Archive in Xcode
   - Android: Generate signed APK/AAB

2. **Test Production Builds:**
   - Verify API connectivity
   - Test authentication
   - Test encryption/decryption

3. **Submit to App Stores:**
   - Follow App Store Preparation Guide

---

## 🔍 Step 9: Testing Production Configuration

### Test Checklist

1. **API Connectivity:**
   - [ ] All apps can connect to production API
   - [ ] Health check endpoint responds
   - [ ] Authentication works

2. **Encryption:**
   - [ ] Request encryption works
   - [ ] Response decryption works
   - [ ] Key matches across all platforms

3. **CORS:**
   - [ ] Web app can access API
   - [ ] No CORS errors in browser console

4. **Security:**
   - [ ] HTTPS enforced
   - [ ] Rate limiting active
   - [ ] Security headers present

---

## 📝 Notes

- **Never commit** `.env.production` files to version control
- Use different Supabase projects for development and production
- Rotate encryption keys periodically
- Monitor API logs for errors
- Set up alerts for production issues

---

## 🆘 Troubleshooting

### API Connection Fails
- Check API URL is correct
- Verify SSL certificate is valid
- Check firewall/network settings

### Encryption Errors
- Verify encryption key matches across all apps
- Check key format (64 hex characters)
- Test encryption/decryption manually

### CORS Errors
- Verify CORS_ORIGIN includes your domain
- Check domain format (no trailing slashes)
- Ensure credentials: true is set

---

**Last Updated:** December 2024


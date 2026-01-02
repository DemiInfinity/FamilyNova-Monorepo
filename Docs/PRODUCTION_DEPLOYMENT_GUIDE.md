# FamilyNova - Production Deployment Guide

**Complete guide for deploying FamilyNova to production**

---

## 📋 Pre-Deployment Checklist

- [ ] All environment variables documented
- [ ] Production database configured
- [ ] SSL/TLS certificates obtained
- [ ] Domain configured
- [ ] API URLs updated in all apps
- [ ] Encryption keys synchronized
- [ ] CORS origins configured
- [ ] Monitoring setup
- [ ] Backup strategy in place

---

## 🔧 Step 1: Backend Production Setup

### 1.1 Environment Variables

Create a `.env.production` file (DO NOT commit to Git):

```bash
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_ANON_KEY=your-anon-key

# Encryption (MUST be same across all clients)
ENCRYPTION_KEY=your-64-character-hex-key-generate-with-crypto-randomBytes-32

# CORS (comma-separated for multiple origins)
CORS_ORIGIN=https://familynova.com,https://app.familynova.com,https://kids.familynova.com

# Node Environment
NODE_ENV=production

# Port (if using custom port)
PORT=3000
```

**Generate Encryption Key:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 1.2 Deploy to Vercel

1. **Install Vercel CLI:**
   ```bash
   npm i -g vercel
   ```

2. **Login:**
   ```bash
   vercel login
   ```

3. **Navigate to backend:**
   ```bash
   cd backend
   ```

4. **Deploy:**
   ```bash
   vercel --prod
   ```

5. **Set Environment Variables in Vercel Dashboard:**
   - Go to your project → Settings → Environment Variables
   - Add all variables from `.env.production`
   - Set for "Production" environment

6. **Get Production URL:**
   - Your API will be at: `https://your-project.vercel.app/api`
   - Note this URL for app configuration

### 1.3 Alternative: Deploy to Your Own Server

See `backend/DEPLOYMENT.md` for Docker/Portainer deployment instructions.

---

## 📱 Step 2: Update Mobile Apps with Production API URL

### 2.1 iOS Apps

**iOS Parent App:**
- File: `apps/ios-parent/FamilyNovaParent/Services/ApiService.swift`
- Update `baseURL`:
  ```swift
  static let baseURL = "https://your-project.vercel.app/api"
  ```

**iOS Kids App:**
- File: `apps/ios-kids/FamilyNovaKids/Services/ApiService.swift`
- Update `baseURL`:
  ```swift
  static let baseURL = "https://your-project.vercel.app/api"
  ```

### 2.2 Android Apps

**Android Kids App:**
- File: `apps/android-kids/app/src/main/java/com/nova/kids/services/ApiService.kt`
- Update `BASE_URL`:
  ```kotlin
  private const val BASE_URL = "https://your-project.vercel.app/api/"
  ```

**Android Parent App:**
- File: `apps/android-parent/app/src/main/java/com/nova/parent/services/ApiService.kt`
- Update `BASE_URL`:
  ```kotlin
  private const val BASE_URL = "https://your-project.vercel.app/api/"
  ```

### 2.3 Web App

**Next.js Environment Variables:**
- Create `apps/web/.env.production`:
  ```bash
  NEXT_PUBLIC_API_URL=https://your-project.vercel.app/api
  ```

---

## 🔐 Step 3: Encryption Key Synchronization

**CRITICAL:** The encryption key must be identical across all clients.

1. **Generate once:**
   ```bash
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

2. **Set in backend** (Vercel environment variables)

3. **Set in iOS apps:**
   - File: `apps/ios-parent/FamilyNovaParent/Utils/Encryption.swift`
   - File: `apps/ios-kids/FamilyNovaKids/Utils/Encryption.swift`
   - Update `encryptionKey` constant

4. **Set in Android apps:**
   - Store in `strings.xml` or secure storage
   - File: `apps/android-kids/app/src/main/res/values/strings.xml`
   - Add: `<string name="encryption_key">your-key-here</string>`

5. **Verify:** Test encryption/decryption across all platforms

---

## 🌐 Step 4: CORS Configuration

### 4.1 Update Backend CORS

In `backend/src/server.js`, ensure:
```javascript
const CORS_ORIGIN = process.env.CORS_ORIGIN || '*';

app.use(cors({
  origin: NODE_ENV === 'production' 
    ? CORS_ORIGIN.split(',') 
    : '*',
  credentials: true
}));
```

### 4.2 Set CORS_ORIGIN Environment Variable

In Vercel, set:
```
CORS_ORIGIN=https://familynova.com,https://app.familynova.com,https://kids.familynova.com
```

**For mobile apps:** Leave CORS_ORIGIN as `*` or add mobile app origins if needed.

---

## 🗄️ Step 5: Production Database Setup

### 5.1 Supabase Production Project

1. **Create Supabase Project:**
   - Go to [supabase.com](https://supabase.com)
   - Create new project
   - Note: URL and keys

2. **Run Migrations:**
   ```bash
   cd backend
   # Connect to Supabase and run all migrations
   # See backend/src/db/migrations/
   ```

3. **Set Environment Variables:**
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `SUPABASE_ANON_KEY`

### 5.2 Database Backups

- Enable Supabase automatic backups
- Set up manual backup schedule
- Test restore procedure

---

## 📊 Step 6: Monitoring & Logging

### 6.1 Error Tracking (Sentry)

1. **Create Sentry Project:**
   - Sign up at [sentry.io](https://sentry.io)
   - Create project for each platform

2. **Backend Integration:**
   ```bash
   npm install @sentry/node
   ```
   - Add to `backend/src/server.js`

3. **iOS Integration:**
   - Add Sentry SDK via Swift Package Manager
   - Configure in app delegate

4. **Android Integration:**
   - Add Sentry SDK to `build.gradle`
   - Configure in Application class

### 6.2 Analytics (Optional)

- Firebase Analytics
- Mixpanel
- Amplitude

**Note:** Ensure GDPR compliance for analytics.

---

## 🔒 Step 7: Security Hardening

### 7.1 SSL/TLS

- Vercel provides SSL automatically
- For custom domain: Configure in Vercel dashboard

### 7.2 Security Headers

Already configured in `backend/src/server.js` via Helmet:
- ✅ Content Security Policy
- ✅ HSTS
- ✅ X-Frame-Options
- ✅ X-Content-Type-Options

### 7.3 Rate Limiting

Already configured:
- ✅ API: 1000 requests/hour
- ✅ Auth: 100 requests/hour

### 7.4 Environment Variable Security

- ✅ Never commit `.env` files
- ✅ Use Vercel environment variables
- ✅ Rotate keys regularly
- ✅ Use different keys for dev/staging/prod

---

## 🧪 Step 8: Testing Production Setup

### 8.1 Health Check

```bash
curl https://your-project.vercel.app/api/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2024-12-14T00:00:00.000Z"
}
```

### 8.2 Test Authentication

```bash
curl -X POST https://your-project.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

### 8.3 Test CORS

```bash
curl -H "Origin: https://familynova.com" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -X OPTIONS https://your-project.vercel.app/api/auth/login
```

---

## 📝 Step 9: Documentation Updates

1. **Update API Documentation:**
   - Update base URL in API docs
   - Document production endpoints

2. **Update README:**
   - Add production deployment section
   - Update environment variable documentation

---

## ✅ Post-Deployment Checklist

- [ ] Health check endpoint responding
- [ ] Authentication working
- [ ] All mobile apps connecting to production API
- [ ] CORS configured correctly
- [ ] Encryption working across all platforms
- [ ] Database migrations applied
- [ ] Monitoring active
- [ ] Error tracking configured
- [ ] Backups configured
- [ ] SSL certificate valid
- [ ] Rate limiting active
- [ ] Security headers present

---

## 🚨 Troubleshooting

### API Returns 404
- Check `vercel.json` routing
- Verify `api/index.js` exists
- Check route paths

### CORS Errors
- Verify `CORS_ORIGIN` environment variable
- Check origin matches exactly
- Test with curl

### Encryption Errors
- Verify encryption key is identical across all clients
- Check key length (64 hex characters = 32 bytes)
- Test encryption/decryption

### Database Connection Errors
- Verify Supabase credentials
- Check network connectivity
- Verify database migrations

---

## 📞 Support

For issues, check:
- `backend/VERCEL_DEPLOYMENT.md`
- `backend/DEPLOYMENT.md`
- Vercel documentation
- Supabase documentation

---

**Last Updated:** December 2024


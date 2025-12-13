# FamilyNova Deployment Guide

## Backend Deployment to Portainer

See [backend/DEPLOYMENT.md](backend/DEPLOYMENT.md) for detailed instructions.

### Quick Start

1. **In Portainer:**
   - Go to **Stacks** → **Add Stack**
   - Name: `familynova-backend`
   - Copy contents of `backend/docker-compose.portainer.yml`
   - Paste and deploy

2. **Get Your Server IP:**
   - Note your server's IP address or domain
   - Backend will be at: `http://YOUR_SERVER_IP:3000`

## Configuring Apps to Connect to Backend

### Android Apps

1. **Update API Base URL:**
   - Open `apps/android-kids/app/src/main/res/values/strings.xml`
   - Replace `YOUR_SERVER_IP` with your server IP
   - Or update `apps/android-kids/app/src/main/java/com/example/familynova/api/ApiClient.java`

2. **For Android Parent App:**
   - Same process in `apps/android-parent/`

### iOS Apps

1. **Update API Base URL:**
   - Open `apps/ios-kids/FamilyNovaKids/Services/ApiService.swift`
   - Replace `YOUR_SERVER_IP` with your server IP
   - Or set it in UserDefaults at runtime

2. **For iOS Parent App:**
   - Same process in `apps/ios-parent/FamilyNovaParent/Services/`

### Web App

1. **Update API URL:**
   - Open `apps/web/next.config.js`
   - Replace `YOUR_SERVER_IP` with your server IP
   - Or set `API_URL` environment variable

## Testing the Connection

1. **Test Backend Health:**
   ```bash
   curl http://YOUR_SERVER_IP:3000/api/health
   ```

2. **Test from App:**
   - Run the app
   - Try to register/login
   - Check network logs for API calls

## Security Notes

- **Development:** Using `http://` is fine for testing
- **Production:** Use `https://` with SSL certificate
- **CORS:** Update `CORS_ORIGIN` in backend to your actual domain
- **JWT Secret:** Change default secret in production

## Default Backend Credentials (Change in Production!)

- MongoDB Username: `admin`
- MongoDB Password: `familynova2024`
- JWT Secret: `familynova-secret-key-change-in-production-2024`

**⚠️ IMPORTANT: Change these before deploying to production!**


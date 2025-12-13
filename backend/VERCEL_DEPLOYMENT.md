# Vercel Deployment Guide for FamilyNova Backend

This guide will help you deploy the FamilyNova backend API to Vercel.

## Prerequisites

1. A Vercel account (sign up at [vercel.com](https://vercel.com))
2. Vercel CLI installed (optional, for local testing):
   ```bash
   npm i -g vercel
   ```

## Deployment Steps

### 1. Prepare Your Repository

Make sure your backend code is in a Git repository (GitHub, GitLab, or Bitbucket).

### 2. Deploy via Vercel Dashboard

1. **Go to Vercel Dashboard:**
   - Visit [vercel.com/dashboard](https://vercel.com/dashboard)
   - Click **"Add New Project"**

2. **Import Your Repository:**
   - Select your Git provider
   - Import the repository containing the backend
   - **Important:** Set the **Root Directory** to `backend` (if your backend is in a subdirectory)

3. **Configure Build Settings:**
   - **Framework Preset:** Other
   - **Build Command:** (leave empty or use `npm install`)
   - **Output Directory:** (leave empty)
   - **Install Command:** `npm install`

4. **Set Environment Variables:**
   Click **"Environment Variables"** and add:

   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
   SUPABASE_ANON_KEY=your-anon-key
   ENCRYPTION_KEY=your-64-character-hex-encryption-key
   CORS_ORIGIN=*
   NODE_ENV=production
   ```

   **Important Environment Variables:**
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_SERVICE_ROLE_KEY`: Service role key (for admin operations)
   - `SUPABASE_ANON_KEY`: Anon key (for client operations)
   - `ENCRYPTION_KEY`: 64-character hex encryption key (generate with: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`)
   - `CORS_ORIGIN`: Set to your frontend domain(s) or `*` for development

5. **Deploy:**
   - Click **"Deploy"**
   - Wait for deployment to complete

### 3. Deploy via Vercel CLI (Alternative)

1. **Install Vercel CLI:**
   ```bash
   npm i -g vercel
   ```

2. **Navigate to Backend Directory:**
   ```bash
   cd backend
   ```

3. **Login to Vercel:**
   ```bash
   vercel login
   ```

4. **Deploy:**
   ```bash
   vercel
   ```
   
   Follow the prompts:
   - Link to existing project or create new
   - Confirm settings
   - Deploy

5. **Set Environment Variables:**
   ```bash
   vercel env add SUPABASE_URL
   vercel env add SUPABASE_SERVICE_ROLE_KEY
   vercel env add SUPABASE_ANON_KEY
   vercel env add ENCRYPTION_KEY
   vercel env add CORS_ORIGIN
   ```

6. **Deploy to Production:**
   ```bash
   vercel --prod
   ```

## Project Structure

Vercel expects this structure:

```
backend/
├── api/
│   └── index.js          # Serverless function entry point
├── public/
│   └── index.html        # Landing page
├── src/
│   ├── server.js         # Express app
│   ├── routes/           # API routes
│   ├── models/           # Data models
│   └── ...
├── vercel.json           # Vercel configuration
└── package.json
```

## How It Works

1. **API Routes:** All `/api/*` requests are routed to `api/index.js`
2. **Static Files:** All other requests serve files from `public/`
3. **Serverless:** Each request invokes a serverless function (cold starts may occur)

## Testing Your Deployment

1. **Health Check:**
   ```bash
   curl https://your-project.vercel.app/api/health
   ```

2. **Landing Page:**
   ```bash
   curl https://your-project.vercel.app/
   ```

3. **Test Registration:**
   ```bash
   curl -X POST https://your-project.vercel.app/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{"encrypted": "your-encrypted-data"}'
   ```

## Updating Your Apps

After deployment, update all mobile apps to use the Vercel URL:

### iOS Apps
- `apps/ios-kids/FamilyNovaKids/Services/ApiService.swift`
- `apps/ios-parent/FamilyNovaParent/Services/ApiService.swift`
- Change base URL to: `https://your-project.vercel.app/api`

### Android Apps
- `apps/android-kids/app/src/main/java/com/example/familynova/api/ApiClient.java`
- `apps/android-parent/app/src/main/java/com/example/familynovaparent/api/ApiClient.java`
- Change base URL to: `https://your-project.vercel.app/api`

### Web App
- `apps/web/next.config.js` or environment variables
- Set API URL to: `https://your-project.vercel.app/api`

## Important Notes

### Cold Starts
- First request after inactivity may be slower (cold start)
- Subsequent requests are fast (warm)
- Consider using Vercel Pro for better performance

### Environment Variables
- **Never commit** `.env` files to Git
- Set all secrets in Vercel Dashboard
- Use different keys for production vs development

### Database Connections
- Supabase connections are lazy-loaded per request
- No persistent connections in serverless (this is fine for Supabase)

### CORS
- Update `CORS_ORIGIN` to your actual frontend domains in production
- Use `*` only for development

### Encryption Key
- Must be the same across all clients (iOS, Android, backend)
- Generate once and use everywhere
- Store securely in Vercel environment variables

## Troubleshooting

### Deployment Fails
- Check build logs in Vercel Dashboard
- Ensure all dependencies are in `package.json`
- Verify Node.js version compatibility

### API Returns 404
- Check `vercel.json` routing configuration
- Ensure `api/index.js` exists and exports the Express app
- Verify route paths match your API structure

### Environment Variables Not Working
- Redeploy after adding environment variables
- Check variable names match exactly (case-sensitive)
- Verify values are set in correct environment (Production/Preview/Development)

### Cold Start Issues
- Consider upgrading to Vercel Pro
- Use Vercel Edge Functions for simple routes
- Implement connection pooling if needed

## Production Checklist

- [ ] All environment variables set in Vercel
- [ ] CORS_ORIGIN set to production domains
- [ ] Encryption key synchronized across all clients
- [ ] Supabase credentials configured
- [ ] All apps updated with new API URL
- [ ] Health check endpoint working
- [ ] Test registration/login flow
- [ ] Monitor Vercel logs for errors
- [ ] Set up custom domain (optional)

## Support

- Vercel Docs: [vercel.com/docs](https://vercel.com/docs)
- Vercel Support: [vercel.com/support](https://vercel.com/support)


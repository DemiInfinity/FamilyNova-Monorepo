# FamilyNova Backend Deployment Guide

## Deploying to Portainer

### Prerequisites
- Portainer installed and running
- Access to Portainer web interface
- Docker installed on the server

### Method 1: Using Portainer Stack (Recommended)

1. **Prepare the Stack File**
   - Use `docker-compose.portainer.yml` (already configured with default values)
   - Or customize `docker-compose.yml` with your own values

2. **In Portainer:**
   - Go to **Stacks** → **Add Stack**
   - Name: `familynova-backend`
   - Build method: **Web editor** or **Repository**
   
3. **If using Web Editor:**
   - Copy contents of `docker-compose.portainer.yml`
   - Paste into the editor
   - Click **Deploy the stack**

4. **If using Repository:**
   - Repository URL: Your Git repository URL
   - Compose path: `backend/docker-compose.portainer.yml`
   - Auto-update: Enable if you want automatic updates

5. **Configure Environment Variables (Optional)**
   - Go to Stack → **Editor**
   - Update environment variables as needed:
     - `MONGO_ROOT_PASSWORD`: Change default password
     - `JWT_SECRET`: Change to a secure random string
     - `CORS_ORIGIN`: Set to your frontend domain

6. **Access the API**
   - Backend will be available at: `http://your-server-ip:3000`
   - Health check: `http://your-server-ip:3000/api/health`
   - MongoDB: Internal only (port 27017 not exposed externally)

### Method 2: Using Portainer Container

1. **Build the Image:**
   - Go to **Images** → **Build a new image**
   - Build method: **Upload** or **Repository**
   - If Upload: Upload the `backend/` folder as a tarball
   - If Repository: Use your Git repository

2. **Create MongoDB Container:**
   - Go to **Containers** → **Add container**
   - Name: `familynova-mongodb`
   - Image: `mongo:7.0`
   - Environment variables:
     - `MONGO_INITDB_ROOT_USERNAME=admin`
     - `MONGO_INITDB_ROOT_PASSWORD=familynova2024`
     - `MONGO_INITDB_DATABASE=familynova`
   - Volumes: Create named volume `mongodb_data` for `/data/db`
   - Network: Create network `familynova-network` (bridge)

3. **Create Backend Container:**
   - Go to **Containers** → **Add container**
   - Name: `familynova-backend`
   - Image: Your built image or build from Dockerfile
   - Environment variables:
     - `NODE_ENV=production`
     - `PORT=3000`
     - `MONGODB_URI=mongodb://admin:familynova2024@familynova-mongodb:27017/familynova?authSource=admin`
     - `JWT_SECRET=your-secret-key`
     - `CORS_ORIGIN=*`
   - Ports: Map `3000:3000`
   - Network: Use `familynova-network`
   - Restart policy: `unless-stopped`

### Default Credentials (Change in Production!)

- **MongoDB:**
  - Username: `admin`
  - Password: `familynova2024`
  - Database: `familynova`

- **JWT Secret:** `familynova-secret-key-change-in-production-2024`

### Security Recommendations

1. **Change Default Passwords:**
   - Update MongoDB root password
   - Use a strong JWT secret (32+ random characters)

2. **Configure CORS:**
   - Set `CORS_ORIGIN` to your actual frontend domain
   - Don't use `*` in production

3. **Use Environment Variables:**
   - Store secrets in Portainer environment variables
   - Don't hardcode credentials

4. **Network Security:**
   - MongoDB should not be exposed externally
   - Use reverse proxy (nginx/traefik) for backend
   - Enable SSL/TLS

### Testing the Deployment

1. **Check Health:**
   ```bash
   curl http://your-server-ip:3000/api/health
   ```

2. **Test Registration:**
   ```bash
   curl -X POST http://your-server-ip:3000/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "test123",
       "userType": "kid",
       "firstName": "Test",
       "lastName": "User"
     }'
   ```

3. **Test Login:**
   ```bash
   curl -X POST http://your-server-ip:3000/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "test123"
     }'
   ```

### Updating the Backend

1. **If using Stack:**
   - Update the code in your repository
   - In Portainer: Stack → **Editor** → **Pull and redeploy**

2. **If using Containers:**
   - Rebuild the image
   - Recreate the container

### Troubleshooting

- **Backend won't start:** Check MongoDB is running and healthy
- **Connection refused:** Verify network configuration
- **MongoDB connection error:** Check credentials and network
- **Port already in use:** Change port mapping in Portainer

### Monitoring

- Check container logs in Portainer
- Monitor health checks
- Set up alerts for container restarts


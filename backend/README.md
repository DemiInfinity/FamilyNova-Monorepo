# FamilyNova Backend API

Backend API server for FamilyNova - A safe social networking platform for kids.

## 🚀 Getting Started

### Prerequisites

- Node.js (v16 or higher)
- MongoDB (local or cloud instance)
- npm or yarn

### Installation

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file from `.env.example`:
```bash
cp .env.example .env
```

3. Update `.env` with your configuration:
- Set `MONGODB_URI` to your MongoDB connection string
- Set `JWT_SECRET` to a secure random string
- Configure `PORT` (default: 3000)

4. Start the server:
```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

## 📡 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user (kid or parent)
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user

### Kids
- `GET /api/kids/profile` - Get kid's profile
- `GET /api/kids/friends` - Get kid's friends list

### Parents
- `GET /api/parents/dashboard` - Get parent dashboard
- `GET /api/parents/children/:childId` - Get child's activity
- `GET /api/parents/connections` - Get parent connections

### Friends
- `POST /api/friends/request` - Send friend request (kids only)
- `GET /api/friends/search` - Search for friends

### Messages
- `POST /api/messages` - Send a message (kids only)
- `GET /api/messages` - Get messages
- `PUT /api/messages/:messageId/moderate` - Moderate message (parents only)

### Verification
- `POST /api/verification/parent` - Verify child (parents only)
- `POST /api/verification/school` - School verification

### Health Check
- `GET /api/health` - API health status

## 🔐 Authentication

All protected routes require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

## 📊 Database Models

### User
- Supports both 'kid' and 'parent' user types
- Two-tick verification system (parent + school)
- Friend connections
- Parent-child relationships
- Automatic parent-to-parent connections

### Message
- Messages between kids
- Moderation flags
- Read receipts

## 🛠️ Development

### Project Structure
```
backend/
├── src/
│   ├── config/        # Configuration files
│   ├── controllers/   # Route controllers (future)
│   ├── middleware/    # Auth and other middleware
│   ├── models/        # Database models
│   ├── routes/        # API routes
│   ├── utils/         # Utility functions
│   └── server.js      # Main server file
├── tests/             # Test files
└── package.json
```

## 🔒 Security Features

- JWT authentication
- Password hashing with bcrypt
- Helmet.js for security headers
- CORS configuration
- Input validation with express-validator
- User type-based access control

## 📝 Environment Variables

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `MONGODB_URI` - MongoDB connection string
- `JWT_SECRET` - Secret for JWT tokens
- `JWT_EXPIRES_IN` - Token expiration (default: 7d)
- `CORS_ORIGIN` - Allowed CORS origin

## 🧪 Testing

```bash
npm test
```

## 📄 License

ISC


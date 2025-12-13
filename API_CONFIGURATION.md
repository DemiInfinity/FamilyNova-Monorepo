# API Configuration Summary

All apps are now configured to connect to the backend at:

**Backend URL:** `http://infinityiotserver.local:3000/api`

## Configured Files

### Android Kids App
- ✅ `apps/android-kids/app/src/main/res/values/strings.xml` - API base URL
- ✅ `apps/android-kids/app/src/main/java/com/example/familynova/api/ApiClient.java` - API client

### Android Parent App
- ✅ `apps/android-parent/app/src/main/res/values/strings.xml` - API base URL
- ✅ `apps/android-parent/app/src/main/java/com/example/familynovaparent/api/ApiClient.java` - API client

### iOS Kids App
- ✅ `apps/ios-kids/FamilyNovaKids/Services/ApiService.swift` - API service

### iOS Parent App
- ✅ `apps/ios-parent/FamilyNovaParent/Services/ApiService.swift` - API service

### Web App
- ✅ `apps/web/next.config.js` - API URL configuration

## Testing the Connection

After deploying the backend to Portainer, test with:

```bash
# Health check
curl http://infinityiotserver.local:3000/api/health

# Test registration
curl -X POST http://infinityiotserver.local:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123",
    "userType": "kid",
    "firstName": "Test",
    "lastName": "User"
  }'
```

## Changing the Server IP

If you need to change the server IP in the future, update all the files listed above with the new IP address.


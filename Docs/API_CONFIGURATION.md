# API Configuration Summary

All apps are now configured to connect to the backend at:

**Backend URL:** `https://family-nova-monorepo.vercel.app/api`

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
- ✅ `apps/ios-parent/FamilyNovaParent/Models/AuthManager.swift` - Registration API URL

### Web App
- ✅ `apps/web/next.config.js` - API URL configuration
- ✅ `apps/web/app/schools/page.tsx` - School registration/login API
- ✅ `apps/web/app/schools/dashboard/page.tsx` - School dashboard API

## Testing the Connection

Test the backend API with:

```bash
# Health check
curl https://family-nova-monorepo.vercel.app/api/health

# Test registration
curl -X POST https://family-nova-monorepo.vercel.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123",
    "userType": "kid",
    "firstName": "Test",
    "lastName": "User"
  }'
```

## Changing the API URL

If you need to change the API URL in the future, update all the files listed above with the new URL.


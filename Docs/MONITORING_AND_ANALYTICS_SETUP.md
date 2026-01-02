# FamilyNova - Monitoring & Analytics Setup Guide

**Complete guide for setting up monitoring, analytics, and error tracking**

---

## 📊 Overview

This guide covers:
- Error tracking (Sentry)
- Analytics (Firebase Analytics)
- Performance monitoring
- Logging
- Alerts

---

## 🐛 Error Tracking: Sentry

### Backend Setup

1. **Install Sentry:**
   ```bash
   cd backend
   npm install @sentry/node
   ```

2. **Create Sentry Project:**
   - Go to [sentry.io](https://sentry.io)
   - Create account
   - Create new project → Node.js
   - Copy DSN

3. **Configure in `backend/src/server.js`:**
   ```javascript
   const Sentry = require("@sentry/node");
   
   Sentry.init({
     dsn: process.env.SENTRY_DSN,
     environment: process.env.NODE_ENV || "production",
     tracesSampleRate: 1.0,
   });
   
   // Add before routes
   app.use(Sentry.Handlers.requestHandler());
   app.use(Sentry.Handlers.tracingHandler());
   
   // Add after routes, before error handler
   app.use(Sentry.Handlers.errorHandler());
   ```

4. **Add Environment Variable:**
   ```bash
   SENTRY_DSN=https://your-key@sentry.io/project-id
   ```

5. **Test:**
   ```javascript
   // In a route handler
   throw new Error("Test Sentry error");
   ```

### iOS Setup

1. **Add Sentry via Swift Package Manager:**
   - In Xcode: File → Add Packages
   - URL: `https://github.com/getsentry/sentry-cocoa`
   - Version: Latest

2. **Configure in `FamilyNovaParentApp.swift`:**
   ```swift
   import Sentry
   
   @main
   struct FamilyNovaParentApp: App {
       init() {
           SentrySDK.start { options in
               options.dsn = "https://your-key@sentry.io/project-id"
               options.debug = false
               options.environment = "production"
           }
       }
       
       var body: some Scene {
           // ...
       }
   }
   ```

3. **Repeat for Kids App**

### Android Setup

1. **Add to `build.gradle.kts`:**
   ```kotlin
   dependencies {
       implementation("io.sentry:sentry-android:6.34.0")
   }
   ```

2. **Configure in `Application` class:**
   ```kotlin
   import io.sentry.android.core.SentryAndroid
   
   class NovaApplication : Application() {
       override fun onCreate() {
           super.onCreate()
           
           SentryAndroid.init(this) { options ->
               options.dsn = "https://your-key@sentry.io/project-id"
               options.environment = "production"
               options.isDebug = false
           }
       }
   }
   ```

3. **Add to AndroidManifest.xml:**
   ```xml
   <application
       android:name=".NovaApplication"
       ...>
   ```

---

## 📈 Analytics: Firebase Analytics

### Setup

1. **Create Firebase Project:**
   - Go to [console.firebase.google.com](https://console.firebase.google.com)
   - Create project: "FamilyNova"
   - Enable Google Analytics

2. **Add Apps:**
   - iOS Parent App
   - iOS Kids App
   - Android Kids App
   - Android Parent App

3. **Download Config Files:**
   - iOS: `GoogleService-Info.plist`
   - Android: `google-services.json`

### iOS Integration

1. **Add Firebase SDK:**
   ```bash
   # Via Swift Package Manager
   https://github.com/firebase/firebase-ios-sdk
   ```

2. **Add `GoogleService-Info.plist` to project**

3. **Configure in App:**
   ```swift
   import FirebaseCore
   import FirebaseAnalytics
   
   @main
   struct FamilyNovaParentApp: App {
       init() {
           FirebaseApp.configure()
       }
       
       var body: some Scene {
           // ...
       }
   }
   ```

4. **Log Events:**
   ```swift
   Analytics.logEvent("post_created", parameters: [
       "post_type": "text",
       "user_type": "kid"
   ])
   ```

### Android Integration

1. **Add to `build.gradle.kts`:**
   ```kotlin
   plugins {
       id("com.google.gms.google-services")
   }
   
   dependencies {
       implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
       implementation("com.google.firebase:firebase-analytics-ktx")
   }
   ```

2. **Add `google-services.json` to `app/`**

3. **Log Events:**
   ```kotlin
   import com.google.firebase.analytics.FirebaseAnalytics
   
   val analytics = FirebaseAnalytics.getInstance(this)
   analytics.logEvent("post_created") {
       param("post_type", "text")
       param("user_type", "kid")
   }
   ```

### GDPR Compliance

**Important:** Ensure analytics comply with GDPR:
- ✅ Anonymize IP addresses
- ✅ No personal data in events
- ✅ User consent (if required)
- ✅ Opt-out option

**Configure:**
```swift
// iOS
Analytics.setAnalyticsCollectionEnabled(true) // With consent

// Android
FirebaseAnalytics.getInstance(this).setAnalyticsCollectionEnabled(true)
```

---

## 📊 Performance Monitoring

### Backend: New Relic (Optional)

1. **Sign up:** [newrelic.com](https://newrelic.com)

2. **Install:**
   ```bash
   npm install newrelic
   ```

3. **Configure:**
   ```javascript
   require('newrelic');
   ```

### Application Performance Monitoring

**Backend:**
- Monitor response times
- Track slow queries
- Monitor memory usage
- Track error rates

**Mobile:**
- Monitor app launch time
- Track screen load times
- Monitor API call performance
- Track crash rates

---

## 📝 Logging

### Backend Logging

**Already configured with Morgan:**
```javascript
app.use(morgan('dev')); // Development
app.use(morgan('combined')); // Production
```

**Structured Logging:**
```javascript
const logger = {
  info: (message, data) => {
    console.log(JSON.stringify({
      level: 'info',
      message,
      data,
      timestamp: new Date().toISOString()
    }));
  },
  error: (message, error) => {
    console.error(JSON.stringify({
      level: 'error',
      message,
      error: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString()
    }));
  }
};
```

### Mobile Logging

**iOS:**
```swift
import os.log

let logger = Logger(subsystem: "com.familynova.parent", category: "api")
logger.info("Post created: \(postId)")
logger.error("API error: \(error.localizedDescription)")
```

**Android:**
```kotlin
import android.util.Log

Log.d("FamilyNova", "Post created: $postId")
Log.e("FamilyNova", "API error: ${error.message}")
```

---

## 🚨 Alerts

### Sentry Alerts

1. **Create Alert Rules:**
   - Error rate > threshold
   - New issue detected
   - Performance degradation

2. **Configure Notifications:**
   - Email
   - Slack
   - PagerDuty

### Uptime Monitoring

**Services:**
- UptimeRobot
- Pingdom
- StatusCake

**Setup:**
- Monitor: `https://your-api.vercel.app/api/health`
- Check every 5 minutes
- Alert on downtime

---

## 📈 Key Metrics to Track

### Backend
- Request rate
- Response time (p50, p95, p99)
- Error rate
- Database query time
- Cache hit rate
- API endpoint usage

### Mobile Apps
- Daily active users (DAU)
- Monthly active users (MAU)
- App crashes
- Screen views
- Feature usage
- Session length
- Retention rate

### Business Metrics
- User registrations
- Friend connections
- Posts created
- Messages sent
- Parent approvals
- School verifications

---

## 🔒 Privacy Considerations

### GDPR Compliance
- ✅ Anonymize data
- ✅ No personal identifiers
- ✅ User consent
- ✅ Data retention policies
- ✅ Right to deletion

### COPPA Compliance
- ✅ No tracking of children under 13
- ✅ Parental consent required
- ✅ Limited data collection
- ✅ No third-party sharing

---

## ✅ Setup Checklist

- [ ] Sentry configured (Backend)
- [ ] Sentry configured (iOS Parent)
- [ ] Sentry configured (iOS Kids)
- [ ] Sentry configured (Android Kids)
- [ ] Sentry configured (Android Parent)
- [ ] Firebase Analytics setup
- [ ] Firebase configured (iOS)
- [ ] Firebase configured (Android)
- [ ] Logging configured
- [ ] Alerts configured
- [ ] Uptime monitoring active
- [ ] Privacy compliance verified

---

## 📞 Support

- Sentry: [docs.sentry.io](https://docs.sentry.io)
- Firebase: [firebase.google.com/docs](https://firebase.google.com/docs)

---

**Last Updated:** December 2024


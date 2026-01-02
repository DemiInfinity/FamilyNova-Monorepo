# FamilyNova Monorepo - Workspace Guide

This document provides guidance on working with the FamilyNova monorepo structure.

## 📁 Directory Structure

```
familynova/
├── apps/
│   ├── android-kids/      # Android app for children
│   ├── android-parent/    # Android app for parents
│   ├── ios-kids/         # iOS app for children
│   ├── ios-parent/       # iOS app for parents
│   └── web/              # Web application
├── packages/
│   └── shared/           # Shared code and utilities
├── README.md             # Main project README
├── WORKSPACE.md          # This file
└── .gitignore            # Git ignore rules
```

## 🚀 Getting Started

### Android Apps

#### Android Kids App
```bash
cd apps/android-kids
./gradlew build
```

Open in Android Studio:
1. File → Open
2. Select `apps/android-kids/` directory
3. Sync Gradle files

#### Android Parent App
🚧 Coming soon - Will follow the same structure as android-kids

### iOS Apps

🚧 Coming soon - iOS apps will be developed using Xcode

### Web Application

🚧 Coming soon - Web app framework to be determined

### Shared Packages

🚧 Coming soon - Shared code will be developed as needed for cross-platform functionality

## 🔧 Development Workflow

### Working on Android Apps

1. Navigate to the specific app directory (`apps/android-kids/` or `apps/android-parent/`)
2. Open in Android Studio
3. Make your changes
4. Build and test locally
5. Commit changes with clear messages indicating which app was modified

### Working on iOS Apps

1. Navigate to the specific app directory (`apps/ios-kids/` or `apps/ios-parent/`)
2. Open the `.xcodeproj` or `.xcworkspace` file in Xcode
3. Make your changes
4. Build and test locally
5. Commit changes with clear messages

### Working on Web App

1. Navigate to `apps/web/`
2. Follow the framework-specific setup instructions
3. Run the development server
4. Make your changes
5. Commit changes

### Working with Shared Packages

1. Navigate to `packages/shared/`
2. Make changes to shared code
3. Update dependent apps if necessary
4. Test across all platforms that use the shared code
5. Commit changes

## 📦 Building All Apps

### Android
```bash
# Build kids app
cd apps/android-kids && ./gradlew build

# Build parent app (when ready)
cd apps/android-parent && ./gradlew build
```

### iOS
```bash
# Build kids app (when ready)
cd apps/ios-kids && xcodebuild ...

# Build parent app (when ready)
cd apps/ios-parent && xcodebuild ...
```

### Web
```bash
# Build web app (when ready)
cd apps/web && npm run build
```

## 🧪 Testing

Each app should have its own test suite:
- Android: Unit tests and instrumented tests
- iOS: Unit tests and UI tests
- Web: Unit tests and integration tests

Run tests from each app's directory.

## 📝 Commit Conventions

When committing changes, use prefixes to indicate which part of the monorepo was modified:

- `[android-kids]` - Changes to Android kids app
- `[android-parent]` - Changes to Android parent app
- `[ios-kids]` - Changes to iOS kids app
- `[ios-parent]` - Changes to iOS parent app
- `[web]` - Changes to web application
- `[shared]` - Changes to shared packages
- `[docs]` - Documentation updates
- `[config]` - Configuration changes

Example:
```
[android-kids] Add login screen UI
[shared] Update user authentication types
[docs] Update README with new features
```

## 🔗 Cross-Platform Considerations

- **Shared Business Logic**: Place in `packages/shared/`
- **API Clients**: Consider shared API client libraries
- **Data Models**: Use shared type definitions where possible
- **Authentication**: Coordinate authentication flow across platforms
- **Backend Integration**: Ensure all apps use the same API endpoints

## 🛠️ Tools & Setup

### Required Tools

- **Android Development**: Android Studio, JDK 17+
- **iOS Development**: Xcode (when iOS apps are developed)
- **Web Development**: Node.js, npm/yarn (when web app is developed)
- **Version Control**: Git

### Recommended Tools

- **Monorepo Management**: Consider tools like Nx, Turborepo, or Lerna if the monorepo grows
- **Code Sharing**: Consider Kotlin Multiplatform or shared TypeScript/JavaScript for business logic

## 📚 Additional Resources

- See individual app READMEs for app-specific documentation
- See root [README.md](../README.md) for project overview
- Check each app's directory for specific setup instructions


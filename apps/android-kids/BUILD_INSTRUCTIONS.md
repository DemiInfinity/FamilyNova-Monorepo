# Build Instructions for Nova Android App

## Prerequisites

1. **Java 11 or Higher** - Required for Android Gradle Plugin 8.x
2. **Android SDK** - Installed via Android Studio

## Setting JAVA_HOME

The build requires Java 11+. If you have Android Studio installed, you can use its bundled JDK:

```bash
export JAVA_HOME="/Applications/Development/Android Studio.app/Contents/jbr/Contents/Home"
```

Or add this to your `~/.zshrc` or `~/.bash_profile`:
```bash
export JAVA_HOME="/Applications/Development/Android Studio.app/Contents/jbr/Contents/Home"
```

## Building the Project

### Command Line

```bash
cd apps/android-kids

# Set JAVA_HOME (if not already set)
export JAVA_HOME="/Applications/Development/Android Studio.app/Contents/jbr/Contents/Home"

# Make gradlew executable (first time only)
chmod +x gradlew

# Build the project
./gradlew build

# Or build and install on connected device/emulator
./gradlew installDebug
```

### Android Studio

1. Open Android Studio
2. File → Open → Select `apps/android-kids` folder
3. Android Studio will automatically use its bundled JDK
4. Sync Gradle files (File → Sync Project with Gradle Files)
5. Run the app (green play button or Shift+F10)

## Troubleshooting

### "JAVA_HOME is set to an invalid directory"
- Make sure Android Studio is installed at the path specified
- Or install Java 11+ and set JAVA_HOME to that installation

### "Permission denied: ./gradlew"
```bash
chmod +x gradlew
```

### Build errors about missing resources
- Old XML layout files have been removed (we're using Jetpack Compose)
- Old menu files have been removed (we're using Compose Navigation)

## Project Status

✅ Kotlin compilation successful
✅ All core components implemented
✅ Cosmic design system applied
✅ Navigation structure in place

The app should build and run successfully!


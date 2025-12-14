# Android Setup Guide

## Prerequisites

### Java 11 or Higher Required

The Android build requires **Java 11 or higher**. Your system currently has Java 8 installed.

### Installing Java 11+ on macOS

#### Option 1: Using Homebrew (Recommended)
```bash
brew install openjdk@11
```

Then set JAVA_HOME:
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
```

#### Option 2: Download from Oracle/Adoptium
1. Visit https://adoptium.net/
2. Download OpenJDK 11 or higher for macOS
3. Install the package
4. Set JAVA_HOME:
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
```

#### Option 3: Use Android Studio's Bundled JDK
If you have Android Studio installed, it includes a JDK:
```bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
```

### Verify Java Version
```bash
java -version
```
Should show version 11 or higher.

### Make gradlew Executable
```bash
chmod +x gradlew
```

## Building the Project

After installing Java 11+:

```bash
cd apps/android-kids
./gradlew build
```

## Running in Android Studio

1. Open Android Studio
2. File → Open → Select `apps/android-kids` folder
3. Android Studio will use its bundled JDK automatically
4. Sync Gradle files
5. Run the app


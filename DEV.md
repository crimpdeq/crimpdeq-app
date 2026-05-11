# Development Guide

## Prerequisites

- Flutter SDK (stable channel)
- JDK 17 (`brew install --cask temurin@17`)
- Android command-line tools (`brew install --cask android-commandlinetools`)
- Android SDK 36 with platform-tools, build-tools, and cmdline-tools

### Android SDK setup

```bash
# Install SDK components
sdkmanager --sdk_root=$HOME/Library/Android/sdk \
  "platform-tools" "platforms;android-36" "build-tools;36.0.0" "cmdline-tools;latest"

# Point Flutter at the SDK
flutter config --android-sdk $HOME/Library/Android/sdk

# Accept licenses
flutter doctor --android-licenses
```

## Build & Deploy to Android

Connect your phone via USB with **USB Debugging** enabled:

1. Settings > About Phone > Software Information > tap "Build Number" 7x
2. Settings > Developer Options > enable "USB Debugging"
3. Connect USB cable, accept the authorization prompt on the phone
4. Set USB mode to **File Transfer / MTP** (swipe down notification)

```bash
# Verify device is detected
flutter devices

# Build and install debug APK
JAVA_HOME=$(/usr/libexec/java_home -v 17) flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

> **Note:** `JAVA_HOME` override is needed if your default JDK is not 17. Gradle requires JDK 17.

## Iterating

After code changes, rebuild and reinstall:

```bash
JAVA_HOME=$(/usr/libexec/java_home -v 17) flutter build apk --debug && \
  adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Close the app on the phone (swipe from recents) and reopen to pick up the new build.

## Reading device logs

```bash
# Clear old logs
adb logcat -c

# Stream Flutter logs (filter by tag)
adb logcat -s flutter

# Or capture to file for a fixed duration
timeout 30 adb logcat | grep "flutter" > /tmp/app_logs.txt
```

`adb` lives at `$HOME/Library/Android/sdk/platform-tools/adb` if not on your PATH.

## Code generation

After modifying `@freezed` classes or Riverpod providers:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Protocol package tests

```bash
cd packages/crimpdeq_protocol && dart test
```

## Static analysis

```bash
flutter analyze
```

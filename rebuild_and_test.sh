#!/bin/bash

# Script to rebuild and test the Android app with device panel fixes
# Run this after applying the fixes

set -e  # Exit on error

echo "════════════════════════════════════════════════════════════"
echo "🔧 Rebuilding ZeroTech Flutter App - Android Device Panel Fix"
echo "════════════════════════════════════════════════════════════"
echo ""

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "📍 Working directory: $SCRIPT_DIR"
echo ""

# Step 1: Flutter clean
echo "🧹 Step 1/5: Cleaning Flutter build..."
flutter clean
echo "✅ Flutter clean completed"
echo ""

# Step 2: Android Gradle clean
echo "🧹 Step 2/5: Cleaning Android Gradle build..."
cd android
./gradlew clean
cd ..
echo "✅ Android Gradle clean completed"
echo ""

# Step 3: Flutter pub get
echo "📦 Step 3/5: Getting Flutter dependencies..."
flutter pub get
echo "✅ Flutter dependencies updated"
echo ""

# Step 4: Build Android debug APK
echo "🔨 Step 4/5: Building Android debug APK..."
echo "⏳ This may take a few minutes..."
flutter build apk --debug
echo "✅ Android debug APK built successfully"
echo ""

# Step 5: Install and run
echo "📱 Step 5/5: Installing and running on connected device..."
echo ""
echo "Make sure you have a device connected via USB or emulator running!"
echo ""
read -p "Press ENTER to install and run, or Ctrl+C to cancel..."
echo ""

flutter run --debug

echo ""
echo "════════════════════════════════════════════════════════════"
echo "🎉 Build and deployment complete!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📝 What to test:"
echo "  1. Log in to your Tuya account"
echo "  2. Navigate to the home screen with devices"
echo "  3. Tap on any device card"
echo "  4. The device control panel should load (not stuck on loading)"
echo ""
echo "🔍 Check logs for:"
echo "  ✅ 'D/TuyaSDK: Setting current family context' (not 'FamilyService not found')"
echo "  ✅ 'D/TuyaSDK: ✅ Panel opened successfully'"
echo "  ✅ Device control panel displays correctly"
echo ""
echo "❌ If you still see 'FamilyService not found':"
echo "  - Check that android/app/build.gradle.kts has 'thingsmart-bizbundle-family'"
echo "  - Try running this script again"
echo ""


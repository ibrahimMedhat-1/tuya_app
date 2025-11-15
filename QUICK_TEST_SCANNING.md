# Quick Test: Device Scanning

## 🚀 Quick Start - Test Scanning in 5 Minutes

### ✅ Prerequisites
- Device with Tuya SDK installed
- Android phone or iOS device
- At least ONE Tuya-compatible smart device to test with

---

## 📱 Android Testing

### Step 1: Connect Device & Start Logging
```bash
# Connect your Android phone via USB
adb devices

# Start logging (keep this terminal open)
adb logcat | grep TuyaSDK
```

### Step 2: Prepare Smart Device
```
1. Power on your smart device
2. Press and hold RESET button for 5 seconds
3. Wait for LED to flash rapidly (pairing mode)
```

### Step 3: Test in App
```
1. Open ZeroTech app
2. Tap "Add Device" or "Pair Device"
3. Watch the logs in terminal
```

### Step 4: Verify Scanning Works
**Look for these logs:**
```
✅ All permissions granted, starting device activator
✅ BizBundle device pairing UI started successfully

OR (if BizBundle fails):

✅ Device scanning started successfully
   Make sure devices are in pairing mode!
   Scan will run for 120 seconds
```

### Step 5: Check Device Discovery
**When device is found, you'll see:**
```
═══════════════════════════════════════
✅ Device FOUND!
   Name: Smart Light
   UUID: abc123...
   Product ID: xyz789
   Type: WiFi
═══════════════════════════════════════
```

---

## 🍎 iOS Testing

### Step 1: Open Xcode Console
```
1. Connect iPhone/iPad via USB
2. Open Xcode
3. Window → Devices and Simulators
4. Select your device
5. Click "Open Console" button
```

### Step 2: Filter Logs
```
In Xcode console, search for: "iOS-NSLog"
```

### Step 3: Prepare Smart Device
```
1. Power on your smart device
2. Press and hold RESET button for 5 seconds
3. Wait for LED to flash rapidly (pairing mode)
```

### Step 4: Test in App
```
1. Open ZeroTech app on iPhone/iPad
2. Tap "Add Device" or "Pair Device"
3. Watch the logs in Xcode console
```

### Step 5: Verify Scanning Works
**Look for these logs:**
```
✅ [iOS-NSLog] Current home confirmed: 123456
🔍 [iOS-NSLog] Starting auto-discovery scan...
   Scanning for Wi-Fi and Bluetooth devices in pairing mode
   Scan duration: 120 seconds
✅ [iOS-NSLog] Device pairing UI launched successfully
   Auto-discovery scan running in background
```

---

## 🔍 Quick Troubleshooting

### No Logs Appearing?

**Android:**
```bash
# Try clearing logcat and start fresh
adb logcat -c
adb logcat | grep TuyaSDK
```

**iOS:**
```
1. Close and reopen Xcode console
2. Restart the app
3. Check "All Messages" not filtered
```

### No Device Found?

**Check these 5 things:**
1. ✅ Device LED is flashing (pairing mode)
2. ✅ Phone Bluetooth is ON
3. ✅ Phone Location is ON
4. ✅ App has all permissions granted
5. ✅ Device is within 10 meters of phone

**Quick permission check (Android):**
```bash
adb shell pm list permissions -d -g | grep -i "location\|bluetooth"
```

### BizBundle UI Not Opening?

**Android - Check dependencies:**
```bash
cd /Users/rebuy/Desktop/Coding\ projects/ZeroTech-Flutter-IB2/android
./gradlew :app:dependencies | grep bizbundle
```

**iOS - Check pods:**
```bash
cd /Users/rebuy/Desktop/Coding\ projects/ZeroTech-Flutter-IB2/ios
pod list | grep Thing
```

---

## 📊 Expected Results

### Successful Scan (Android)

```
TuyaSDK: Starting device active action
TuyaSDK: User is logged in, checking permissions
TuyaSDK: All permissions granted, starting device activator
TuyaSDK: Attempting to start BizBundle device pairing UI
TuyaSDK: BizBundle device pairing UI started successfully

# If BizBundle fails, you'll see:
TuyaSDK: BizBundle UI failed, falling back to core scanning
TuyaSDK: Starting device scan with 120 second timeout
TuyaSDK: Scanning for Wi-Fi and Bluetooth devices...
TuyaSDK: ✅ Device scanning started successfully

# When device is found:
TuyaSDK: ═══════════════════════════════════════
TuyaSDK: ✅ Device FOUND!
TuyaSDK:    Name: Smart Light
TuyaSDK:    UUID: abc-123-def-456
TuyaSDK:    Product ID: xyz789
TuyaSDK:    Type: WiFi
TuyaSDK: ═══════════════════════════════════════
```

### Successful Scan (iOS)

```
[iOS-NSLog] 🔧 Starting device pairing flow with auto-discovery
[iOS-NSLog] ✅ Current home confirmed: 123456
[iOS-NSLog] 🔍 Starting auto-discovery scan...
[iOS-NSLog]    Scanning for Wi-Fi and Bluetooth devices in pairing mode
[iOS-NSLog]    Scan duration: 120 seconds
[iOS-NSLog] ✅ Home instance created for discovery
[iOS-NSLog]    Home ID: 123456
[iOS-NSLog]    Devices in home: 5
[iOS-NSLog] ✅ ThingActivatorProtocol service found
[iOS-NSLog] ✅ Device pairing UI launched successfully
[iOS-NSLog]    Auto-discovery scan running in background
[iOS-NSLog]    Scan will run for 120 seconds
```

---

## 🎯 Quick Commands Reference

### Android

```bash
# Connect and start logging
adb devices && adb logcat | grep TuyaSDK

# Check permissions
adb shell dumpsys package com.zerotechiot.eg | grep permission

# Clear app data (fresh start)
adb shell pm clear com.zerotechiot.eg

# Restart app
adb shell am force-stop com.zerotechiot.eg
adb shell am start -n com.zerotechiot.eg/.MainActivity
```

### iOS

```bash
# Install pods
cd ios && pod install && cd ..

# Build and run
flutter run

# Clean build
flutter clean && flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Both Platforms

```bash
# Full clean rebuild
flutter clean
flutter pub get
flutter run

# Check Flutter doctor
flutter doctor -v
```

---

## 📋 Testing Checklist

### Before Testing
- [ ] Device in pairing mode (LED flashing)
- [ ] Phone Bluetooth enabled
- [ ] Phone Location services enabled
- [ ] App permissions granted
- [ ] Logged into app
- [ ] Home created in app

### During Testing
- [ ] Logs appearing in console
- [ ] "Starting device pairing" log appears
- [ ] Scan starts successfully
- [ ] Device discovered within 30 seconds
- [ ] Device information logged correctly

### After Testing
- [ ] Device appears in app UI
- [ ] Can select and pair device
- [ ] Pairing completes successfully
- [ ] Device shows in device list

---

## 🔧 Debug Mode

### Enable Detailed Logging

**Android (MainActivity.kt):**
```kotlin
// Already enabled - logs use Log.d()
// View with: adb logcat | grep TuyaSDK
```

**iOS (AppDelegate.swift):**
```swift
#if DEBUG
ThingSmartSDK.sharedInstance().debugMode = true
#endif
// Already enabled in AppDelegate
```

---

## 📞 Need Help?

### Can't Find Logs?

**Android:**
```bash
# Try broader search
adb logcat | grep -i "tuya\|device\|scan"
```

**iOS:**
```
# In Xcode console
Search for: "tuya" or "device" or "scan"
```

### Still No Devices Found?

1. **Read full guide:** `DEVICE_PAIRING_GUIDE.md`
2. **Check permissions:** `TUYA_SDK_PERMISSIONS.md`
3. **Review implementation:** `SCANNING_IMPLEMENTATION_SUMMARY.md`

### Report Issues

Create detailed report with:
- Platform (Android/iOS)
- OS version
- App logs
- Steps to reproduce
- Expected vs actual behavior

---

## ✅ Success Criteria

**Scanning is working if:**
- ✅ Logs show "Device scanning started successfully"
- ✅ Scan runs for 120 seconds
- ✅ Device found within 30 seconds (when in pairing mode)
- ✅ Device information logged correctly
- ✅ No crashes or errors

**Pairing is working if:**
- ✅ BizBundle UI opens
- ✅ Can select device from list
- ✅ Pairing completes successfully
- ✅ Device appears in home device list

---

## 🎉 You're Done!

If you see device discovery logs and devices appearing in the app, **scanning is working!**

**Next Steps:**
1. Test with different device types (Wi-Fi, Bluetooth)
2. Test pairing flow end-to-end
3. Test on different Android/iOS versions
4. Build and test release version

---

**Testing Time:** ~5 minutes  
**Documentation:** Complete  
**Support:** Available  

**Happy Testing! 🚀**


# Tuya SDK Permissions Documentation

## Overview
This document describes all the permissions required for the Tuya Smart Home SDK integration in both Android and iOS platforms. All permissions have been implemented according to the official Tuya documentation.

**Official Tuya Documentation References:**
- [Tuya App SDK Documentation](https://developer.tuya.com/en/docs/app-development/preparation/preparation?id=Ka69nt983bhh5)
- [Android Bluetooth BLE Documentation](https://developer.tuya.com/en/docs/app-development/android-bluetooth-ble?id=Karv7r2ju4c21)
- [Tuya Smart Home SDK](https://support.tuya.com/en/help/_detail/Kamw6wganpgt2)

---

## Android Permissions (`AndroidManifest.xml`)

### Network Permissions
**Purpose:** Essential for device communication, cloud connectivity, and Wi-Fi configuration during device pairing.

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE"/>
```

**Why needed:**
- `INTERNET` - Required for all cloud communication with Tuya servers
- `ACCESS_NETWORK_STATE` - Monitor network connectivity status
- `ACCESS_WIFI_STATE` - Read Wi-Fi network information
- `CHANGE_WIFI_STATE` - Configure device Wi-Fi during pairing (EZ mode, AP mode)
- `CHANGE_NETWORK_STATE` - Modify network settings during device configuration

---

### Bluetooth Permissions

#### Legacy Bluetooth (Android 11 and below)
```xml
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30"/>
```

#### New Bluetooth Permissions (Android 12+, API 31+)
**Purpose:** Required for pairing and controlling Bluetooth and BLE smart devices.

```xml
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
    android:usesPermissionFlags="neverForLocation"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE"/>
```

**Why needed:**
- `BLUETOOTH_CONNECT` - Connect to paired Bluetooth devices
- `BLUETOOTH_SCAN` - Discover and scan for BLE devices during pairing
- `BLUETOOTH_ADVERTISE` - Advertise as a Bluetooth peripheral (required for some device types)

**Note:** The `neverForLocation` flag indicates that Bluetooth scanning is not used for location purposes, which can help with privacy compliance.

---

### Location Permissions
**Purpose:** Required for Wi-Fi pairing and BLE device discovery. This is a Google/Android requirement, not a Tuya limitation.

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**Why needed:**
- Wi-Fi SSID information is considered location data by Android
- Bluetooth scanning can reveal device locations
- Required for EZ mode and AP mode device pairing

---

### Camera Permissions
**Purpose:** QR code scanning for device pairing.

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="true"/>
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false"/>
```

**Why needed:**
- Scan QR codes on device packaging for quick pairing
- Some devices require QR code activation

---

### Storage Permissions
**Purpose:** Critical for BizBundle panel extraction and device panel resources.

```xml
<!-- For Android 12 and below -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />

<!-- For Android 13+ (API 33+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

**Why needed:**
- Download and extract device control panels (BizBundle)
- Store device panel resources locally
- Cache device images and videos

---

### Additional System Permissions

#### Wake Lock & Vibration
```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
```

**Why needed:**
- `WAKE_LOCK` - Keep device awake during critical operations (device pairing, firmware updates)
- `VIBRATE` - Haptic feedback for user interactions and notifications

#### Foreground Services
```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE" />
```

**Why needed:**
- Run background services for device monitoring
- Maintain connections during device pairing
- Handle location-based automation

#### Notifications
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

**Why needed:**
- Device status notifications
- Automation trigger notifications
- Security alerts (Android 13+ requirement)

#### OTA Updates
```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

**Why needed:**
- Install firmware updates for smart devices
- Update device control panels

---

### Bluetooth Features
```xml
<uses-feature android:name="android.hardware.bluetooth" android:required="false"/>
<uses-feature android:name="android.hardware.bluetooth_le" android:required="false"/>
```

**Why needed:**
- Declare Bluetooth hardware support
- Set to `required="false"` to allow installation on non-Bluetooth devices
- App will gracefully handle absence of Bluetooth

---

## iOS Permissions (`Info.plist`)

### Location Permissions
**Purpose:** Required for Wi-Fi network information retrieval during device pairing.

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need location access to retrieve Wi-Fi network information for device pairing</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need location access to retrieve Wi-Fi network information for device pairing</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access to retrieve Wi-Fi network information for device pairing</string>
```

**Why needed:**
- iOS requires location permission to access Wi-Fi SSID
- Essential for EZ mode and AP mode pairing

---

### Camera Permission
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan QR codes for device pairing</string>
```

**Why needed:**
- QR code scanning for device activation

---

### Photo Library Permissions
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access for device panels</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save photos from device panels</string>
```

**Why needed:**
- Access photos for device configuration
- Save snapshots from camera devices

---

### Microphone Permission
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for video communication with camera devices</string>
```

**Why needed:**
- Two-way audio with camera devices (IPC/doorbell)
- Video call functionality

---

### Bluetooth Permissions
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>We need Bluetooth access to pair and control Bluetooth devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>We need Bluetooth access to pair and control Bluetooth devices</string>
```

**Why needed:**
- Pair and control BLE smart devices
- Bluetooth mesh network support

---

### Local Network Permissions
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>We need local network access to discover and control smart devices</string>
```

**Why needed:**
- Device discovery on local network
- Control devices via LAN

---

### Bonjour Services
```xml
<key>NSBonjourServices</key>
<array>
    <string>_tuya._tcp</string>
    <string>_tuyasmart._tcp</string>
</array>
```

**Why needed:**
- mDNS device discovery
- Local device communication

---

### Optional Permissions

#### Speech Recognition (Optional)
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>We need speech recognition access for voice control features</string>
```

**Use case:** Voice control for smart devices

#### Face ID (Optional)
```xml
<key>NSFaceIDUsageDescription</key>
<string>We use Face ID to secure your account access</string>
```

**Use case:** Biometric authentication for app security

#### Calendar & Reminders (Optional)
```xml
<key>NSCalendarsUsageDescription</key>
<string>We need calendar access to schedule device automation</string>
<key>NSRemindersUsageDescription</key>
<string>We need reminders access to set up device automation reminders</string>
```

**Use case:** Schedule-based automation and reminders

---

## Permission Request Best Practices

### Android
1. **Runtime Permissions:** Request dangerous permissions at runtime when needed
2. **Permission Rationale:** Show explanation before requesting permissions
3. **Graceful Degradation:** Handle permission denial gracefully
4. **Target SDK 34:** All permissions are compatible with Android 14+

### iOS
1. **Just-in-Time:** Request permissions when the feature is used
2. **Clear Descriptions:** Provide clear, user-friendly permission descriptions
3. **Privacy Manifest:** Consider adding a privacy manifest for App Store review
4. **Minimum iOS 13.0:** All permissions compatible with iOS 13.0+

---

## Verification Checklist

### Android
- ✅ All Bluetooth permissions (legacy + Android 12+)
- ✅ Location permissions (FINE + COARSE)
- ✅ Network permissions (Wi-Fi state + change)
- ✅ Camera permission for QR scanning
- ✅ Storage permissions (with SDK version restrictions)
- ✅ Foreground service permissions
- ✅ Notification permission (Android 13+)
- ✅ OTA update permission
- ✅ Bluetooth features declared

### iOS
- ✅ Location permissions (all variants)
- ✅ Bluetooth permissions (Always + Peripheral)
- ✅ Camera permission
- ✅ Photo library permissions
- ✅ Microphone permission
- ✅ Local network permission
- ✅ Bonjour services configured
- ✅ Optional permissions added

---

## SDK Versions

### Android
- **Min SDK:** 26 (Android 8.0)
- **Target SDK:** Latest (as per Flutter configuration)
- **Tuya SDK:** 6.7.3
- **BizBundle BOM:** 6.7.31

### iOS
- **Minimum iOS Version:** 13.0
- **Tuya SDK:** 6.7.0
- **Deployment Target:** 13.0

---

## Testing Recommendations

1. **Test on Different Android Versions:**
   - Android 8-11 (legacy Bluetooth permissions)
   - Android 12+ (new Bluetooth permissions)
   - Android 13+ (notification permissions)

2. **Test on Different iOS Versions:**
   - iOS 13.0+
   - Latest iOS version

3. **Test Permission Flows:**
   - First-time permission requests
   - Permission denial handling
   - Settings redirect for denied permissions

4. **Test Device Types:**
   - Wi-Fi devices (EZ mode, AP mode)
   - Bluetooth/BLE devices
   - Camera devices (IPC)
   - Mesh devices

---

## Common Issues & Solutions

### Android
**Issue:** Bluetooth scanning not working on Android 12+
**Solution:** Ensure BLUETOOTH_SCAN, BLUETOOTH_CONNECT, and ACCESS_FINE_LOCATION are granted

**Issue:** Wi-Fi pairing fails
**Solution:** Verify CHANGE_WIFI_STATE and location permissions are granted

**Issue:** Device panels not loading
**Solution:** Check storage permissions and network connectivity

### iOS
**Issue:** Cannot get Wi-Fi SSID
**Solution:** Location permission must be granted

**Issue:** Bluetooth devices not discovered
**Solution:** Ensure NSBluetoothAlwaysUsageDescription is in Info.plist and permission is granted

**Issue:** Local network discovery fails
**Solution:** Add Bonjour services to Info.plist

---

## References

1. [Tuya Developer Platform](https://developer.tuya.com/)
2. [Android Bluetooth Permissions](https://developer.android.com/guide/topics/connectivity/bluetooth/permissions)
3. [iOS App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
4. [Tuya SDK Integration Guide](https://support.tuya.com/en/help/_detail/Kamw6wganpgt2)

---

**Last Updated:** 2025-11-15
**Tuya SDK Version:** 6.7.x
**Project:** ZeroTech Smart Home


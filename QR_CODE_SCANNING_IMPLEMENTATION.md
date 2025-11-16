# QR Code Scanning Implementation for Tuya BizBundle UI

## Overview

QR code scanning functionality has been added to the Tuya BizBundle device pairing UI for both Android and iOS platforms. This enables users to quickly pair devices by scanning their QR codes directly within the pairing interface.

## Implementation Details

### Android Implementation

**Dependencies Added:**
- `thingsmart-bizbundle-qrcode_mlkit` - QR code scanning BizBundle using ML Kit
- Camera permission handling restored for QR code scanning

**Changes Made:**

1. **`android/app/build.gradle.kts`**
   ```kotlin
   // QR Code BizBundle - REQUIRED for QR code scanning in device pairing UI
   implementation("com.thingclips.smart:thingsmart-bizbundle-qrcode_mlkit") {
       exclude(group = "com.gyf.immersionbar", module = "immersionbar")
       exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
   }
   ```

2. **`MainActivity.kt`**
   - Restored camera permission checks in `checkPermissions()`
   - Restored camera permission requests in `requestPermissions()`
   - Enhanced logging to indicate QR code scanning availability

**How It Works:**
- The Tuya BizBundle device activator UI (`ThingDeviceActivatorManager.startDeviceActiveAction()`) automatically includes QR code scanning when the QR code BizBundle dependency is present
- Camera permission is checked and requested before opening the pairing UI
- Users can access QR code scanning directly from the pairing interface

### iOS Implementation

**Status:** ✅ Already Implemented

The iOS implementation already includes QR code scanning:
- `ThingSmartActivatorBizBundle` pod includes `ThingQRCodeModule` as a dependency
- QR code scanning is automatically available in the device pairing UI
- Camera permissions are already configured in `Info.plist`

## Official Documentation References

- **Android/iOS QR Code Pairing**: https://developer.tuya.com/en/docs/app-development/activator_mqttdirectly_ios?id=Kcy5fd1gt4htl
- **Device Pairing UI BizBundle**: https://images.tuyacn.com/goat/pdf/1696668809127/Device%20Pairing%20UI%20BizBundle_IoT%20App%20SDK_IoT%20App%20SDK.pdf

## Permissions Required

### Android
- `CAMERA` - Required for QR code scanning
- `ACCESS_FINE_LOCATION` - Required for device pairing
- `BLUETOOTH_SCAN` / `BLUETOOTH_CONNECT` - Required for Bluetooth device pairing (Android 12+)

### iOS
- `NSCameraUsageDescription` - Already configured in `Info.plist`
- Location permissions - Already configured

## Usage

### From Flutter/Dart

```dart
// Open device pairing UI (includes QR code scanning)
await platform.invokeMethod('pairDevices');
```

The BizBundle UI will automatically show:
1. Device category selection (Wi-Fi, Bluetooth, etc.)
2. QR code scanning option
3. Manual device scanning option

### User Flow

1. User calls `pairDevices()` from Flutter
2. App checks and requests camera permission (if needed)
3. Tuya BizBundle pairing UI opens
4. User can:
   - **Scan QR Code**: Tap QR code scan button → Camera opens → Scan device QR code → Device pairs automatically
   - **Scan for Devices**: Tap scan button → Devices in pairing mode are discovered → Select device to pair

## QR Code Scanning Process

Per Tuya documentation, the QR code scanning process:

1. **Parse QR Code**: Extract device UUID from QR code URL
2. **Register Pairing Type**: Determine if device is directly connected (MQTT) or Bluetooth
3. **Start Searching**: Begin device discovery with UUID
4. **Activate Device**: Once device is found, activate and bind to home

The BizBundle UI handles all these steps automatically when a QR code is scanned.

## Testing Checklist

### Android
- [ ] Build app with new QR code BizBundle dependency
- [ ] Install on device/emulator
- [ ] Open device pairing UI
- [ ] Verify QR code scan button appears
- [ ] Test QR code scanning with a Tuya device
- [ ] Verify camera permission is requested if not granted
- [ ] Verify device pairs successfully after scanning

### iOS
- [ ] Verify QR code scanning is available in pairing UI
- [ ] Test QR code scanning with a Tuya device
- [ ] Verify device pairs successfully after scanning

## Troubleshooting

### QR Code Scan Button Not Appearing
- **Cause**: QR code BizBundle dependency not included
- **Solution**: Ensure `thingsmart-bizbundle-qrcode_mlkit` is in `build.gradle.kts`

### Camera Permission Denied
- **Cause**: Camera permission not granted
- **Solution**: App automatically requests permission before opening pairing UI

### QR Code Scan Fails
- **Cause**: Invalid QR code or device not in pairing mode
- **Solution**: Ensure device is in pairing mode and QR code is valid Tuya device QR code

### Build Errors
- **Cause**: Missing dependencies or version conflicts
- **Solution**: Ensure all BizBundle dependencies use the same BOM version

## Summary

✅ **Android**: QR code BizBundle added, camera permissions restored  
✅ **iOS**: Already includes QR code scanning via `ThingSmartActivatorBizBundle`  
✅ **Integration**: QR code scanning automatically available in BizBundle pairing UI  
✅ **Permissions**: Camera permission properly handled on both platforms

The QR code scanning feature is now fully integrated into the Tuya BizBundle device pairing UI on both platforms.




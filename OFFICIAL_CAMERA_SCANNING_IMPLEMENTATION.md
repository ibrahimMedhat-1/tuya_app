# Official Tuya Camera Scanning Implementation

## Based on Official Tuya Documentation

This document outlines the implementation of camera scanning in the Tuya BizBundle device activator UI, following the official Tuya SDK documentation.

## Official Documentation References

- **Device Activator BizBundle**: https://developer.tuya.com/en/docs/app-development/activator
- **Integration Guide**: https://developer.tuya.com/en/docs/app-development/integration?id=Ka8qhzk13vkfq
- **Device Pairing UI BizBundle**: Official PDF documentation

---

## Implementation Steps (Per Official Docs)

### 1. ✅ Required Configuration File

**File**: `android/app/src/main/assets/activator_auto_search_capacity.json`

```json
{
  "autoSearch": true,
  "searchTypes": [
    "WIFI",
    "BLE",
    "BLE_MESH",
    "ZIGBEE",
    "ZIGBEE_MESH"
  ],
  "enableQRCodeScan": true,
  "enableCameraScan": true
}
```

**Purpose**: This file configures the device activator BizBundle to:
- Enable auto-discovery of devices
- Enable QR code scanning
- Enable camera scanning
- Support multiple device types (WiFi, BLE, Zigbee, etc.)

---

### 2. ✅ Camera Permission (CRITICAL)

**AndroidManifest.xml**:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false"/>
<uses-feature android:name="android.hardware.camera.any" android:required="false"/>
```

**Runtime Permission Request** (in `MainActivity.kt`):
```kotlin
// CRITICAL: Check camera permission BEFORE opening BizBundle UI
if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) 
    != PackageManager.PERMISSION_GRANTED) {
    permissions.add(Manifest.permission.CAMERA)
    // Request permission
    ActivityCompat.requestPermissions(this, permissions.toTypedArray(), 1001)
}
```

**Why Critical**: The BizBundle UI will crash with a white screen if camera permission is not granted when the user presses the scan button.

---

### 3. ✅ BizBundle Initialization

**TuyaSmartApplication.kt**:
```kotlin
// Initialize BizBundle with error listeners
BizBundleInitializer.init(
    this,
    object : RouteEventListener {
        override fun onFaild(errorCode: Int, error: UrlBuilder?) {
            Log.e(TAG, "BizBundle route failed: $errorCode")
        }
    },
    object : ServiceEventListener {
        override fun onFaild(serviceName: String?) {
            Log.e(TAG, "BizBundle service failed: $serviceName")
        }
    }
)

// Register Family Service (REQUIRED for device pairing)
BizBundleInitializer.registerService(
    AbsBizBundleFamilyService::class.java,
    BizBundleFamilyServiceImpl()
)
```

**Purpose**: 
- Initializes the BizBundle system
- Registers error listeners to catch initialization failures
- Registers family service to provide home context

---

### 4. ✅ Home Context Setup (REQUIRED)

**Before opening device activator UI**:
```kotlin
// CRITICAL: Device activator requires a home context
val familyService = serviceManager.findServiceByInterface(
    AbsBizBundleFamilyService::class.java.name
) as? AbsBizBundleFamilyService

if (familyService.currentHomeId <= 0) {
    // Get first home from user's home list
    ThingHomeSdk.getHomeManagerInstance().queryHomeList(object : IThingGetHomeListCallback {
        override fun onSuccess(homeBeans: MutableList<HomeBean>?) {
            if (!homeBeans.isNullOrEmpty()) {
                val firstHome = homeBeans[0]
                familyService.shiftCurrentFamily(firstHome.homeId, firstHome.name)
            }
        }
        override fun onError(code: String?, error: String?) {
            // Handle error
        }
    })
}
```

**Why Required**: The device activator needs to know which home to add the device to. Without a home context, pairing will fail.

---

### 5. ✅ Opening Device Activator UI

**Official Method** (in `MainActivity.kt`):
```kotlin
// Per official Tuya documentation
// This opens the full device pairing UI with camera scanning support
ThingDeviceActivatorManager.startDeviceActiveAction(this)
```

**What This Does**:
- Opens the Tuya BizBundle device pairing UI
- Provides multiple pairing methods:
  - QR code scanning (camera)
  - Manual entry
  - Auto-discovery
  - Network configuration
- Handles all pairing logic internally

---

### 6. ✅ Permissions Checklist

Before calling `ThingDeviceActivatorManager.startDeviceActiveAction()`, ensure:

- ✅ **CAMERA** permission granted (for QR code scanning)
- ✅ **ACCESS_FINE_LOCATION** permission granted (for Wi-Fi and BLE pairing)
- ✅ **BLUETOOTH_SCAN** permission granted (Android 12+)
- ✅ **BLUETOOTH_CONNECT** permission granted (Android 12+)
- ✅ **BLUETOOTH_ADVERTISE** permission granted (Android 12+)
- ✅ **POST_NOTIFICATIONS** permission granted (Android 13+)
- ✅ Storage permissions granted (for BizBundle resource extraction)

---

## Complete Flow

1. **User clicks "Pair Device"** in Flutter app
2. **Flutter calls** `pairDevices()` method channel
3. **Android checks** all required permissions
4. **If permissions missing**: Request permissions, wait for grant
5. **After permissions granted**: 
   - Verify home context is set
   - If no home, get first home from user's home list
   - Set home context via `familyService.shiftCurrentFamily()`
6. **Call** `ThingDeviceActivatorManager.startDeviceActiveAction(this)`
7. **Tuya BizBundle UI opens** with pairing options
8. **User presses "Scan" button**
9. **Camera opens** (permission already granted)
10. **User scans QR code**
11. **Device pairs automatically**

---

## Troubleshooting

### White Screen When Pressing Scan Button

**Causes**:
1. ❌ Camera permission not granted
2. ❌ Missing `activator_auto_search_capacity.json` file
3. ❌ BizBundle not properly initialized
4. ❌ Home context not set

**Solutions**:
1. ✅ Add CAMERA permission check and request
2. ✅ Create `activator_auto_search_capacity.json` in assets
3. ✅ Verify BizBundle initialization in Application class
4. ✅ Ensure home is set before opening activator UI

### Camera Doesn't Open

**Causes**:
1. ❌ Camera permission denied
2. ❌ Camera feature marked as required="true" (prevents emulator install)
3. ❌ Missing camera hardware (emulator without camera)

**Solutions**:
1. ✅ Check permission status in app settings
2. ✅ Set `android:required="false"` for camera features
3. ✅ Test on physical device with camera

### Crash on Scan Button

**Causes**:
1. ❌ SecurityException: Camera permission not granted
2. ❌ Missing Google Maps service (for location-based features)
3. ❌ BizBundle service not initialized

**Solutions**:
1. ✅ Request camera permission BEFORE opening BizBundle UI
2. ✅ Add Google Maps BizBundle dependencies
3. ✅ Verify all BizBundle services are registered

---

## Files Modified

1. **`android/app/src/main/assets/activator_auto_search_capacity.json`** (NEW)
   - Configuration for device activator auto-search and camera scanning

2. **`android/app/src/main/AndroidManifest.xml`**
   - Camera permissions and features
   - QR code scan meta-data

3. **`android/app/src/main/kotlin/com/zerotechiot/eg/MainActivity.kt`**
   - Added CAMERA permission check and request
   - Enhanced home context setup
   - Proper error handling

4. **`android/app/src/main/kotlin/com/zerotechiot/eg/TuyaSmartApplication.kt`**
   - Enhanced BizBundle initialization with error listeners

5. **`android/app/build.gradle.kts`**
   - Google Maps BizBundle dependencies (for location services)

---

## Testing Checklist

- [ ] Build app successfully
- [ ] Install on device/emulator
- [ ] Open app and login
- [ ] Navigate to device pairing
- [ ] Verify camera permission prompt appears
- [ ] Grant camera permission
- [ ] Verify Tuya BizBundle UI opens
- [ ] Press "Scan" button
- [ ] Verify camera opens (not white screen)
- [ ] Scan a device QR code
- [ ] Verify device pairs successfully

---

## Summary

Following the official Tuya documentation, the camera scanning feature requires:

1. ✅ **Configuration file** (`activator_auto_search_capacity.json`)
2. ✅ **Camera permission** (declared + runtime request)
3. ✅ **Proper BizBundle initialization** (with error listeners)
4. ✅ **Home context** (set before opening activator UI)
5. ✅ **Official method** (`ThingDeviceActivatorManager.startDeviceActiveAction()`)

All of these have been implemented according to the official Tuya SDK documentation.


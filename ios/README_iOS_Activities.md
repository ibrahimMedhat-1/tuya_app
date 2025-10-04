# iOS Activities for Tuya Smart Home SDK

This document describes the iOS equivalent activities created for the Tuya Smart Home Flutter project.

## Overview

The iOS project now includes native view controllers that replicate the functionality of Android activities:

- **HomeViewController** - Equivalent to Android HomeActivity
- **DeviceControlViewController** - Equivalent to Android DeviceControlActivity  
- **AddDeviceViewController** - Equivalent to Android AddDeviceActivity
- **SettingsViewController** - Equivalent to Android SettingsActivity

## Architecture

### Tuya SDK Version
- **iOS**: ThingSmartHomeKit v6.2.0 (latest stable version)
- **Android**: TuyaHomeSdk v3.25.0

### Flutter Integration
All iOS activities are accessible through Flutter method channels:

```dart
// Open Home Activity
await TuyaSdkPlugin.openHomeActivity();

// Open Device Control Activity
await TuyaSdkPlugin.openDeviceControlActivity(deviceId);

// Open Add Device Activity  
await TuyaSdkPlugin.openAddDeviceActivity();

// Open Settings Activity
await TuyaSdkPlugin.openSettingsActivity();
```

## Activity Details

### 1. HomeViewController
**Purpose**: Main home screen displaying homes and devices

**Features**:
- Lists all user homes
- Displays devices for selected home
- Device status indicators (online/offline)
- Navigation to device control
- Pull-to-refresh functionality
- Add device and settings navigation

**Key Methods**:
- `loadHomesAndDevices()` - Loads homes and devices
- `loadDevices(for:)` - Loads devices for specific home
- `refreshData()` - Refreshes device list

### 2. DeviceControlViewController
**Purpose**: Individual device control and monitoring

**Features**:
- Device information display
- Power control (switch)
- Brightness control (slider)
- Color control (color picker)
- Temperature display
- Custom controls based on device capabilities
- Real-time device status updates

**Key Methods**:
- `loadDeviceData()` - Loads device data points
- `updateControlUI()` - Updates control interface
- `powerSwitchChanged(_:)` - Handles power toggle
- `brightnessSliderChanged(_:)` - Handles brightness changes

### 3. AddDeviceViewController
**Purpose**: Device pairing and addition

**Features**:
- Device discovery via WiFi scanning
- QR code scanning for device pairing
- Device pairing process
- Camera permission handling
- Pairing status feedback

**Key Methods**:
- `startDeviceScanning()` - Starts device discovery
- `pairDevice(_:)` - Pairs selected device
- `presentQRCodeScanner()` - Shows QR scanner
- `processQRCode(_:)` - Processes scanned QR codes

### 4. SettingsViewController
**Purpose**: App settings and user management

**Features**:
- User information display
- Home management
- App settings (notifications, privacy, about)
- Account actions (change password, logout)
- Settings navigation

**Key Methods**:
- `loadUserData()` - Loads user information
- `loadHomes()` - Loads user homes
- `performLogout()` - Handles user logout

## Permissions Required

The iOS app requires the following permissions (configured in Info.plist):

```xml
<!-- Camera for QR code scanning -->
<key>NSCameraUsageDescription</key>
<string>This app requires camera access to scan QR codes for device pairing</string>

<!-- Photo library for device images -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires photo library access to save and share device images</string>

<!-- Location for device discovery -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app requires location access to find nearby devices for pairing</string>

<!-- Microphone for voice control -->
<key>NSMicrophoneUsageDescription</key>
<string>This app requires microphone access for voice control and device communication</string>

<!-- Bluetooth for device connection -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app requires Bluetooth access to connect with smart devices</string>

<!-- Local network for device discovery -->
<key>NSLocalNetworkUsageDescription</key>
<string>This app requires local network access to discover and connect to devices</string>
```

## Dependencies

### Podfile Configuration
```ruby
platform :ios, '11.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  # Tuya Smart SDK v6.2.0 (latest stable version)
  pod 'ThingSmartHomeKit', '~> 6.2.0'
  
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

## Usage

### 1. Install Dependencies
```bash
cd ios
pod install
```

### 2. Build and Run
```bash
flutter run
```

### 3. Test Activities
Use the Flutter demo page buttons to test each activity:
- "Open Home Activity" - Shows home and device list
- "Open Add Device Activity" - Shows device pairing interface
- "Open Settings Activity" - Shows settings and user management

## Error Handling

All activities include comprehensive error handling:
- Network errors during device operations
- Permission denials for camera/location
- Device pairing failures
- SDK initialization errors

## Customization

### UI Customization
- Modify `HomeTableViewCell` and `DeviceTableViewCell` for custom device list appearance
- Update `createControlView` in `DeviceControlViewController` for custom device controls
- Customize navigation bar appearance in each view controller

### Functionality Extension
- Add new device control types in `DeviceControlViewController`
- Implement additional pairing methods in `AddDeviceViewController`
- Add new settings sections in `SettingsViewController`

## Troubleshooting

### Common Issues

1. **SDK Initialization Fails**
   - Verify app key and secret are correct
   - Check network connectivity
   - Ensure proper bundle identifier

2. **Device Discovery Fails**
   - Check location permissions
   - Verify WiFi connectivity
   - Ensure devices are in pairing mode

3. **Device Control Fails**
   - Verify device is online
   - Check device data point format
   - Ensure proper device permissions

### Debug Mode
Enable debug mode in `AppDelegate.swift`:
```swift
ThingSmartSDK.sharedInstance().debugMode = true
```

## Future Enhancements

- Real-time device status updates
- Push notifications for device events
- Voice control integration
- Scene automation
- Device grouping and rooms
- Advanced device analytics

## Support

For issues related to:
- **Tuya SDK**: Check [Tuya Developer Documentation](https://developer.tuya.com/)
- **iOS Implementation**: Review this documentation and code comments
- **Flutter Integration**: Check method channel implementation in `AppDelegate.swift`

# Tuya Smart Home Flutter Integration

This project demonstrates the integration of Tuya Smart Home SDK with Flutter using the official Tuya Home Android SDK sample as reference.

## Implementation Details

This project integrates Tuya Smart Home SDK v6.2.0 with Flutter using platform channels. The implementation follows the official [Tuya Home Android SDK Sample (Kotlin)](https://github.com/tuya/tuya-home-android-sdk-sample-kotlin).

### Key Components

1. **Android Native Implementation**
   - `TuyaSmartApplication.kt`: Initializes the Tuya SDK with SHA256 security verification
   - `MainActivity.kt`: Provides platform channel methods for Flutter communication

2. **Flutter Implementation**
   - `tuya_sdk_plugin.dart`: Flutter interface for the Tuya SDK
   - `TuyaSDKService`: Service class for Tuya SDK operations

## Setup Requirements

### 1. Tuya Developer Account
- Register at [Tuya IoT Platform](https://iot.tuya.com/)
- Create a project and get your AppKey and AppSecret

### 2. SHA256 Security Verification
- Generate SHA256 hash for your signing key
- Add the hash to your Tuya IoT project
- Update the SHA256 values in `TuyaSmartApplication.kt`

### 3. Signing Configuration
- Update the signing configuration in `android/app/build.gradle`
- For development, you can use the debug keystore

## Key Features

- User Registration and Login
- Device Network Configuration (EZ and AP mode)
- Device Control via LAN and MQTT
- Home Management

## Getting Started

1. Update the AppKey and AppSecret in `lib/data/services/tuya_sdk_service.dart`
2. Update the SHA256 hash values in `android/app/src/main/kotlin/com/zerotechiot/smart_home_tuya/TuyaSmartApplication.kt`
3. Run the app on an Android device

## References

- [Tuya Home Android SDK Sample (Kotlin)](https://github.com/tuya/tuya-home-android-sdk-sample-kotlin)
- [Tuya Developer Documentation](https://developer.tuya.com/en/docs/app-development/android-app-sdk/featureoverview?id=Ka69nt97vtsfu)

## License

This project is for demonstration purposes only. Use of the Tuya SDK is subject to Tuya's terms and conditions.

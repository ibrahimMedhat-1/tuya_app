import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// TuyaSdkPlugin provides Flutter interface for the Tuya Smart Home SDK
class TuyaSdkPlugin {
  static const MethodChannel _channel = MethodChannel('tuya_flutter_sdk');

  /// Initialize the Tuya SDK with your app key and secret
  /// These values can be obtained from the Tuya IoT Platform
  static Future<bool> initTuyaSDK({
    required String appKey,
    required String appSecret,
    String? packageName,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('initTuyaSDK', {
        'appKey': appKey,
        'appSecret': appSecret,
        'packageName': packageName,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('Error initializing Tuya SDK: $e');
      return false;
    }
  }

  /// Register a new user with email and password
  static Future<Map<String, dynamic>?> registerWithEmail({
    required String email,
    required String password,
    String countryCode = '1',
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'registerWithEmail',
        {
          'email': email,
          'password': password,
          'countryCode': countryCode,
        },
      );
      return result?.cast<String, dynamic>();
    } catch (e) {
      debugPrint('Error registering user: $e');
      rethrow;
    }
  }

  /// Login with email and password
  static Future<Map<String, dynamic>?> loginWithEmail({
    required String email,
    required String password,
    String countryCode = '1',
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'loginWithEmail',
        {
          'email': email,
          'password': password,
          'countryCode': countryCode,
        },
      );
      return result?.cast<String, dynamic>();
    } catch (e) {
      debugPrint('Error logging in: $e');
      rethrow;
    }
  }

  /// Logout the current user
  static Future<void> logout() async {
    try {
      await _channel.invokeMethod('logout');
    } catch (e) {
      debugPrint('Error logging out: $e');
      rethrow;
    }
  }

  /// Check if a user is currently logged in
  static Future<bool> isLoggedIn() async {
    try {
      final result = await _channel.invokeMethod<bool>('isLoggedIn');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  /// Get the platform version
  static Future<String?> getPlatformVersion() async {
    try {
      return await _channel.invokeMethod<String>('getPlatformVersion');
    } catch (e) {
      debugPrint('Error getting platform version: $e');
      return null;
    }
  }

  /// Open Home Activity (iOS equivalent of Android HomeActivity)
  static Future<void> openHomeActivity() async {
    try {
      await _channel.invokeMethod('openHomeActivity');
    } catch (e) {
      debugPrint('Error opening Home Activity: $e');
      rethrow;
    }
  }

  /// Open Device Control Activity (iOS equivalent of Android DeviceControlActivity)
  static Future<void> openDeviceControlActivity(String deviceId) async {
    try {
      await _channel.invokeMethod('openDeviceControlActivity', {'deviceId': deviceId});
    } catch (e) {
      debugPrint('Error opening Device Control Activity: $e');
      rethrow;
    }
  }

  /// Open Add Device Activity (iOS equivalent of Android AddDeviceActivity)
  static Future<void> openAddDeviceActivity() async {
    try {
      await _channel.invokeMethod('openAddDeviceActivity');
    } catch (e) {
      debugPrint('Error opening Add Device Activity: $e');
      rethrow;
    }
  }

  /// Open Settings Activity (iOS equivalent of Android SettingsActivity)
  static Future<void> openSettingsActivity() async {
    try {
      await _channel.invokeMethod('openSettingsActivity');
    } catch (e) {
      debugPrint('Error opening Settings Activity: $e');
      rethrow;
    }
  }

  /// Start device discovery for pairing
  static Future<String> startDeviceDiscovery(String homeId) async {
    try {
      final result = await _channel.invokeMethod<String>('startDeviceDiscovery', {'homeId': homeId});
      return result ?? 'Device discovery started';
    } catch (e) {
      debugPrint('Error starting device discovery: $e');
      rethrow;
    }
  }

  /// Stop device discovery
  static Future<void> stopDeviceDiscovery() async {
    try {
      await _channel.invokeMethod('stopDeviceDiscovery');
    } catch (e) {
      debugPrint('Error stopping device discovery: $e');
      rethrow;
    }
  }

  /// Pair a device to a home
  static Future<String> pairDevice({
    required String homeId,
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('pairDevice', {
        'homeId': homeId,
        'deviceId': deviceId,
        'deviceName': deviceName,
      });
      return result ?? 'Device paired successfully';
    } catch (e) {
      debugPrint('Error pairing device: $e');
      rethrow;
    }
  }

  /// Get list of homes
  static Future<List<Map<String, dynamic>>> getHomes() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getHomes');
      return result?.cast<Map<dynamic, dynamic>>().map((home) => home.cast<String, dynamic>()).toList() ?? [];
    } catch (e) {
      debugPrint('Error getting homes: $e');
      return [];
    }
  }

  /// Get devices for a specific home
  static Future<List<Map<String, dynamic>>> getDevices(String homeId) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getDevices', {'homeId': homeId});
      return result?.cast<Map<dynamic, dynamic>>().map((device) => device.cast<String, dynamic>()).toList() ?? [];
    } catch (e) {
      debugPrint('Error getting devices: $e');
      return [];
    }
  }
} 
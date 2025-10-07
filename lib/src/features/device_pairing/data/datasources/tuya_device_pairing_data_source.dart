import 'package:tuya_app/src/core/utils/app_imports.dart';
import 'package:tuya_app/src/core/utils/constants.dart';

class TuyaDevicePairingDataSource {
  /// Start device pairing process (checks prerequisites)
  Future<Map<String, dynamic>> startDevicePairing() async {
    try {
      final result = await AppConstants.channel.invokeMethod(
        'startDevicePairing',
      );
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    } catch (e) {
      throw Exception('Failed to start device pairing: ${e.toString()}');
    }
  }

  /// Open Tuya BizBundle Device Pairing UI
  /// This launches the pre-built Tuya UI for complete device pairing
  Future<Map<String, dynamic>> openDevicePairingUI() async {
    try {
      final result = await AppConstants.channel.invokeMethod(
        'openDevicePairingUI',
      );
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    } catch (e) {
      throw Exception('Failed to open device pairing UI: ${e.toString()}');
    }
  }

  /// Scan QR code for device pairing
  Future<Map<String, dynamic>> scanQRCode() async {
    try {
      final result = await AppConstants.channel.invokeMethod('scanQRCode');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    } catch (e) {
      throw Exception('Failed to scan QR code: ${e.toString()}');
    }
  }

  /// Start WiFi pairing with device
  Future<Map<String, dynamic>> startWifiPairing({
    required String ssid,
    required String password,
    required String token,
  }) async {
    try {
      final result = await AppConstants.channel.invokeMethod(
        'startWifiPairing',
        {'ssid': ssid, 'password': password, 'token': token},
      );
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    } catch (e) {
      throw Exception('Failed to start WiFi pairing: ${e.toString()}');
    }
  }

  /// Stop device pairing process
  Future<Map<String, dynamic>> stopDevicePairing() async {
    try {
      final result = await AppConstants.channel.invokeMethod(
        'stopDevicePairing',
      );
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    } catch (e) {
      throw Exception('Failed to stop device pairing: ${e.toString()}');
    }
  }

  /// Get device specifications (Data Points schema)
  Future<Map<String, dynamic>> getDeviceSpecifications(String deviceId) async {
    try {
      final result = await AppConstants.channel.invokeMethod(
        'getDeviceSpecifications',
        {'deviceId': deviceId},
      );
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    } catch (e) {
      throw Exception('Failed to get device specifications: ${e.toString()}');
    }
  }

  Exception _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NOT_LOGGED_IN':
        return Exception('User must be logged in to pair devices');
      case 'PERMISSION_DENIED':
        return Exception('Required permissions not granted: ${e.message}');
      case 'PAIRING_ERROR':
        return Exception('Device pairing error: ${e.message}');
      case 'QR_SCAN_ERROR':
        return Exception('QR scan error: ${e.message}');
      case 'WIFI_PAIRING_ERROR':
        return Exception('WiFi pairing error: ${e.message}');
      case 'PAIRING_FAILED':
        return Exception('Device pairing failed: ${e.message}');
      case 'STOP_PAIRING_ERROR':
        return Exception('Failed to stop pairing: ${e.message}');
      case 'INVALID_ARGUMENTS':
        return Exception('Invalid arguments: ${e.message}');
      default:
        return Exception('Platform error: ${e.message}');
    }
  }
}

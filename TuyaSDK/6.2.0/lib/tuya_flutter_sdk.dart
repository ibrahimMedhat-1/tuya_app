import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tuya_flutter_sdk/tuya_flutter_sdk_platform_interface.dart';

/// The main class for interacting with the Tuya Smart Home SDK
class TuyaFlutterSdk {
  static const MethodChannel _channel = MethodChannel('tuya_flutter_sdk');

  /// Returns the version of the platform (Android/iOS)
  static Future<String?> getPlatformVersion() {
    return _channel.invokeMethod<String>('getPlatformVersion');
  }
  
  /// Initialize the Tuya SDK
  /// This should be called early in your app's lifecycle
  static Future<bool> initTuyaSDK() async {
    final result = await _channel.invokeMethod<bool>('initTuyaSDK');
    return result ?? false;
  }
} 
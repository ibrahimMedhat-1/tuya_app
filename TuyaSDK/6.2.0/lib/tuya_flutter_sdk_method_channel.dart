import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tuya_flutter_sdk/tuya_flutter_sdk_platform_interface.dart';

/// An implementation of [TuyaFlutterSdkPlatform] that uses method channels.
class MethodChannelTuyaFlutterSdk extends TuyaFlutterSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tuya_flutter_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  
  @override
  Future<bool> initTuyaSDK() async {
    final result = await methodChannel.invokeMethod<bool>('initTuyaSDK');
    return result ?? false;
  }
} 
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class TuyaFlutterSdkPlatform extends PlatformInterface {
  TuyaFlutterSdkPlatform() : super(token: _token);

  static final Object _token = Object();
  static TuyaFlutterSdkPlatform _instance = MethodChannelTuyaFlutterSdk();

  static TuyaFlutterSdkPlatform get instance => _instance;

  static set instance(TuyaFlutterSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  
  Future<bool> initTuyaSDK() {
    throw UnimplementedError('initTuyaSDK() has not been implemented.');
  }
}

class MethodChannelTuyaFlutterSdk extends TuyaFlutterSdkPlatform {
  @override
  Future<String?> getPlatformVersion() async {
    return "Not implemented";
  }
  
  @override
  Future<bool> initTuyaSDK() async {
    return false;
  }
} 
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import '../../domain/entities/user.dart';

/// Service to interact with the Tuya SDK through platform channels
/// This uses the Tuya SDK v3.25.0
class TuyaSDKService {
  static const MethodChannel _channel = MethodChannel('tuya_flutter_sdk');
  
  // Real Tuya AppKey and AppSecret from the developer platform
  // Android keys
  static const String _androidAppKey = 'xvtf3fqw93d37sucppkn';
  static const String _androidAppSecret = 'k8u9edtefgrwcmxqaesra9gmmpuh8uy';
  
  // iOS keys 
  static const String _iosAppKey = 'm7q5wupkcc55e4wamdxr';
  static const String _iosAppSecret = 'u53dy9rhuv4vqkz93g3cyuf9pcixvag9c';
  
  // Package Name / Bundle ID
  static const String _packageName = 'com.zerotechiot.smart_home_tuya';
  
  String get _appKey => Platform.isIOS ? _iosAppKey : _androidAppKey;
  String get _appSecret => Platform.isIOS ? _iosAppSecret : _androidAppSecret;
  
  /// Initialize the Tuya SDK with the appropriate platform-specific keys
  Future<bool> initSDK() async {
    try {
      final bool result = await _channel.invokeMethod('initTuyaSDK', {
        'appKey': _appKey,
        'appSecret': _appSecret,
        'packageName': _packageName,
      });
      print('TuyaSDK v3.25.0 initialized: $result');
      return result;
    } on PlatformException catch (e) {
      print('Failed to initialize TuyaSDK v3.25.0: ${e.message}');
      return false;
    }
  }

  /// Register a new user with email
  /// Using Tuya SDK v3.25.0 email registration flow
  Future<User?> registerWithEmail(String email, String password, String countryCode) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('registerWithEmail', {
        'email': email,
        'password': password,
        'countryCode': countryCode,
      });
      
      return User(
        id: result['id'],
        email: result['email'],
        username: result['username'],
      );
    } on PlatformException catch (e) {
      print('Failed to register: ${e.message}');
      throw Exception('Registration failed: ${e.message}');
    }
  }

  /// Login with email
  /// Using Tuya SDK v3.25.0 email login flow
  Future<User?> loginWithEmail(String email, String password, String countryCode) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('loginWithEmail', {
        'email': email,
        'password': password,
        'countryCode': countryCode,
      });
      
      return User(
        id: result['id'],
        email: result['email'],
        username: result['username'],
      );
    } on PlatformException catch (e) {
      print('Failed to login: ${e.message}');
      throw Exception('Login failed: ${e.message}');
    }
  }
  
  /// Logout the current user
  /// Using Tuya SDK v3.25.0 logout flow
  Future<void> logout() async {
    try {
      await _channel.invokeMethod('logout');
    } on PlatformException catch (e) {
      print('Failed to logout: ${e.message}');
      throw Exception('Logout failed: ${e.message}');
    }
  }
  
  /// Check if user is logged in
  /// Using Tuya SDK v3.25.0 user session management
  Future<bool> isLoggedIn() async {
    try {
      final bool result = await _channel.invokeMethod('isLoggedIn');
      return result;
    } on PlatformException catch (e) {
      print('Failed to check login status: ${e.message}');
      return false;
    }
  }
} 
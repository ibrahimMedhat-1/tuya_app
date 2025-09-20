import 'package:tuya_app/src/core/utils/app_imports.dart';

class TuyaAuthDataSource {
  static const MethodChannel _channel = MethodChannel(
    'com.zerotechiot.eg/tuya_sdk',
  );
  User? _currentUser;

  Future<User> login(String email, String password) async {
    try {
      final result = await _channel.invokeMethod('login', {
        'email': email,
        'password': password,
      });

      if (result is Map<String, dynamic>) {
        _currentUser = User.fromJson(result);
        return _currentUser!;
      } else {
        throw Exception('Invalid response format from Tuya SDK');
      }
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _channel.invokeMethod('resetPassword', {'email': email});
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    } catch (e) {
      throw Exception('Reset password failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      // Tuya SDK doesn't have a specific logout method in the channel
      // We'll just clear the local user state
      _currentUser = null;
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<User?> getCurrentUser() async {
    // For now, return the cached user
    // In a real implementation, you might want to verify with the server
    return _currentUser;
  }

  Stream<User?> get authStateChanges {
    // This would typically be a stream from Firebase Auth or similar
    // For now, we'll simulate it with the cached user
    return Stream.value(_currentUser);
  }

  Exception _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'LOGIN_FAILED':
        return Exception('Login failed: ${e.message}');
      case 'RESET_PASSWORD_FAILED':
        return Exception('Reset password failed: ${e.message}');
      case 'INVALID_ARGUMENTS':
        return Exception('Invalid arguments: ${e.message}');
      default:
        return Exception('Platform error: ${e.message}');
    }
  }
}

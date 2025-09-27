import 'package:tuya_app/src/core/utils/app_imports.dart';
import 'package:tuya_app/src/core/utils/constants.dart';

class TuyaAuthDataSource {
  User? _currentUser;
  Future<User> login(String email, String password) async {
    try {
      final result = await AppConstants.channel.invokeMethod('login', {
        'email': email,
        'password': password,
      });
        _currentUser = User.fromJson(result);
        return _currentUser!;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
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

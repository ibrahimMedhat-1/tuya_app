import 'package:tuya_app/src/core/utils/app_imports.dart';

class AuthRepositoryImpl implements AuthRepository {
  final TuyaAuthDataSource _dataSource;

  AuthRepositoryImpl(TuyaAuthDataSource dataSource) : _dataSource = dataSource;

  @override
  Future<User> login(String email, String password) async {
    return await _dataSource.login(email, password);
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _dataSource.getCurrentUser();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _dataSource.resetPassword(email);
  }

  @override
  Stream<User?> get authStateChanges {
    return _dataSource.authStateChanges;
  }
}

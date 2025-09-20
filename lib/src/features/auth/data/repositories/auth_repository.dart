import 'package:tuya_app/src/core/utils/app_imports.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> resetPassword(String email);
  Stream<User?> get authStateChanges;
}

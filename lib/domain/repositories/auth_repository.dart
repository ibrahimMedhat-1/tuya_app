import 'package:smart_home_tuya/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> loginWithEmail(String email, String password);
  Future<User> registerWithEmail(String email, String password, String countryCode);
  Future<void> logout();
  Future<bool> isLoggedIn();
} 
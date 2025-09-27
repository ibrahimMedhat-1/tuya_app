import 'package:tuya_app/src/core/utils/app_imports.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
}

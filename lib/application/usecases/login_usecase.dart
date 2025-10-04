import 'package:smart_home_tuya/domain/entities/user.dart';
import 'package:smart_home_tuya/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> execute(String email, String password) async {
    return await repository.loginWithEmail(email, password);
  }
} 
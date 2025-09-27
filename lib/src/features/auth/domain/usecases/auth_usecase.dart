import 'package:tuya_app/src/features/auth/domain/entities/user.dart';
import 'package:tuya_app/src/features/auth/data/repositories/auth_repository.dart';

class AuthUseCase {
  final AuthRepository _authRepository;

  AuthUseCase(this._authRepository);

  Future<User> login(String email, String password) async {
    // Add any business logic validation here
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }

    if (!email.contains('@')) {
      throw Exception('Please enter a valid email address');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long');
    }

    return await _authRepository.login(email, password);
  }


}

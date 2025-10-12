import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/either.dart';
import 'package:tuya_app/src/features/auth/domain/entities/user.dart';
import 'package:tuya_app/src/features/auth/data/repositories/auth_repository.dart';

class AuthUseCase {
  final AuthRepository _authRepository;

  AuthUseCase(this._authRepository);

  Future<Either<Failure, User>> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('Email and password cannot be empty'));
    }

    if (!email.contains('@')) {
      return const Left(ValidationFailure('Please enter a valid email address'));
    }

    if (password.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters long'));
    }

    return await _authRepository.login(email, password);
  }

  Future<Either<Failure, User?>> isLoggedIn() async {
    return await _authRepository.isLoggedIn();
  }

  Future<Either<Failure, void>> logout() async {
    return await _authRepository.logout();
  }
}

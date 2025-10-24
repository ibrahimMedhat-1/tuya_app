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

  Future<Either<Failure, User>> register(String email, String password, String verificationCode) async {
    if (email.isEmpty || password.isEmpty || verificationCode.isEmpty) {
      return const Left(ValidationFailure('Email, password, and verification code cannot be empty'));
    }

    if (!email.contains('@')) {
      return const Left(ValidationFailure('Please enter a valid email address'));
    }

    if (password.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters long'));
    }

    if (verificationCode.length < 4) {
      return const Left(ValidationFailure('Verification code must be at least 4 characters'));
    }

    return await _authRepository.register(email, password, verificationCode);
  }

  Future<Either<Failure, String>> sendVerificationCode(String email) async {
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }

    if (!email.contains('@')) {
      return const Left(ValidationFailure('Please enter a valid email address'));
    }

    return await _authRepository.sendVerificationCode(email);
  }

  Future<Either<Failure, void>> logout() async {
    return await _authRepository.logout();
  }
}

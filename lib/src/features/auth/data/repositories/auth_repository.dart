import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/either.dart';

import '../../domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(String email, String password, String verificationCode);
  Future<Either<Failure, String>> sendVerificationCode(String email);
  Future<Either<Failure, User?>> isLoggedIn();
  Future<Either<Failure, void>> logout();
}

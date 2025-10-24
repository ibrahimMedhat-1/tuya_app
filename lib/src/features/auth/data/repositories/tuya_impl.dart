import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/either.dart';
import 'package:tuya_app/src/features/auth/data/datasources/tuya_auth_data_source.dart';

import '../../domain/entities/user.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final TuyaAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    return await _dataSource.login(email, password);
  }
  
  @override
  Future<Either<Failure, User?>> isLoggedIn() async {
    return await _dataSource.isLoggedIn();
  }

  @override
  Future<Either<Failure, User>> register(String email, String password, String verificationCode) async {
    return await _dataSource.register(email, password, verificationCode);
  }

  @override
  Future<Either<Failure, String>> sendVerificationCode(String email) async {
    return await _dataSource.sendVerificationCode(email);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return await _dataSource.logout();
  }
}

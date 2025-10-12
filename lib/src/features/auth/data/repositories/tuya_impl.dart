
import 'package:tuya_app/src/core/error/failures.dart';
import 'package:tuya_app/src/core/utils/either.dart';

import '../../../../core/utils/app_imports.dart';

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
  Future<Either<Failure, void>> logout() async {
    return await _dataSource.logout();
  }
}

import 'package:tuya_app/src/core/utils/app_imports.dart';

class AuthRepositoryImpl implements AuthRepository {
  final TuyaAuthDataSource _dataSource;

  AuthRepositoryImpl(TuyaAuthDataSource dataSource) : _dataSource = dataSource;

  @override
  Future<User> login(String email, String password) async {
    return await _dataSource.login(email, password);
  }





}

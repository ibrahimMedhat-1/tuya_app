import 'package:smart_home_tuya/data/datasources/tuya_auth_datasource.dart';
import 'package:smart_home_tuya/domain/entities/user.dart';
import 'package:smart_home_tuya/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final TuyaAuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<User> loginWithEmail(String email, String password) async {
    final userData = await dataSource.loginWithEmail(email, password);
    
    return User(
      id: userData['id'] as String, 
      email: userData['email'] as String, 
      username: userData['username'] as String
    );
  }

  @override
  Future<User> registerWithEmail(String email, String password, String countryCode) async {
    final userData = await dataSource.registerWithEmail(email, password, countryCode);
    
    return User(
      id: userData['id'] as String, 
      email: userData['email'] as String, 
      username: userData['username'] as String
    );
  }

  @override
  Future<void> logout() async {
    await dataSource.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await dataSource.isLoggedIn();
  }
} 
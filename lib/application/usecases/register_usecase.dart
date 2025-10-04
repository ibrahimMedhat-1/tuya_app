import 'package:smart_home_tuya/domain/entities/user.dart';
import 'package:smart_home_tuya/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> execute(String email, String password, String countryCode) async {
    return await repository.registerWithEmail(email, password, countryCode);
  }
} 
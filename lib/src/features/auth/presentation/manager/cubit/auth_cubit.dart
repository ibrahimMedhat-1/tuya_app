 import 'package:tuya_app/src/core/utils/app_imports.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  AuthCubit() : super(AuthCubitInitial());
  AuthUseCase authUseCase = sl<AuthUseCase>();

  Future<User> login(BuildContext context, String email,String  password) async {
    try {
      final User user = await authUseCase.login(email, password);
      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    // TODO: Implement actual logout logic when needed
    emit(AuthCubitInitial());
  }
}

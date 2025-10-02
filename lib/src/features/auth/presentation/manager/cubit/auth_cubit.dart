 import 'package:tuya_app/src/core/utils/app_imports.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  AuthCubit() : super(AuthCubitInitial());
  AuthUseCase authUseCase = sl<AuthUseCase>();

  Future<User> login(BuildContext context, String email, String password) async {
    emit(AuthCubitLoading());
    try {
      final User user = await authUseCase.login(email, password);
      emit(AuthCubitAuthenticated(user));
      return user;
    } catch (e) {
      emit(AuthCubitError(e.toString()));
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> checkLoginStatus() async {
    emit(AuthCubitLoading());
    try {
      final User? user = await authUseCase.isLoggedIn();
      if (user != null) {
        emit(AuthCubitAuthenticated(user));
      } else {
        emit(AuthCubitUnauthenticated());
      }
    } catch (e) {
      emit(AuthCubitError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthCubitLoading());
    try {
      await authUseCase.logout();
      emit(AuthCubitUnauthenticated());
    } catch (e) {
      emit(AuthCubitError(e.toString()));
    }
  }
}

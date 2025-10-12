 import 'package:tuya_app/src/core/utils/app_imports.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final AuthUseCase _authUseCase;

  AuthCubit(this._authUseCase) : super(AuthCubitInitial());

  Future<void> login(String email, String password) async {
    emit(AuthCubitLoading());
    final result = await _authUseCase.login(email, password);
    result.fold(
      (failure) => emit(AuthCubitError(failure.message)),
      (user) => emit(AuthCubitAuthenticated(user)),
    );
  }

  Future<void> checkLoginStatus() async {
    emit(AuthCubitLoading());
    final result = await _authUseCase.isLoggedIn();
    result.fold(
      (failure) => emit(AuthCubitError(failure.message)),
      (user) {
        if (user != null) {
          emit(AuthCubitAuthenticated(user));
        } else {
          emit(AuthCubitUnauthenticated());
        }
      },
    );
  }

  Future<void> logout() async {
    emit(AuthCubitLoading());
    final result = await _authUseCase.logout();
    result.fold(
      (failure) => emit(AuthCubitError(failure.message)),
      (_) => emit(AuthCubitUnauthenticated()),
    );
  }
}

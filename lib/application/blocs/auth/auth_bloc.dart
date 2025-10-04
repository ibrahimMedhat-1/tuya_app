import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_tuya/application/blocs/auth/auth_event.dart';
import 'package:smart_home_tuya/application/blocs/auth/auth_state.dart';
import 'package:smart_home_tuya/application/usecases/login_usecase.dart';
import 'package:smart_home_tuya/application/usecases/register_usecase.dart';
import 'package:smart_home_tuya/domain/entities/user.dart';
import 'package:smart_home_tuya/domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<RegisterWithEmailEvent>(_onRegisterWithEmail);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase.execute(
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onRegisterWithEmail(
    RegisterWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase.execute(
        event.email,
        event.password,
        event.countryCode,
      );
      emit(AuthRegistrationSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        // In a real app, you would fetch the user details here
        // For now, we'll just emit authenticated with a placeholder user
        emit(AuthAuthenticated(
          User(id: 'placeholder', email: '', username: 'User')
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
} 
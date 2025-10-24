part of 'auth_cubit.dart';

sealed class AuthCubitState {}

final class AuthCubitInitial extends AuthCubitState {}

final class AuthCubitLoading extends AuthCubitState {}

final class AuthCubitAuthenticated extends AuthCubitState {
  final User user;
  AuthCubitAuthenticated(this.user);
}

final class AuthCubitUnauthenticated extends AuthCubitState {}

final class AuthCubitError extends AuthCubitState {
  final String message;
  AuthCubitError(this.message);
}

final class AuthCubitVerificationCodeSent extends AuthCubitState {}

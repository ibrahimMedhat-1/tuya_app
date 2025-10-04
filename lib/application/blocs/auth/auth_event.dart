import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class LoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  
  const LoginWithEmailEvent({
    required this.email,
    required this.password
  });
  
  @override
  List<Object?> get props => [email, password];
}

class RegisterWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String countryCode;
  
  const RegisterWithEmailEvent({
    required this.email,
    required this.password,
    required this.countryCode,
  });
  
  @override
  List<Object?> get props => [email, password, countryCode];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {} 
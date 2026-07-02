import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {}

class LoginRequestedEvent extends AuthEvent {
  final String cedula;
  final String password;

  const LoginRequestedEvent(this.cedula, this.password);

  @override
  List<Object?> get props => [cedula, password];
}

class ChangePasswordRequestedEvent extends AuthEvent {
  final String newPassword;

  const ChangePasswordRequestedEvent(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}

class LogoutRequestedEvent extends AuthEvent {}

class RecoverPasswordRequestedEvent extends AuthEvent {
  final String cedula;

  const RecoverPasswordRequestedEvent(this.cedula);

  @override
  List<Object?> get props => [cedula];
}
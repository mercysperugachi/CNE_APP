import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/recover_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final CheckAuthUseCase checkAuthUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final RecoverPasswordUseCase recoverPasswordUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.checkAuthUseCase,
    required this.changePasswordUseCase,
    required this.recoverPasswordUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginRequestedEvent>(_onLoginRequested);
    on<ChangePasswordRequestedEvent>(_onChangePasswordRequested);
    on<RecoverPasswordRequestedEvent>(_onRecoverPasswordRequested);
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await checkAuthUseCase();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user.requiresPasswordChange) {
          emit(AuthRequiresPasswordChange(user));
        } else {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  Future<void> _onLoginRequested(LoginRequestedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(event.cedula, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        if (user.requiresPasswordChange) {
          emit(AuthRequiresPasswordChange(user));
        } else {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  Future<void> _onChangePasswordRequested(ChangePasswordRequestedEvent event, Emitter<AuthState> emit) async {
    // Si estamos aquí es porque el estado actual probablemente era AuthRequiresPasswordChange
    final currentUserState = state;
    if (currentUserState is AuthRequiresPasswordChange) {
      emit(AuthLoading());
      final result = await changePasswordUseCase(event.newPassword);
      result.fold(
        (failure) {
          emit(AuthError(failure.message));
          // Volvemos a emitir el estado de requerir cambio para no perderlo
          emit(currentUserState);
        },
        (_) => emit(AuthAuthenticated(currentUserState.user)), // Contraseña cambiada con éxito
      );
    }
  }

  Future<void> _onLogoutRequested(LogoutRequestedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await logoutUseCase();
    emit(AuthUnauthenticated());
  }

  Future<void> _onRecoverPasswordRequested(RecoverPasswordRequestedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await recoverPasswordUseCase(event.cedula);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthRecoveryEmailSent('Se ha enviado un enlace de recuperación a su correo electrónico registrado.')),
    );
  }
}
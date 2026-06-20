import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:feyam/features/auth/domain/failures/auth_failure.dart';
import 'package:feyam/features/auth/domain/usecases/check_auth_session.dart';
import 'package:feyam/features/auth/domain/usecases/login.dart';
import 'package:feyam/features/auth/domain/usecases/logout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthSessionUseCase checkAuthSessionUseCase,
    Stream<void>? sessionExpiredStream,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _checkAuthSessionUseCase = checkAuthSessionUseCase,
       super(const AuthState()) {
    on<SignInPressed>(_onSignInPressed);
    on<SignOutPressed>(_onSignOutPressed);
    on<AuthSessionChecked>(_onAuthSessionChecked);
    on<SessionExpired>(_onSessionExpired);

    // La expiración real de sesión (refresh token inválido) llega por este
    // stream desde AuthenticatedHttpClient y desloguea de forma centralizada,
    // sin importar la pantalla activa.
    _sessionExpiredSubscription = sessionExpiredStream?.listen((_) {
      add(SessionExpired());
    });
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthSessionUseCase _checkAuthSessionUseCase;
  StreamSubscription<void>? _sessionExpiredSubscription;

  @override
  Future<void> close() {
    _sessionExpiredSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSignInPressed(
    SignInPressed event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.loading) {
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));

    try {
      await _loginUseCase();
      emit(state.copyWith(status: AuthStatus.success, clearErrorMessage: true));
    } on AuthFailure catch (failure) {
      if (failure.code == AuthFailureCode.cancelled) {
        emit(
          state.copyWith(status: AuthStatus.initial, clearErrorMessage: true),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            errorMessage: _getErrorMessage(failure.code),
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _getErrorMessage(AuthFailureCode.unknown),
        ),
      );
    }
  }

  Future<void> _onSignOutPressed(
    SignOutPressed event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _logoutUseCase();
    } catch (_) {
      // endSession puede fallar si el server ya invalidó la sesión; igual limpiamos
    }
    emit(state.copyWith(status: AuthStatus.initial, clearErrorMessage: true));
  }

  Future<void> _onSessionExpired(
    SessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    // Tokens ya limpiados por _clearSession() en KeycloakDataSource.refreshToken()
    emit(state.copyWith(status: AuthStatus.initial, clearErrorMessage: true));
  }

  Future<void> _onAuthSessionChecked(
    AuthSessionChecked event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.loading) {
      return;
    }

    final isAuthenticated = await _checkAuthSessionUseCase();
    if (isAuthenticated) {
      emit(state.copyWith(status: AuthStatus.success, clearErrorMessage: true));
    }
  }

  String _getErrorMessage(AuthFailureCode code) {
    switch (code) {
      case AuthFailureCode.cancelled:
        return 'Inicio de sesión cancelado.';
      case AuthFailureCode.unknown:
      default:
        return 'No pudimos iniciar sesión. Intentá nuevamente.';
    }
  }
}

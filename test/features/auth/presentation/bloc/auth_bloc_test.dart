import 'dart:async';

import 'package:feyam/features/auth/domain/entities/auth_user_entity.dart';
import 'package:feyam/features/auth/domain/failures/auth_failure.dart';
import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';
import 'package:feyam/features/auth/domain/usecases/check_auth_session.dart';
import 'package:feyam/features/auth/domain/usecases/get_current_user.dart';
import 'package:feyam/features/auth/domain/usecases/login.dart';
import 'package:feyam/features/auth/domain/usecases/logout.dart';
import 'package:feyam/features/auth/domain/usecases/refresh_auth_session.dart';
import 'package:feyam/features/auth/domain/usecases/register.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allows retrying sign in after a failure', () async {
    final repository = _FakeAuthRepository();
    final bloc = AuthBloc(
      loginUseCase: LoginUseCase(repository),
      registerUseCase: RegisterUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      checkAuthSessionUseCase: CheckAuthSessionUseCase(repository),
      getCurrentUserUseCase: GetCurrentUserUseCase(repository),
      refreshAuthSessionUseCase: RefreshAuthSessionUseCase(repository),
    );

    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);

    repository.loginResult = _AuthResult.failure;
    bloc.add(SignInPressed());
    await bloc.stream.firstWhere((state) => state.status == AuthStatus.failure);

    repository.loginResult = _AuthResult.success;
    bloc.add(SignInPressed());
    await bloc.stream.firstWhere((state) => state.status == AuthStatus.success);

    await subscription.cancel();
    await bloc.close();

    expect(repository.loginAttempts, 2);
    expect(
      states.map((state) => state.status),
      containsAllInOrder(<AuthStatus>[
        AuthStatus.loading,
        AuthStatus.failure,
        AuthStatus.loading,
        AuthStatus.success,
      ]),
    );
    expect(states.last.errorMessage, isNull);
  });

  test('logs out (status initial) when the session-expired stream fires',
      () async {
    final repository = _FakeAuthRepository();
    final controller = StreamController<void>.broadcast();
    final bloc = AuthBloc(
      loginUseCase: LoginUseCase(repository),
      registerUseCase: RegisterUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      checkAuthSessionUseCase: CheckAuthSessionUseCase(repository),
      getCurrentUserUseCase: GetCurrentUserUseCase(repository),
      refreshAuthSessionUseCase: RefreshAuthSessionUseCase(repository),
      sessionExpiredStream: controller.stream,
    );

    // Partimos de una sesión activa.
    repository.authenticated = true;
    bloc.add(AuthSessionChecked());
    await bloc.stream.firstWhere((s) => s.status == AuthStatus.success);

    controller.add(null);
    final state =
        await bloc.stream.firstWhere((s) => s.status == AuthStatus.initial);

    expect(state.status, AuthStatus.initial);

    await bloc.close();
    await controller.close();
  });

  test('logs out on AppResumed when the proactive refresh finds a dead session',
      () async {
    final repository = _FakeAuthRepository();
    final bloc = AuthBloc(
      loginUseCase: LoginUseCase(repository),
      registerUseCase: RegisterUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      checkAuthSessionUseCase: CheckAuthSessionUseCase(repository),
      getCurrentUserUseCase: GetCurrentUserUseCase(repository),
      refreshAuthSessionUseCase: RefreshAuthSessionUseCase(repository),
    );

    repository.authenticated = true;
    bloc.add(AuthSessionChecked());
    await bloc.stream.firstWhere((s) => s.status == AuthStatus.success);

    repository.refreshError = const AuthTokenExpiredException();
    bloc.add(AppResumed());
    final state =
        await bloc.stream.firstWhere((s) => s.status == AuthStatus.initial);

    expect(state.status, AuthStatus.initial);
    expect(state.user, isNull);

    await bloc.close();
  });

  test(
      'keeps the session on AppResumed when the refresh fails transiently',
      () async {
    final repository = _FakeAuthRepository();
    final bloc = AuthBloc(
      loginUseCase: LoginUseCase(repository),
      registerUseCase: RegisterUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      checkAuthSessionUseCase: CheckAuthSessionUseCase(repository),
      getCurrentUserUseCase: GetCurrentUserUseCase(repository),
      refreshAuthSessionUseCase: RefreshAuthSessionUseCase(repository),
    );

    repository.authenticated = true;
    bloc.add(AuthSessionChecked());
    await bloc.stream.firstWhere((s) => s.status == AuthStatus.success);

    repository.refreshError = const AuthTokenRefreshTransientException();
    bloc.add(AppResumed());
    // No debería haber transición de estado: damos tiempo al handler y
    // verificamos que seguimos en success.
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.status, AuthStatus.success);
    expect(repository.refreshAttempts, 1);

    await bloc.close();
  });

  test('AppResumed is a no-op when there is no active session', () async {
    final repository = _FakeAuthRepository();
    final bloc = AuthBloc(
      loginUseCase: LoginUseCase(repository),
      registerUseCase: RegisterUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      checkAuthSessionUseCase: CheckAuthSessionUseCase(repository),
      getCurrentUserUseCase: GetCurrentUserUseCase(repository),
      refreshAuthSessionUseCase: RefreshAuthSessionUseCase(repository),
    );

    bloc.add(AppResumed());
    await Future<void>.delayed(Duration.zero);

    expect(repository.refreshAttempts, 0);
    expect(bloc.state.status, AuthStatus.initial);

    await bloc.close();
  });
}

enum _AuthResult { success, failure }

class _FakeAuthRepository implements AuthRepository {
  var loginResult = _AuthResult.success;
  var loginAttempts = 0;
  var authenticated = false;
  var refreshAttempts = 0;
  Exception? refreshError;

  @override
  Future<void> login() async {
    loginAttempts++;

    if (loginResult == _AuthResult.failure) {
      throw const AuthFailure(AuthFailureCode.unknown);
    }
  }

  @override
  Future<void> register() async {}

  @override
  Future<bool> logout() async {
    return true;
  }

  @override
  Future<bool> isAuthenticated() async {
    return authenticated;
  }

  @override
  Future<void> refreshAccessToken() async {
    refreshAttempts++;
    final error = refreshError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<AuthUserEntity?> getCurrentUser() async => null;
}

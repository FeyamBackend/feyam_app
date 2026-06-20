import 'dart:async';

import 'package:feyam/features/auth/domain/failures/auth_failure.dart';
import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';
import 'package:feyam/features/auth/domain/usecases/check_auth_session.dart';
import 'package:feyam/features/auth/domain/usecases/login.dart';
import 'package:feyam/features/auth/domain/usecases/logout.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allows retrying sign in after a failure', () async {
    final repository = _FakeAuthRepository();
    final bloc = AuthBloc(
      loginUseCase: LoginUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      checkAuthSessionUseCase: CheckAuthSessionUseCase(repository),
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
      logoutUseCase: LogoutUseCase(repository),
      checkAuthSessionUseCase: CheckAuthSessionUseCase(repository),
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
}

enum _AuthResult { success, failure }

class _FakeAuthRepository implements AuthRepository {
  var loginResult = _AuthResult.success;
  var loginAttempts = 0;
  var authenticated = false;

  @override
  Future<void> login() async {
    loginAttempts++;

    if (loginResult == _AuthResult.failure) {
      throw const AuthFailure(AuthFailureCode.unknown);
    }
  }

  @override
  Future<bool> logout() async {
    return true;
  }

  @override
  Future<bool> isAuthenticated() async {
    return authenticated;
  }

  @override
  Future<void> refreshAccessToken() async {}
}

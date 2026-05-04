import 'package:feyam/features/auth/data/datasources/keycloak_auth_datasource.dart';
import 'package:feyam/features/auth/domain/failures/auth_failure.dart';
import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final KeycloakDataSource keycloakDataSource;

  AuthRepositoryImpl({required this.keycloakDataSource});

  @override
  Future<void> login() async {
    try {
      await keycloakDataSource.redirectToLogin();
    } on UserCancelledAuthException {
      throw const AuthFailure(AuthFailureCode.cancelled);
    }
  }

  @override
  Future<bool> logout() {
    return keycloakDataSource.logout();
  }

  @override
  Future<bool> isAuthenticated() {
    return keycloakDataSource.isAuthenticated();
  }
}

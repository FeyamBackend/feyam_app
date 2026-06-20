import 'package:feyam/features/auth/data/datasources/keycloak_auth_datasource.dart';
import 'package:feyam/features/auth/domain/entities/auth_user_entity.dart';
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

  @override
  Future<void> refreshAccessToken() async {
    try {
      await keycloakDataSource.refreshToken();
    } on TokenRefreshException catch (e) {
      if (e.isTransient) {
        throw const AuthTokenRefreshTransientException();
      }
      throw const AuthTokenExpiredException();
    }
  }

  @override
  Future<AuthUserEntity?> getCurrentUser() async {
    final claims = await keycloakDataSource.getIdTokenClaims();
    if (claims == null) {
      return null;
    }

    final uid = claims['sub'] as String?;
    if (uid == null) {
      return null;
    }

    final givenName = claims['given_name'] as String?;
    final familyName = claims['family_name'] as String?;
    final displayName =
        (claims['name'] as String?) ??
        [givenName, familyName].whereType<String>().join(' ').trim();

    return AuthUserEntity(
      uid: uid,
      email: claims['email'] as String?,
      displayName: displayName.isEmpty ? null : displayName,
      photoUrl: claims['picture'] as String?,
    );
  }
}

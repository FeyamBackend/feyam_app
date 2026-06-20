import 'package:feyam/features/auth/domain/entities/auth_user_entity.dart';

/// La sesión terminó de verdad: el refresh token es inválido o expiró
/// (`invalid_grant`). El usuario debe volver a loguearse.
class AuthTokenExpiredException implements Exception {
  const AuthTokenExpiredException();
}

/// El refresh falló por un motivo transitorio (red/timeout). La sesión sigue
/// vigente; conviene reintentar más tarde en vez de deslogear.
class AuthTokenRefreshTransientException implements Exception {
  const AuthTokenRefreshTransientException();
}

abstract class AuthRepository {
  Future<void> login();

  Future<bool> logout();

  Future<bool> isAuthenticated();

  Future<void> refreshAccessToken();

  Future<AuthUserEntity?> getCurrentUser();
}

class AuthTokenExpiredException implements Exception {
  const AuthTokenExpiredException();
}

abstract class AuthRepository {
  Future<void> login();

  Future<bool> logout();

  Future<bool> isAuthenticated();

  Future<void> refreshAccessToken();
}

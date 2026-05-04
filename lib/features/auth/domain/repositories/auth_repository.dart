abstract class AuthRepository {
  Future<void> login();

  Future<bool> logout();

  Future<bool> isAuthenticated();
}

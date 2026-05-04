import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this.repository);

  final AuthRepository repository;

  Future<bool> call() {
    return repository.logout();
  }
}

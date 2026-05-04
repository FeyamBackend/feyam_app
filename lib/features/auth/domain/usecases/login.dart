import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call() {
    return repository.login();
  }
}

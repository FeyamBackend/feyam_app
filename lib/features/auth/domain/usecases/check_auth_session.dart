import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthSessionUseCase {
  const CheckAuthSessionUseCase(this.repository);

  final AuthRepository repository;

  Future<bool> call() {
    return repository.isAuthenticated();
  }
}

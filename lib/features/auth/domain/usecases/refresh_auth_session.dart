import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';

class RefreshAuthSessionUseCase {
  const RefreshAuthSessionUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call() {
    return repository.refreshAccessToken();
  }
}

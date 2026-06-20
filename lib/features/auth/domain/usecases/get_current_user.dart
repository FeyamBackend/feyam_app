import 'package:feyam/features/auth/domain/entities/auth_user_entity.dart';
import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this.repository);

  final AuthRepository repository;

  Future<AuthUserEntity?> call() {
    return repository.getCurrentUser();
  }
}

import 'package:feyam/features/notifications/domain/repositories/notifications_repository.dart';

class GetUnreadCountUseCase {
  const GetUnreadCountUseCase(this.repository);

  final NotificationsRepository repository;

  Future<int> call() => repository.getUnreadCount();
}

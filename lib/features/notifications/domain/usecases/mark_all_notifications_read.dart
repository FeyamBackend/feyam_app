import 'package:feyam/features/notifications/domain/repositories/notifications_repository.dart';

class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase(this.repository);

  final NotificationsRepository repository;

  Future<void> call() => repository.markAllNotificationsRead();
}

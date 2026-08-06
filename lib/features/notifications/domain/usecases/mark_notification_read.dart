import 'package:feyam/features/notifications/domain/repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this.repository);

  final NotificationsRepository repository;

  Future<void> call(String notificationId) =>
      repository.markNotificationRead(notificationId);
}

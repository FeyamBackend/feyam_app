import 'package:feyam/features/notifications/domain/entities/notifications_page.dart';
import 'package:feyam/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this.repository);

  final NotificationsRepository repository;

  Future<NotificationsPage> call({int skip = 0, int take = 20}) =>
      repository.getNotifications(skip: skip, take: take);
}

import 'package:feyam/features/notifications/domain/entities/notifications_page.dart';

abstract class NotificationsRepository {
  Future<NotificationsPage> getNotifications({
    required int skip,
    required int take,
  });

  Future<int> getUnreadCount();

  Future<void> markNotificationRead(String notificationId);

  Future<void> markAllNotificationsRead();

  Future<void> registerDeviceToken({
    required String fcmToken,
    required String platform,
    String? appVersion,
  });

  Future<void> unregisterDeviceToken(String fcmToken);
}

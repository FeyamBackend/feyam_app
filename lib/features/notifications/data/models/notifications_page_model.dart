import 'package:feyam/features/notifications/data/models/notification_model.dart';
import 'package:feyam/features/notifications/domain/entities/notifications_page.dart';

class NotificationsPageModel extends NotificationsPage {
  const NotificationsPageModel({
    required super.items,
    required super.unreadCount,
    required super.hasMore,
  });

  factory NotificationsPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>;
    return NotificationsPageModel(
      items: rawItems
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadCount: json['unreadCount'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }
}

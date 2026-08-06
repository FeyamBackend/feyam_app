import 'package:equatable/equatable.dart';
import 'package:feyam/features/notifications/domain/entities/notification_entity.dart';

class NotificationsPage extends Equatable {
  const NotificationsPage({
    required this.items,
    required this.unreadCount,
    required this.hasMore,
  });

  final List<NotificationEntity> items;
  final int unreadCount;
  final bool hasMore;

  @override
  List<Object?> get props => [items, unreadCount, hasMore];
}

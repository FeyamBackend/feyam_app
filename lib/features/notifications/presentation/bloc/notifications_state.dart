import 'package:equatable/equatable.dart';
import 'package:feyam/features/notifications/domain/entities/notification_entity.dart';
import 'package:feyam/features/notifications/domain/failures/notifications_failure.dart';

enum NotificationsStatus { initial, loading, loaded, empty, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const <NotificationEntity>[],
    this.unreadCount = 0,
    this.failure,
  });

  final NotificationsStatus status;
  final List<NotificationEntity> items;
  final int unreadCount;
  final NotificationsFailure? failure;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? items,
    int? unreadCount,
    NotificationsFailure? failure,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, items, unreadCount, failure];
}

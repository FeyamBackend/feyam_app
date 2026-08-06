import 'package:equatable/equatable.dart';
import 'package:feyam/features/notifications/domain/entities/notification_entity.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationsLoadRequested extends NotificationsEvent {
  const NotificationsLoadRequested();
}

final class NotificationsMarkReadRequested extends NotificationsEvent {
  const NotificationsMarkReadRequested(this.notificationId);

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

final class NotificationsMarkAllReadRequested extends NotificationsEvent {
  const NotificationsMarkAllReadRequested();
}

/// A push arrived while the app was in the foreground — insert it directly instead of
/// waiting for the next full refetch, so the list updates instantly.
final class NotificationsPushReceived extends NotificationsEvent {
  const NotificationsPushReceived(this.notification);

  final NotificationEntity notification;

  @override
  List<Object?> get props => [notification];
}

import 'package:feyam/features/notifications/domain/failures/notifications_failure.dart';
import 'package:feyam/features/notifications/domain/usecases/get_notifications.dart';
import 'package:feyam/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:feyam/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:feyam/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:feyam/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationReadUseCase markNotificationReadUseCase,
    required MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase,
  }) : _getNotifications = getNotificationsUseCase,
       _markNotificationRead = markNotificationReadUseCase,
       _markAllNotificationsRead = markAllNotificationsReadUseCase,
       super(const NotificationsState()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<NotificationsMarkReadRequested>(_onMarkReadRequested);
    on<NotificationsMarkAllReadRequested>(_onMarkAllReadRequested);
    on<NotificationsPushReceived>(_onPushReceived);
  }

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markNotificationRead;
  final MarkAllNotificationsReadUseCase _markAllNotificationsRead;

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final page = await _getNotifications();
      emit(
        state.copyWith(
          status: page.items.isEmpty
              ? NotificationsStatus.empty
              : NotificationsStatus.loaded,
          items: page.items,
          unreadCount: page.unreadCount,
        ),
      );
    } on NotificationsFailure catch (failure) {
      emit(
        state.copyWith(status: NotificationsStatus.failure, failure: failure),
      );
    }
  }

  Future<void> _onMarkReadRequested(
    NotificationsMarkReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final alreadyRead = state.items
        .where((n) => n.id == event.notificationId)
        .every((n) => n.isRead);
    if (alreadyRead) return;

    // Optimistic: the customer sees the read state flip immediately, no round-trip wait.
    emit(
      state.copyWith(
        items: state.items
            .map(
              (n) =>
                  n.id == event.notificationId ? n.copyWith(isRead: true) : n,
            )
            .toList(),
        unreadCount: (state.unreadCount - 1).clamp(0, state.unreadCount),
      ),
    );

    try {
      await _markNotificationRead(event.notificationId);
    } catch (_) {
      // Best-effort: a failed mark-read syncs back on the next full load rather than
      // rolling back the optimistic UI update, which would just look like a glitch.
    }
  }

  Future<void> _onMarkAllReadRequested(
    NotificationsMarkAllReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.unreadCount == 0) return;

    emit(
      state.copyWith(
        items: state.items.map((n) => n.copyWith(isRead: true)).toList(),
        unreadCount: 0,
      ),
    );

    try {
      await _markAllNotificationsRead();
    } catch (_) {
      // Best-effort, same reasoning as _onMarkReadRequested.
    }
  }

  void _onPushReceived(
    NotificationsPushReceived event,
    Emitter<NotificationsState> emit,
  ) {
    emit(
      state.copyWith(
        status: NotificationsStatus.loaded,
        items: [event.notification, ...state.items],
        unreadCount: state.unreadCount + 1,
      ),
    );
  }
}

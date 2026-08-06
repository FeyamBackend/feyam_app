import 'package:feyam/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:feyam/features/notifications/presentation/bloc/unread_count_event.dart';
import 'package:feyam/features/notifications/presentation/bloc/unread_count_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Separate from [NotificationsBloc] so the bell icon's badge can stay live (fed by the
/// foreground push listener) without the notification history screen needing to be open.
class UnreadCountBloc extends Bloc<UnreadCountEvent, UnreadCountState> {
  UnreadCountBloc({required GetUnreadCountUseCase getUnreadCountUseCase})
    : _getUnreadCount = getUnreadCountUseCase,
      super(const UnreadCountState()) {
    on<UnreadCountRefreshRequested>(_onRefreshRequested);
    on<UnreadCountIncremented>(_onIncremented);
    on<UnreadCountCleared>(_onCleared);
  }

  final GetUnreadCountUseCase _getUnreadCount;

  Future<void> _onRefreshRequested(
    UnreadCountRefreshRequested event,
    Emitter<UnreadCountState> emit,
  ) async {
    try {
      final count = await _getUnreadCount();
      emit(state.copyWith(count: count));
    } catch (_) {
      // Best-effort — the badge just keeps its last known value on failure.
    }
  }

  void _onIncremented(
    UnreadCountIncremented event,
    Emitter<UnreadCountState> emit,
  ) {
    emit(state.copyWith(count: state.count + 1));
  }

  void _onCleared(UnreadCountCleared event, Emitter<UnreadCountState> emit) {
    emit(state.copyWith(count: 0));
  }
}

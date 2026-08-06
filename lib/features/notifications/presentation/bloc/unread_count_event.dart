import 'package:equatable/equatable.dart';

sealed class UnreadCountEvent extends Equatable {
  const UnreadCountEvent();

  @override
  List<Object?> get props => [];
}

final class UnreadCountRefreshRequested extends UnreadCountEvent {
  const UnreadCountRefreshRequested();
}

final class UnreadCountIncremented extends UnreadCountEvent {
  const UnreadCountIncremented();
}

final class UnreadCountCleared extends UnreadCountEvent {
  const UnreadCountCleared();
}

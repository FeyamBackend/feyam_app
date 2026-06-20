import 'package:equatable/equatable.dart';

sealed class RecentOrdersEvent extends Equatable {
  const RecentOrdersEvent();

  @override
  List<Object?> get props => [];
}

final class RecentOrdersLoadRequested extends RecentOrdersEvent {
  const RecentOrdersLoadRequested({this.take = 5});

  final int take;

  @override
  List<Object?> get props => [take];
}

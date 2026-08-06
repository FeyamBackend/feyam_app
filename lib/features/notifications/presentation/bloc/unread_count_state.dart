import 'package:equatable/equatable.dart';

class UnreadCountState extends Equatable {
  const UnreadCountState({this.count = 0});

  final int count;

  UnreadCountState copyWith({int? count}) =>
      UnreadCountState(count: count ?? this.count);

  @override
  List<Object?> get props => [count];
}

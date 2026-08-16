import 'package:equatable/equatable.dart';

sealed class QuoteEvent extends Equatable {
  const QuoteEvent();

  @override
  List<Object?> get props => [];
}

final class QuoteRequested extends QuoteEvent {
  const QuoteRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

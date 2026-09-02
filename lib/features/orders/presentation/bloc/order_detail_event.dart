import 'package:equatable/equatable.dart';

sealed class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

final class OrderDetailRequested extends OrderDetailEvent {
  const OrderDetailRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

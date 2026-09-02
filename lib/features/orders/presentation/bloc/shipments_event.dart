import 'package:equatable/equatable.dart';

sealed class ShipmentsEvent extends Equatable {
  const ShipmentsEvent();

  @override
  List<Object?> get props => [];
}

final class ShipmentsRequested extends ShipmentsEvent {
  const ShipmentsRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

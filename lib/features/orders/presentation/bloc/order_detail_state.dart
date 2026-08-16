import 'package:equatable/equatable.dart';
import 'package:feyam/features/orders/domain/entities/order_detail_entity.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';

enum OrderDetailStatus { initial, loading, loaded, failure }

class OrderDetailState extends Equatable {
  const OrderDetailState({
    this.status = OrderDetailStatus.initial,
    this.detail,
    this.failure,
  });

  final OrderDetailStatus status;
  final OrderDetailEntity? detail;
  final OrdersFailure? failure;

  OrderDetailState copyWith({
    OrderDetailStatus? status,
    OrderDetailEntity? detail,
    OrdersFailure? failure,
  }) {
    return OrderDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, detail, failure];
}

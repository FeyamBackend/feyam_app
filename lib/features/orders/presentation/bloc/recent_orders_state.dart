import 'package:equatable/equatable.dart';
import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';

enum RecentOrdersStatus { initial, loading, loaded, empty, failure }

class RecentOrdersState extends Equatable {
  const RecentOrdersState({
    this.status = RecentOrdersStatus.initial,
    this.orders = const <RecentOrderEntity>[],
    this.failure,
  });

  final RecentOrdersStatus status;
  final List<RecentOrderEntity> orders;
  final OrdersFailure? failure;

  /// Sum of charged amounts of orders not yet delivered.
  double get activeTotal => orders
      .where((o) => o.isActive)
      .fold(0, (sum, o) => sum + o.chargedAmount);

  /// Number of orders not yet delivered.
  int get activeCount => orders.where((o) => o.isActive).length;

  RecentOrdersState copyWith({
    RecentOrdersStatus? status,
    List<RecentOrderEntity>? orders,
    OrdersFailure? failure,
  }) {
    return RecentOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, orders, failure];
}

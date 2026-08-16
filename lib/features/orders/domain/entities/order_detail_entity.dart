import 'package:equatable/equatable.dart';

/// Single line item within an [OrderDetailEntity].
class OrderLineEntity extends Equatable {
  const OrderLineEntity({
    required this.productTitle,
    this.variant,
    required this.quantity,
    required this.unitPrice,
    required this.currencyCode,
    this.storeName,
  });

  final String productTitle;
  final String? variant;
  final int quantity;
  final double unitPrice;
  final String currencyCode;
  final String? storeName;

  @override
  List<Object?> get props => [
        productTitle,
        variant,
        quantity,
        unitPrice,
        currencyCode,
        storeName,
      ];
}

/// Full order detail fetched from `GET /api/orders/{id}`.
class OrderDetailEntity extends Equatable {
  const OrderDetailEntity({
    required this.id,
    required this.status,
    required this.submittedAt,
    required this.lines,
  });

  final String id;

  /// Raw order-lifecycle status from the detail endpoint (e.g. "Submitted",
  /// "InTransitUs", "Delivered"). This is a *separate, unrelated* vocabulary
  /// from `RecentOrderEntity.financialStatus` / `OrderDisplayStatus` — do not
  /// feed it into `orderDisplayStatusFromFinancial()` or the list-screen
  /// stepper widgets.
  final String status;
  final DateTime submittedAt;
  final List<OrderLineEntity> lines;

  @override
  List<Object?> get props => [id, status, submittedAt, lines];
}

import 'package:equatable/equatable.dart';
import 'package:feyam/features/orders/domain/entities/order_display_status.dart';

class RecentOrderEntity extends Equatable {
  const RecentOrderEntity({
    required this.orderId,
    required this.title,
    required this.itemCount,
    required this.status,
    required this.estimatedTotal,
    this.confirmedTotal,
    required this.currencyCode,
    required this.createdDate,
    this.chargedAmount,
    this.financialStatus,
    this.imageUrl,
  });

  final String orderId;
  final String title;
  final int itemCount;

  /// The order's own raw lifecycle status (e.g. "PendingPriceReview",
  /// "AwaitingPayment", "Paid", ...) — always present, unlike
  /// [financialStatus].
  final String status;

  /// Rough total computed at submit time. Never what the customer is
  /// actually charged.
  final double estimatedTotal;

  /// The exact amount the customer must pay, once a price_confirmator has
  /// set it. Null before then.
  final double? confirmedTotal;
  final String currencyCode;
  final DateTime createdDate;

  /// What was actually charged — only set once a wallet exists for the order
  /// (i.e. once it's paid).
  final double? chargedAmount;

  /// Raw financial status name from the API (e.g. "FundsReserved") — null
  /// until the order is paid. See [status] for the always-present lifecycle
  /// status.
  final String? financialStatus;

  /// Product thumbnail captured from the cart at checkout time; null if the
  /// source cart item had none.
  final String? imageUrl;

  /// UI status derived from [status] and [financialStatus].
  OrderDisplayStatus get displayStatus =>
      orderDisplayStatus(status: status, financialStatus: financialStatus);

  /// True while the order is not yet delivered.
  bool get isActive => displayStatus != OrderDisplayStatus.delivered;

  /// The amount to show the customer — what they were actually charged once
  /// paid, otherwise the CRM-confirmed total, otherwise the rough estimate.
  double get displayAmount => chargedAmount ?? confirmedTotal ?? estimatedTotal;

  @override
  List<Object?> get props => [
        orderId,
        title,
        itemCount,
        status,
        estimatedTotal,
        confirmedTotal,
        currencyCode,
        createdDate,
        chargedAmount,
        financialStatus,
        imageUrl,
      ];
}

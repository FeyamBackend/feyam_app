import 'package:equatable/equatable.dart';
import 'package:feyam/features/orders/domain/entities/order_display_status.dart';

class RecentOrderEntity extends Equatable {
  const RecentOrderEntity({
    required this.orderId,
    required this.title,
    required this.itemCount,
    required this.chargedAmount,
    required this.currencyCode,
    required this.financialStatus,
    required this.createdDate,
    this.imageUrl,
  });

  final String orderId;
  final String title;
  final int itemCount;
  final double chargedAmount;
  final String currencyCode;

  /// Raw financial status name from the API (e.g. "FundsReserved").
  final String financialStatus;
  final DateTime createdDate;

  /// Product thumbnail captured from the cart at checkout time; null if the
  /// source cart item had none.
  final String? imageUrl;

  /// UI status derived from [financialStatus].
  OrderDisplayStatus get displayStatus =>
      orderDisplayStatusFromFinancial(financialStatus);

  /// True while the order is not yet delivered.
  bool get isActive => displayStatus != OrderDisplayStatus.delivered;

  @override
  List<Object?> get props => [
        orderId,
        title,
        itemCount,
        chargedAmount,
        currencyCode,
        financialStatus,
        createdDate,
        imageUrl,
      ];
}

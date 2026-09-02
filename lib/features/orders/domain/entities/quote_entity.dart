import 'package:equatable/equatable.dart';

/// Real, itemized final price breakdown produced by the backend once an
/// operator has verified a client's group checkout (`GET
/// /api/orders/{id}/quote`), as opposed to the rough pre-payment estimate
/// shown during checkout. A given order may not have one yet — most orders,
/// most of the time — which callers represent as `null`, not as this entity.
class QuoteEntity extends Equatable {
  const QuoteEntity({
    required this.orderId,
    required this.allocatedRetailerCost,
    required this.feeByQuantity,
    required this.valueSurcharge,
    required this.storeSurcharge,
    required this.feyamFee,
    required this.nationalLogistics,
    required this.internationalLogistics,
    required this.feyamTaxes,
    required this.otherExplicitCharges,
    required this.finalCustomerTotal,
    required this.currencyCode,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  final String orderId;
  final double allocatedRetailerCost;
  final double feeByQuantity;
  final double valueSurcharge;
  final double storeSurcharge;
  final double feyamFee;
  final double nationalLogistics;

  /// Currently `0` for essentially every quote — the backend doesn't yet
  /// have any way to capture a package's real weight. Not a bug in the UI.
  final double internationalLogistics;
  final double feyamTaxes;
  final double otherExplicitCharges;
  final double finalCustomerTotal;
  final String currencyCode;

  /// Raw quote status from the backend (e.g. "Active"). A plain string, not
  /// an enum, mirroring `OrderDetailEntity.status`'s existing convention.
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [
        orderId,
        allocatedRetailerCost,
        feeByQuantity,
        valueSurcharge,
        storeSurcharge,
        feyamFee,
        nationalLogistics,
        internationalLogistics,
        feyamTaxes,
        otherExplicitCharges,
        finalCustomerTotal,
        currencyCode,
        status,
        createdAt,
        expiresAt,
      ];
}

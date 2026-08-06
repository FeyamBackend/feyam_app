import 'package:equatable/equatable.dart';

class PriceAdjustmentStatusEntity extends Equatable {
  const PriceAdjustmentStatusEntity({
    required this.id,
    required this.purchaseId,
    required this.status,
    required this.amount,
    required this.currencyCode,
  });

  final String id;
  final String purchaseId;
  final String status;
  final double amount;
  final String currencyCode;

  bool get isSucceeded => status == 'Succeeded';
  bool get isFailed => status == 'Failed';

  @override
  List<Object> get props => [id, purchaseId, status, amount, currencyCode];
}

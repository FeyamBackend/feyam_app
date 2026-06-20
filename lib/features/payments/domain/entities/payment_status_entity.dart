import 'package:equatable/equatable.dart';

/// Estado de un pago según el backend (`GET /api/payments/{id}`).
/// `status` arranca en "Pending" y pasa a "Succeeded"/"Failed" cuando
/// el webhook de Stripe es procesado por el servidor.
class PaymentStatusEntity extends Equatable {
  const PaymentStatusEntity({
    required this.id,
    required this.cartId,
    required this.status,
    required this.chargedAmount,
    required this.currencyCode,
    required this.productsAmount,
    required this.feyamFee,
    required this.estimatedLogistics,
  });

  final String id;
  final String cartId;
  final String status;
  final double chargedAmount;
  final String currencyCode;
  final double productsAmount;
  final double feyamFee;
  final double estimatedLogistics;

  bool get isSucceeded => status.toLowerCase() == 'succeeded';
  bool get isFailed => status.toLowerCase() == 'failed';

  @override
  List<Object> get props => [
        id,
        cartId,
        status,
        chargedAmount,
        currencyCode,
        productsAmount,
        feyamFee,
        estimatedLogistics,
      ];
}

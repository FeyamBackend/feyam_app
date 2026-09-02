import 'package:equatable/equatable.dart';

/// Estado de un pago según el backend (`GET /api/payments/{id}`).
/// `status` arranca en "Pending", pasa a "Authorized" cuando Stripe retiene
/// los fondos (checkout con captura manual) y recién llega a "Succeeded"
/// cuando un operador verifica el precio real y se captura el cobro —
/// eso puede ocurrir horas o días después del checkout.
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

  static const _completedStatuses = {'authorized', 'succeeded'};

  /// El checkout está completo (fondos retenidos o ya capturados). No
  /// distingue entre "autorizado" y "capturado" — para eso usar [status].
  bool get isCheckoutComplete => _completedStatuses.contains(status.toLowerCase());
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

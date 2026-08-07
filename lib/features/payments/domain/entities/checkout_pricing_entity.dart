import 'package:equatable/equatable.dart';

/// Desglose autoritativo de `GET /api/payments/checkout/pricing`: el mismo
/// cálculo que usará `POST /api/payments/checkout` al cobrar, para que el
/// total mostrado antes de pagar nunca difiera del monto real cobrado.
class CheckoutPricingEntity extends Equatable {
  const CheckoutPricingEntity({
    required this.productsAmount,
    required this.feyamFee,
    required this.estimatedLogistics,
    required this.total,
    required this.currencyCode,
    required this.itemCount,
  });

  final double productsAmount;
  final double feyamFee;
  final double estimatedLogistics;
  final double total;
  final String currencyCode;
  final int itemCount;

  @override
  List<Object> get props => [
    productsAmount,
    feyamFee,
    estimatedLogistics,
    total,
    currencyCode,
    itemCount,
  ];
}

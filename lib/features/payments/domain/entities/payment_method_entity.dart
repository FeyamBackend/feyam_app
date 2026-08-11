import 'package:equatable/equatable.dart';

/// Tarjeta guardada en la pasarela de pago del usuario. Espeja
/// `PaymentMethodResponse` del backend (Module.Payments).
class PaymentMethodEntity extends Equatable {
  const PaymentMethodEntity({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
  });

  /// Id del payment method en la pasarela (ej. Stripe `pm_...`).
  final String id;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  @override
  List<Object?> get props => [id, brand, last4, expMonth, expYear, isDefault];
}

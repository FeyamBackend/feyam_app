import 'package:equatable/equatable.dart';

sealed class PaymentMethodsEvent extends Equatable {
  const PaymentMethodsEvent();

  @override
  List<Object?> get props => [];
}

final class PaymentMethodsLoadRequested extends PaymentMethodsEvent {
  const PaymentMethodsLoadRequested();
}

/// Inicia el alta de una tarjeta nueva: pide el setup al backend y delega la
/// captura al gateway que corresponda según el provider devuelto.
final class PaymentMethodAddRequested extends PaymentMethodsEvent {
  const PaymentMethodAddRequested();
}

final class PaymentMethodDeleteRequested extends PaymentMethodsEvent {
  const PaymentMethodDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class PaymentMethodSetDefaultRequested extends PaymentMethodsEvent {
  const PaymentMethodSetDefaultRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

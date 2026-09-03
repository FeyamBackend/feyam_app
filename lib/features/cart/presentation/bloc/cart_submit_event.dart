import 'package:equatable/equatable.dart';

sealed class CartSubmitEvent extends Equatable {
  const CartSubmitEvent();

  @override
  List<Object?> get props => [];
}

/// Envía el carrito activo con envío a [addressId] — no cobra nada, solo
/// crea la orden para que un price_confirmator la revise.
final class CartSubmitRequested extends CartSubmitEvent {
  const CartSubmitRequested(this.addressId);

  final String addressId;

  @override
  List<Object?> get props => [addressId];
}

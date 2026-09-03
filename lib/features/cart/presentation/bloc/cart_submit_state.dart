import 'package:equatable/equatable.dart';
import 'package:feyam/features/cart/domain/failures/cart_failure.dart';

enum CartSubmitStatus {
  /// Estado inicial, antes de enviar el carrito.
  initial,

  /// Enviando el carrito al backend.
  processing,

  /// El carrito fue enviado y la orden fue creada — sin ningún cobro.
  success,

  /// Falló el envío.
  failure,
}

class CartSubmitState extends Equatable {
  const CartSubmitState({
    this.status = CartSubmitStatus.initial,
    this.orderId,
    this.failure,
  });

  final CartSubmitStatus status;
  final String? orderId;
  final CartFailure? failure;

  CartSubmitState copyWith({
    CartSubmitStatus? status,
    String? orderId,
    CartFailure? failure,
  }) {
    return CartSubmitState(
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, orderId, failure];
}

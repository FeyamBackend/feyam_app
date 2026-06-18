import 'package:equatable/equatable.dart';
import 'package:feyam/features/cart/domain/entities/cart_entity.dart';
import 'package:feyam/features/cart/domain/failures/cart_failure.dart';

enum CartStatus { initial, loading, loaded, empty, failure }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.cart,
    this.failure,
  });

  final CartStatus status;
  final CartEntity? cart;
  final CartFailure? failure;

  CartState copyWith({
    CartStatus? status,
    CartEntity? cart,
    CartFailure? failure,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, cart, failure];
}

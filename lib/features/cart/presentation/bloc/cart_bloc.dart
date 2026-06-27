import 'package:feyam/features/cart/domain/failures/cart_failure.dart';
import 'package:feyam/features/cart/domain/usecases/get_cart.dart';
import 'package:feyam/features/cart/domain/usecases/remove_cart_item.dart';
import 'package:feyam/features/cart/domain/usecases/update_cart_item_quantity.dart';
import 'package:feyam/features/cart/presentation/bloc/cart_event.dart';
import 'package:feyam/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required GetCartUseCase getCartUseCase,
    required RemoveCartItemUseCase removeCartItemUseCase,
    required UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase,
  })  : _getCart = getCartUseCase,
        _removeCartItem = removeCartItemUseCase,
        _updateCartItemQuantity = updateCartItemQuantityUseCase,
        super(const CartState()) {
    on<CartLoadRequested>(_onLoadRequested);
    on<CartItemRemoveRequested>(_onRemoveRequested);
    on<CartItemQuantityUpdateRequested>(_onQuantityUpdateRequested);
  }

  final GetCartUseCase _getCart;
  final RemoveCartItemUseCase _removeCartItem;
  final UpdateCartItemQuantityUseCase _updateCartItemQuantity;

  Future<void> _onLoadRequested(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final cart = await _getCart();
      if (cart == null || cart.items.isEmpty) {
        emit(state.copyWith(status: CartStatus.empty, cart: cart));
      } else {
        emit(state.copyWith(status: CartStatus.loaded, cart: cart));
      }
    } on CartFailure catch (failure) {
      emit(state.copyWith(status: CartStatus.failure, failure: failure));
    }
  }

  Future<void> _onRemoveRequested(
    CartItemRemoveRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final cart = await _removeCartItem(event.itemId);
      if (cart.items.isEmpty) {
        emit(state.copyWith(status: CartStatus.empty, cart: cart));
      } else {
        emit(state.copyWith(status: CartStatus.loaded, cart: cart));
      }
    } on CartFailure catch (failure) {
      emit(state.copyWith(status: CartStatus.failure, failure: failure));
    }
  }

  Future<void> _onQuantityUpdateRequested(
    CartItemQuantityUpdateRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.updating));
    try {
      final cart = await _updateCartItemQuantity(event.itemId, event.newQuantity);
      emit(state.copyWith(status: CartStatus.loaded, cart: cart));
    } on CartFailure catch (failure) {
      emit(state.copyWith(status: CartStatus.failure, failure: failure));
    }
  }
}

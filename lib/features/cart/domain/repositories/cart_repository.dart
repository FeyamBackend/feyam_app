import 'package:feyam/features/cart/domain/entities/cart_entity.dart';
import 'package:feyam/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:feyam/features/cart/domain/usecases/add_to_cart.dart';

abstract class CartRepository {
  Future<CartSummaryEntity> addToCart(AddToCartParams params);
  Future<CartEntity?> getCart();
  Future<CartEntity> removeCartItem(String itemId);
  Future<CartEntity> updateCartItemQuantity(String itemId, int newQuantity);

  /// Envía el carrito activo con envío a [addressId], sin cobrar nada.
  /// Devuelve el id de la orden creada.
  Future<String> submitCart(String addressId);
}

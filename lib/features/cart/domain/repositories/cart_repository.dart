import 'package:feyam/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:feyam/features/cart/domain/usecases/add_to_cart.dart';

abstract class CartRepository {
  Future<CartSummaryEntity> addToCart(AddToCartParams params);
}

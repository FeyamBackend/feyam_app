import 'package:feyam/features/cart/domain/entities/cart_entity.dart';
import 'package:feyam/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartItemQuantityUseCase {
  const UpdateCartItemQuantityUseCase(this.repository);

  final CartRepository repository;

  Future<CartEntity> call(String itemId, int newQuantity) =>
      repository.updateCartItemQuantity(itemId, newQuantity);
}

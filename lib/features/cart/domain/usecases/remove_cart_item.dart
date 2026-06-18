import 'package:feyam/features/cart/domain/entities/cart_entity.dart';
import 'package:feyam/features/cart/domain/repositories/cart_repository.dart';

class RemoveCartItemUseCase {
  const RemoveCartItemUseCase(this.repository);

  final CartRepository repository;

  Future<CartEntity> call(String itemId) => repository.removeCartItem(itemId);
}

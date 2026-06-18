import 'package:feyam/features/cart/domain/entities/cart_entity.dart';
import 'package:feyam/features/cart/domain/repositories/cart_repository.dart';

class GetCartUseCase {
  const GetCartUseCase(this.repository);

  final CartRepository repository;

  Future<CartEntity?> call() => repository.getCart();
}

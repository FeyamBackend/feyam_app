import 'package:feyam/features/cart/domain/repositories/cart_repository.dart';

class SubmitCartUseCase {
  const SubmitCartUseCase(this.repository);

  final CartRepository repository;

  /// Returns the id of the newly-created order.
  Future<String> call(String addressId) => repository.submitCart(addressId);
}

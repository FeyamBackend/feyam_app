import 'package:feyam/features/orders/domain/entities/final_package_entity.dart';
import 'package:feyam/features/orders/domain/repositories/orders_repository.dart';

class GetOrderFinalPackageUseCase {
  const GetOrderFinalPackageUseCase(this.repository);

  final OrdersRepository repository;

  /// Returns `null` when no final package has been recorded yet for this
  /// order.
  Future<FinalPackageEntity?> call({required String orderId}) =>
      repository.getOrderFinalPackage(orderId: orderId);
}

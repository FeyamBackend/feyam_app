import 'package:feyam/features/payments/domain/entities/price_adjustment_status_entity.dart';
import 'package:feyam/features/payments/domain/repositories/payment_repository.dart';

class GetPriceAdjustmentPaymentStatusUseCase {
  const GetPriceAdjustmentPaymentStatusUseCase(this.repository);

  final PaymentRepository repository;

  Future<PriceAdjustmentStatusEntity> call(String chargeId) =>
      repository.getPriceAdjustmentPaymentStatus(chargeId);
}

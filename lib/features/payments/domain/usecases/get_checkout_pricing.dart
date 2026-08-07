import 'package:feyam/features/payments/domain/entities/checkout_pricing_entity.dart';
import 'package:feyam/features/payments/domain/repositories/payment_repository.dart';

class GetCheckoutPricingUseCase {
  const GetCheckoutPricingUseCase(this.repository);

  final PaymentRepository repository;

  Future<CheckoutPricingEntity> call() => repository.getCheckoutPricing();
}

import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/repositories/payment_repository.dart';

class CreateCheckoutUseCase {
  const CreateCheckoutUseCase(this.repository);

  final PaymentRepository repository;

  Future<CheckoutSessionEntity> call(String addressId) =>
      repository.createCheckout(addressId);
}

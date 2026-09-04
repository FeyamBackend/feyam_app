import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/repositories/payment_repository.dart';

class PayConfirmedOrderUseCase {
  const PayConfirmedOrderUseCase(this.repository);

  final PaymentRepository repository;

  Future<CheckoutSessionEntity> call(String orderId) =>
      repository.payConfirmedOrder(orderId);
}

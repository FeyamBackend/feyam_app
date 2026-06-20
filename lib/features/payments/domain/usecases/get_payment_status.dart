import 'package:feyam/features/payments/domain/entities/payment_status_entity.dart';
import 'package:feyam/features/payments/domain/repositories/payment_repository.dart';

class GetPaymentStatusUseCase {
  const GetPaymentStatusUseCase(this.repository);

  final PaymentRepository repository;

  Future<PaymentStatusEntity> call(String paymentId) =>
      repository.getPaymentStatus(paymentId);
}

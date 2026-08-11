import 'package:feyam/features/payments/domain/repositories/payment_methods_repository.dart';

class DeletePaymentMethodUseCase {
  const DeletePaymentMethodUseCase(this.repository);

  final PaymentMethodsRepository repository;

  Future<void> call(String id) => repository.deletePaymentMethod(id);
}

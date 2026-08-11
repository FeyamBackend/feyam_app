import 'package:feyam/features/payments/domain/repositories/payment_methods_repository.dart';

class SetDefaultPaymentMethodUseCase {
  const SetDefaultPaymentMethodUseCase(this.repository);

  final PaymentMethodsRepository repository;

  Future<void> call(String id) => repository.setDefaultPaymentMethod(id);
}

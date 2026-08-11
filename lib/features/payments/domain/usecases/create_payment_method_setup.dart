import 'package:feyam/features/payments/domain/entities/payment_method_setup_entity.dart';
import 'package:feyam/features/payments/domain/repositories/payment_methods_repository.dart';

class CreatePaymentMethodSetupUseCase {
  const CreatePaymentMethodSetupUseCase(this.repository);

  final PaymentMethodsRepository repository;

  Future<PaymentMethodSetupEntity> call() => repository.createSetup();
}

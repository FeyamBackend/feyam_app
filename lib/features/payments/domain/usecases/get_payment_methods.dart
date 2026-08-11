import 'package:feyam/features/payments/domain/entities/payment_method_entity.dart';
import 'package:feyam/features/payments/domain/repositories/payment_methods_repository.dart';

class GetPaymentMethodsUseCase {
  const GetPaymentMethodsUseCase(this.repository);

  final PaymentMethodsRepository repository;

  Future<List<PaymentMethodEntity>> call() => repository.getPaymentMethods();
}

import 'package:feyam/features/payments/domain/entities/payment_method_entity.dart';
import 'package:feyam/features/payments/domain/entities/payment_method_setup_entity.dart';

abstract class PaymentMethodsRepository {
  Future<List<PaymentMethodEntity>> getPaymentMethods();

  /// Prepara el alta de un método nuevo: asegura el customer en la pasarela y
  /// devuelve lo que el gateway resuelto necesita para capturarlo.
  Future<PaymentMethodSetupEntity> createSetup();

  Future<void> deletePaymentMethod(String id);
  Future<void> setDefaultPaymentMethod(String id);
}

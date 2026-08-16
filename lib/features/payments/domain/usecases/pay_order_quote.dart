import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/repositories/payment_repository.dart';

class PayOrderQuoteUseCase {
  const PayOrderQuoteUseCase(this.repository);

  final PaymentRepository repository;

  /// Returns `null` when the backend reports `requiresPayment: false` — the
  /// order's cart-checkout payment already covers the verified quote total.
  Future<CheckoutSessionEntity?> call(String orderId) =>
      repository.payOrderQuote(orderId);
}

import 'package:feyam/features/orders/domain/entities/quote_entity.dart';
import 'package:feyam/features/orders/domain/repositories/orders_repository.dart';

class GetOrderQuoteUseCase {
  const GetOrderQuoteUseCase(this.repository);

  final OrdersRepository repository;

  /// Returns `null` when no quote exists yet for this order.
  Future<QuoteEntity?> call({required String orderId}) =>
      repository.getOrderQuote(orderId: orderId);
}

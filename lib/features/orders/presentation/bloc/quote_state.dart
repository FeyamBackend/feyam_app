import 'package:equatable/equatable.dart';
import 'package:feyam/features/orders/domain/entities/quote_entity.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';

enum QuoteStatus { initial, loading, loaded, failure }

class QuoteState extends Equatable {
  const QuoteState({
    this.status = QuoteStatus.initial,
    this.quote,
    this.failure,
  });

  final QuoteStatus status;

  /// The fetched quote once `status` is [QuoteStatus.loaded]. `null` while
  /// loaded means "no quote exists yet for this order" — the normal case
  /// for most orders — and is distinct from [QuoteStatus.failure], which is
  /// a real error.
  final QuoteEntity? quote;
  final OrdersFailure? failure;

  QuoteState copyWith({
    QuoteStatus? status,
    QuoteEntity? quote,
    OrdersFailure? failure,
  }) {
    return QuoteState(
      status: status ?? this.status,
      quote: quote ?? this.quote,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, quote, failure];
}

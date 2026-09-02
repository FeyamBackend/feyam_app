import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/usecases/get_order_quote.dart';
import 'package:feyam/features/orders/presentation/bloc/quote_event.dart';
import 'package:feyam/features/orders/presentation/bloc/quote_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  QuoteBloc({required GetOrderQuoteUseCase getOrderQuoteUseCase})
      : _getOrderQuote = getOrderQuoteUseCase,
        super(const QuoteState()) {
    on<QuoteRequested>(_onRequested);
  }

  final GetOrderQuoteUseCase _getOrderQuote;

  Future<void> _onRequested(
    QuoteRequested event,
    Emitter<QuoteState> emit,
  ) async {
    emit(state.copyWith(status: QuoteStatus.loading));
    try {
      final quote = await _getOrderQuote(orderId: event.orderId);
      // Built directly (not via copyWith(quote: quote)) so a genuinely null
      // quote — the normal "no quote yet" outcome — actually lands in the
      // emitted state instead of being swallowed by copyWith's `??`
      // fallback onto a stale non-null value from a prior fetch.
      emit(QuoteState(status: QuoteStatus.loaded, quote: quote));
    } on OrdersFailure catch (failure) {
      emit(state.copyWith(status: QuoteStatus.failure, failure: failure));
    }
  }
}

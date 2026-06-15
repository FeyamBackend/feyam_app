import 'package:feyam/features/cart/domain/failures/cart_failure.dart';
import 'package:feyam/features/cart/domain/usecases/add_to_cart.dart';
import 'package:feyam/features/cart/presentation/bloc/add_to_cart_event.dart';
import 'package:feyam/features/cart/presentation/bloc/add_to_cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddToCartBloc extends Bloc<AddToCartEvent, AddToCartState> {
  AddToCartBloc({required AddToCartUseCase addToCartUseCase})
      : _addToCartUseCase = addToCartUseCase,
        super(const AddToCartState()) {
    on<AddToCartSubmitted>(_onSubmitted);
  }

  final AddToCartUseCase _addToCartUseCase;

  Future<void> _onSubmitted(
    AddToCartSubmitted event,
    Emitter<AddToCartState> emit,
  ) async {
    emit(state.copyWith(status: AddToCartStatus.loading));
    try {
      final summary = await _addToCartUseCase(
        AddToCartParams(
          productName: event.productName,
          productUrl: event.productUrl,
          quantity: event.quantity,
          unitPriceAmount: event.unitPriceAmount,
          currencyCode: 'USD',
          notes: event.notes?.isEmpty ?? true ? null : event.notes,
        ),
      );
      emit(state.copyWith(status: AddToCartStatus.success, summary: summary));
    } on CartFailure catch (failure) {
      emit(state.copyWith(status: AddToCartStatus.failure, failure: failure));
    }
  }
}

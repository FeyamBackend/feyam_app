import 'package:feyam/features/cart/domain/failures/cart_failure.dart';
import 'package:feyam/features/cart/domain/usecases/submit_cart.dart';
import 'package:feyam/features/cart/presentation/bloc/cart_submit_event.dart';
import 'package:feyam/features/cart/presentation/bloc/cart_submit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartSubmitBloc extends Bloc<CartSubmitEvent, CartSubmitState> {
  CartSubmitBloc({required SubmitCartUseCase submitCartUseCase})
      : _submitCart = submitCartUseCase,
        super(const CartSubmitState()) {
    on<CartSubmitRequested>(_onRequested);
  }

  final SubmitCartUseCase _submitCart;

  Future<void> _onRequested(
    CartSubmitRequested event,
    Emitter<CartSubmitState> emit,
  ) async {
    emit(state.copyWith(status: CartSubmitStatus.processing));

    try {
      final orderId = await _submitCart(event.addressId);
      emit(
        state.copyWith(status: CartSubmitStatus.success, orderId: orderId),
      );
    } on CartFailure catch (failure) {
      emit(state.copyWith(status: CartSubmitStatus.failure, failure: failure));
    }
  }
}

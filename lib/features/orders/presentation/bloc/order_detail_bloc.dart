import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/usecases/get_order_detail.dart';
import 'package:feyam/features/orders/presentation/bloc/order_detail_event.dart';
import 'package:feyam/features/orders/presentation/bloc/order_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  OrderDetailBloc({required GetOrderDetailUseCase getOrderDetailUseCase})
      : _getOrderDetail = getOrderDetailUseCase,
        super(const OrderDetailState()) {
    on<OrderDetailRequested>(_onRequested);
  }

  final GetOrderDetailUseCase _getOrderDetail;

  Future<void> _onRequested(
    OrderDetailRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(state.copyWith(status: OrderDetailStatus.loading));
    try {
      final detail = await _getOrderDetail(orderId: event.orderId);
      emit(state.copyWith(status: OrderDetailStatus.loaded, detail: detail));
    } on OrdersFailure catch (failure) {
      emit(state.copyWith(status: OrderDetailStatus.failure, failure: failure));
    }
  }
}

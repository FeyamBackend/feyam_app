import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/usecases/get_order_shipments.dart';
import 'package:feyam/features/orders/presentation/bloc/shipments_event.dart';
import 'package:feyam/features/orders/presentation/bloc/shipments_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShipmentsBloc extends Bloc<ShipmentsEvent, ShipmentsState> {
  ShipmentsBloc({required GetOrderShipmentsUseCase getOrderShipmentsUseCase})
      : _getOrderShipments = getOrderShipmentsUseCase,
        super(const ShipmentsState()) {
    on<ShipmentsRequested>(_onRequested);
  }

  final GetOrderShipmentsUseCase _getOrderShipments;

  Future<void> _onRequested(
    ShipmentsRequested event,
    Emitter<ShipmentsState> emit,
  ) async {
    emit(state.copyWith(status: ShipmentsStatus.loading));
    try {
      final shipments = await _getOrderShipments(orderId: event.orderId);
      // Unlike QuoteBloc's quote (nullable, so copyWith's `??` could swallow
      // a genuine null), `shipments` is never null — an empty list is itself
      // the normal "no shipments yet" value — so a plain copyWith is safe
      // here.
      emit(
        state.copyWith(status: ShipmentsStatus.loaded, shipments: shipments),
      );
    } on OrdersFailure catch (failure) {
      emit(state.copyWith(status: ShipmentsStatus.failure, failure: failure));
    }
  }
}

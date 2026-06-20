import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/usecases/get_recent_orders.dart';
import 'package:feyam/features/orders/presentation/bloc/recent_orders_event.dart';
import 'package:feyam/features/orders/presentation/bloc/recent_orders_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentOrdersBloc extends Bloc<RecentOrdersEvent, RecentOrdersState> {
  RecentOrdersBloc({
    required GetRecentOrdersUseCase getRecentOrdersUseCase,
  })  : _getRecentOrders = getRecentOrdersUseCase,
        super(const RecentOrdersState()) {
    on<RecentOrdersLoadRequested>(_onLoadRequested);
  }

  final GetRecentOrdersUseCase _getRecentOrders;

  Future<void> _onLoadRequested(
    RecentOrdersLoadRequested event,
    Emitter<RecentOrdersState> emit,
  ) async {
    emit(state.copyWith(status: RecentOrdersStatus.loading));
    try {
      final orders = await _getRecentOrders(take: event.take);
      if (orders.isEmpty) {
        emit(state.copyWith(status: RecentOrdersStatus.empty, orders: orders));
      } else {
        emit(state.copyWith(status: RecentOrdersStatus.loaded, orders: orders));
      }
    } on OrdersFailure catch (failure) {
      emit(state.copyWith(status: RecentOrdersStatus.failure, failure: failure));
    }
  }
}

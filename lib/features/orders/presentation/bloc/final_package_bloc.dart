import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/usecases/get_order_final_package.dart';
import 'package:feyam/features/orders/presentation/bloc/final_package_event.dart';
import 'package:feyam/features/orders/presentation/bloc/final_package_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinalPackageBloc extends Bloc<FinalPackageEvent, FinalPackageState> {
  FinalPackageBloc({
    required GetOrderFinalPackageUseCase getOrderFinalPackageUseCase,
  })  : _getOrderFinalPackage = getOrderFinalPackageUseCase,
        super(const FinalPackageState()) {
    on<FinalPackageRequested>(_onRequested);
  }

  final GetOrderFinalPackageUseCase _getOrderFinalPackage;

  Future<void> _onRequested(
    FinalPackageRequested event,
    Emitter<FinalPackageState> emit,
  ) async {
    emit(state.copyWith(status: FinalPackageStatus.loading));
    try {
      final package = await _getOrderFinalPackage(orderId: event.orderId);
      // Built directly (not via copyWith(package: package)) so a genuinely
      // null package — the normal "no final package yet" outcome — actually
      // lands in the emitted state instead of being swallowed by copyWith's
      // `??` fallback onto a stale non-null value from a prior fetch.
      emit(FinalPackageState(status: FinalPackageStatus.loaded, package: package));
    } on OrdersFailure catch (failure) {
      emit(state.copyWith(status: FinalPackageStatus.failure, failure: failure));
    }
  }
}

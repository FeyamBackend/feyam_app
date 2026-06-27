import 'package:feyam/features/profile/domain/usecases/get_user_country_code.dart';
import 'package:feyam/features/stores/domain/usecases/get_stores_usecase.dart';
import 'package:feyam/features/stores/presentation/bloc/stores_event.dart';
import 'package:feyam/features/stores/presentation/bloc/stores_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoresBloc extends Bloc<StoresEvent, StoresState> {
  StoresBloc({
    required GetStoresUseCase getStoresUseCase,
    required GetUserCountryCodeUseCase getUserCountryCodeUseCase,
  })  : _getStores = getStoresUseCase,
        _getUserCountryCode = getUserCountryCodeUseCase,
        super(const StoresState()) {
    on<StoresLoadRequested>(_onLoadRequested);
  }

  final GetStoresUseCase _getStores;
  final GetUserCountryCodeUseCase _getUserCountryCode;

  Future<void> _onLoadRequested(
    StoresLoadRequested event,
    Emitter<StoresState> emit,
  ) async {
    emit(state.copyWith(status: StoresStatus.loading));
    try {
      // Resolve country code: use the explicit one, or fall back to the
      // user's first saved address, or null (shows all stores).
      final countryCode =
          event.countryCode ?? await _getUserCountryCode();
      final stores = await _getStores(countryCode);
      emit(state.copyWith(status: StoresStatus.loaded, stores: stores));
    } catch (_) {
      emit(state.copyWith(status: StoresStatus.failure));
    }
  }
}

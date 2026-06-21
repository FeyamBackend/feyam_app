import 'package:feyam/features/profile/domain/failures/address_failure.dart';
import 'package:feyam/features/profile/domain/usecases/create_address.dart';
import 'package:feyam/features/profile/domain/usecases/delete_address.dart';
import 'package:feyam/features/profile/domain/usecases/get_addresses.dart';
import 'package:feyam/features/profile/domain/usecases/get_countries.dart';
import 'package:feyam/features/profile/domain/usecases/update_address.dart';
import 'package:feyam/features/profile/presentation/bloc/addresses_event.dart';
import 'package:feyam/features/profile/presentation/bloc/addresses_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressesBloc extends Bloc<AddressesEvent, AddressesState> {
  AddressesBloc({
    required GetAddressesUseCase getAddressesUseCase,
    required GetCountriesUseCase getCountriesUseCase,
    required CreateAddressUseCase createAddressUseCase,
    required UpdateAddressUseCase updateAddressUseCase,
    required DeleteAddressUseCase deleteAddressUseCase,
  })  : _getAddresses = getAddressesUseCase,
        _getCountries = getCountriesUseCase,
        _createAddress = createAddressUseCase,
        _updateAddress = updateAddressUseCase,
        _deleteAddress = deleteAddressUseCase,
        super(const AddressesState()) {
    on<AddressesLoadRequested>(_onLoadRequested);
    on<AddressCreateRequested>(_onCreateRequested);
    on<AddressUpdateRequested>(_onUpdateRequested);
    on<AddressDeleteRequested>(_onDeleteRequested);
  }

  final GetAddressesUseCase _getAddresses;
  final GetCountriesUseCase _getCountries;
  final CreateAddressUseCase _createAddress;
  final UpdateAddressUseCase _updateAddress;
  final DeleteAddressUseCase _deleteAddress;

  Future<void> _onLoadRequested(
    AddressesLoadRequested event,
    Emitter<AddressesState> emit,
  ) async {
    emit(state.copyWith(status: AddressesStatus.loading));
    await _loadCountries(event.languageCode, emit);
    await _reload(emit);
  }

  /// Carga los países disponibles (reference data). Best-effort: si falla, no
  /// rompe el listado de direcciones — la lista queda vacía y la UI lo refleja.
  Future<void> _loadCountries(
    String languageCode,
    Emitter<AddressesState> emit,
  ) async {
    if (state.countries.isNotEmpty) return;
    try {
      final countries = await _getCountries(languageCode);
      emit(state.copyWith(countries: countries));
    } on AddressFailure {
      // Ignorado a propósito: el formulario degrada a sin países.
    }
  }

  Future<void> _onCreateRequested(
    AddressCreateRequested event,
    Emitter<AddressesState> emit,
  ) async {
    await _mutate(emit, () => _createAddress(event.params));
  }

  Future<void> _onUpdateRequested(
    AddressUpdateRequested event,
    Emitter<AddressesState> emit,
  ) async {
    await _mutate(emit, () => _updateAddress(event.id, event.params));
  }

  Future<void> _onDeleteRequested(
    AddressDeleteRequested event,
    Emitter<AddressesState> emit,
  ) async {
    await _mutate(emit, () => _deleteAddress(event.id));
  }

  /// Ejecuta una mutación y, si tiene éxito, recarga el listado desde el backend
  /// (fuente de verdad). Reporta el resultado vía [AddressActionStatus].
  Future<void> _mutate(
    Emitter<AddressesState> emit,
    Future<void> Function() action,
  ) async {
    emit(state.copyWith(
      actionStatus: AddressActionStatus.inProgress,
      actionFailure: null,
    ));
    try {
      await action();
      await _reload(emit);
      emit(state.copyWith(actionStatus: AddressActionStatus.success));
    } on AddressFailure catch (failure) {
      emit(state.copyWith(
        actionStatus: AddressActionStatus.failure,
        actionFailure: failure,
      ));
    }
  }

  /// Recarga el listado. Actualiza solo el estado de la lista, no el de acción.
  Future<void> _reload(Emitter<AddressesState> emit) async {
    try {
      final addresses = await _getAddresses();
      emit(state.copyWith(
        status: addresses.isEmpty
            ? AddressesStatus.empty
            : AddressesStatus.loaded,
        addresses: addresses,
        failure: null,
      ));
    } on AddressFailure catch (failure) {
      emit(state.copyWith(
        status: AddressesStatus.failure,
        failure: failure,
      ));
    }
  }
}

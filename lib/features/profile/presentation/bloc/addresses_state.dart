import 'package:equatable/equatable.dart';
import 'package:feyam/features/profile/domain/entities/address_entity.dart';
import 'package:feyam/features/profile/domain/entities/country_entity.dart';
import 'package:feyam/features/profile/domain/failures/address_failure.dart';

/// Estado de la lista de direcciones.
enum AddressesStatus { initial, loading, loaded, empty, failure }

/// Estado de la mutación en curso (crear/editar/eliminar) — desacoplado del
/// estado de la lista para que la UI pueda reaccionar a la mutación sin perder
/// el listado ya cargado.
enum AddressActionStatus { idle, inProgress, success, failure }

class AddressesState extends Equatable {
  const AddressesState({
    this.status = AddressesStatus.initial,
    this.addresses = const <AddressEntity>[],
    this.failure,
    this.actionStatus = AddressActionStatus.idle,
    this.actionFailure,
    this.countries = const <CountryEntity>[],
  });

  final AddressesStatus status;
  final List<AddressEntity> addresses;
  final AddressFailure? failure;
  final AddressActionStatus actionStatus;
  final AddressFailure? actionFailure;

  /// Países disponibles consultados al backend. Vacío hasta que cargan.
  final List<CountryEntity> countries;

  AddressesState copyWith({
    AddressesStatus? status,
    List<AddressEntity>? addresses,
    AddressFailure? failure,
    AddressActionStatus? actionStatus,
    AddressFailure? actionFailure,
    List<CountryEntity>? countries,
  }) {
    return AddressesState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      failure: failure ?? this.failure,
      actionStatus: actionStatus ?? this.actionStatus,
      actionFailure: actionFailure ?? this.actionFailure,
      countries: countries ?? this.countries,
    );
  }

  @override
  List<Object?> get props =>
      [status, addresses, failure, actionStatus, actionFailure, countries];
}

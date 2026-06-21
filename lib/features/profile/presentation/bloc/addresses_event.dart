import 'package:equatable/equatable.dart';
import 'package:feyam/features/profile/domain/entities/address_params.dart';

sealed class AddressesEvent extends Equatable {
  const AddressesEvent();

  @override
  List<Object?> get props => [];
}

final class AddressesLoadRequested extends AddressesEvent {
  const AddressesLoadRequested(this.languageCode);

  /// Idioma para los nombres de país (Accept-Language).
  final String languageCode;

  @override
  List<Object?> get props => [languageCode];
}

final class AddressCreateRequested extends AddressesEvent {
  const AddressCreateRequested(this.params);

  final AddressParams params;

  @override
  List<Object?> get props => [params];
}

final class AddressUpdateRequested extends AddressesEvent {
  const AddressUpdateRequested(this.id, this.params);

  final String id;
  final AddressParams params;

  @override
  List<Object?> get props => [id, params];
}

final class AddressDeleteRequested extends AddressesEvent {
  const AddressDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

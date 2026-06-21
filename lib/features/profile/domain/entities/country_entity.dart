import 'package:equatable/equatable.dart';

/// País disponible para direcciones. Espeja `CountryVm` del backend (Module.Identity).
class CountryEntity extends Equatable {
  const CountryEntity({
    required this.code,
    required this.name,
  });

  /// ISO 3166-1 alpha-2 (2 letras).
  final String code;

  /// Nombre localizado según el idioma solicitado al backend.
  final String name;

  @override
  List<Object?> get props => [code, name];
}

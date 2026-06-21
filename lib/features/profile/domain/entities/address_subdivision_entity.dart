import 'package:equatable/equatable.dart';

/// Subdivisión de una dirección (estado, provincia, etc.). Espeja
/// `AddressSubdivisionVm` del backend.
class AddressSubdivisionEntity extends Equatable {
  const AddressSubdivisionEntity({
    required this.type,
    required this.code,
    required this.name,
  });

  /// Tipo de subdivisión: State, Province, Prefecture, Region, County,
  /// District, Emirate, Other.
  final String type;

  /// Código (p.ej. "CA" para California).
  final String code;

  /// Nombre legible (p.ej. "California").
  final String name;

  @override
  List<Object?> get props => [type, code, name];
}

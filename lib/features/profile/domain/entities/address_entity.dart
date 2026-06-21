import 'package:equatable/equatable.dart';
import 'package:feyam/features/profile/domain/entities/address_subdivision_entity.dart';

/// Dirección del usuario. Espeja `AddressVm` del backend (Module.Identity).
class AddressEntity extends Equatable {
  const AddressEntity({
    required this.id,
    required this.type,
    required this.countryCode,
    required this.lines,
    required this.subdivisions,
    this.zipCode,
    this.recipient,
    this.deliveryInstructions,
  });

  /// Id de la dirección (Guid serializado como String).
  final String id;

  /// Tipo: 'Shipment' o 'Billing'.
  final String type;

  /// ISO 3166-1 alpha-2 (2 letras).
  final String countryCode;

  /// 1 a 5 líneas de dirección.
  final List<String> lines;

  final List<AddressSubdivisionEntity> subdivisions;

  final String? zipCode;
  final String? recipient;
  final String? deliveryInstructions;

  @override
  List<Object?> get props => [
        id,
        type,
        countryCode,
        lines,
        subdivisions,
        zipCode,
        recipient,
        deliveryInstructions,
      ];
}

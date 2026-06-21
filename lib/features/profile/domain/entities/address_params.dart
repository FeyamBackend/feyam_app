import 'package:feyam/features/profile/domain/entities/address_subdivision_entity.dart';

/// Datos para crear o actualizar una dirección. El `id` no va acá: en update
/// se pasa por separado al repositorio (va en la ruta del endpoint).
class AddressParams {
  const AddressParams({
    required this.type,
    required this.countryCode,
    required this.lines,
    this.zipCode,
    this.recipient,
    this.deliveryInstructions,
    this.subdivisions = const <AddressSubdivisionEntity>[],
  });

  final String type;
  final String countryCode;
  final List<String> lines;
  final String? zipCode;
  final String? recipient;
  final String? deliveryInstructions;
  final List<AddressSubdivisionEntity> subdivisions;
}

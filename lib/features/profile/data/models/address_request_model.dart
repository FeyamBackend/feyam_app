import 'package:feyam/features/profile/data/models/address_subdivision_model.dart';
import 'package:feyam/features/profile/domain/entities/address_params.dart';

/// Cuerpo JSON para POST/PUT de direcciones. Espeja `CreateAddressRequest` /
/// `UpdateAddressRequest` del backend (el `id` del update va en la ruta).
class AddressRequestModel {
  const AddressRequestModel.fromParams(this._params);

  final AddressParams _params;

  Map<String, dynamic> toJson() => {
        'type': _params.type,
        'countryCode': _params.countryCode,
        'lines': _params.lines,
        if (_params.zipCode != null) 'zipCode': _params.zipCode,
        if (_params.recipient != null) 'recipient': _params.recipient,
        if (_params.deliveryInstructions != null)
          'deliveryInstructions': _params.deliveryInstructions,
        'subdivisions': _params.subdivisions
            .map(AddressSubdivisionModel.toJsonFrom)
            .toList(),
      };
}

import 'package:feyam/features/profile/domain/entities/address_subdivision_entity.dart';

class AddressSubdivisionModel extends AddressSubdivisionEntity {
  const AddressSubdivisionModel({
    required super.type,
    required super.code,
    required super.name,
  });

  factory AddressSubdivisionModel.fromJson(Map<String, dynamic> json) {
    return AddressSubdivisionModel(
      type: json['type'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  static Map<String, dynamic> toJsonFrom(AddressSubdivisionEntity s) => {
        'type': s.type,
        'code': s.code,
        'name': s.name,
      };
}

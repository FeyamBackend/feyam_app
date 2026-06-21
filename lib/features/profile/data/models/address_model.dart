import 'package:feyam/features/profile/data/models/address_subdivision_model.dart';
import 'package:feyam/features/profile/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.type,
    required super.countryCode,
    required super.lines,
    required super.subdivisions,
    super.zipCode,
    super.recipient,
    super.deliveryInstructions,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final rawLines = (json['lines'] as List<dynamic>?) ?? const <dynamic>[];
    final rawSubs = (json['subdivisions'] as List<dynamic>?) ?? const <dynamic>[];
    return AddressModel(
      id: json['id'] as String,
      type: json['type'] as String,
      countryCode: json['countryCode'] as String,
      lines: rawLines.map((e) => e as String).toList(),
      subdivisions: rawSubs
          .map((e) =>
              AddressSubdivisionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      zipCode: json['zipCode'] as String?,
      recipient: json['recipient'] as String?,
      deliveryInstructions: json['deliveryInstructions'] as String?,
    );
  }
}

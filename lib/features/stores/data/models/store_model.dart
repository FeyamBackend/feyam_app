import 'package:feyam/features/stores/domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.name,
    required super.host,
    required super.iconName,
    required super.colorHex,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      host: json['host'] as String,
      iconName: json['iconName'] as String,
      colorHex: json['colorHex'] as String,
    );
  }
}

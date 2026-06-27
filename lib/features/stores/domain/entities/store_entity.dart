import 'package:equatable/equatable.dart';

class StoreEntity extends Equatable {
  const StoreEntity({
    required this.id,
    required this.name,
    required this.host,
    required this.iconName,
    required this.colorHex,
  });

  final String id;
  final String name;
  final String host;

  /// Icon identifier resolved to an IconData by the UI layer.
  final String iconName;

  /// Brand hex color without the # prefix (e.g. "FF9900").
  final String colorHex;

  @override
  List<Object> get props => [id, name, host, iconName, colorHex];
}

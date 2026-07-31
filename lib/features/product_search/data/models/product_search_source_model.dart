import 'package:feyam/features/product_search/domain/entities/product_search_source_entity.dart';

class ProductSearchSourceModel extends ProductSearchSourceEntity {
  const ProductSearchSourceModel({
    required super.status,
    super.source,
    super.retailer,
  });

  factory ProductSearchSourceModel.fromJson(Map<String, dynamic> json) {
    return ProductSearchSourceModel(
      status: json['status'] as String,
      source: json['source'] as String?,
      retailer: json['retailer'] as String?,
    );
  }
}

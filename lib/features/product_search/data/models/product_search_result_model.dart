import 'package:feyam/features/product_search/data/models/product_search_item_model.dart';
import 'package:feyam/features/product_search/data/models/product_search_source_model.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_result_entity.dart';

class ProductSearchResultModel extends ProductSearchResultEntity {
  const ProductSearchResultModel({
    required super.query,
    required super.items,
    required super.sources,
    required super.isPartial,
    super.nextPage,
  });

  factory ProductSearchResultModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    final sources = json['sources'] as List<dynamic>? ?? [];

    return ProductSearchResultModel(
      query: json['query'] as String? ?? '',
      items: results
          .map((e) => ProductSearchItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      sources: sources
          .map(
            (e) => ProductSearchSourceModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      isPartial: json['isPartial'] as bool? ?? false,
      nextPage: json['nextPage'] as int?,
    );
  }
}

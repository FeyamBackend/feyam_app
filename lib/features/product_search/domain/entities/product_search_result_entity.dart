import 'package:equatable/equatable.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_item_entity.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_source_entity.dart';

class ProductSearchResultEntity extends Equatable {
  const ProductSearchResultEntity({
    required this.query,
    required this.items,
    required this.sources,
    required this.isPartial,
    this.nextPage,
  });

  final String query;
  final List<ProductSearchItemEntity> items;
  final List<ProductSearchSourceEntity> sources;

  /// True when at least one Zinc source failed/timed out but another still
  /// returned results — the UI should show results plus a soft warning.
  final bool isPartial;
  final int? nextPage;

  @override
  List<Object?> get props => [query, items, sources, isPartial, nextPage];
}

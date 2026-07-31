import 'package:equatable/equatable.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_item_entity.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_source_entity.dart';
import 'package:feyam/features/product_search/domain/failures/product_search_failure.dart';

enum ProductSearchStatus { initial, loading, loaded, empty, failure }

class ProductSearchState extends Equatable {
  const ProductSearchState({
    this.status = ProductSearchStatus.initial,
    this.query = '',
    this.retailer,
    this.items = const [],
    this.sources = const [],
    this.isPartial = false,
    this.isLoadingMore = false,
    this.nextPage,
    this.failure,
  });

  final ProductSearchStatus status;
  final String query;
  final String? retailer;
  final List<ProductSearchItemEntity> items;
  final List<ProductSearchSourceEntity> sources;
  final bool isPartial;
  final bool isLoadingMore;
  final int? nextPage;
  final ProductSearchFailure? failure;

  ProductSearchState copyWith({
    ProductSearchStatus? status,
    String? query,
    String? retailer,
    bool clearRetailer = false,
    List<ProductSearchItemEntity>? items,
    List<ProductSearchSourceEntity>? sources,
    bool? isPartial,
    bool? isLoadingMore,
    int? nextPage,
    bool clearNextPage = false,
    ProductSearchFailure? failure,
  }) {
    return ProductSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      retailer: clearRetailer ? null : (retailer ?? this.retailer),
      items: items ?? this.items,
      sources: sources ?? this.sources,
      isPartial: isPartial ?? this.isPartial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextPage: clearNextPage ? null : (nextPage ?? this.nextPage),
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        query,
        retailer,
        items,
        sources,
        isPartial,
        isLoadingMore,
        nextPage,
        failure,
      ];
}

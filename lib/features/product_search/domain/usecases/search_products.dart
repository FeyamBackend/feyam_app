import 'package:feyam/features/product_search/domain/entities/product_search_result_entity.dart';
import 'package:feyam/features/product_search/domain/repositories/product_search_repository.dart';

class SearchProductsUseCase {
  const SearchProductsUseCase(this.repository);

  final ProductSearchRepository repository;

  Future<ProductSearchResultEntity> call({
    required String query,
    String? retailer,
    int page = 1,
  }) =>
      repository.search(query: query, retailer: retailer, page: page);
}

import 'package:feyam/features/product_search/domain/entities/product_search_result_entity.dart';
import 'package:feyam/features/product_search/domain/repositories/product_search_repository.dart';

class LookupProductByUrlUseCase {
  const LookupProductByUrlUseCase(this.repository);

  final ProductSearchRepository repository;

  Future<ProductSearchResultEntity> call({required String url}) =>
      repository.lookupByUrl(url: url);
}

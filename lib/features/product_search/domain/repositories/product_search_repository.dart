import 'package:feyam/features/product_search/domain/entities/product_search_result_entity.dart';

abstract class ProductSearchRepository {
  Future<ProductSearchResultEntity> search({
    required String query,
    String? retailer,
    int page = 1,
  });
}

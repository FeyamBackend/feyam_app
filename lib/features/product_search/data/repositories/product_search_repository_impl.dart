import 'dart:io';

import 'package:feyam/features/product_search/data/datasources/product_search_remote_datasource.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_result_entity.dart';
import 'package:feyam/features/product_search/domain/failures/product_search_failure.dart';
import 'package:feyam/features/product_search/domain/repositories/product_search_repository.dart';

class ProductSearchRepositoryImpl implements ProductSearchRepository {
  const ProductSearchRepositoryImpl({required this.remoteDataSource});

  final ProductSearchRemoteDataSource remoteDataSource;

  @override
  Future<ProductSearchResultEntity> search({
    required String query,
    String? retailer,
    int page = 1,
  }) async {
    try {
      return await remoteDataSource.search(
        query: query,
        retailer: retailer,
        page: page,
      );
    } on ProductSearchUnauthorizedException {
      throw const ProductSearchFailure(ProductSearchFailureCode.sessionExpired);
    } on ProductSearchServerException {
      throw const ProductSearchFailure(ProductSearchFailureCode.serverError);
    } on SocketException {
      throw const ProductSearchFailure(ProductSearchFailureCode.networkError);
    } catch (_) {
      throw const ProductSearchFailure(ProductSearchFailureCode.unknown);
    }
  }

  @override
  Future<ProductSearchResultEntity> lookupByUrl({required String url}) async {
    try {
      return await remoteDataSource.lookupByUrl(url: url);
    } on ProductSearchUnauthorizedException {
      throw const ProductSearchFailure(ProductSearchFailureCode.sessionExpired);
    } on ProductSearchServerException {
      throw const ProductSearchFailure(ProductSearchFailureCode.serverError);
    } on SocketException {
      throw const ProductSearchFailure(ProductSearchFailureCode.networkError);
    } catch (_) {
      throw const ProductSearchFailure(ProductSearchFailureCode.unknown);
    }
  }
}

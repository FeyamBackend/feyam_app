import 'dart:io';

import 'package:feyam/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:feyam/features/cart/data/models/add_to_cart_request_model.dart';
import 'package:feyam/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:feyam/features/cart/domain/failures/cart_failure.dart';
import 'package:feyam/features/cart/domain/repositories/cart_repository.dart';
import 'package:feyam/features/cart/domain/usecases/add_to_cart.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required CartRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CartRemoteDataSource _remoteDataSource;

  @override
  Future<CartSummaryEntity> addToCart(AddToCartParams params) async {
    try {
      return await _remoteDataSource.addItem(
        AddToCartRequestModel(
          productName: params.productName,
          productUrl: params.productUrl,
          quantity: params.quantity,
          unitPriceAmount: params.unitPriceAmount,
          currencyCode: params.currencyCode,
          productImageUrl: params.productImageUrl,
          notes: params.notes,
          variantAttributes: params.variantAttributes,
        ),
      );
    } on CartUnauthorizedException {
      throw const CartFailure(CartFailureCode.unauthorized);
    } on CartServerException {
      throw const CartFailure(CartFailureCode.serverError);
    } on SocketException {
      throw const CartFailure(CartFailureCode.networkError);
    } catch (_) {
      throw const CartFailure(CartFailureCode.unknown);
    }
  }
}

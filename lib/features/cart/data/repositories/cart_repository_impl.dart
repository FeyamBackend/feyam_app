import 'dart:io';

import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';
import 'package:feyam/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:feyam/features/cart/data/models/add_to_cart_request_model.dart';
import 'package:feyam/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:feyam/features/cart/domain/failures/cart_failure.dart';
import 'package:feyam/features/cart/domain/repositories/cart_repository.dart';
import 'package:feyam/features/cart/domain/usecases/add_to_cart.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({
    required CartRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
  })  : _remoteDataSource = remoteDataSource,
        _authRepository = authRepository;

  final CartRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  @override
  Future<CartSummaryEntity> addToCart(AddToCartParams params) async {
    final model = AddToCartRequestModel(
      productName: params.productName,
      productUrl: params.productUrl,
      quantity: params.quantity,
      unitPriceAmount: params.unitPriceAmount,
      currencyCode: params.currencyCode,
      productImageUrl: params.productImageUrl,
      notes: params.notes,
      variantAttributes: params.variantAttributes,
    );

    try {
      return await _remoteDataSource.addItem(model);
    } on CartUnauthorizedException {
      try {
        await _authRepository.refreshAccessToken();
      } on AuthTokenExpiredException {
        throw const CartFailure(CartFailureCode.sessionExpired);
      }
      // Retry: CartRemoteDataSource re-lee el access_token de SecureStorage
      try {
        return await _remoteDataSource.addItem(model);
      } on CartUnauthorizedException {
        throw const CartFailure(CartFailureCode.sessionExpired);
      } on CartServerException {
        throw const CartFailure(CartFailureCode.serverError);
      } on SocketException {
        throw const CartFailure(CartFailureCode.networkError);
      }
    } on CartServerException {
      throw const CartFailure(CartFailureCode.serverError);
    } on SocketException {
      throw const CartFailure(CartFailureCode.networkError);
    } catch (_) {
      throw const CartFailure(CartFailureCode.unknown);
    }
  }
}

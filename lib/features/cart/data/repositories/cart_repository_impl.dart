import 'dart:io';

import 'package:feyam/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:feyam/features/cart/data/models/add_to_cart_request_model.dart';
import 'package:feyam/features/cart/domain/entities/cart_entity.dart';
import 'package:feyam/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:feyam/features/cart/domain/failures/cart_failure.dart';
import 'package:feyam/features/cart/domain/repositories/cart_repository.dart';
import 'package:feyam/features/cart/domain/usecases/add_to_cart.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required CartRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CartRemoteDataSource _remoteDataSource;

  @override
  Future<CartSummaryEntity> addToCart(AddToCartParams params) {
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

    return _guard(() => _remoteDataSource.addItem(model));
  }

  @override
  Future<CartEntity?> getCart() {
    return _guard(() => _remoteDataSource.getCart());
  }

  @override
  Future<CartEntity> removeCartItem(String itemId) {
    return _guard(() => _remoteDataSource.removeCartItem(itemId));
  }

  @override
  Future<CartEntity> updateCartItemQuantity(String itemId, int newQuantity) {
    return _guard(
      () => _remoteDataSource.updateCartItemQuantity(itemId, newQuantity),
    );
  }

  /// Ejecuta [action] mapeando las excepciones del datasource a [CartFailure].
  /// El refresh y el retry de 401 los maneja AuthenticatedHttpClient; un 401 que
  /// llegue acá significa que la sesión expiró (el logout global lo dispara el
  /// cliente vía SessionExpiredNotifier).
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CartUnauthorizedException {
      throw const CartFailure(CartFailureCode.sessionExpired);
    } on CartServerException {
      throw const CartFailure(CartFailureCode.serverError);
    } on SocketException {
      throw const CartFailure(CartFailureCode.networkError);
    } catch (_) {
      throw const CartFailure(CartFailureCode.unknown);
    }
  }
}

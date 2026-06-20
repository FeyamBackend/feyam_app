import 'dart:io';

import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';
import 'package:feyam/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/entities/payment_status_entity.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({
    required PaymentRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
  })  : _remoteDataSource = remoteDataSource,
        _authRepository = authRepository;

  final PaymentRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  @override
  Future<CheckoutSessionEntity> createCheckout() {
    return _withAuthRefresh(() => _remoteDataSource.createCheckout());
  }

  @override
  Future<PaymentStatusEntity> getPaymentStatus(String paymentId) {
    return _withAuthRefresh(
      () => _remoteDataSource.getPaymentStatus(paymentId),
    );
  }

  /// Ejecuta [action]; ante un 401 intenta refrescar el token una vez y
  /// reintenta, mapeando las excepciones de datasource a [PaymentFailure]
  /// (mismo patrón que CartRepositoryImpl).
  Future<T> _withAuthRefresh<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PaymentUnauthorizedException {
      try {
        await _authRepository.refreshAccessToken();
      } on AuthTokenExpiredException {
        throw const PaymentFailure(PaymentFailureCode.sessionExpired);
      }
      // Retry: el datasource re-lee el access_token de SecureStorage.
      try {
        return await action();
      } on PaymentUnauthorizedException {
        throw const PaymentFailure(PaymentFailureCode.sessionExpired);
      } on PaymentServerException {
        throw const PaymentFailure(PaymentFailureCode.serverError);
      } on SocketException {
        throw const PaymentFailure(PaymentFailureCode.networkError);
      }
    } on PaymentServerException {
      throw const PaymentFailure(PaymentFailureCode.serverError);
    } on SocketException {
      throw const PaymentFailure(PaymentFailureCode.networkError);
    } catch (_) {
      throw const PaymentFailure(PaymentFailureCode.unknown);
    }
  }
}

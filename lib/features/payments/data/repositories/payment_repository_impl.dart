import 'dart:io';

import 'package:feyam/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/entities/payment_status_entity.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({required PaymentRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final PaymentRemoteDataSource _remoteDataSource;

  @override
  Future<CheckoutSessionEntity> createCheckout(String addressId) {
    return _guard(() => _remoteDataSource.createCheckout(addressId));
  }

  @override
  Future<PaymentStatusEntity> getPaymentStatus(String paymentId) {
    return _guard(() => _remoteDataSource.getPaymentStatus(paymentId));
  }

  /// Ejecuta [action] mapeando las excepciones del datasource a [PaymentFailure].
  /// El refresh y el retry de 401 los maneja AuthenticatedHttpClient; un 401 que
  /// llegue acá significa que la sesión expiró (el logout global lo dispara el
  /// cliente vía SessionExpiredNotifier).
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PaymentUnauthorizedException {
      throw const PaymentFailure(PaymentFailureCode.sessionExpired);
    } on PaymentServerException {
      throw const PaymentFailure(PaymentFailureCode.serverError);
    } on SocketException {
      throw const PaymentFailure(PaymentFailureCode.networkError);
    } catch (_) {
      throw const PaymentFailure(PaymentFailureCode.unknown);
    }
  }
}

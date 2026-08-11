import 'dart:io';

import 'package:feyam/features/payments/data/datasources/payment_method_remote_datasource.dart';
import 'package:feyam/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:feyam/features/payments/domain/entities/payment_method_entity.dart';
import 'package:feyam/features/payments/domain/entities/payment_method_setup_entity.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/domain/repositories/payment_methods_repository.dart';

class PaymentMethodsRepositoryImpl implements PaymentMethodsRepository {
  PaymentMethodsRepositoryImpl({
    required PaymentMethodRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PaymentMethodRemoteDataSource _remoteDataSource;

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() {
    return _guard(() => _remoteDataSource.list());
  }

  @override
  Future<PaymentMethodSetupEntity> createSetup() {
    return _guard(() => _remoteDataSource.createSetupIntent());
  }

  @override
  Future<void> deletePaymentMethod(String id) {
    return _guard(() => _remoteDataSource.delete(id));
  }

  @override
  Future<void> setDefaultPaymentMethod(String id) {
    return _guard(() => _remoteDataSource.setDefault(id));
  }

  /// Ejecuta [action] mapeando las excepciones del datasource a [PaymentFailure].
  /// Mismo patrón que PaymentRepositoryImpl/AddressRepositoryImpl: el refresh y
  /// retry de 401 los maneja AuthenticatedHttpClient, un 401 acá es sesión
  /// expirada.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PaymentUnauthorizedException {
      throw const PaymentFailure(PaymentFailureCode.sessionExpired);
    } on PaymentMethodNotFoundException {
      throw const PaymentFailure(PaymentFailureCode.notFound);
    } on PaymentServerException {
      throw const PaymentFailure(PaymentFailureCode.serverError);
    } on SocketException {
      throw const PaymentFailure(PaymentFailureCode.networkError);
    } catch (_) {
      throw const PaymentFailure(PaymentFailureCode.unknown);
    }
  }
}

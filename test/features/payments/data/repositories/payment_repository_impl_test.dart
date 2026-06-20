import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';
import 'package:feyam/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:feyam/features/payments/data/models/checkout_session_model.dart';
import 'package:feyam/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  late _FakeDataSource dataSource;
  late _FakeAuthRepository auth;

  PaymentRepositoryImpl buildRepo() => PaymentRepositoryImpl(
        remoteDataSource: dataSource,
        authRepository: auth,
      );

  setUp(() {
    dataSource = _FakeDataSource();
    auth = _FakeAuthRepository();
  });

  test('maps server exceptions to PaymentFailure.serverError', () async {
    dataSource.checkoutBehaviors = <_Behavior>[_Behavior.server];

    final failure = await _captureFailure(() => buildRepo().createCheckout());

    expect(failure.code, PaymentFailureCode.serverError);
  });

  test('refreshes the token and retries once on 401', () async {
    dataSource.checkoutBehaviors = <_Behavior>[_Behavior.unauthorized, _Behavior.ok];

    final session = await buildRepo().createCheckout();

    expect(session.paymentId, 'pay_1');
    expect(auth.refreshCount, 1);
    expect(dataSource.checkoutCalls, 2);
  });

  test('maps an expired refresh token to PaymentFailure.sessionExpired',
      () async {
    dataSource.checkoutBehaviors = <_Behavior>[_Behavior.unauthorized];
    auth.throwOnRefresh = true;

    final failure = await _captureFailure(() => buildRepo().createCheckout());

    expect(failure.code, PaymentFailureCode.sessionExpired);
    expect(dataSource.checkoutCalls, 1); // no se reintenta sin token válido
  });
}

Future<PaymentFailure> _captureFailure(Future<void> Function() action) async {
  try {
    await action();
  } on PaymentFailure catch (f) {
    return f;
  }
  fail('Expected PaymentFailure to be thrown');
}

enum _Behavior { ok, unauthorized, server }

class _FakeDataSource extends PaymentRemoteDataSource {
  _FakeDataSource()
      : super(
          client: http.Client(),
          secureStorage: const FlutterSecureStorage(),
          apiBaseUrl: '',
        );

  List<_Behavior> checkoutBehaviors = <_Behavior>[_Behavior.ok];
  int checkoutCalls = 0;

  @override
  Future<CheckoutSessionModel> createCheckout() async {
    final behavior = checkoutBehaviors[checkoutCalls];
    checkoutCalls++;
    switch (behavior) {
      case _Behavior.ok:
        return _model;
      case _Behavior.unauthorized:
        throw const PaymentUnauthorizedException();
      case _Behavior.server:
        throw const PaymentServerException(500);
    }
  }
}

class _FakeAuthRepository implements AuthRepository {
  int refreshCount = 0;
  bool throwOnRefresh = false;

  @override
  Future<void> refreshAccessToken() async {
    refreshCount++;
    if (throwOnRefresh) throw const AuthTokenExpiredException();
  }

  @override
  Future<void> login() async {}

  @override
  Future<bool> logout() async => true;

  @override
  Future<bool> isAuthenticated() async => false;
}

const _model = CheckoutSessionModel(
  paymentId: 'pay_1',
  paymentIntentClientSecret: 'pi_secret',
  ephemeralKeySecret: 'ek_secret',
  stripeCustomerId: 'cus_1',
  publishableKey: 'pk_test',
  chargedAmount: 100.0,
  currencyCode: 'USD',
);

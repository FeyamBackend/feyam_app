import 'package:feyam/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:feyam/features/payments/data/models/checkout_session_model.dart';
import 'package:feyam/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  late _FakeDataSource dataSource;

  PaymentRepositoryImpl buildRepo() =>
      PaymentRepositoryImpl(remoteDataSource: dataSource);

  setUp(() {
    dataSource = _FakeDataSource();
  });

  test('maps server exceptions to PaymentFailure.serverError', () async {
    dataSource.checkoutBehaviors = <_Behavior>[_Behavior.server];

    final failure = await _captureFailure(() => buildRepo().createCheckout('addr_1'));

    expect(failure.code, PaymentFailureCode.serverError);
  });

  test('returns the checkout session on success', () async {
    dataSource.checkoutBehaviors = <_Behavior>[_Behavior.ok];

    final session = await buildRepo().createCheckout('addr_1');

    expect(session.paymentId, 'pay_1');
    expect(dataSource.checkoutCalls, 1);
  });

  test(
    'maps a 401 (sesión ya expirada; refresh/retry lo maneja el cliente HTTP) '
    'to PaymentFailure.sessionExpired',
    () async {
      // Con AuthenticatedHttpClient, un 401 que llega al repo significa que el
      // refresh ya falló de forma definitiva: no se reintenta acá.
      dataSource.checkoutBehaviors = <_Behavior>[_Behavior.unauthorized];

      final failure = await _captureFailure(() => buildRepo().createCheckout('addr_1'));

      expect(failure.code, PaymentFailureCode.sessionExpired);
      expect(dataSource.checkoutCalls, 1);
    },
  );
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
  _FakeDataSource() : super(client: http.Client(), apiBaseUrl: '');

  List<_Behavior> checkoutBehaviors = <_Behavior>[_Behavior.ok];
  int checkoutCalls = 0;

  @override
  Future<CheckoutSessionModel> createCheckout(String addressId) async {
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

const _model = CheckoutSessionModel(
  paymentId: 'pay_1',
  paymentIntentClientSecret: 'pi_secret',
  ephemeralKeySecret: 'ek_secret',
  stripeCustomerId: 'cus_1',
  publishableKey: 'pk_test',
  chargedAmount: 100.0,
  currencyCode: 'USD',
);

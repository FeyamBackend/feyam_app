import 'package:feyam/core/payments/stripe_payment_service.dart';
import 'package:feyam/features/payments/domain/entities/checkout_pricing_entity.dart';
import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/entities/payment_status_entity.dart';
import 'package:feyam/features/payments/domain/entities/price_adjustment_status_entity.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/domain/repositories/payment_repository.dart';
import 'package:feyam/features/payments/domain/usecases/create_checkout.dart';
import 'package:feyam/features/payments/domain/usecases/get_checkout_pricing.dart';
import 'package:feyam/features/payments/domain/usecases/get_payment_status.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_event.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakePaymentRepository repository;
  late _FakeStripeService stripe;

  PaymentBloc buildBloc() => PaymentBloc(
    getCheckoutPricingUseCase: GetCheckoutPricingUseCase(repository),
    createCheckoutUseCase: CreateCheckoutUseCase(repository),
    getPaymentStatusUseCase: GetPaymentStatusUseCase(repository),
    stripeService: stripe,
  );

  setUp(() {
    repository = _FakePaymentRepository();
    stripe = _FakeStripeService();
  });

  test(
    'confirms payment against the backend after a successful sheet',
    () async {
      repository.session = _session;
      repository.statuses = <PaymentStatusEntity>[_status('Succeeded')];
      stripe.behavior = _SheetBehavior.success;

      final bloc = buildBloc();
      final states = <PaymentState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const PaymentCheckoutRequested('addr_1'));
      await bloc.stream.firstWhere((s) => s.status == PaymentStatus.success);

      await subscription.cancel();
      await bloc.close();

      expect(
        states.map((s) => s.status),
        containsAllInOrder(<PaymentStatus>[
          PaymentStatus.processing,
          PaymentStatus.verifying,
          PaymentStatus.success,
        ]),
      );
      // El estado se consulta con el id devuelto por el checkout.
      expect(repository.requestedPaymentIds, <String>['pay_1']);
      expect(stripe.presentedSession?.paymentId, 'pay_1');
    },
  );

  test('emits cancelled when the user dismisses the payment sheet', () async {
    repository.session = _session;
    stripe.behavior = _SheetBehavior.cancelled;

    final bloc = buildBloc();
    final states = <PaymentState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const PaymentCheckoutRequested('addr_1'));
    await bloc.stream.firstWhere((s) => s.status == PaymentStatus.cancelled);

    await subscription.cancel();
    await bloc.close();

    expect(
      states.map((s) => s.status),
      containsAllInOrder(<PaymentStatus>[
        PaymentStatus.processing,
        PaymentStatus.cancelled,
      ]),
    );
    // No se llega a verificar el estado contra el backend.
    expect(repository.requestedPaymentIds, isEmpty);
  });

  test('emits failure when the payment sheet errors', () async {
    repository.session = _session;
    stripe.behavior = _SheetBehavior.error;

    final bloc = buildBloc();
    bloc.add(const PaymentCheckoutRequested('addr_1'));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == PaymentStatus.failure,
    );
    await bloc.close();

    expect(state.failure?.code, PaymentFailureCode.unknown);
    expect(repository.requestedPaymentIds, isEmpty);
  });

  test('propagates checkout creation failures', () async {
    repository.checkoutFailure = const PaymentFailure(
      PaymentFailureCode.networkError,
    );

    final bloc = buildBloc();
    bloc.add(const PaymentCheckoutRequested('addr_1'));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == PaymentStatus.failure,
    );
    await bloc.close();

    expect(state.failure?.code, PaymentFailureCode.networkError);
    // El sheet nunca se presenta si no hay sesión.
    expect(stripe.presentedSession, isNull);
  });

  test(
    'marks the payment pending when the status check fails after charging',
    () async {
      // El cobro se realizó pero no logramos consultar el estado: no es un error,
      // el webhook lo confirmará y se le informará al usuario luego.
      repository.session = _session;
      repository.statusFailure = const PaymentFailure(
        PaymentFailureCode.networkError,
      );
      stripe.behavior = _SheetBehavior.success;

      final bloc = buildBloc();
      final states = <PaymentState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const PaymentCheckoutRequested('addr_1'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == PaymentStatus.pendingConfirmation,
      );

      await subscription.cancel();
      await bloc.close();

      expect(state.failure, isNull);
      expect(
        states.map((s) => s.status),
        containsAllInOrder(<PaymentStatus>[
          PaymentStatus.processing,
          PaymentStatus.verifying,
          PaymentStatus.pendingConfirmation,
        ]),
      );
    },
  );

  test('emits failure when the backend reports the payment failed', () async {
    repository.session = _session;
    repository.statuses = <PaymentStatusEntity>[_status('Failed')];
    stripe.behavior = _SheetBehavior.success;

    final bloc = buildBloc();
    final states = <PaymentState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const PaymentCheckoutRequested('addr_1'));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == PaymentStatus.failure,
    );

    await subscription.cancel();
    await bloc.close();

    expect(state.failure?.code, PaymentFailureCode.serverError);
    expect(
      states.map((s) => s.status),
      containsAllInOrder(<PaymentStatus>[
        PaymentStatus.processing,
        PaymentStatus.verifying,
        PaymentStatus.failure,
      ]),
    );
  });

  test('loads the checkout pricing breakdown from the backend', () async {
    repository.pricing = _pricing;

    final bloc = buildBloc();
    bloc.add(const PaymentPricingRequested());
    final state = await bloc.stream.firstWhere(
      (s) => s.pricingStatus == CheckoutPricingStatus.loaded,
    );
    await bloc.close();

    // El total mostrado viene siempre del backend, nunca se recalcula en el cliente.
    expect(state.pricing, _pricing);
  });

  test('surfaces a pricing failure without touching the checkout status', () async {
    repository.pricingFailure = const PaymentFailure(
      PaymentFailureCode.networkError,
    );

    final bloc = buildBloc();
    bloc.add(const PaymentPricingRequested());
    final state = await bloc.stream.firstWhere(
      (s) => s.pricingStatus == CheckoutPricingStatus.failure,
    );
    await bloc.close();

    expect(state.pricingFailure?.code, PaymentFailureCode.networkError);
    expect(state.status, PaymentStatus.initial);
  });
}

const _pricing = CheckoutPricingEntity(
  productsAmount: 80.0,
  feyamFee: 9.6,
  estimatedLogistics: 18.5,
  total: 108.1,
  currencyCode: 'USD',
  itemCount: 2,
);

const _session = CheckoutSessionEntity(
  paymentId: 'pay_1',
  paymentIntentClientSecret: 'pi_secret',
  ephemeralKeySecret: 'ek_secret',
  stripeCustomerId: 'cus_1',
  publishableKey: 'pk_test',
  chargedAmount: 100.0,
  currencyCode: 'USD',
);

PaymentStatusEntity _status(String status) => PaymentStatusEntity(
  id: 'pay_1',
  cartId: 'cart_1',
  status: status,
  chargedAmount: 100.0,
  currencyCode: 'USD',
  productsAmount: 80.0,
  feyamFee: 9.6,
  estimatedLogistics: 18.5,
);

class _FakePaymentRepository implements PaymentRepository {
  CheckoutSessionEntity? session;
  PaymentFailure? checkoutFailure;
  PaymentFailure? statusFailure;
  List<PaymentStatusEntity> statuses = <PaymentStatusEntity>[];
  final List<String> requestedPaymentIds = <String>[];

  CheckoutPricingEntity? pricing;
  PaymentFailure? pricingFailure;

  @override
  Future<CheckoutPricingEntity> getCheckoutPricing() async {
    final failure = pricingFailure;
    if (failure != null) throw failure;
    return pricing!;
  }

  @override
  Future<CheckoutSessionEntity> createCheckout(String addressId) async {
    final failure = checkoutFailure;
    if (failure != null) throw failure;
    return session!;
  }

  @override
  Future<PaymentStatusEntity> getPaymentStatus(String paymentId) async {
    requestedPaymentIds.add(paymentId);
    final failure = statusFailure;
    if (failure != null) throw failure;
    // Devuelve el siguiente estado encolado (o el último si se agotan).
    final index = requestedPaymentIds.length - 1;
    return statuses[index < statuses.length ? index : statuses.length - 1];
  }

  @override
  Future<CheckoutSessionEntity> createPriceAdjustmentPayment(
    String purchaseId,
  ) => throw UnimplementedError('not exercised by these tests');

  @override
  Future<PriceAdjustmentStatusEntity> getPriceAdjustmentPaymentStatus(
    String chargeId,
  ) => throw UnimplementedError('not exercised by these tests');
}

enum _SheetBehavior { success, cancelled, error }

class _FakeStripeService extends StripePaymentService {
  _SheetBehavior behavior = _SheetBehavior.success;
  CheckoutSessionEntity? presentedSession;

  @override
  Future<void> presentPaymentSheet(CheckoutSessionEntity session) async {
    presentedSession = session;
    switch (behavior) {
      case _SheetBehavior.success:
        return;
      case _SheetBehavior.cancelled:
        throw const StripePaymentCancelled();
      case _SheetBehavior.error:
        throw const StripePaymentException('boom');
    }
  }
}

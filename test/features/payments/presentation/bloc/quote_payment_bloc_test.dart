import 'package:feyam/core/payments/stripe_payment_service.dart';
import 'package:feyam/features/orders/domain/entities/final_package_entity.dart';
import 'package:feyam/features/orders/domain/entities/order_detail_entity.dart';
import 'package:feyam/features/orders/domain/entities/quote_entity.dart';
import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/domain/entities/shipment_entity.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/repositories/orders_repository.dart';
import 'package:feyam/features/orders/domain/usecases/get_order_quote.dart';
import 'package:feyam/features/payments/domain/entities/checkout_pricing_entity.dart';
import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/entities/payment_status_entity.dart';
import 'package:feyam/features/payments/domain/entities/price_adjustment_status_entity.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/domain/repositories/payment_repository.dart';
import 'package:feyam/features/payments/domain/usecases/pay_order_quote.dart';
import 'package:feyam/features/payments/presentation/bloc/quote_payment_bloc.dart';
import 'package:feyam/features/payments/presentation/bloc/quote_payment_event.dart';
import 'package:feyam/features/payments/presentation/bloc/quote_payment_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakePaymentRepository paymentRepository;
  late _FakeOrdersRepository ordersRepository;
  late _FakeStripeService stripe;

  QuotePaymentBloc buildBloc({
    Duration pollInterval = const Duration(milliseconds: 1),
    int pollMaxAttempts = 3,
  }) => QuotePaymentBloc(
    payOrderQuoteUseCase: PayOrderQuoteUseCase(paymentRepository),
    getOrderQuoteUseCase: GetOrderQuoteUseCase(ordersRepository),
    stripeService: stripe,
    pollInterval: pollInterval,
    pollMaxAttempts: pollMaxAttempts,
  );

  setUp(() {
    paymentRepository = _FakePaymentRepository();
    ordersRepository = _FakeOrdersRepository();
    stripe = _FakeStripeService();
  });

  test(
    'skips Stripe entirely and reaches success when the backend reports no '
    'outstanding balance (requiresPayment: false)',
    () async {
      paymentRepository.payment = null;

      final bloc = buildBloc();
      final states = <QuotePaymentState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const QuotePaymentRequested('order_1'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == QuotePaymentStatus.success,
      );

      await subscription.cancel();
      await bloc.close();

      expect(
        states.map((s) => s.status),
        containsAllInOrder(<QuotePaymentStatus>[
          QuotePaymentStatus.processing,
          QuotePaymentStatus.success,
        ]),
      );
      expect(state.paymentRequired, isFalse);
      // Never touched Stripe or re-fetched the quote for polling.
      expect(stripe.presentedSession, isNull);
      expect(ordersRepository.requestedOrderIds, isEmpty);
    },
  );

  test(
    'presents the Stripe sheet and reaches success once the polled quote '
    'flips to Paid',
    () async {
      paymentRepository.payment = _session;
      stripe.behavior = _SheetBehavior.success;
      ordersRepository.quotes = <QuoteEntity>[_quote(status: 'Paid')];

      final bloc = buildBloc();
      final states = <QuotePaymentState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const QuotePaymentRequested('order_1'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == QuotePaymentStatus.success,
      );

      await subscription.cancel();
      await bloc.close();

      expect(
        states.map((s) => s.status),
        containsAllInOrder(<QuotePaymentStatus>[
          QuotePaymentStatus.processing,
          QuotePaymentStatus.verifying,
          QuotePaymentStatus.success,
        ]),
      );
      expect(state.paymentRequired, isTrue);
      expect(state.amount, _session.chargedAmount);
      expect(state.currencyCode, _session.currencyCode);
      expect(stripe.presentedSession?.paymentId, _session.paymentId);
      expect(ordersRepository.requestedOrderIds, <String>['order_1']);
    },
  );

  test('emits cancelled when the user dismisses the payment sheet', () async {
    paymentRepository.payment = _session;
    stripe.behavior = _SheetBehavior.cancelled;

    final bloc = buildBloc();
    final states = <QuotePaymentState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const QuotePaymentRequested('order_1'));
    await bloc.stream.firstWhere(
      (s) => s.status == QuotePaymentStatus.cancelled,
    );

    await subscription.cancel();
    await bloc.close();

    expect(
      states.map((s) => s.status),
      containsAllInOrder(<QuotePaymentStatus>[
        QuotePaymentStatus.processing,
        QuotePaymentStatus.cancelled,
      ]),
    );
    // Never got to the polling step.
    expect(ordersRepository.requestedOrderIds, isEmpty);
  });

  test(
    'emits failure when the backend refuses to start the payment (e.g. the '
    'quote already expired)',
    () async {
      paymentRepository.payFailure = const PaymentFailure(
        PaymentFailureCode.serverError,
      );

      final bloc = buildBloc();
      bloc.add(const QuotePaymentRequested('order_1'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == QuotePaymentStatus.failure,
      );
      await bloc.close();

      expect(state.failure?.code, PaymentFailureCode.serverError);
      expect(stripe.presentedSession, isNull);
    },
  );

  test('emits failure when the payment sheet errors', () async {
    paymentRepository.payment = _session;
    stripe.behavior = _SheetBehavior.error;

    final bloc = buildBloc();
    bloc.add(const QuotePaymentRequested('order_1'));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == QuotePaymentStatus.failure,
    );
    await bloc.close();

    expect(state.failure?.code, PaymentFailureCode.unknown);
    expect(ordersRepository.requestedOrderIds, isEmpty);
  });

  test(
    'marks the payment pending once polling exhausts its attempt budget '
    "without the quote ever flipping to Paid",
    () async {
      paymentRepository.payment = _session;
      stripe.behavior = _SheetBehavior.success;
      // Never reaches 'Paid' within the attempt budget.
      ordersRepository.quotes = <QuoteEntity>[_quote(status: 'Active')];

      final bloc = buildBloc(
        pollInterval: const Duration(milliseconds: 1),
        pollMaxAttempts: 3,
      );
      final states = <QuotePaymentState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const QuotePaymentRequested('order_1'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == QuotePaymentStatus.pendingConfirmation,
      );

      await subscription.cancel();
      await bloc.close();

      expect(state.failure, isNull);
      expect(
        states.map((s) => s.status),
        containsAllInOrder(<QuotePaymentStatus>[
          QuotePaymentStatus.processing,
          QuotePaymentStatus.verifying,
          QuotePaymentStatus.pendingConfirmation,
        ]),
      );
      // Polled exactly pollMaxAttempts times before giving up.
      expect(ordersRepository.requestedOrderIds.length, 3);
    },
  );

  test(
    'marks the payment pending (not a failure) when polling the quote '
    'throws',
    () async {
      paymentRepository.payment = _session;
      stripe.behavior = _SheetBehavior.success;
      ordersRepository.failure = const OrdersFailure(
        OrdersFailureCode.networkError,
      );

      final bloc = buildBloc();
      bloc.add(const QuotePaymentRequested('order_1'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == QuotePaymentStatus.pendingConfirmation,
      );
      await bloc.close();

      expect(state.failure, isNull);
    },
  );
}

QuoteEntity _quote({required String status}) => QuoteEntity(
  orderId: 'order_1',
  allocatedRetailerCost: 21.40,
  feeByQuantity: 4.80,
  valueSurcharge: 0,
  storeSurcharge: 0,
  feyamFee: 4.80,
  nationalLogistics: 4.00,
  internationalLogistics: 0,
  feyamTaxes: 0,
  otherExplicitCharges: 0,
  finalCustomerTotal: 30.20,
  currencyCode: 'USD',
  status: status,
  createdAt: DateTime.utc(2026, 8, 15, 19),
  expiresAt: DateTime.utc(2026, 8, 16, 19),
);

const _session = CheckoutSessionEntity(
  paymentId: 'pay_1',
  paymentIntentClientSecret: 'pi_secret',
  ephemeralKeySecret: 'ek_secret',
  stripeCustomerId: 'cus_1',
  publishableKey: 'pk_test',
  chargedAmount: 5.20,
  currencyCode: 'USD',
);

class _FakePaymentRepository implements PaymentRepository {
  CheckoutSessionEntity? payment;
  PaymentFailure? payFailure;

  @override
  Future<CheckoutSessionEntity?> payOrderQuote(String orderId) async {
    final failure = payFailure;
    if (failure != null) throw failure;
    return payment;
  }

  @override
  Future<CheckoutPricingEntity> getCheckoutPricing() =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<CheckoutSessionEntity> createCheckout(String addressId) =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<PaymentStatusEntity> getPaymentStatus(String paymentId) =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<CheckoutSessionEntity> createPriceAdjustmentPayment(
    String purchaseId,
  ) => throw UnimplementedError('not exercised by these tests');

  @override
  Future<PriceAdjustmentStatusEntity> getPriceAdjustmentPaymentStatus(
    String chargeId,
  ) => throw UnimplementedError('not exercised by these tests');
}

class _FakeOrdersRepository implements OrdersRepository {
  List<QuoteEntity> quotes = <QuoteEntity>[];
  OrdersFailure? failure;
  final List<String> requestedOrderIds = <String>[];

  @override
  Future<QuoteEntity?> getOrderQuote({required String orderId}) async {
    requestedOrderIds.add(orderId);
    final f = failure;
    if (f != null) throw f;
    if (quotes.isEmpty) return null;
    final index = requestedOrderIds.length - 1;
    return quotes[index < quotes.length ? index : quotes.length - 1];
  }

  @override
  Future<OrderDetailEntity> getOrderDetail({required String orderId}) =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<List<RecentOrderEntity>> getRecentOrders({int take = 5}) =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<List<ShipmentEntity>> getOrderShipments({required String orderId}) =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<FinalPackageEntity?> getOrderFinalPackage({required String orderId}) =>
      throw UnimplementedError('not exercised by these tests');
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

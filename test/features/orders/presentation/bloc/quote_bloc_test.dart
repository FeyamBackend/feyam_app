import 'package:feyam/features/orders/domain/entities/final_package_entity.dart';
import 'package:feyam/features/orders/domain/entities/order_detail_entity.dart';
import 'package:feyam/features/orders/domain/entities/quote_entity.dart';
import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/domain/entities/shipment_entity.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/repositories/orders_repository.dart';
import 'package:feyam/features/orders/domain/usecases/get_order_quote.dart';
import 'package:feyam/features/orders/presentation/bloc/quote_bloc.dart';
import 'package:feyam/features/orders/presentation/bloc/quote_event.dart';
import 'package:feyam/features/orders/presentation/bloc/quote_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeOrdersRepository repository;

  QuoteBloc buildBloc() =>
      QuoteBloc(getOrderQuoteUseCase: GetOrderQuoteUseCase(repository));

  setUp(() {
    repository = _FakeOrdersRepository();
  });

  test('emits loading then loaded-with-quote on a successful fetch', () async {
    repository.quote = _quote;

    final bloc = buildBloc();
    final states = <QuoteState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const QuoteRequested(orderId: 'order_1'));
    await bloc.stream.firstWhere((s) => s.status == QuoteStatus.loaded);

    await subscription.cancel();
    await bloc.close();

    expect(
      states.map((s) => s.status),
      containsAllInOrder(<QuoteStatus>[QuoteStatus.loading, QuoteStatus.loaded]),
    );
    expect(states.last.quote, _quote);
    expect(repository.requestedOrderIds, <String>['order_1']);
  });

  test(
    'emits loading then loaded-with-no-quote (not a failure) when the order '
    "hasn't reached CheckoutVerified yet",
    () async {
      repository.quote = null;

      final bloc = buildBloc();
      final states = <QuoteState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const QuoteRequested(orderId: 'order_1'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == QuoteStatus.loaded,
      );

      await subscription.cancel();
      await bloc.close();

      expect(
        states.map((s) => s.status),
        containsAllInOrder(<QuoteStatus>[
          QuoteStatus.loading,
          QuoteStatus.loaded,
        ]),
      );
      expect(state.status, QuoteStatus.loaded);
      expect(state.quote, isNull);
      expect(state.failure, isNull);
    },
  );

  test('emits loading then failure when the repository throws', () async {
    repository.failure = const OrdersFailure(OrdersFailureCode.serverError);

    final bloc = buildBloc();
    final states = <QuoteState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const QuoteRequested(orderId: 'order_1'));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == QuoteStatus.failure,
    );

    await subscription.cancel();
    await bloc.close();

    expect(
      states.map((s) => s.status),
      containsAllInOrder(<QuoteStatus>[QuoteStatus.loading, QuoteStatus.failure]),
    );
    expect(state.failure?.code, OrdersFailureCode.serverError);
    expect(state.quote, isNull);
  });
}

final _quote = QuoteEntity(
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
  status: 'Active',
  createdAt: DateTime.utc(2026, 8, 15, 19),
  expiresAt: DateTime.utc(2026, 8, 16, 19),
);

class _FakeOrdersRepository implements OrdersRepository {
  QuoteEntity? quote;
  OrdersFailure? failure;
  final List<String> requestedOrderIds = <String>[];

  @override
  Future<QuoteEntity?> getOrderQuote({required String orderId}) async {
    requestedOrderIds.add(orderId);
    final f = failure;
    if (f != null) throw f;
    return quote;
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

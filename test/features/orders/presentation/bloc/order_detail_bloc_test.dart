import 'package:feyam/features/orders/domain/entities/final_package_entity.dart';
import 'package:feyam/features/orders/domain/entities/order_detail_entity.dart';
import 'package:feyam/features/orders/domain/entities/quote_entity.dart';
import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/domain/entities/shipment_entity.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/repositories/orders_repository.dart';
import 'package:feyam/features/orders/domain/usecases/get_order_detail.dart';
import 'package:feyam/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:feyam/features/orders/presentation/bloc/order_detail_event.dart';
import 'package:feyam/features/orders/presentation/bloc/order_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeOrdersRepository repository;

  OrderDetailBloc buildBloc() => OrderDetailBloc(
        getOrderDetailUseCase: GetOrderDetailUseCase(repository),
      );

  setUp(() {
    repository = _FakeOrdersRepository();
  });

  test('emits loading then loaded on a successful fetch', () async {
    repository.detail = _detail;

    final bloc = buildBloc();
    final states = <OrderDetailState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const OrderDetailRequested(orderId: 'order_1'));
    await bloc.stream.firstWhere((s) => s.status == OrderDetailStatus.loaded);

    await subscription.cancel();
    await bloc.close();

    expect(
      states.map((s) => s.status),
      containsAllInOrder(<OrderDetailStatus>[
        OrderDetailStatus.loading,
        OrderDetailStatus.loaded,
      ]),
    );
    expect(states.last.detail, _detail);
    expect(repository.requestedOrderIds, <String>['order_1']);
  });

  test('emits loading then failure when the repository throws', () async {
    repository.failure = const OrdersFailure(OrdersFailureCode.notFound);

    final bloc = buildBloc();
    final states = <OrderDetailState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const OrderDetailRequested(orderId: 'missing'));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == OrderDetailStatus.failure,
    );

    await subscription.cancel();
    await bloc.close();

    expect(
      states.map((s) => s.status),
      containsAllInOrder(<OrderDetailStatus>[
        OrderDetailStatus.loading,
        OrderDetailStatus.failure,
      ]),
    );
    expect(state.failure?.code, OrdersFailureCode.notFound);
    expect(state.detail, isNull);
  });
}

final _detail = OrderDetailEntity(
  id: 'order_1',
  status: 'PendingPriceReview',
  submittedAt: DateTime.utc(2026, 8, 15, 12),
  lines: const <OrderLineEntity>[
    OrderLineEntity(
      productTitle: 'Widget',
      variant: 'Blue',
      quantity: 2,
      unitPrice: 50.0,
      currencyCode: 'USD',
      storeName: 'Acme',
    ),
  ],
  estimatedTotal: 100.0,
  currencyCode: 'USD',
);

class _FakeOrdersRepository implements OrdersRepository {
  OrderDetailEntity? detail;
  OrdersFailure? failure;
  final List<String> requestedOrderIds = <String>[];

  @override
  Future<OrderDetailEntity> getOrderDetail({required String orderId}) async {
    requestedOrderIds.add(orderId);
    final f = failure;
    if (f != null) throw f;
    return detail!;
  }

  @override
  Future<List<RecentOrderEntity>> getRecentOrders({int take = 5}) =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<QuoteEntity?> getOrderQuote({required String orderId}) =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<List<ShipmentEntity>> getOrderShipments({required String orderId}) =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<FinalPackageEntity?> getOrderFinalPackage({required String orderId}) =>
      throw UnimplementedError('not exercised by these tests');
}

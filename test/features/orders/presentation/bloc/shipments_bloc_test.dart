import 'package:feyam/features/orders/domain/entities/final_package_entity.dart';
import 'package:feyam/features/orders/domain/entities/order_detail_entity.dart';
import 'package:feyam/features/orders/domain/entities/quote_entity.dart';
import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/domain/entities/shipment_entity.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/repositories/orders_repository.dart';
import 'package:feyam/features/orders/domain/usecases/get_order_shipments.dart';
import 'package:feyam/features/orders/presentation/bloc/shipments_bloc.dart';
import 'package:feyam/features/orders/presentation/bloc/shipments_event.dart';
import 'package:feyam/features/orders/presentation/bloc/shipments_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeOrdersRepository repository;

  ShipmentsBloc buildBloc() => ShipmentsBloc(
        getOrderShipmentsUseCase: GetOrderShipmentsUseCase(repository),
      );

  setUp(() {
    repository = _FakeOrdersRepository();
  });

  test(
    'emits loading then loaded-with-shipments on a successful fetch',
    () async {
      repository.shipments = <ShipmentEntity>[_shipment];

      final bloc = buildBloc();
      final states = <ShipmentsState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const ShipmentsRequested(orderId: 'order_1'));
      await bloc.stream.firstWhere((s) => s.status == ShipmentsStatus.loaded);

      await subscription.cancel();
      await bloc.close();

      expect(
        states.map((s) => s.status),
        containsAllInOrder(<ShipmentsStatus>[
          ShipmentsStatus.loading,
          ShipmentsStatus.loaded,
        ]),
      );
      expect(states.last.shipments, <ShipmentEntity>[_shipment]);
      expect(repository.requestedOrderIds, <String>['order_1']);
    },
  );

  test(
    'emits loading then loaded-with-empty-list (not a failure) when the '
    "order's purchase group hasn't been executed yet",
    () async {
      repository.shipments = <ShipmentEntity>[];

      final bloc = buildBloc();
      final states = <ShipmentsState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const ShipmentsRequested(orderId: 'order_1'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == ShipmentsStatus.loaded,
      );

      await subscription.cancel();
      await bloc.close();

      expect(
        states.map((s) => s.status),
        containsAllInOrder(<ShipmentsStatus>[
          ShipmentsStatus.loading,
          ShipmentsStatus.loaded,
        ]),
      );
      expect(state.status, ShipmentsStatus.loaded);
      expect(state.shipments, isEmpty);
      expect(state.failure, isNull);
    },
  );

  test('emits loading then failure when the repository throws', () async {
    repository.failure = const OrdersFailure(OrdersFailureCode.serverError);

    final bloc = buildBloc();
    final states = <ShipmentsState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const ShipmentsRequested(orderId: 'order_1'));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == ShipmentsStatus.failure,
    );

    await subscription.cancel();
    await bloc.close();

    expect(
      states.map((s) => s.status),
      containsAllInOrder(<ShipmentsStatus>[
        ShipmentsStatus.loading,
        ShipmentsStatus.failure,
      ]),
    );
    expect(state.failure?.code, OrdersFailureCode.serverError);
    expect(state.shipments, isEmpty);
  });
}

final _shipment = ShipmentEntity(
  id: 'shipment_1',
  purchaseGroupId: 'group_1',
  trackingNumbers: const <String>['1Z999AA10123456784'],
  status: 'InTransit',
  carrier: 'DHL',
  createdAt: DateTime.utc(2026, 8, 15, 20),
);

class _FakeOrdersRepository implements OrdersRepository {
  List<ShipmentEntity> shipments = <ShipmentEntity>[];
  OrdersFailure? failure;
  final List<String> requestedOrderIds = <String>[];

  @override
  Future<List<ShipmentEntity>> getOrderShipments({
    required String orderId,
  }) async {
    requestedOrderIds.add(orderId);
    final f = failure;
    if (f != null) throw f;
    return shipments;
  }

  @override
  Future<QuoteEntity?> getOrderQuote({required String orderId}) =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<OrderDetailEntity> getOrderDetail({required String orderId}) =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<List<RecentOrderEntity>> getRecentOrders({int take = 5}) =>
      throw UnimplementedError('not exercised by these tests');

  @override
  Future<FinalPackageEntity?> getOrderFinalPackage({required String orderId}) =>
      throw UnimplementedError('not exercised by these tests');
}

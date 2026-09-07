import 'package:feyam/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:feyam/features/orders/data/models/order_detail_model.dart';
import 'package:feyam/features/orders/data/models/quote_model.dart';
import 'package:feyam/features/orders/data/models/shipment_model.dart';
import 'package:feyam/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  late _FakeDataSource dataSource;

  OrdersRepositoryImpl buildRepo() =>
      OrdersRepositoryImpl(remoteDataSource: dataSource);

  setUp(() {
    dataSource = _FakeDataSource();
  });

  test('returns the order detail on success', () async {
    dataSource.behavior = _Behavior.ok;

    final detail = await buildRepo().getOrderDetail(orderId: 'order_1');

    expect(detail.id, 'order_1');
    expect(detail.lines, hasLength(1));
  });

  test('maps a 404 to OrdersFailure.notFound', () async {
    dataSource.behavior = _Behavior.notFound;

    final failure = await _captureFailure(
      () => buildRepo().getOrderDetail(orderId: 'missing'),
    );

    expect(failure.code, OrdersFailureCode.notFound);
  });

  test(
    'maps a 401 (sesión ya expirada; refresh/retry lo maneja el cliente HTTP) '
    'to OrdersFailure.sessionExpired',
    () async {
      dataSource.behavior = _Behavior.unauthorized;

      final failure = await _captureFailure(
        () => buildRepo().getOrderDetail(orderId: 'order_1'),
      );

      expect(failure.code, OrdersFailureCode.sessionExpired);
    },
  );

  test('maps a server error to OrdersFailure.serverError', () async {
    dataSource.behavior = _Behavior.server;

    final failure = await _captureFailure(
      () => buildRepo().getOrderDetail(orderId: 'order_1'),
    );

    expect(failure.code, OrdersFailureCode.serverError);
  });

  test('returns the quote on success', () async {
    dataSource.quoteBehavior = _QuoteBehavior.ok;

    final quote = await buildRepo().getOrderQuote(orderId: 'order_1');

    expect(quote, isNotNull);
    expect(quote!.orderId, 'order_1');
  });

  test(
    'returns null (not a failure) when the order has no quote yet',
    () async {
      dataSource.quoteBehavior = _QuoteBehavior.noQuote;

      final quote = await buildRepo().getOrderQuote(orderId: 'order_1');

      expect(quote, isNull);
    },
  );

  test(
    'maps a 401 (sesión ya expirada) to OrdersFailure.sessionExpired for '
    'the quote fetch',
    () async {
      dataSource.quoteBehavior = _QuoteBehavior.unauthorized;

      final failure = await _captureFailure(
        () => buildRepo().getOrderQuote(orderId: 'order_1'),
      );

      expect(failure.code, OrdersFailureCode.sessionExpired);
    },
  );

  test('maps a server error to OrdersFailure.serverError for the quote fetch', () async {
    dataSource.quoteBehavior = _QuoteBehavior.server;

    final failure = await _captureFailure(
      () => buildRepo().getOrderQuote(orderId: 'order_1'),
    );

    expect(failure.code, OrdersFailureCode.serverError);
  });

  test('returns the shipments (possibly empty) on success', () async {
    dataSource.shipmentsBehavior = _ShipmentsBehavior.ok;

    final shipments = await buildRepo().getOrderShipments(orderId: 'order_1');

    expect(shipments, hasLength(1));
    expect(shipments.single.id, 'shipment_1');
  });

  test(
    'returns an empty list (not a failure) when the order has no shipments '
    "yet — the normal case before its purchase group has been executed",
    () async {
      dataSource.shipmentsBehavior = _ShipmentsBehavior.empty;

      final shipments = await buildRepo().getOrderShipments(
        orderId: 'order_1',
      );

      expect(shipments, isEmpty);
    },
  );

  test(
    'maps a 404 to OrdersFailure.notFound for the shipments fetch — unlike '
    "the quote fetch, a 404 here is a real failure",
    () async {
      dataSource.shipmentsBehavior = _ShipmentsBehavior.notFound;

      final failure = await _captureFailure(
        () => buildRepo().getOrderShipments(orderId: 'missing'),
      );

      expect(failure.code, OrdersFailureCode.notFound);
    },
  );

  test(
    'maps a 401 (sesión ya expirada) to OrdersFailure.sessionExpired for '
    'the shipments fetch',
    () async {
      dataSource.shipmentsBehavior = _ShipmentsBehavior.unauthorized;

      final failure = await _captureFailure(
        () => buildRepo().getOrderShipments(orderId: 'order_1'),
      );

      expect(failure.code, OrdersFailureCode.sessionExpired);
    },
  );

  test(
    'maps a server error to OrdersFailure.serverError for the shipments '
    'fetch',
    () async {
      dataSource.shipmentsBehavior = _ShipmentsBehavior.server;

      final failure = await _captureFailure(
        () => buildRepo().getOrderShipments(orderId: 'order_1'),
      );

      expect(failure.code, OrdersFailureCode.serverError);
    },
  );
}

Future<OrdersFailure> _captureFailure(Future<void> Function() action) async {
  try {
    await action();
  } on OrdersFailure catch (f) {
    return f;
  }
  fail('Expected OrdersFailure to be thrown');
}

enum _Behavior { ok, notFound, unauthorized, server }

enum _QuoteBehavior { ok, noQuote, unauthorized, server }

enum _ShipmentsBehavior { ok, empty, notFound, unauthorized, server }

class _FakeDataSource extends OrdersRemoteDataSource {
  _FakeDataSource() : super(client: http.Client(), apiBaseUrl: '');

  _Behavior behavior = _Behavior.ok;
  _QuoteBehavior quoteBehavior = _QuoteBehavior.ok;
  _ShipmentsBehavior shipmentsBehavior = _ShipmentsBehavior.ok;

  @override
  Future<OrderDetailModel> getOrderDetail({required String orderId}) async {
    switch (behavior) {
      case _Behavior.ok:
        return OrderDetailModel.fromJson(<String, dynamic>{
          'id': orderId,
          'status': 'Submitted',
          'submittedAt': '2026-08-15T12:00:00Z',
          'lines': <dynamic>[
            <String, dynamic>{
              'productTitle': 'Widget',
              'variant': null,
              'quantity': 1,
              'unitPrice': 10.0,
              'currencyCode': 'USD',
              'storeName': null,
            },
          ],
        });
      case _Behavior.notFound:
        throw const OrdersOrderNotFoundException();
      case _Behavior.unauthorized:
        throw const OrdersUnauthorizedException();
      case _Behavior.server:
        throw const OrdersServerException(500);
    }
  }

  @override
  Future<QuoteModel?> getOrderQuote({required String orderId}) async {
    switch (quoteBehavior) {
      case _QuoteBehavior.ok:
        return QuoteModel.fromJson(<String, dynamic>{
          'orderId': orderId,
          'allocatedRetailerCost': 21.40,
          'feeByQuantity': 4.80,
          'valueSurcharge': 0,
          'storeSurcharge': 0,
          'feyamFee': 4.80,
          'nationalLogistics': 4.00,
          'internationalLogistics': 0,
          'feyamTaxes': 0,
          'otherExplicitCharges': 0,
          'finalCustomerTotal': 30.20,
          'currencyCode': 'USD',
          'status': 'Active',
          'createdAt': '2026-08-15T19:00:00Z',
          'expiresAt': '2026-08-16T19:00:00Z',
        });
      case _QuoteBehavior.noQuote:
        return null;
      case _QuoteBehavior.unauthorized:
        throw const OrdersUnauthorizedException();
      case _QuoteBehavior.server:
        throw const OrdersServerException(500);
    }
  }

  @override
  Future<List<ShipmentModel>> getOrderShipments({
    required String orderId,
  }) async {
    switch (shipmentsBehavior) {
      case _ShipmentsBehavior.ok:
        return <ShipmentModel>[
          ShipmentModel.fromJson(<String, dynamic>{
            'id': 'shipment_1',
            'purchaseGroupId': 'group_1',
            'trackingNumbers': <String>['1Z999AA10123456784'],
            'status': 'InTransit',
            'carrier': 'DHL',
            'createdAt': '2026-08-15T20:00:00Z',
            'exceptionReason': null,
          }),
        ];
      case _ShipmentsBehavior.empty:
        return <ShipmentModel>[];
      case _ShipmentsBehavior.notFound:
        throw const OrdersOrderNotFoundException();
      case _ShipmentsBehavior.unauthorized:
        throw const OrdersUnauthorizedException();
      case _ShipmentsBehavior.server:
        throw const OrdersServerException(500);
    }
  }
}

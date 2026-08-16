import 'dart:convert';

import 'package:feyam/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  OrdersRemoteDataSource build(http.Client client) => OrdersRemoteDataSource(
        client: client,
        apiBaseUrl: 'https://api.test',
      );

  group('getOrderQuote', () {
    test('returns the parsed quote on 200', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), 'https://api.test/api/orders/order_1/quote');
        return http.Response(
          jsonEncode(<String, dynamic>{
            'orderId': 'order_1',
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
          }),
          200,
        );
      });

      final quote = await build(client).getOrderQuote(orderId: 'order_1');

      expect(quote, isNotNull);
      expect(quote!.orderId, 'order_1');
      expect(quote.finalCustomerTotal, 30.20);
    });

    test(
      'returns null on 404 — no quote exists yet, which is the normal case',
      () async {
        final client = MockClient((request) async => http.Response('', 404));

        final quote = await build(client).getOrderQuote(orderId: 'order_1');

        expect(quote, isNull);
      },
    );

    test('throws OrdersUnauthorizedException on 401', () async {
      final client = MockClient((request) async => http.Response('', 401));

      await expectLater(
        build(client).getOrderQuote(orderId: 'order_1'),
        throwsA(isA<OrdersUnauthorizedException>()),
      );
    });

    test('throws OrdersServerException on a non-200/401/404 status', () async {
      final client = MockClient((request) async => http.Response('', 500));

      await expectLater(
        build(client).getOrderQuote(orderId: 'order_1'),
        throwsA(
          isA<OrdersServerException>().having(
            (e) => e.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });
  });

  group('getOrderShipments', () {
    test('returns the parsed (possibly empty) list on 200', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.test/api/orders/order_1/shipments',
        );
        return http.Response(
          jsonEncode(<dynamic>[
            <String, dynamic>{
              'id': 'shipment_1',
              'purchaseGroupId': 'group_1',
              'trackingNumbers': <String>['1Z999AA10123456784'],
              'status': 'InTransit',
              'carrier': 'DHL',
              'createdAt': '2026-08-15T20:00:00Z',
              'exceptionReason': null,
            },
          ]),
          200,
        );
      });

      final shipments = await build(client).getOrderShipments(
        orderId: 'order_1',
      );

      expect(shipments, hasLength(1));
      expect(shipments.single.id, 'shipment_1');
      expect(shipments.single.trackingNumbers, <String>[
        '1Z999AA10123456784',
      ]);
    });

    test(
      'returns an empty list on 200 with an empty array — the normal case '
      "before an order's purchase group has been executed",
      () async {
        final client = MockClient(
          (request) async => http.Response(jsonEncode(<dynamic>[]), 200),
        );

        final shipments = await build(client).getOrderShipments(
          orderId: 'order_1',
        );

        expect(shipments, isEmpty);
      },
    );

    test(
      'throws OrdersOrderNotFoundException on 404 — unlike getOrderQuote, '
      "this means the order itself doesn't exist or isn't the caller's",
      () async {
        final client = MockClient((request) async => http.Response('', 404));

        await expectLater(
          build(client).getOrderShipments(orderId: 'order_1'),
          throwsA(isA<OrdersOrderNotFoundException>()),
        );
      },
    );

    test('throws OrdersUnauthorizedException on 401', () async {
      final client = MockClient((request) async => http.Response('', 401));

      await expectLater(
        build(client).getOrderShipments(orderId: 'order_1'),
        throwsA(isA<OrdersUnauthorizedException>()),
      );
    });

    test('throws OrdersServerException on a non-200/401/404 status', () async {
      final client = MockClient((request) async => http.Response('', 500));

      await expectLater(
        build(client).getOrderShipments(orderId: 'order_1'),
        throwsA(
          isA<OrdersServerException>().having(
            (e) => e.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });
  });
}

import 'package:feyam/features/orders/data/models/order_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'OrderDetailModel.fromJson parses all fields, including nullable line fields',
    () {
      final json = <String, dynamic>{
        'id': 'order_1',
        'status': 'PendingPriceReview',
        'submittedAt': '2026-08-15T12:00:00Z',
        'lines': <dynamic>[
          <String, dynamic>{
            'productTitle': 'Widget',
            'variant': 'Blue / L',
            'quantity': 2,
            'unitPrice': 50.0,
            'currencyCode': 'USD',
            'storeName': 'Acme',
          },
          <String, dynamic>{
            'productTitle': 'Gadget',
            'variant': null,
            // Backend may send a whole-number price as an int.
            'quantity': 1,
            'unitPrice': 10,
            'currencyCode': 'USD',
            'storeName': null,
          },
        ],
        'estimatedTotal': 110.0,
        'confirmedTotal': null,
        'currencyCode': 'USD',
        'rejectionReason': null,
      };

      final model = OrderDetailModel.fromJson(json);

      expect(model.id, 'order_1');
      expect(model.status, 'PendingPriceReview');
      expect(model.submittedAt, DateTime.parse('2026-08-15T12:00:00Z'));
      expect(model.lines, hasLength(2));

      expect(model.lines[0].productTitle, 'Widget');
      expect(model.lines[0].variant, 'Blue / L');
      expect(model.lines[0].quantity, 2);
      expect(model.lines[0].unitPrice, 50.0);
      expect(model.lines[0].currencyCode, 'USD');
      expect(model.lines[0].storeName, 'Acme');

      expect(model.lines[1].variant, isNull);
      expect(model.lines[1].storeName, isNull);
      expect(model.lines[1].unitPrice, 10.0);

      expect(model.estimatedTotal, 110.0);
      expect(model.confirmedTotal, isNull);
      expect(model.currencyCode, 'USD');
      expect(model.rejectionReason, isNull);
    },
  );

  test('OrderDetailModel.fromJson tolerates a missing lines array', () {
    final json = <String, dynamic>{
      'id': 'order_2',
      'status': 'Cancelled',
      'submittedAt': '2026-08-15T12:00:00Z',
      'estimatedTotal': 25.0,
      'currencyCode': 'USD',
      'rejectionReason': 'Product no longer available',
    };

    final model = OrderDetailModel.fromJson(json);

    expect(model.lines, isEmpty);
    expect(model.estimatedTotal, 25.0);
    expect(model.rejectionReason, 'Product no longer available');
  });
}

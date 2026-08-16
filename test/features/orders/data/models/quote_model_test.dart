import 'package:feyam/features/orders/data/models/quote_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QuoteModel.fromJson parses all fields', () {
    final json = <String, dynamic>{
      'orderId': 'order_1',
      'allocatedRetailerCost': 21.40,
      'feeByQuantity': 4.80,
      'valueSurcharge': 0,
      'storeSurcharge': 0,
      'feyamFee': 4.80,
      // Backend may send a whole-number amount as an int.
      'nationalLogistics': 4,
      'internationalLogistics': 0,
      'feyamTaxes': 0,
      'otherExplicitCharges': 0,
      'finalCustomerTotal': 30.20,
      'currencyCode': 'USD',
      'status': 'Active',
      'createdAt': '2026-08-15T19:00:00Z',
      'expiresAt': '2026-08-16T19:00:00Z',
    };

    final model = QuoteModel.fromJson(json);

    expect(model.orderId, 'order_1');
    expect(model.allocatedRetailerCost, 21.40);
    expect(model.feeByQuantity, 4.80);
    expect(model.valueSurcharge, 0.0);
    expect(model.storeSurcharge, 0.0);
    expect(model.feyamFee, 4.80);
    expect(model.nationalLogistics, 4.0);
    expect(model.internationalLogistics, 0.0);
    expect(model.feyamTaxes, 0.0);
    expect(model.otherExplicitCharges, 0.0);
    expect(model.finalCustomerTotal, 30.20);
    expect(model.currencyCode, 'USD');
    expect(model.status, 'Active');
    expect(model.createdAt, DateTime.parse('2026-08-15T19:00:00Z'));
    expect(model.expiresAt, DateTime.parse('2026-08-16T19:00:00Z'));
  });
}

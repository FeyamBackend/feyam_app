import 'package:feyam/features/orders/data/models/shipment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShipmentModel.fromJson parses all fields', () {
    final json = <String, dynamic>{
      'id': 'shipment_1',
      'purchaseGroupId': 'group_1',
      'trackingNumbers': <String>['1Z999AA10123456784'],
      'status': 'InTransit',
      'carrier': 'DHL',
      'createdAt': '2026-08-15T20:00:00Z',
      'exceptionReason': null,
    };

    final model = ShipmentModel.fromJson(json);

    expect(model.id, 'shipment_1');
    expect(model.purchaseGroupId, 'group_1');
    expect(model.trackingNumbers, <String>['1Z999AA10123456784']);
    expect(model.status, 'InTransit');
    expect(model.carrier, 'DHL');
    expect(model.createdAt, DateTime.parse('2026-08-15T20:00:00Z'));
    expect(model.exceptionReason, isNull);
  });

  test(
    'ShipmentModel.fromJson tolerates an empty trackingNumbers array — the '
    'normal case while status is AwaitingTracking',
    () {
      final json = <String, dynamic>{
        'id': 'shipment_2',
        'purchaseGroupId': 'group_1',
        'trackingNumbers': <String>[],
        'status': 'AwaitingTracking',
        'carrier': null,
        'createdAt': '2026-08-15T20:00:00Z',
        'exceptionReason': null,
      };

      final model = ShipmentModel.fromJson(json);

      expect(model.trackingNumbers, isEmpty);
      expect(model.status, 'AwaitingTracking');
      expect(model.carrier, isNull);
    },
  );

  test(
    'ShipmentModel.fromJson parses multiple tracking numbers accumulated '
    'over time, and an exceptionReason when status is Exception',
    () {
      final json = <String, dynamic>{
        'id': 'shipment_3',
        'purchaseGroupId': 'group_1',
        'trackingNumbers': <String>['TRACK-1', 'TRACK-2', 'TRACK-3'],
        'status': 'Exception',
        'carrier': 'FedEx',
        'createdAt': '2026-08-15T20:00:00Z',
        'exceptionReason': 'Package lost in transit',
      };

      final model = ShipmentModel.fromJson(json);

      expect(model.trackingNumbers, <String>['TRACK-1', 'TRACK-2', 'TRACK-3']);
      expect(model.status, 'Exception');
      expect(model.exceptionReason, 'Package lost in transit');
    },
  );
}

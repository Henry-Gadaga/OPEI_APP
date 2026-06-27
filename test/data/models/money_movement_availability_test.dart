import 'package:flutter_test/flutter_test.dart';
import 'package:opei/data/models/money_movement_availability.dart';

void main() {
  group('MoneyMovementAvailability', () {
    test('parses explicit disabled rails and networks', () {
      final availability = MoneyMovementAvailability.fromJson({
        'version': 2,
        'updatedAt': '2026-06-27T01:00:00.000Z',
        'deposit': {
          'expressP2P': {
            'enabled': true,
            'currencies': [
              {'code': 'MWK', 'enabled': false},
            ],
          },
          'crypto': {
            'enabled': true,
            'assets': [
              {
                'code': 'USDT',
                'enabled': true,
                'networks': [
                  {'code': 'tron', 'enabled': false},
                ],
              },
            ],
          },
        },
      });

      expect(availability.version, 2);
      expect(availability.isFallback, isFalse);
      expect(availability.deposit.expressP2P.isCurrencyEnabled('MWK'), isFalse);
      expect(
        availability.deposit.crypto.isNetworkEnabled('USDT', 'tron'),
        isFalse,
      );
    });

    test('keeps omitted methods enabled for backwards compatibility', () {
      final availability = MoneyMovementAvailability.fromJson({
        'version': 1,
        'withdrawal': {
          'mobileMoney': {
            'enabled': true,
            'countries': [
              {
                'country': 'GH',
                'enabled': true,
                'networks': [
                  {'code': 'MTN', 'enabled': true},
                ],
              },
            ],
          },
          'crypto': {
            'enabled': true,
            'assets': [
              {'code': 'USDT', 'enabled': true},
            ],
          },
        },
      });

      expect(
        availability.withdrawal.mobileMoney.isCountryEnabled('SN'),
        isTrue,
      );
      expect(
        availability.withdrawal.mobileMoney.isNetworkEnabled('GH', 'AIRTEL'),
        isTrue,
      );
      expect(
        availability.withdrawal.crypto.isNetworkEnabled('USDC', 'polygon'),
        isTrue,
      );
      expect(availability.cards.creation.enabled, isTrue);
      expect(availability.cards.topUp.enabled, isTrue);
      expect(availability.cards.withdrawal.enabled, isTrue);
    });

    test('parses card availability flags', () {
      final availability = MoneyMovementAvailability.fromJson({
        'version': 3,
        'cards': {
          'creation': {'enabled': false, 'reason': 'Temporary maintenance'},
          'topUp': {'enabled': true},
          'withdrawal': {'enabled': false},
        },
      });

      expect(availability.cards.creation.enabled, isFalse);
      expect(availability.cards.creation.reason, 'Temporary maintenance');
      expect(availability.cards.topUp.enabled, isTrue);
      expect(availability.cards.withdrawal.enabled, isFalse);
    });
  });
}

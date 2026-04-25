import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:napstack/features/pro/purchase_service.dart';

void main() {
  group('ProUnlockStatus', () {
    test('przechowuje isPro i ostrzeżenie o cache', () {
      const s = ProUnlockStatus(
        isPro: true,
        staleCacheWarning: true,
      );
      expect(s.isPro, isTrue);
      expect(s.staleCacheWarning, isTrue);
    });
  });

  group('PurchaseException', () {
    test('isUserCancelled — purchase cancelled', () {
      final e = PurchaseException(
        'cancelled',
        purchasesCode: PurchasesErrorCode.purchaseCancelledError,
      );
      expect(e.isUserCancelled, isTrue);
    });

    test('isUserCancelled — inny kod', () {
      final e = PurchaseException(
        'other',
        purchasesCode: PurchasesErrorCode.networkError,
      );
      expect(e.isUserCancelled, isFalse);
    });

    test('fromPlatform — tworzy PurchaseException', () {
      final pe = PlatformException(
        code: '0',
        message: 'test',
        details: {'readable_error_code': 'NetworkError'},
      );
      final ex = PurchaseException.fromPlatform(pe);
      expect(ex, isA<PurchaseException>());
      expect(ex.toString(), isNotEmpty);
    });
  });
}

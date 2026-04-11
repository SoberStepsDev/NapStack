import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/security/secure_storage_service.dart';

/// Zarządza statusem Pro przez RevenueCat.
///
/// Cache statusu Pro jest przechowywany w flutter_secure_storage
/// (nie SharedPreferences) — status Pro wpływa na dostęp do funkcji.
class PurchaseService {
  PurchaseService(this._storage);

  final SecureStorageService _storage;

  static const _kEntitlement = 'pro';
  static const _kProductId = 'napstack_pro_lifetime';

  static Future<void> configure(String appUserId) async {
    await Purchases.configure(
      PurchasesConfiguration(
        const String.fromEnvironment(
          'RC_PUBLIC_KEY_ANDROID',
          defaultValue: 'REPLACE_WITH_RC_KEY',
        ),
      )..appUserID = appUserId,
    );
  }

  /// Sprawdza Pro z RC, z fallbackiem na secure storage.
  Future<bool> isProUnlocked() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final isActive = info.entitlements.active.containsKey(_kEntitlement);
      await _storage.setProCached(isActive);
      return isActive;
    } catch (_) {
      // Offline lub RC niedostępny — ostatni znany status
      return _storage.getProCached();
    }
  }

  Future<bool> purchasePro() async {
    try {
      final offerings = await Purchases.getOfferings();
      final package = offerings.current?.availablePackages
          .where((p) => p.storeProduct.identifier == _kProductId)
          .firstOrNull;

      if (package == null) throw Exception('Pakiet Pro nie znaleziony.');

      final result = await Purchases.purchase(PurchaseParams.package(package));
      final isActive =
          result.customerInfo.entitlements.active.containsKey(_kEntitlement);
      await _storage.setProCached(isActive);
      return isActive;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return false;
      rethrow;
    }
  }

  /// Synchronizuje zakupy z RevenueCat i aktualizuje lokalny cache Pro
  /// (secure storage), tak jak [isProUnlocked] po udanym odczycie z RC.
  Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      final isActive = info.entitlements.active.containsKey(_kEntitlement);
      await _storage.setProCached(isActive);
      return isActive;
    } on PlatformException catch (_) {
      // Bez nadpisywania cache przy błędzie sieci / konfiguracji sklepu.
      rethrow;
    }
  }
}

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService(ref.watch(secureStorageProvider));
});

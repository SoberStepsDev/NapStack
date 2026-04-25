import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/security/secure_storage_service.dart';

/// Wynik [PurchaseService.getProUnlockStatus] — w tym ewent. ostrzeżenie o starym cache.
class ProUnlockStatus {
  const ProUnlockStatus({
    required this.isPro,
    this.staleCacheWarning = false,
  });

  final bool isPro;
  final bool staleCacheWarning;
}

/// Ujednolicony błąd operacji sklepu (purchase / restore).
class PurchaseException implements Exception {
  PurchaseException(
    this.message, {
    this.purchasesCode,
    this.cause,
  });

  final String message;
  final PurchasesErrorCode? purchasesCode;
  final Object? cause;

  bool get isUserCancelled =>
      purchasesCode == PurchasesErrorCode.purchaseCancelledError;

  factory PurchaseException.fromPlatform(PlatformException e) {
    final c = PurchasesErrorHelper.getErrorCode(e);
    return PurchaseException(
      e.message ?? e.toString(),
      purchasesCode: c,
      cause: e,
    );
  }

  @override
  String toString() => message;
}

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
    const rcKey = String.fromEnvironment(
      'RC_PUBLIC_KEY_ANDROID',
      defaultValue: 'REPLACE_WITH_RC_KEY',
    );
    if (rcKey == 'REPLACE_WITH_RC_KEY' || rcKey.isEmpty) {
      throw StateError(
        'RevenueCat: RC_PUBLIC_KEY_ANDROID nie jest ustawiony. Podaj go przez '
        '--dart-define=RC_PUBLIC_KEY_ANDROID=... lub --dart-define-from-file '
        '(np. wygenerowane: python3 tool/sync_dart_defines_from_env.py z plikiem .env). '
        'Devlog: PurchaseService.configure() odrzucił placeholder/empty key.',
      );
    }
    await Purchases.configure(
      PurchasesConfiguration(
        rcKey,
      )..appUserID = appUserId,
    );
  }

  /// Uproszczone API — tylko [ProUnlockStatus.isPro].
  Future<bool> isProUnlocked() async =>
      (await getProUnlockStatus()).isPro;

  /// Pełny status w tym ewent. ostrzeżenia o starym cache (offline, >7 dni).
  Future<ProUnlockStatus> getProUnlockStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final isActive = info.entitlements.active.containsKey(_kEntitlement);
      await _storage.setProCached(isActive);
      return ProUnlockStatus(isPro: isActive, staleCacheWarning: false);
    } catch (_) {
      final snap = await _storage.getProCacheSnapshot();
      return ProUnlockStatus(
        isPro: snap.isProUnlocked,
        staleCacheWarning: snap.isStale,
      );
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
    } on PlatformException catch (e) {
      final c = PurchasesErrorHelper.getErrorCode(e);
      if (c == PurchasesErrorCode.purchaseCancelledError) return false;
      throw PurchaseException.fromPlatform(e);
    }
  }

  /// Synchronizuje zakupy z RevenueCat i aktualizuje lokalny cache Pro
  /// (secure storage), tak jak [getProUnlockStatus] po udanym odczycie z RC.
  Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      final isActive = info.entitlements.active.containsKey(_kEntitlement);
      await _storage.setProCached(isActive);
      return isActive;
    } on PlatformException catch (e) {
      throw PurchaseException.fromPlatform(e);
    }
  }
}

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService(ref.watch(secureStorageProvider));
});

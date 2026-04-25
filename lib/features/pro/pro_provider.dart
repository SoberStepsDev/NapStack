import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'purchase_service.dart';

export 'purchase_service.dart' show PurchaseException, ProUnlockStatus;

/// Stan Pro + ewent. [ProUnlockStatus.staleCacheWarning] (offline, stary cache).
///
/// Użycie: `ref.watch(proStatusProvider).value?.isPro ?? false`
///
/// Po zakupie / przywróceniu: `ref.invalidate(proStatusProvider)`.
final proStatusProvider = FutureProvider.autoDispose<ProUnlockStatus>((ref) async {
  return ref.read(purchaseServiceProvider).getProUnlockStatus();
});

/// Notifier dla akcji zakupu/przywrócenia — emituje nowy stan Pro po operacji.
class ProActionsNotifier extends Notifier<AsyncValue<bool>> {
  @override
  AsyncValue<bool> build() {
    _init();
    return const AsyncValue.loading();
  }

  PurchaseService get _service => ref.read(purchaseServiceProvider);

  Future<void> _init() async {
    state = await AsyncValue.guard(() => _service.isProUnlocked());
  }

  Future<void> purchase() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.purchasePro());
    if (!state.hasError) {
      ref.invalidate(proStatusProvider);
      // Wymuś odczyt Pro z RC — reszta UI (proStatusProvider) ma aktualne dane przed klatką.
      await ref.read(proStatusProvider.future);
    }
  }

  Future<void> restore() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.restorePurchases());
    if (!state.hasError) {
      ref.invalidate(proStatusProvider);
      await ref.read(proStatusProvider.future);
    }
  }
}

final proActionsProvider =
    NotifierProvider<ProActionsNotifier, AsyncValue<bool>>(
        ProActionsNotifier.new);

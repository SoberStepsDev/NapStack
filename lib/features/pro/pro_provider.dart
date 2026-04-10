import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'purchase_service.dart';

/// Stan Pro — AsyncValue bool z możliwością ręcznego odświeżenia.
///
/// Użycie (gate Pro feature):
///   final isPro = ref.watch(proStatusProvider).value ?? false;
///   if (!isPro) GoRouter.of(context).push('/paywall');
///
/// Użycie po zakupie / przywróceniu:
///   ref.invalidate(proStatusProvider);
final proStatusProvider = FutureProvider.autoDispose<bool>((ref) async {
  return ref.read(purchaseServiceProvider).isProUnlocked();
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
    }
  }

  Future<void> restore() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.restorePurchases());
    if (!state.hasError) {
      ref.invalidate(proStatusProvider);
    }
  }
}

final proActionsProvider =
    NotifierProvider<ProActionsNotifier, AsyncValue<bool>>(
        ProActionsNotifier.new);

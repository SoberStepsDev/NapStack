import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'boot_recovery_service.dart';

/// Rejestruje handler dla MethodChannel od BootReceiver (Kotlin).
/// Wywoływać w [main] przed pierwszym `await` oraz w [bootRecoveryMain].
///
/// Odpowiedź do Androida jest wysyłana dopiero po zakończeniu
/// [BootRecoveryService.recoverAlarms] — wtedy wywoływany jest Result.success
/// po stronie Kotlin i można bezpiecznie zniszczyć headless FlutterEngine.
void registerBootRecoveryChannel() {
  const channel = MethodChannel('com.patrykdev.napstack/boot_recovery');

  channel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'recoverAlarms':
        try {
          await BootRecoveryService.recoverAlarms();
          return true;
        } catch (e, st) {
          debugPrint('BootRecoveryService.recoverAlarms failed: $e\n$st');
          throw PlatformException(
            code: 'recover_alarms_failed',
            message: e.toString(),
          );
        }
      default:
        throw MissingPluginException(
          'No implementation for ${call.method} on boot_recovery',
        );
    }
  });
}

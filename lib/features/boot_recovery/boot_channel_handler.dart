import 'package:flutter/services.dart';

import 'boot_recovery_service.dart';

/// Rejestruje handler dla MethodChannel od BootReceiver (Kotlin).
/// Wywoływać w main() przed runApp().
void registerBootRecoveryChannel() {
  const channel = MethodChannel('com.patrykdev.napstack/boot_recovery');

  channel.setMethodCallHandler((call) async {
    if (call.method == 'recoverAlarms') {
      await BootRecoveryService.recoverAlarms();
    }
  });
}

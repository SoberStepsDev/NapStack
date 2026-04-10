import 'package:flutter/widgets.dart';

import 'features/boot_recovery/boot_channel_handler.dart';

/// Punkt wejścia dla headless [BootReceiver]: tylko binding + kanał boot recovery.
/// Nie wywołuje `main()` — tam są `await` przed rejestracją kanału, co powodowało
/// wyścig z natywnym `invokeMethod` i przedwczesne zamykanie silnika.
@pragma('vm:entry-point')
void bootRecoveryMain() {
  WidgetsFlutterBinding.ensureInitialized();
  registerBootRecoveryChannel();
}

import 'package:flutter_test/flutter_test.dart';

import 'package:napstack/features/boot_recovery/boot_channel_handler.dart';

/// Etap 11.2 – smoke: kanał boot recovery (bez Android / bez FLN).
/// Plik w `test/integration/`, bo `flutter test` z katalogu `integration_test/`
/// wymaga podłączonego urządzenia. Pełny E2E: urządzenie + odpalony [BootReceiver].
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('registerBootRecoveryChannel — wielokrotne wywołanie nie psuje bindingu',
      (tester) async {
    registerBootRecoveryChannel();
    registerBootRecoveryChannel();
    expect(tester.takeException(), isNull);
  });
}

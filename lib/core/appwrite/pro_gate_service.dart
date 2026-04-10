import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'appwrite_client.dart';
import 'appwrite_error_handler.dart';

/// Wywołuje Appwrite Function `pro_gate` w celu server-side weryfikacji Pro.
///
/// Używaj przed każdą akcją Pro-only tam, gdzie frontend guard mógłby być
/// ominięty (np. bezpośredni zapis do Appwrite przez zmodyfikowanego klienta).
///
/// Akcje do weryfikacji:
///   - "fullCycle"  — użycie presetu Full Cycle (90 min REM)
///   - "addToStack" — dodanie elementu > 3 do Nap Stack
///
/// Zachowanie przy błędzie (RC niedostępne, timeout):
///   - Rzuca [ProGateException] — caller decyduje czy blokować UI czy zezwalać.
///   - Strategia domyślna: block (bezpieczniejsze, bo failsafe).
class ProGateService {
  ProGateService(this._functions);

  final Functions _functions;

  /// ID funkcji Appwrite — deployowana jako "pro_gate".
  /// Wartość pochodzi z --dart-define APPWRITE_PRO_GATE_FN_ID.
  static const _kFunctionId = String.fromEnvironment(
    'APPWRITE_PRO_GATE_FN_ID',
    defaultValue: 'pro_gate',
  );

  /// Sprawdza czy zalogowany użytkownik ma aktywne Pro dla danej [action].
  ///
  /// Zwraca `true` jeśli allowed, `false` jeśli not_pro.
  /// Rzuca [ProGateException] przy błędzie komunikacji lub błędnej konfiguracji.
  Future<bool> checkProAccess({required String action}) async {
    final execution = await AppwriteErrorHandler.run(
      () => _functions.createExecution(
        functionId: _kFunctionId,
        body: jsonEncode({'action': action}),
        method: ExecutionMethod.pOST,
      ),
      resource: 'pro_gate/$action',
    );

    // Sprawdzamy status HTTP zawarty w odpowiedzi funkcji
    final statusCode = execution.responseStatusCode;
    if (statusCode == 401) {
      throw ProGateException('Niezalogowany użytkownik (401).');
    }
    if (statusCode == 500 || statusCode == 502) {
      throw ProGateException(
        'Błąd serwera pro_gate ($statusCode). '
        'Spróbuj ponownie lub sprawdź połączenie.',
      );
    }

    final body = execution.responseBody;
    if (body.isEmpty) {
      throw ProGateException('Pusta odpowiedź z pro_gate.');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['allowed'] == true;
  }
}

class ProGateException implements Exception {
  const ProGateException(this.message);
  final String message;

  @override
  String toString() => 'ProGateException: $message';
}

// ── Provider ──────────────────────────────────────────────────────────────────

final proGateServiceProvider = Provider<ProGateService>((ref) {
  return ProGateService(
    Functions(ref.watch(appwriteClientProvider)),
  );
});

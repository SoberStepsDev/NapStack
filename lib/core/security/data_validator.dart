import '../../features/timer/nap_preset.dart';

/// Walidacja danych wejściowych przed zapisem do Appwrite.
///
/// Cel: odrzucenie nieprawidłowych danych na poziomie klienta,
/// zanim wyślemy request do Appwrite (oszczędza round-trip, chroni przed
/// przypadkowymi błędami programistycznymi i manipulacją stanem).
///
/// NIE zastępuje walidacji serwera (atrybuty Appwrite z min/max/required).
/// Działa jako pierwsza linia obrony.
abstract final class DataValidator {
  // ── NapSession ─────────────────────────────────────────────────────────────

  /// Waliduje dane przed zapisem sesji drzemki.
  static NapSessionValidationResult validateSession({
    required String userId,
    required DateTime startedAt,
    required DateTime endedAt,
    required NapType napType,
    required int plannedMinutes,
    int? qualityRating,
  }) {
    final errors = <String>[];

    // userId
    if (userId.isEmpty || userId.length < 8) {
      errors.add('userId nieprawidłowy: "$userId"');
    }

    // Czas
    if (endedAt.isBefore(startedAt)) {
      errors.add('endedAt ($endedAt) jest przed startedAt ($startedAt)');
    }

    final duration = endedAt.difference(startedAt);
    if (duration.inSeconds < 60) {
      errors.add('Sesja krótsza niż 60s (${duration.inSeconds}s) — prawdopodobny błąd');
    }
    if (duration.inHours > 3) {
      errors.add('Sesja dłuższa niż 3 godziny — prawdopodobny błąd');
    }

    // Czas w przyszłości — ochrona przed manipulacją zegarem
    final now = DateTime.now();
    if (startedAt.isAfter(now.add(const Duration(minutes: 1)))) {
      errors.add('startedAt jest w przyszłości: $startedAt');
    }

    // Planowany czas
    if (plannedMinutes < 1 || plannedMinutes > 180) {
      errors.add('plannedMinutes poza zakresem [1, 180]: $plannedMinutes');
    }

    // Ocena jakości (opcjonalna)
    if (qualityRating != null && (qualityRating < 1 || qualityRating > 5)) {
      errors.add('qualityRating poza zakresem [1, 5]: $qualityRating');
    }

    // Spójność: plannedMinutes vs napType
    final preset = presetByType(napType);
    final tolerance = 5; // minuty
    if ((plannedMinutes - preset.plannedMinutes).abs() > tolerance) {
      errors.add(
        'plannedMinutes ($plannedMinutes) nie zgadza się z presetem '
        '${preset.label} (${preset.plannedMinutes} min) — tolerancja ±$tolerance',
      );
    }

    return NapSessionValidationResult(errors: errors);
  }

  // ── NapStackItem ───────────────────────────────────────────────────────────

  static NapStackValidationResult validateStackItem({
    required String userId,
    required DateTime scheduledAt,
    required NapType napType,
  }) {
    final errors = <String>[];

    if (userId.isEmpty || userId.length < 8) {
      errors.add('userId nieprawidłowy: "$userId"');
    }

    final now = DateTime.now();

    // Alarm w przeszłości
    if (scheduledAt.isBefore(now)) {
      errors.add(
        'scheduledAt ($scheduledAt) jest w przeszłości. '
        'Alarm nie odpali — wybierz przyszłą godzinę.',
      );
    }

    // Alarm zbyt daleko w przyszłości (> 7 dni) — UX guard
    if (scheduledAt.isAfter(now.add(const Duration(days: 7)))) {
      errors.add(
        'scheduledAt ($scheduledAt) jest dalej niż 7 dni. '
        'Appwrite przechowa rekord, ale Android może nie utrzymać alarmu.',
      );
    }

    return NapStackValidationResult(errors: errors);
  }

  // ── UserPrefs ──────────────────────────────────────────────────────────────

  static void assertValidUserId(String userId) {
    if (userId.isEmpty || userId.length < 8) {
      throw DataValidationException(
        field: 'userId',
        message: 'userId "$userId" jest nieprawidłowy. '
            'Sesja Appwrite niezainicjalizowana.',
      );
    }
  }
}

// ── Wyniki walidacji ───────────────────────────────────────────────────────────

class NapSessionValidationResult {
  const NapSessionValidationResult({required this.errors});
  final List<String> errors;
  bool get isValid => errors.isEmpty;
}

class NapStackValidationResult {
  const NapStackValidationResult({required this.errors});
  final List<String> errors;
  bool get isValid => errors.isEmpty;

  /// Czy błędy są tylko ostrzeżeniami (nie blokują zapisu).
  bool get hasOnlyWarnings => errors.every(isWarning);

  static bool isWarning(String e) =>
      e.contains('7 dni'); // > 7 dni to ostrzeżenie, nie błąd krytyczny
}

class DataValidationException implements Exception {
  const DataValidationException({required this.field, required this.message});
  final String field;
  final String message;

  @override
  String toString() => 'DataValidation[$field]: $message';
}

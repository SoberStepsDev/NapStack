import 'package:flutter_test/flutter_test.dart';

import 'package:napstack/core/security/data_validator.dart';
import 'package:napstack/features/timer/nap_preset.dart';

void main() {
  // ── helpers ────────────────────────────────────────────────────────────────

  const validUserId = 'user-00000001'; // ≥8 znaków

  DateTime now() => DateTime.now();

  // Poprawna, kompletna sesja Power Nap (20 min drzemki).
  NapSessionValidationResult validateGoodSession({
    String userId = validUserId,
    DateTime? startedAt,
    DateTime? endedAt,
    NapType napType = NapType.powerNap,
    int plannedMinutes = 20,
    int? qualityRating,
  }) {
    final start = startedAt ?? now().subtract(const Duration(minutes: 27));
    final end = endedAt ?? now();
    return DataValidator.validateSession(
      userId: userId,
      startedAt: start,
      endedAt: end,
      napType: napType,
      plannedMinutes: plannedMinutes,
      qualityRating: qualityRating,
    );
  }

  // ── validateSession — przypadki poprawne ────────────────────────────────────

  group('validateSession — poprawna sesja', () {
    test('powerNap 20 min — isValid true', () {
      expect(validateGoodSession().isValid, isTrue);
    });

    test('coffeeNap 15 min — isValid true', () {
      expect(
        validateGoodSession(
          napType: NapType.coffeeNap,
          plannedMinutes: 15,
        ).isValid,
        isTrue,
      );
    });

    test('fullCycle 90 min — isValid true', () {
      final start = now().subtract(const Duration(minutes: 100));
      expect(
        DataValidator.validateSession(
          userId: validUserId,
          startedAt: start,
          endedAt: now(),
          napType: NapType.fullCycle,
          plannedMinutes: 90,
        ).isValid,
        isTrue,
      );
    });

    test('qualityRating = 1 (min) — isValid true', () {
      expect(validateGoodSession(qualityRating: 1).isValid, isTrue);
    });

    test('qualityRating = 5 (max) — isValid true', () {
      expect(validateGoodSession(qualityRating: 5).isValid, isTrue);
    });
  });

  // ── validateSession — userId ────────────────────────────────────────────────

  group('validateSession — userId', () {
    test('pusty userId → błąd', () {
      final r = validateGoodSession(userId: '');
      expect(r.isValid, isFalse);
      expect(r.errors.first, contains('userId'));
    });

    test('userId krótszy niż 8 znaków → błąd', () {
      final r = validateGoodSession(userId: 'abc123');
      expect(r.isValid, isFalse);
      expect(r.errors.first, contains('userId'));
    });

    test('userId = 8 znaków → OK', () {
      final r = validateGoodSession(userId: '12345678');
      expect(r.isValid, isTrue);
    });
  });

  // ── validateSession — czasy ────────────────────────────────────────────────

  group('validateSession — czasy', () {
    test('endedAt przed startedAt → błąd', () {
      final start = now();
      final end = now().subtract(const Duration(minutes: 1));
      final r = validateGoodSession(startedAt: start, endedAt: end);
      expect(r.isValid, isFalse);
      expect(r.errors.any((e) => e.contains('endedAt')), isTrue);
    });

    test('sesja krótsza niż 60s → błąd', () {
      final start = now().subtract(const Duration(seconds: 59));
      final r = validateGoodSession(startedAt: start, endedAt: now());
      expect(r.isValid, isFalse);
      expect(r.errors.any((e) => e.contains('60s')), isTrue);
    });

    test('sesja dokładnie 60s → OK', () {
      final start = now().subtract(const Duration(seconds: 60));
      // plannedMinutes=1, napType=powerNap → tolerancja ±5 → 1 vs 20 = błąd presetu.
      // Testujemy tylko brak błędu dot. długości — preset sprawdzamy osobno.
      final r = DataValidator.validateSession(
        userId: validUserId,
        startedAt: start,
        endedAt: now(),
        napType: NapType.powerNap,
        plannedMinutes: 20, // poprawny preset
      );
      // Sesja 60s nie pasuje do powerNap 20min — ale sprawdzamy brak błędu "60s".
      expect(r.errors.any((e) => e.contains('60s')), isFalse);
    });

    test('sesja dłuższa niż 3 godziny → błąd', () {
      final start = now().subtract(const Duration(hours: 3, seconds: 1));
      final r = DataValidator.validateSession(
        userId: validUserId,
        startedAt: start,
        endedAt: now(),
        napType: NapType.fullCycle,
        plannedMinutes: 90,
      );
      expect(r.isValid, isFalse);
      expect(r.errors.any((e) => e.contains('3 godziny')), isTrue);
    });

    test('startedAt w przyszłości (>1 min) → błąd', () {
      final start = now().add(const Duration(minutes: 2));
      final end = start.add(const Duration(minutes: 20));
      final r = DataValidator.validateSession(
        userId: validUserId,
        startedAt: start,
        endedAt: end,
        napType: NapType.powerNap,
        plannedMinutes: 20,
      );
      expect(r.isValid, isFalse);
      expect(r.errors.any((e) => e.contains('przyszłości')), isTrue);
    });
  });

  // ── validateSession — plannedMinutes ────────────────────────────────────────

  group('validateSession — plannedMinutes', () {
    test('plannedMinutes = 0 → błąd zakresu', () {
      final r = validateGoodSession(plannedMinutes: 0);
      expect(r.isValid, isFalse);
      expect(r.errors.any((e) => e.contains('plannedMinutes')), isTrue);
    });

    test('plannedMinutes = 181 → błąd zakresu', () {
      final start = now().subtract(const Duration(hours: 3, minutes: 2));
      final r = DataValidator.validateSession(
        userId: validUserId,
        startedAt: start,
        endedAt: now(),
        napType: NapType.fullCycle,
        plannedMinutes: 181,
      );
      expect(r.isValid, isFalse);
      expect(r.errors.any((e) => e.contains('plannedMinutes')), isTrue);
    });

    test('plannedMinutes poza tolerancją presetu → błąd spójności', () {
      // powerNap = 20 min; podajemy 26 → różnica 6 > 5 (tolerancja).
      final r = validateGoodSession(plannedMinutes: 26);
      expect(r.isValid, isFalse);
      expect(r.errors.any((e) => e.contains('preset')), isTrue);
    });

    test('plannedMinutes w tolerancji ±5 → OK', () {
      // powerNap = 20; 24 → diff = 4 ≤ 5.
      final r = validateGoodSession(plannedMinutes: 24);
      expect(r.isValid, isTrue);
    });
  });

  // ── validateSession — qualityRating ─────────────────────────────────────────

  group('validateSession — qualityRating', () {
    test('qualityRating = 0 → błąd', () {
      final r = validateGoodSession(qualityRating: 0);
      expect(r.isValid, isFalse);
      expect(r.errors.any((e) => e.contains('qualityRating')), isTrue);
    });

    test('qualityRating = 6 → błąd', () {
      final r = validateGoodSession(qualityRating: 6);
      expect(r.isValid, isFalse);
    });

    test('qualityRating = null → OK (opcjonalne)', () {
      expect(validateGoodSession(qualityRating: null).isValid, isTrue);
    });
  });

  // ── validateStackItem ────────────────────────────────────────────────────────

  group('validateStackItem', () {
    final futureTime = DateTime.now().add(const Duration(hours: 1));

    test('poprawny element → isValid true', () {
      final r = DataValidator.validateStackItem(
        userId: validUserId,
        scheduledAt: futureTime,
        napType: NapType.powerNap,
      );
      expect(r.isValid, isTrue);
    });

    test('scheduledAt w przeszłości → błąd', () {
      final r = DataValidator.validateStackItem(
        userId: validUserId,
        scheduledAt: DateTime.now().subtract(const Duration(minutes: 1)),
        napType: NapType.powerNap,
      );
      expect(r.isValid, isFalse);
      expect(r.errors.any((e) => e.contains('przeszłości')), isTrue);
    });

    test('scheduledAt > 7 dni → ostrzeżenie, ale hasOnlyWarnings = true', () {
      final farFuture = DateTime.now().add(const Duration(days: 8));
      final r = DataValidator.validateStackItem(
        userId: validUserId,
        scheduledAt: farFuture,
        napType: NapType.powerNap,
      );
      expect(r.isValid, isFalse);
      expect(r.hasOnlyWarnings, isTrue);
    });

    test('userId za krótki → błąd', () {
      final r = DataValidator.validateStackItem(
        userId: 'short',
        scheduledAt: futureTime,
        napType: NapType.powerNap,
      );
      expect(r.isValid, isFalse);
    });
  });

  // ── assertValidUserId ────────────────────────────────────────────────────────

  group('assertValidUserId', () {
    test('poprawny userId → nie rzuca wyjątku', () {
      expect(
        () => DataValidator.assertValidUserId(validUserId),
        returnsNormally,
      );
    });

    test('pusty userId → rzuca DataValidationException', () {
      expect(
        () => DataValidator.assertValidUserId(''),
        throwsA(isA<DataValidationException>()),
      );
    });

    test('krótki userId → rzuca DataValidationException z polem userId', () {
      expect(
        () => DataValidator.assertValidUserId('abc'),
        throwsA(
          isA<DataValidationException>().having(
            (e) => e.field,
            'field',
            'userId',
          ),
        ),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:napstack/features/sessions/nap_session_model.dart';
import 'package:napstack/features/stats/stats_service.dart';
import 'package:napstack/features/timer/nap_preset.dart';

// StatsService.computeFromSessions jest publiczne — testujemy przez nie,
// bo _calculateStreak i _activeDays są prywatne.
//
// SessionsService NIE jest potrzebny — pomijamy wstrzyknięcie
// i testujemy tylko ścieżkę synchroniczną computeFromSessions(sessions).

void main() {
  // ── helpers ────────────────────────────────────────────────────────────────

  /// Tworzy sesję ukończoną dla danego dnia (godzina 12:00).
  NapSession completedSession(
    DateTime day, {
    NapType type = NapType.powerNap,
    bool completed = true,
  }) {
    final start = DateTime(day.year, day.month, day.day, 12);
    final end = start.add(const Duration(minutes: 27)); // 20 min + 7 min zasyp.
    return NapSession(
      id: 'test-${day.toIso8601String()}',
      userId: 'user-00000001',
      startedAt: start,
      endedAt: end,
      napType: type,
      completed: completed,
      plannedMinutes: 20,
    );
  }

  /// Dziś o północy (bez czasu).
  DateTime today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  DateTime daysAgo(int n) => today().subtract(Duration(days: n));

  // computeFromSessions() nigdy nie wywołuje SessionsService (_sessions).
  // Używamy null as dynamic — bezpieczne dopóki testujemy wyłącznie
  // ścieżkę synchroniczną. Gdyby testy pokryły fetchWeeklyStats(),
  // potrzebny będzie mock/fake SessionsService.
  // ignore: avoid_dynamic_calls
  final sut = StatsService(null as dynamic);

  // ── WeeklyStats.empty ──────────────────────────────────────────────────────

  group('computeFromSessions — pusta lista', () {
    test('zwraca WeeklyStats.empty gdy brak sesji', () {
      final stats = sut.computeFromSessions([]);
      expect(stats.totalSessions, 0);
      expect(stats.completedSessions, 0);
      expect(stats.totalSleepMinutes, 0);
      expect(stats.streak, 0);
      expect(stats.favoritePreset, isNull);
    });
  });

  // ── _calculateStreak ────────────────────────────────────────────────────────

  group('_calculateStreak', () {
    test('brak ukończonych sesji → streak = 0', () {
      final sessions = [
        completedSession(today(), completed: false),
      ];
      final stats = sut.computeFromSessions(sessions);
      expect(stats.streak, 0);
    });

    test('tylko dziś → streak = 1', () {
      final stats = sut.computeFromSessions([completedSession(today())]);
      expect(stats.streak, 1);
    });

    test('wczoraj i dziś → streak = 2', () {
      final stats = sut.computeFromSessions([
        completedSession(today()),
        completedSession(daysAgo(1)),
      ]);
      expect(stats.streak, 2);
    });

    test('3 kolejne dni (wczoraj, przedwczoraj, 3 dni temu) bez dzisiaj → streak = 3', () {
      // Reguła: jeśli dziś brak sesji, zacznij od wczoraj.
      final stats = sut.computeFromSessions([
        completedSession(daysAgo(1)),
        completedSession(daysAgo(2)),
        completedSession(daysAgo(3)),
      ]);
      expect(stats.streak, 3);
    });

    test('luka w serii → streak liczy tylko ciągłą część', () {
      // Dziś + 3 dni temu — luka 2 dni temu i wczoraj.
      final stats = sut.computeFromSessions([
        completedSession(today()),
        completedSession(daysAgo(3)),
      ]);
      expect(stats.streak, 1);
    });

    test('wiele sesji tego samego dnia liczy się jako 1 dzień serii', () {
      final stats = sut.computeFromSessions([
        completedSession(today()),
        completedSession(today()), // duplikat dnia
        completedSession(daysAgo(1)),
      ]);
      expect(stats.streak, 2);
    });

    test('dziś brak sesji, wczoraj brak sesji, przedwczoraj jest → streak = 0', () {
      // Reguła: jeśli dziś brak → sprawdzamy od wczoraj.
      // Wczoraj też brak → luka → 0.
      final stats = sut.computeFromSessions([
        completedSession(daysAgo(2)),
        completedSession(daysAgo(3)),
      ]);
      expect(stats.streak, 0);
    });

    test('5 kolejnych dni z dzisiaj → streak = 5', () {
      final sessions = List.generate(
        5,
        (i) => completedSession(daysAgo(i)),
      );
      final stats = sut.computeFromSessions(sessions);
      expect(stats.streak, 5);
    });

    test('nieukończone sesje nie liczą się do serii', () {
      // Tylko dziś jest ukończona; wczoraj nieukończona.
      final stats = sut.computeFromSessions([
        completedSession(today(), completed: true),
        completedSession(daysAgo(1), completed: false),
      ]);
      expect(stats.streak, 1);
    });
  });

  // ── _activeDays ─────────────────────────────────────────────────────────────

  group('_activeDays (via activeDaysCount)', () {
    test('sesje z tego samego dnia → 1 aktywny dzień', () {
      final stats = sut.computeFromSessions([
        completedSession(today()),
        completedSession(today()),
      ]);
      expect(stats.activeDaysCount, 1);
    });

    test('3 różne dni → 3 aktywne dni', () {
      final stats = sut.computeFromSessions([
        completedSession(today()),
        completedSession(daysAgo(1)),
        completedSession(daysAgo(2)),
      ]);
      expect(stats.activeDaysCount, 3);
    });
  });

  // ── _favoritePreset ──────────────────────────────────────────────────────────

  group('_favoritePreset', () {
    test('jeden typ → jest faworytem', () {
      final stats = sut.computeFromSessions([
        completedSession(today(), type: NapType.coffeeNap),
      ]);
      expect(stats.favoritePreset, NapType.coffeeNap);
    });

    test('dwa typy z remisem → zwraca pierwszy wg iteracji (min. jeden z nich)', () {
      final stats = sut.computeFromSessions([
        completedSession(today(), type: NapType.powerNap),
        completedSession(daysAgo(1), type: NapType.coffeeNap),
      ]);
      // Remis — jeden z nich; kluczowe że jest non-null.
      expect(stats.favoritePreset, isNotNull);
    });

    test('powerNap dominuje → powerNap jest faworytem', () {
      final stats = sut.computeFromSessions([
        completedSession(today(), type: NapType.powerNap),
        completedSession(daysAgo(1), type: NapType.powerNap),
        completedSession(daysAgo(2), type: NapType.coffeeNap),
      ]);
      expect(stats.favoritePreset, NapType.powerNap);
    });
  });

  // ── totalSleepMinutes ────────────────────────────────────────────────────────

  group('totalSleepMinutes', () {
    test('sumuje tylko ukończone sesje', () {
      final stats = sut.computeFromSessions([
        completedSession(today(), completed: true),   // 20 min
        completedSession(daysAgo(1), completed: false), // nie liczy się
      ]);
      expect(stats.totalSleepMinutes, 20);
    });
  });
}

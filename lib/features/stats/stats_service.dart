import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sessions/nap_session_model.dart';
import '../sessions/sessions_service.dart';
import '../timer/nap_preset.dart';
import 'stats_model.dart';

/// Oblicza statystyki tygodniowe z sesji pobranych z Appwrite.
///
/// Dane obliczane in-memory — przy < 1000 sesji (realistyczne przez lata)
/// pełny scan jest wystarczający. Brak potrzeby agregacji po stronie Appwrite.
class StatsService {
  StatsService(this._sessions);

  final SessionsService _sessions;

  /// Pobiera dane z Appwrite i oblicza statystyki.
  Future<WeeklyStats> fetchWeeklyStats() async {
    final sessions = await _sessions.fetchRecentSessions(days: 7);
    return _compute(sessions);
  }

  /// Oblicza statystyki z gotowej listy sesji (np. już załadowanych w UI).
  WeeklyStats computeFromSessions(List<NapSession> sessions) =>
      _compute(sessions);

  WeeklyStats _compute(List<NapSession> sessions) {
    if (sessions.isEmpty) return WeeklyStats.empty;

    final completed = sessions.where((s) => s.completed).toList();

    return WeeklyStats(
      totalSessions: sessions.length,
      completedSessions: completed.length,
      totalSleepMinutes: completed.fold(0, (sum, s) => sum + s.plannedMinutes),
      activeDaysCount: _activeDays(sessions),
      streak: _calculateStreak(completed),
      favoritePreset: _favoritePreset(sessions),
    );
  }

  int _activeDays(List<NapSession> sessions) {
    return sessions
        .map((s) => DateUtils.dateOnly(s.startedAt))
        .toSet()
        .length;
  }

  /// Streak = liczba kolejnych dni wstecz z ≥1 ukończoną sesją.
  ///
  /// Reguła produktowa (udokumentowana):
  /// Jeśli dzisiaj nie ma jeszcze sesji, streak zaczyna od wczoraj.
  /// Dzięki temu użytkownik nie traci serii rano przed pierwszą drzemką.
  int _calculateStreak(List<NapSession> completed) {
    if (completed.isEmpty) return 0;

    final completedDays = completed
        .map((s) => DateUtils.dateOnly(s.startedAt))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // malejąco

    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    // Jeśli dzisiaj brak sesji, zacznij od wczoraj
    var expected =
        completedDays.first == today ? today : yesterday;

    var streak = 0;
    for (final day in completedDays) {
      if (day == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else if (day.isBefore(expected)) {
        break; // luka w serii
      }
    }
    return streak;
  }

  NapType? _favoritePreset(List<NapSession> sessions) {
    if (sessions.isEmpty) return null;

    final counts = <NapType, int>{};
    for (final s in sessions) {
      counts[s.napType] = (counts[s.napType] ?? 0) + 1;
    }
    return counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }
}

final statsServiceProvider = Provider<StatsService>((ref) {
  return StatsService(ref.watch(sessionsServiceProvider));
});

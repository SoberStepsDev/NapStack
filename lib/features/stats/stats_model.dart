import '../timer/nap_preset.dart';

/// Zagregowane statystyki tygodniowe obliczane z sesji Appwrite.
class WeeklyStats {
  const WeeklyStats({
    required this.totalSessions,
    required this.completedSessions,
    required this.totalSleepMinutes,
    required this.activeDaysCount,
    required this.streak,
    this.favoritePreset,
  });

  /// Wszystkie sesje z ostatnich 7 dni (ukończone i przerwane).
  final int totalSessions;

  /// Tylko sesje zakończone naturalnie (completed == true).
  final int completedSessions;

  /// Suma plannedMinutes dla completed sesji.
  final int totalSleepMinutes;

  /// Liczba dni z ≥1 sesją w ostatnich 7 dniach.
  final int activeDaysCount;

  /// Seria kolejnych dni wstecz z ≥1 ukończoną sesją.
  final int streak;

  /// Najczęstszy preset w ostatnich 7 dniach (null jeśli brak sesji).
  final NapType? favoritePreset;

  double get completionRate =>
      totalSessions == 0 ? 0.0 : completedSessions / totalSessions;

  static const empty = WeeklyStats(
    totalSessions: 0,
    completedSessions: 0,
    totalSleepMinutes: 0,
    activeDaysCount: 0,
    streak: 0,
  );
}

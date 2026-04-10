import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'stats_model.dart';
import 'stats_service.dart';

/// Statystyki tygodniowe — odświeżane przy każdej wizycie na StatsScreen.
///
/// Użycie w UI:
///   final stats = ref.watch(weeklyStatsProvider);
///   stats.when(
///     loading: () => const StatsSkeletonView(),
///     error: (e, _) => ErrorView(message: e.toString()),
///     data: (stats) => StatsView(stats: stats),
///   );
final weeklyStatsProvider = FutureProvider<WeeklyStats>((ref) async {
  return ref.read(statsServiceProvider).fetchWeeklyStats();
});

/// Wersja z możliwością ręcznego odświeżenia (np. pull-to-refresh).
/// ref.invalidate(weeklyStatsRefreshableProvider) wymusi ponowny fetch.
final weeklyStatsRefreshableProvider =
    FutureProvider.autoDispose<WeeklyStats>((ref) async {
  return ref.read(statsServiceProvider).fetchWeeklyStats();
});

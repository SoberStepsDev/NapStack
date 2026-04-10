import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../features/stats/stats_model.dart';
import '../../features/stats/stats_provider.dart';
import '../../features/timer/nap_preset.dart';
import '../widgets/stat_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(weeklyStatsRefreshableProvider);

    return Scaffold(
      backgroundColor: AppColors.kBgBase,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.kAccent,
          backgroundColor: AppColors.kBgCard,
          onRefresh: () => ref.refresh(weeklyStatsRefreshableProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _StatsHeader()),
              statsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.kAccent,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: _ErrorState(
                    onRetry: () =>
                        ref.refresh(weeklyStatsRefreshableProvider.future),
                  ),
                ),
                data: (stats) => stats.totalSessions == 0
                    ? const SliverFillRemaining(child: _EmptyStatsState())
                    : SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        sliver: SliverToBoxAdapter(
                          child: _StatsContent(stats: stats),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statystyki',
            style: GoogleFonts.syne(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ostatnie 7 dni',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.kTextSecondary,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({required this.stats});
  final WeeklyStats stats;

  String _presetLabel(NapType? type) => type == null
      ? '—'
      : switch (type) {
          NapType.powerNap  => 'Power Nap',
          NapType.coffeeNap => 'Coffee Nap',
          NapType.fullCycle => 'Full Cycle',
        };

  Color _presetColor(NapType? type) => switch (type) {
    NapType.powerNap  => AppColors.kPowerNapColor,
    NapType.coffeeNap => AppColors.kCoffeeNapColor,
    NapType.fullCycle => AppColors.kFullCycleColor,
    null              => AppColors.kAccent,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Streak (full width) ──────────────────────────────────────────
        StatCard(
          value: '${stats.streak} ${_streakLabel(stats.streak)}',
          label: 'Seria aktywnych dni',
          icon: Icons.local_fire_department_rounded,
          accent: stats.streak > 0 ? AppColors.kWarning : AppColors.kTextMuted,
          isWide: true,
        ),
        const SizedBox(height: 12),

        // ── 2×2 grid ────────────────────────────────────────────────────
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  value: '${stats.totalSessions}',
                  label: 'Sesji łącznie',
                  icon: Icons.bedtime_outlined,
                  accent: AppColors.kAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  value: '${stats.totalSleepMinutes} min',
                  label: 'Łączny czas snu',
                  icon: Icons.timer_outlined,
                  accent: AppColors.kAccentLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  value: '${(stats.completionRate * 100).toStringAsFixed(0)}%',
                  label: 'Ukończonych',
                  icon: Icons.check_circle_outline_rounded,
                  accent: AppColors.kSuccess,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  value: _presetLabel(stats.favoritePreset),
                  label: 'Ulubiony preset',
                  icon: Icons.star_outline_rounded,
                  accent: _presetColor(stats.favoritePreset),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Aktywne dni ──────────────────────────────────────────────────
        StatCard(
          value: '${stats.activeDaysCount} / 7 dni',
          label: 'Aktywnych dni w tygodniu',
          icon: Icons.calendar_today_outlined,
          accent: AppColors.kCoffeeNapColor,
          isWide: true,
        ),

        const SizedBox(height: 28),
        _WeekGrid(stats: stats),
      ],
    );
  }

  String _streakLabel(int n) {
    if (n == 1) return 'dzień';
    if (n >= 2 && n <= 4) return 'dni';
    return 'dni';
  }
}

// ── Mini tygodniowy grid ──────────────────────────────────────────────────────

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.stats});
  final WeeklyStats stats;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      return day;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AKTYWNOŚĆ W TYGODNIU',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.kTextMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((day) => _DayDot(day: day)).toList(),
        ),
      ],
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.day});
  final DateTime day;

  static const _dayNames = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(day, DateTime.now());

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.kBgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isToday
                  ? AppColors.kAccent.withValues(alpha: 0.6)
                  : AppColors.kBorder,
              width: isToday ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: isToday
                    ? AppColors.kTextPrimary
                    : AppColors.kTextMuted,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _dayNames[day.weekday - 1],
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: AppColors.kTextMuted,
          ),
        ),
      ],
    );
  }
}

// ── Stany puste / błąd ────────────────────────────────────────────────────────

class _EmptyStatsState extends StatelessWidget {
  const _EmptyStatsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined,
              color: AppColors.kTextMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            'Brak danych',
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.kTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ukończ pierwszą drzemkę,\nby zobaczyć statystyki.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.kTextMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: AppColors.kTextMuted, size: 40),
          const SizedBox(height: 16),
          Text(
            'Brak połączenia',
            style: GoogleFonts.syne(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.kTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Spróbuj ponownie')),
        ],
      ),
    );
  }
}

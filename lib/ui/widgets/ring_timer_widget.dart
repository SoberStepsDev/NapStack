import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../features/timer/nap_preset.dart';
import '../../features/timer/timer_state.dart';
import 'ring_timer_painter.dart';

/// Kompozytowy widget timera:
/// - [TweenAnimationBuilder] interpoluje progress między tickami (płynna animacja łuku)
/// - [RingTimerPainter] rysuje łuk
/// - Wewnątrz pierścienia: pozostały czas + etykieta fazy
///
/// [size] — średnica pierścienia, domyślnie 260dp
class RingTimerWidget extends StatelessWidget {
  const RingTimerWidget({
    required this.state,
    required this.preset,
    this.size = 260,
    super.key,
  });

  final TimerState state;
  final NapPreset preset;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (progress, phase, remainingSeconds) = _extract();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 950),
      curve: Curves.linear,
      builder: (context, animProgress, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: RingTimerPainter(
              progress: animProgress,
              phase: phase,
            ),
            child: Center(
              child: _RingCenter(
                remainingSeconds: remainingSeconds,
                phase: phase,
              ),
            ),
          ),
        );
      },
    );
  }

  (double progress, TimerPhase phase, int remaining) _extract() =>
      state.when(
        idle: () => (0.0, TimerPhase.idle, 0),
        running: (preset, remaining, startedAt, wakeTime) => (
          1.0 - (remaining / preset.totalSeconds).clamp(0.0, 1.0),
          state.phase,
          remaining,
        ),
        done: (preset, startedAt, endedAt, completed) =>
            (1.0, TimerPhase.done, 0),
      );
}

class _RingCenter extends StatelessWidget {
  const _RingCenter({
    required this.remainingSeconds,
    required this.phase,
  });

  final int remainingSeconds;
  final TimerPhase phase;

  String get _timeLabel {
    if (remainingSeconds <= 0) return '00:00';
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _phaseLabel => switch (phase) {
    TimerPhase.idle         => 'Gotowy',
    TimerPhase.fallingAsleep => 'Zasypiasz',
    TimerPhase.napping      => 'Śnisz',
    TimerPhase.done         => 'Obudź się',
  };

  Color get _phaseColor => switch (phase) {
    TimerPhase.fallingAsleep => AppColors.kAccentDim,
    TimerPhase.napping       => AppColors.kAccent,
    TimerPhase.done          => AppColors.kSuccess,
    _                        => AppColors.kTextMuted,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _timeLabel,
          style: GoogleFonts.syne(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: AppColors.kTextPrimary,
            letterSpacing: -1,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _phaseColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _phaseColor.withValues(alpha: 0.4), width: 1),
          ),
          child: Text(
            _phaseLabel,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _phaseColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

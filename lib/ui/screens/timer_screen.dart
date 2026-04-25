import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/errors/user_facing_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../features/timer/nap_preset.dart';
import '../../features/timer/timer_notifier.dart';
import '../../features/timer/timer_state.dart';
import '../widgets/ring_timer_widget.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({required this.preset, super.key});
  final NapPreset preset;

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  Future<void> _onStart() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(timerNotifierProvider.notifier).start(widget.preset);
    } on UserFacingException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.messageL10n(l10n))),
      );
    }
  }

  @override
  void dispose() {
    // stop() anuluje alarm systemowy i wyłącza Wakelock.
    // reset() tego nie robi — alarm pozostałby zaplanowany po wyjściu z ekranu.
    final notifier = ref.read(timerNotifierProvider.notifier);
    final isRunning = ref.read(timerNotifierProvider).isRunning;
    if (isRunning) {
      notifier.stop();
    } else {
      notifier.reset();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timerNotifierProvider);

    // Nawiguj do home po zakończeniu — bez referencji do prywatnego _Done
    ref.listen<TimerState>(timerNotifierProvider, (_, next) {
      if (next.completedSuccessfully) {
        _showDoneSheet(context, next.activePreset!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.kBgDeep,
      body: Stack(
        children: [
          // Gradient tła
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 0.8,
                  colors: [
                    Color(0xFF0D1F3C),
                    AppColors.kBgDeep,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _TopBar(preset: widget.preset),
                Expanded(
                  child: _TimerBody(
                    state: state,
                    preset: widget.preset,
                  ),
                ),
                _BottomControls(
                  state: state,
                  preset: widget.preset,
                  onStart: _onStart,
                  onStop: _confirmStop,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmStop() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Przerwać drzemkę?'),
        content:
            const Text('Sesja zostanie zapisana jako nieukończona.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kontynuuj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.kError),
            child: const Text('Przerwij'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(timerNotifierProvider.notifier).stop();
      if (mounted) context.pop();
    }
  }

  void _showDoneSheet(BuildContext context, NapPreset preset) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _DoneSheet(
        preset: preset,
        onClose: () {
          Navigator.pop(context);
          context.pop();
        },
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.preset});
  final NapPreset preset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.kTextSecondary, size: 20),
          ),
          Expanded(
            child: Text(
              preset.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.syne(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.kTextPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48), // balans z back button
        ],
      ),
    );
  }
}

// ── Timer body ────────────────────────────────────────────────────────────────

class _TimerBody extends StatelessWidget {
  const _TimerBody({required this.state, required this.preset});

  final TimerState state;
  final NapPreset preset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RingTimerWidget(state: state, preset: preset, size: 260),
        const SizedBox(height: 40),
        _WakeTimeCard(state: state),
      ],
    );
  }
}

class _WakeTimeCard extends StatelessWidget {
  const _WakeTimeCard({required this.state});
  final TimerState state;

  @override
  Widget build(BuildContext context) {
    final wakeTime = state.wakeTimeOrNull;

    if (wakeTime == null) {
      return _EmptyWakeCard();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kBorder, width: 1),
      ),
      child: Column(
        children: [
          Text(
            'Wstaniesz o',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.kTextMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(wakeTime),
            style: GoogleFonts.syne(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.kAccent,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '~${(state.whenOrNull(running: (p, r, startedAt, wakeTime) => r ~/ 60) ?? 0)} minut',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWakeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kBorder, width: 1),
      ),
      child: Text(
        'Naciśnij START',
        style: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.kTextMuted,
        ),
      ),
    );
  }
}

// ── Bottom controls ───────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.state,
    required this.preset,
    required this.onStart,
    required this.onStop,
  });

  final TimerState state;
  final NapPreset preset;
  final Future<void> Function() onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: state.when(
        idle: () => _StartButton(preset: preset, onTap: onStart),
        running: (_, __, ___, ____) => _StopButton(onTap: onStop),
        done: (_, __, ___, ____) => const SizedBox.shrink(),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.preset, required this.onTap});
  final NapPreset preset;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          onTap();
        },
        icon: const Icon(Icons.play_arrow_rounded, size: 22),
        label: Text('Start — ${preset.plannedMinutes} min'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.stop_rounded, size: 22),
        label: const Text('Zatrzymaj'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          foregroundColor: AppColors.kError,
          side: BorderSide(color: AppColors.kError.withValues(alpha: 0.5), width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

// ── Done sheet ────────────────────────────────────────────────────────────────

class _DoneSheet extends StatelessWidget {
  const _DoneSheet({required this.preset, required this.onClose});
  final NapPreset preset;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.kSuccess.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.kSuccess, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            'Dobra robota!',
            style: GoogleFonts.syne(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${preset.label} zakończony.\nOdświeżony i gotowy do działania.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.kTextSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onClose,
              child: const Text('Wróć do domu'),
            ),
          ),
        ],
      ),
    );
  }
}

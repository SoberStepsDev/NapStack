import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../sessions/sessions_service.dart';
import 'alarm_service.dart';
import 'nap_preset.dart';
import 'timer_state.dart';

const _kTimerAlarmId = 42000;

class TimerNotifier extends Notifier<TimerState> {
  Timer? _ticker;

  @override
  TimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const TimerState.idle();
  }

  SessionsService get _sessions => ref.read(sessionsServiceProvider);

  Future<void> start(NapPreset preset) async {
    if (state.isRunning) return;

    final now = DateTime.now();
    final wakeTime = now.add(Duration(seconds: preset.totalSeconds));

    await AlarmService.scheduleWakeUp(
      alarmId: _kTimerAlarmId,
      wakeAt: wakeTime,
      label: '${preset.label} — czas wstawać!',
    );

    state = TimerState.running(
      preset: preset,
      remainingSeconds: preset.totalSeconds,
      startedAt: now,
      wakeTime: wakeTime,
    );

    await WakelockPlus.enable();
    _startTicker(preset);
  }

  Future<void> stop() async {
    if (!state.isRunning) return;

    final preset = state.activePreset!;
    final startedAt = state.startedAtOrNull!;

    _ticker?.cancel();
    await AlarmService.cancel(_kTimerAlarmId);
    await WakelockPlus.disable();

    final endedAt = DateTime.now();

    await _sessions.saveSession(
      preset: preset,
      startedAt: startedAt,
      endedAt: endedAt,
      completed: false,
    );

    state = TimerState.done(
      preset: preset,
      startedAt: startedAt,
      endedAt: endedAt,
      completed: false,
    );
  }

  void _startTicker(NapPreset preset) {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.remainingSecondsOrNull;
      if (remaining == null) {
        _ticker?.cancel();
        return;
      }

      final next = remaining - 1;
      if (next <= 0) {
        _onComplete();
      } else {
        state = state.maybeWhen(
          running: (p, _, startedAt, wakeTime) => TimerState.running(
            preset: p,
            remainingSeconds: next,
            startedAt: startedAt,
            wakeTime: wakeTime,
          ),
          orElse: () => state,
        );
      }
    });
  }

  Future<void> _onComplete() async {
    final preset = state.activePreset;
    final startedAt = state.startedAtOrNull;

    _ticker?.cancel();
    await WakelockPlus.disable();

    if (preset == null || startedAt == null) return;

    final endedAt = DateTime.now();

    await _sessions.saveSession(
      preset: preset,
      startedAt: startedAt,
      endedAt: endedAt,
      completed: true,
    );

    state = TimerState.done(
      preset: preset,
      startedAt: startedAt,
      endedAt: endedAt,
      completed: true,
    );
  }

  void reset() {
    _ticker?.cancel();
    state = const TimerState.idle();
  }
}

final timerNotifierProvider =
    NotifierProvider<TimerNotifier, TimerState>(TimerNotifier.new);

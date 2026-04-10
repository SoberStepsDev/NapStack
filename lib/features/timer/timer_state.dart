import 'package:freezed_annotation/freezed_annotation.dart';
import 'nap_preset.dart';

part 'timer_state.freezed.dart';

/// Faza timera determinuje kolor łuku i etykietę UI.
enum TimerPhase { idle, fallingAsleep, napping, done }

@freezed
class TimerState with _$TimerState {
  const TimerState._(); // custom methods wymagają prywatnego konstruktora

  const factory TimerState.idle() = _Idle;

  const factory TimerState.running({
    required NapPreset preset,
    required int remainingSeconds,
    required DateTime startedAt,
    required DateTime wakeTime,
  }) = _Running;

  const factory TimerState.done({
    required NapPreset preset,
    required DateTime startedAt,
    required DateTime endedAt,
    required bool completed,
  }) = _Done;

  /// Faza timera — dynamiczna, oparta o preset.durationSeconds.
  TimerPhase get phase => when(
        idle: () => TimerPhase.idle,
        running: (preset, remaining, _, __) =>
            remaining > preset.durationSeconds
                ? TimerPhase.fallingAsleep
                : TimerPhase.napping,
        done: (_, __, ___, ____) => TimerPhase.done,
      );

  bool get isRunning => maybeWhen(
        running: (_, __, ___, ____) => true,
        orElse: () => false,
      );

  bool get isDone => maybeWhen(
        done: (_, __, ___, ____) => true,
        orElse: () => false,
      );

  /// Pozostały czas w sekundach — null jeśli timer nie działa.
  int? get remainingSecondsOrNull => whenOrNull(
        running: (_, remaining, __, ___) => remaining,
      );

  /// Czas pobudki — null jeśli timer nie działa.
  DateTime? get wakeTimeOrNull => whenOrNull(
        running: (_, __, ___, wakeTime) => wakeTime,
      );

  /// Preset aktywnej sesji — null w idle.
  NapPreset? get activePreset => whenOrNull(
        running: (preset, _, __, ___) => preset,
        done: (preset, _, __, ___) => preset,
      );

  /// Czas startu aktywnej sesji — null w idle.
  DateTime? get startedAtOrNull => whenOrNull(
        running: (_, __, startedAt, ___) => startedAt,
        done: (_, startedAt, __, ___) => startedAt,
      );

  /// Czy sesja zakończyła się naturalnie (nie przerwana).
  bool get completedSuccessfully => maybeWhen(
        done: (_, __, ___, completed) => completed,
        orElse: () => false,
      );
}

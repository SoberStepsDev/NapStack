import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/appwrite/appwrite_constants.dart';
import '../timer/alarm_service.dart';
import '../timer/nap_preset.dart';
import 'nap_stack_item_model.dart';
import 'nap_stack_service.dart';

/// Stan Nap Stack — lista zaplanowanych drzemek + flaga ładowania.
class NapStackState {
  const NapStackState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<NapStackItem> items;
  final bool isLoading;
  final Object? error;

  bool get canAddFree => items.length < 3;

  NapStackState copyWith({
    List<NapStackItem>? items,
    bool? isLoading,
    Object? error,
  }) =>
      NapStackState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// Notifier Nap Stack — zarządza listą zaplanowanych drzemek.
///
/// Zasada re-sync: każda mutacja kończy się `_syncFromAppwrite()`.
/// Eliminuje to desync między lokalnym stanem a Appwrite.
class NapStackNotifier extends Notifier<NapStackState> {
  @override
  NapStackState build() {
    _syncFromAppwrite();
    return const NapStackState();
  }

  NapStackService get _service => ref.read(napStackServiceProvider);

  /// Dodaje drzemkę do stosu i planuje alarm systemowy.
  /// Status Pro w Appwrite: tylko funkcja pro_gate (w [NapStackService.addItem]), nie z UI.
  Future<void> add({
    required DateTime scheduledAt,
    required NapType napType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final item = await _service.addItem(
        scheduledAt: scheduledAt,
        napType: napType,
      );

      final preset = presetByType(napType);
      await AlarmService.scheduleWakeUp(
        alarmId: item.alarmId,
        wakeAt: scheduledAt.add(Duration(seconds: preset.totalSeconds)),
        label: '${preset.label} — czas wstawać!',
      );
    } on NapStackLimitException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return;
    }
    await _syncFromAppwrite();
  }

  /// Usuwa element i anuluje alarm.
  Future<void> remove(String itemId) async {
    final item = state.items.firstWhere((i) => i.id == itemId);
    await AlarmService.cancel(item.alarmId);
    await _service.deleteItem(itemId);
    await _syncFromAppwrite();
  }

  /// Oznacza element jako done.
  Future<void> markDone(String itemId) async {
    await _service.markDone(itemId);
    await _syncFromAppwrite();
  }

  /// Odczyt stosu z Appwrite bez odtwarzania alarmów (np. gdy Realtime niedostępny).
  Future<void> syncFromServer() async {
    await _syncFromAppwrite();
  }

  /// Przywraca alarmy dla wszystkich niezrealizowanych elementów.
  /// Najpierw weryfikuje listę w Appwrite; przy błędzie odczytu nie modyfikuje alarmów.
  Future<void> rescheduleAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefBootRecoveryDone, false);

    final previousItems = state.items;
    final List<NapStackItem> items;
    try {
      items = await _service.fetchStack();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return;
    }

    state = state.copyWith(items: items, isLoading: false, error: null);
    final now = DateTime.now();
    final newAlarmIds = items.map((e) => e.alarmId).toSet();

    for (final p in previousItems) {
      if (!newAlarmIds.contains(p.alarmId)) {
        await AlarmService.cancel(p.alarmId);
      }
    }

    for (final item in items) {
      final preset = presetByType(item.napType);
      final wakeAt =
          item.scheduledAt.add(Duration(seconds: preset.totalSeconds));

      if (wakeAt.isAfter(now)) {
        await AlarmService.scheduleWakeUp(
          alarmId: item.alarmId,
          wakeAt: wakeAt,
          label: '${preset.label} — czas wstawać!',
        );
      } else {
        await _service.markDone(item.id);
      }
    }
    await _syncFromAppwrite();
  }

  Future<void> _syncFromAppwrite() async {
    try {
      final items = await _service.fetchStack();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }
}

final napStackNotifierProvider =
    NotifierProvider<NapStackNotifier, NapStackState>(NapStackNotifier.new);

import 'dart:async';
import 'dart:developer' as developer;

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/appwrite/appwrite_client.dart';
import '../../core/appwrite/appwrite_constants.dart';
import '../auth/auth_provider.dart';
import '../nap_stack/nap_stack_notifier.dart';
import '../sessions/sessions_provider.dart';

/// Nasłuchuje zmian w Appwrite Realtime i aktualizuje lokalne providery.
///
/// Brak cyklu zależności z [napStackNotifierProvider]: Realtime tylko woła
/// [NapStackNotifier.rescheduleAll]; notifier nie subskrybuje tego serwisu.
///
/// Bezpieczeństwo Realtime:
/// - Appwrite wysyła zdarzenia WYŁĄCZNIE dla zasobów, do których użytkownik
///   ma uprawnienia read. Klient nigdy nie zobaczy danych innego użytkownika.
/// - Dodatkowy filtr po user_id w payload to defense-in-depth.
class SyncService {
  SyncService(this._realtime, this._userId, this._ref);

  final Realtime _realtime;
  final String _userId;
  final Ref _ref;

  RealtimeSubscription? _stackSub;
  RealtimeSubscription? _sessionsSub;
  Timer? _fallbackPoll;

  void startListening() {
    if (_userId.isEmpty) return;
    _subscribeNapStack();
    _subscribeSessions();
  }

  void _handleSyncError(String channel, Object error, StackTrace? stack) {
    developer.log(
      'Realtime error — $channel',
      name: 'napstack.sync',
      error: error,
      stackTrace: stack,
    );
    _startFallbackPoll();
  }

  void _startFallbackPoll() {
    if (_fallbackPoll != null) return;
    _fallbackPoll = Timer.periodic(const Duration(seconds: 30), (_) {
      _runFallbackRefresh();
    });
  }

  void _stopFallbackPoll() {
    _fallbackPoll?.cancel();
    _fallbackPoll = null;
  }

  Future<void> _runFallbackRefresh() async {
    if (_userId.isEmpty) return;
    try {
      await _ref.read(sessionsNotifierProvider.notifier).refresh();
    } catch (e, st) {
      developer.log(
        'Fallback refresh — sessions',
        name: 'napstack.sync',
        error: e,
        stackTrace: st,
      );
    }
    try {
      await _ref.read(napStackNotifierProvider.notifier).syncFromServer();
    } catch (e, st) {
      developer.log(
        'Fallback refresh — nap_stack',
        name: 'napstack.sync',
        error: e,
        stackTrace: st,
      );
    }
    // Próba ponownego podpięcia Realtime (idempotentne zamknięcie w startListening).
    try {
      _subscribeNapStack();
      _subscribeSessions();
    } catch (e, st) {
      developer.log(
        'Fallback resubscribe',
        name: 'napstack.sync',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _subscribeNapStack() {
    _stackSub?.close();
    _stackSub = null;

    try {
      _stackSub = _realtime.subscribe([
        Channel.tablesdb(kDbId).table(kTableStack).row(),
      ]);
    } catch (e, st) {
      _handleSyncError('nap_stack.subscribe', e, st);
      return;
    }

    _stackSub!.stream.listen(
      (event) {
        final payload = event.payload;
        if (payload['user_id'] != _userId) return;
        unawaited(
          _ref.read(napStackNotifierProvider.notifier).rescheduleAll(),
        );
      },
      onError: (e, st) {
        _handleSyncError('nap_stack.stream', e, st);
      },
    );
    _stopFallbackPoll();
  }

  void _subscribeSessions() {
    _sessionsSub?.close();
    _sessionsSub = null;

    try {
      _sessionsSub = _realtime.subscribe([
        Channel.tablesdb(kDbId).table(kTableSessions).row(),
      ]);
    } catch (e, st) {
      _handleSyncError('nap_sessions.subscribe', e, st);
      return;
    }

    _sessionsSub!.stream.listen(
      (event) {
        final payload = event.payload;
        if (payload['user_id'] != _userId) return;
        unawaited(
          _ref.read(sessionsNotifierProvider.notifier).refresh(),
        );
      },
      onError: (e, st) {
        _handleSyncError('nap_sessions.stream', e, st);
      },
    );
  }

  void stopListening() {
    _stopFallbackPoll();
    _stackSub?.close();
    _sessionsSub?.close();
    _stackSub = null;
    _sessionsSub = null;
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final userId = ref.watch(authInitProvider).value ?? '';
  return SyncService(
    ref.watch(appwriteRealtimeProvider),
    userId,
    ref,
  );
});

/// Odczyt [authInitProvider] z ponowieniami wykładniczymi (1s…32s, max 8 prób)
/// gdy inicjalizacja sesji padnie (np. sieć) — używane do startu Realtime.
/// Parametr [family] zarezerwowany (np. `'sync'`) na wielu konsumentów w przyszłości.
final authResilientIdProvider = FutureProvider.family<String?, String>((ref, _) async {
  var delayMs = 1000;
  for (var attempt = 0; attempt < 8; attempt++) {
    final async = ref.read(authInitProvider);
    if (async.hasValue) {
      final id = async.value;
      if (id != null && id.isNotEmpty) return id;
    }
    if (async.hasError) {
      if (attempt < 7) {
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        delayMs = (delayMs * 2).clamp(1000, 32000);
        ref.invalidate(authInitProvider);
        continue;
      }
      return null;
    }
    try {
      final id = await ref.read(authInitProvider.future);
      if (id.isNotEmpty) return id;
      return null;
    } catch (_) {
      if (attempt >= 7) return null;
      await Future<void>.delayed(Duration(milliseconds: delayMs));
      delayMs = (delayMs * 2).clamp(1000, 32000);
      ref.invalidate(authInitProvider);
    }
  }
  return null;
});

/// Uruchamia [SyncService] po uzyskaniu odpartego o retry `userId` (3.3).
final syncListenerProvider = Provider<void>((ref) {
  const syncScope = 'sync';
  ref.watch(authResilientIdProvider(syncScope));
  ref.listen<AsyncValue<String?>>(
    authResilientIdProvider(syncScope),
    (previous, next) {
      next.when(
        data: (id) {
          if (id == null || id.isEmpty) {
            ref.read(syncServiceProvider).stopListening();
            return;
          }
          ref.read(syncServiceProvider).startListening();
        },
        error: (e, st) {
          developer.log(
            'authResilientId',
            name: 'napstack.sync',
            error: e,
            stackTrace: st,
          );
          ref.read(syncServiceProvider).stopListening();
        },
        loading: () {},
      );
    },
    fireImmediately: true,
  );
  ref.onDispose(() => ref.read(syncServiceProvider).stopListening());
});

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/appwrite/appwrite_client.dart';
import '../../core/appwrite/appwrite_constants.dart';
import '../auth/auth_provider.dart';
import '../nap_stack/nap_stack_notifier.dart';
import '../sessions/sessions_provider.dart';

/// Nasłuchuje zmian w Appwrite Realtime i aktualizuje lokalne providery.
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

  void startListening() {
    if (_userId.isEmpty) return;
    _subscribeNapStack();
    _subscribeSessions();
  }

  void _subscribeNapStack() {
    _stackSub?.close();

    _stackSub = _realtime.subscribe([
      Channel.tablesdb(kDbId).table(kTableStack).row(),
    ]);

    _stackSub!.stream.listen((event) {
      final payload = event.payload;
      if (payload['user_id'] != _userId) return;
      _ref.read(napStackNotifierProvider.notifier).rescheduleAll();
    });
  }

  void _subscribeSessions() {
    _sessionsSub?.close();

    _sessionsSub = _realtime.subscribe([
      Channel.tablesdb(kDbId).table(kTableSessions).row(),
    ]);

    _sessionsSub!.stream.listen((event) {
      final payload = event.payload;
      if (payload['user_id'] != _userId) return;
      _ref.read(sessionsNotifierProvider.notifier).refresh();
    });
  }

  void stopListening() {
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

final syncListenerProvider = Provider<void>((ref) {
  final userId = ref.watch(authInitProvider).value;
  if (userId == null || userId.isEmpty) return;

  final service = ref.watch(syncServiceProvider);
  service.startListening();

  ref.onDispose(service.stopListening);
});

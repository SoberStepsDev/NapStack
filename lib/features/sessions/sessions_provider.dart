import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nap_session_model.dart';
import 'sessions_service.dart';

/// Stan historii sesji — lista NapSession z informacją o paginacji.
class SessionsState {
  const SessionsState({
    this.sessions = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.cursor,
    this.error,
  });

  final List<NapSession> sessions;
  final bool isLoading;
  final bool hasMore;
  final String? cursor;
  final Object? error;

  SessionsState copyWith({
    List<NapSession>? sessions,
    bool? isLoading,
    bool? hasMore,
    String? cursor,
    Object? error,
  }) =>
      SessionsState(
        sessions: sessions ?? this.sessions,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        cursor: cursor ?? this.cursor,
        error: error,
      );
}

/// Notifier historii sesji — stronicowana lista, odświeżana po każdej nowej sesji.
class SessionsNotifier extends Notifier<SessionsState> {
  @override
  SessionsState build() {
    loadMore();
    return const SessionsState();
  }

  SessionsService get _service => ref.read(sessionsServiceProvider);

  /// Ładuje kolejną stronę historii.
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final page = await _service.fetchHistory(cursor: state.cursor);
      final newSessions = [...state.sessions, ...page];
      state = state.copyWith(
        sessions: newSessions,
        isLoading: false,
        hasMore: page.length == 50,
        cursor: page.isNotEmpty ? page.last.id : state.cursor,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  /// Odświeża całą listę (pull-to-refresh lub po nowej sesji).
  Future<void> refresh() async {
    state = const SessionsState();
    await loadMore();
  }

  /// Usuwa sesję i odświeża listę lokalnie.
  Future<void> deleteSession(String sessionId) async {
    await _service.deleteSession(sessionId);
    state = state.copyWith(
      sessions: state.sessions.where((s) => s.id != sessionId).toList(),
    );
  }
}

final sessionsNotifierProvider =
    NotifierProvider<SessionsNotifier, SessionsState>(SessionsNotifier.new);

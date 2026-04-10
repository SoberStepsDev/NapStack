import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/appwrite/appwrite_client.dart';
import '../../core/appwrite/appwrite_constants.dart';
import '../../core/appwrite/appwrite_error_handler.dart';
import '../../core/security/data_validator.dart';
import '../../core/security/permissions_helper.dart';
import '../auth/auth_provider.dart';
import '../timer/nap_preset.dart';
import 'nap_session_model.dart';

class SessionsService {
  SessionsService(this._db, this._userId);

  final TablesDB _db;
  final String _userId;

  static const _uuid = Uuid();

  /// Zapisuje zakończoną lub przerwaną sesję drzemki.
  ///
  /// Walidacja i uprawnienia są wymuszane przed każdym zapisem.
  Future<NapSession> saveSession({
    required NapPreset preset,
    required DateTime startedAt,
    required DateTime endedAt,
    required bool completed,
  }) async {
    // 1. Walidacja danych
    final validation = DataValidator.validateSession(
      userId: _userId,
      startedAt: startedAt,
      endedAt: endedAt,
      napType: preset.type,
      plannedMinutes: preset.plannedMinutes,
    );
    if (!validation.isValid) {
      throw DataValidationException(
        field: 'NapSession',
        message: validation.errors.join('; '),
      );
    }

    // 2. Budowanie rekordu
    final rowId = _uuid.v4();
    final session = NapSession(
      id: rowId,
      userId: _userId,
      startedAt: startedAt,
      endedAt: endedAt,
      napType: preset.type,
      completed: completed,
      plannedMinutes: preset.plannedMinutes,
    );

    // 3. Zapis z uprawnieniami i obsługą błędów
    await AppwriteErrorHandler.runWithRetry(
      () => _db.createRow(
        databaseId: kDbId,
        tableId: kTableSessions,
        rowId: rowId,
        data: session.toAppwrite(),
        permissions: PermissionsHelperSafe.ownerFullAccessSafe(_userId),
      ),
      resource: 'nap_sessions',
    );

    return session;
  }

  /// Historia sesji — cursor pagination, malejąco po dacie.
  Future<List<NapSession>> fetchHistory({
    String? cursor,
    int limit = 50,
  }) async {
    DataValidator.assertValidUserId(_userId);

    final result = await AppwriteErrorHandler.run(
      () => _db.listRows(
        databaseId: kDbId,
        tableId: kTableSessions,
        queries: [
          Query.equal('user_id', _userId),
          Query.orderDesc('started_at'),
          Query.limit(limit),
          if (cursor != null) Query.cursorAfter(cursor),
        ],
      ),
      resource: 'nap_sessions',
    );

    return result.rows.map((r) => NapSession.fromAppwrite(r.data)).toList();
  }

  /// Sesje z ostatnich [days] dni — dla statystyk.
  Future<List<NapSession>> fetchRecentSessions({int days = 7}) async {
    DataValidator.assertValidUserId(_userId);

    final since = DateTime.now()
        .subtract(Duration(days: days))
        .toUtc()
        .toIso8601String();

    final result = await AppwriteErrorHandler.run(
      () => _db.listRows(
        databaseId: kDbId,
        tableId: kTableSessions,
        queries: [
          Query.equal('user_id', _userId),
          Query.greaterThanEqual('started_at', since),
          Query.orderDesc('started_at'),
          Query.limit(100),
        ],
      ),
      resource: 'nap_sessions',
    );

    return result.rows.map((r) => NapSession.fromAppwrite(r.data)).toList();
  }

  /// Aktualizuje ocenę jakości snu (MirrorMind Q3-2026).
  Future<void> updateQualityRating(String sessionId, int rating) async {
    if (rating < 1 || rating > 5) {
      throw DataValidationException(
        field: 'qualityRating',
        message: 'qualityRating musi być w zakresie [1, 5], otrzymano: $rating',
      );
    }

    await AppwriteErrorHandler.run(
      () => _db.updateRow(
        databaseId: kDbId,
        tableId: kTableSessions,
        rowId: sessionId,
        data: {'quality_rating': rating},
      ),
      resource: 'nap_sessions/$sessionId',
    );
  }

  Future<void> deleteSession(String sessionId) async {
    await AppwriteErrorHandler.run(
      () => _db.deleteRow(
        databaseId: kDbId,
        tableId: kTableSessions,
        rowId: sessionId,
      ),
      resource: 'nap_sessions/$sessionId',
    );
  }
}

final sessionsServiceProvider = Provider<SessionsService>((ref) {
  final userId = ref.watch(authInitProvider).value ?? '';
  return SessionsService(ref.watch(appwriteTablesDBProvider), userId);
});

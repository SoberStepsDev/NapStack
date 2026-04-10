import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/appwrite/appwrite_client.dart';
import '../../core/appwrite/appwrite_constants.dart';
import '../../core/appwrite/appwrite_error_handler.dart';
import '../../core/security/data_validator.dart';
import '../../core/security/permissions_helper.dart';
import '../auth/auth_provider.dart';

/// Preferencje użytkownika w Appwrite — jeden rekord per konto.
///
/// Bezpieczeństwo:
/// - rowId == userId → tylko właściciel może odczytać/zaktualizować.
/// - Permission.delete BRAK — rekord jest trwały (historia Pro, onboarding).
/// - Każda operacja przez AppwriteErrorHandler.run() z retry.
class UserPrefsService {
  UserPrefsService(this._db, this._userId);

  final TablesDB _db;
  final String _userId;

  Future<Map<String, dynamic>> getOrCreate() async {
    DataValidator.assertValidUserId(_userId);

    return AppwriteErrorHandler.run(
      () async {
        try {
          final row = await _db.getRow(
            databaseId: kDbId,
            tableId: kTableUserPrefs,
            rowId: _userId,
          );
          return row.data;
        } on AppwriteException catch (e) {
          if (e.code == 404) return _create();
          rethrow;
        }
      },
      resource: 'user_prefs',
    );
  }

  Future<Map<String, dynamic>> _create() async {
    final defaults = {
      'user_id': _userId,
      'pro_active': false,
      'rc_user_id': _userId,
      'onboarded': false,
    };

    await _db.createRow(
      databaseId: kDbId,
      tableId: kTableUserPrefs,
      rowId: _userId,
      data: defaults,
      // user_prefs: read + update, bez delete
      permissions: PermissionsHelperSafe.ownerReadUpdateSafe(_userId),
    );

    return defaults;
  }

  Future<void> syncProStatus(bool isActive) async {
    await AppwriteErrorHandler.run(
      () => _db.updateRow(
        databaseId: kDbId,
        tableId: kTableUserPrefs,
        rowId: _userId,
        data: {'pro_active': isActive},
      ),
      resource: 'user_prefs',
    );
  }

  Future<void> setOnboarded() async {
    await AppwriteErrorHandler.run(
      () => _db.updateRow(
        databaseId: kDbId,
        tableId: kTableUserPrefs,
        rowId: _userId,
        data: {'onboarded': true},
      ),
      resource: 'user_prefs',
    );
  }
}

final userPrefsServiceProvider = Provider<UserPrefsService>((ref) {
  final userId = ref.watch(authInitProvider).value ?? '';
  return UserPrefsService(ref.watch(appwriteTablesDBProvider), userId);
});

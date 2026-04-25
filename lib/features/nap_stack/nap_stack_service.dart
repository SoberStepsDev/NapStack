import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/appwrite/appwrite_client.dart';
import '../../core/appwrite/appwrite_constants.dart';
import '../../core/appwrite/appwrite_error_handler.dart';
import '../../core/appwrite/pro_gate_service.dart';
import '../../core/security/data_validator.dart';
import '../../core/security/permissions_helper.dart';
import '../auth/auth_provider.dart';
import '../timer/nap_preset.dart';
import 'nap_stack_item_model.dart';

class NapStackService {
  NapStackService(this._db, this._userId, this._proGate);

  final TablesDB _db;
  final String _userId;

  /// Weryfikacja Pro w Appwrite Function (RevenueCat) — **nigdy** nie ufamy polom
  /// w rekordach stack dot. Pro; tu jedyna ścieżka gdy wykorzystany limit free.
  final ProGateService _proGate;

  static const _uuid = Uuid();
  static const _freeLimit = 3;

  Future<List<NapStackItem>> fetchStack() async {
    DataValidator.assertValidUserId(_userId);

    final result = await AppwriteErrorHandler.run(
      () => _db.listRows(
        databaseId: kDbId,
        tableId: kTableStack,
        queries: [
          Query.equal('user_id', _userId),
          Query.equal('done', false),
          Query.orderAsc('scheduled_iso'),
          Query.limit(100),
        ],
      ),
      resource: 'nap_stack',
    );

    return result.rows.map((r) => NapStackItem.fromAppwrite(r.data)).toList();
  }

  Future<NapStackItem> addItem({
    required DateTime scheduledAt,
    required NapType napType,
  }) async {
    // 1. Walidacja
    final validation = DataValidator.validateStackItem(
      userId: _userId,
      scheduledAt: scheduledAt,
      napType: napType,
    );

    // Błędy krytyczne (np. godzina w przeszłości) — zablokuj
    final criticalErrors =
        validation.errors.where((e) => !NapStackValidationResult.isWarning(e));
    if (criticalErrors.isNotEmpty) {
      throw DataValidationException(
        field: 'NapStackItem',
        message: criticalErrors.join('; '),
      );
    }

    // 2. Limit free (3 aktywne) — **bez** parametru isPro z klienta; przy >= 3
    // tylko [ProGateService] (RevenueCat) może odblokować. Fail-secure przy błędzie funkcji.
    final current = await fetchStack();
    if (current.length >= _freeLimit) {
      final serverAllowed = await _proGate.checkProAccess(action: 'addToStack');
      if (!serverAllowed) {
        throw NapStackLimitException();
      }
    }

    // 3. Zapis
    final rowId = _uuid.v4();
    final item = NapStackItem(
      id: rowId,
      userId: _userId,
      scheduledAt: scheduledAt,
      napType: napType,
    );

    await AppwriteErrorHandler.runWithRetry(
      () => _db.createRow(
        databaseId: kDbId,
        tableId: kTableStack,
        rowId: rowId,
        data: item.toAppwrite(),
        permissions: PermissionsHelperSafe.ownerFullAccessSafe(_userId),
      ),
      resource: 'nap_stack',
    );

    return item;
  }

  Future<void> markDone(String itemId) async {
    await AppwriteErrorHandler.run(
      () => _db.updateRow(
        databaseId: kDbId,
        tableId: kTableStack,
        rowId: itemId,
        data: {'done': true},
      ),
      resource: 'nap_stack/$itemId',
    );
  }

  Future<void> deleteItem(String itemId) async {
    await AppwriteErrorHandler.run(
      () => _db.deleteRow(
        databaseId: kDbId,
        tableId: kTableStack,
        rowId: itemId,
      ),
      resource: 'nap_stack/$itemId',
    );
  }
}

class NapStackLimitException implements Exception {
  @override
  String toString() =>
      'NapStackLimit: Wersja darmowa pozwala na maksymalnie 3 drzemki. '
      'Kup Pro aby usunąć limit.';
}

final napStackServiceProvider = Provider<NapStackService>((ref) {
  final userId = ref.watch(authInitProvider).value ?? '';
  return NapStackService(
    ref.watch(appwriteTablesDBProvider),
    userId,
    ref.watch(proGateServiceProvider),
  );
});

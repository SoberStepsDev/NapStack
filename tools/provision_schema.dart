/// NapStack — Schema Provisioner
///
/// Uruchamiaj WYŁĄCZNIE server-side z kluczem API (nie z klienta Flutter):
///   dart run tools/provision_schema.dart
///
/// Wymagane zmienne środowiskowe:
///   APPWRITE_ENDPOINT    — np. https://fra.cloud.appwrite.io/v1
///   APPWRITE_PROJECT_ID  — ID projektu Appwrite
///   APPWRITE_API_KEY     — klucz z uprawnieniami: databases.write, collections.write
///
/// Skrypt jest idempotentny: sprawdza czy zasób istnieje przed created.
/// Bezpieczny do ponownego uruchomienia (np. po zmianie schematu).
library;

import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';

// ── Stałe bazy ────────────────────────────────────────────────────────────────

const _kDbId = 'napstack';
const _kDbName = 'NapStack';

const _kTableSessions = 'nap_sessions';
const _kTableStack = 'nap_stack';
const _kTableUserPrefs = 'user_prefs';

// ── Entry point ───────────────────────────────────────────────────────────────

Future<void> main() async {
  final endpoint = _requireEnv('APPWRITE_ENDPOINT');
  final projectId = _requireEnv('APPWRITE_PROJECT_ID');
  final apiKey = _requireEnv('APPWRITE_API_KEY');

  final client = Client()
      .setEndpoint(endpoint)
      .setProject(projectId)
      .setKey(apiKey);

  final db = TablesDB(client);

  log('NapStack Schema Provisioner v1.0');
  log('Project: $projectId @ $endpoint');
  log('');

  await _provisionDatabase(db);
  await _provisionNapSessions(db);
  await _provisionNapStack(db);
  await _provisionUserPrefs(db);

  log('');
  log('✓ Schema provisioning complete.');
}

// ── Database ──────────────────────────────────────────────────────────────────

Future<void> _provisionDatabase(TablesDB db) async {
  log('── Database: $_kDbId ──────────────────────────────────────────────');
  try {
    await db.get(databaseId: _kDbId);
    log('  SKIP  database "$_kDbId" already exists');
  } on AppwriteException catch (e) {
    if (e.code != 404) rethrow;
    await db.create(databaseId: _kDbId, name: _kDbName);
    log('  CREATE database "$_kDbId"');
  }
}

// ── nap_sessions ──────────────────────────────────────────────────────────────

Future<void> _provisionNapSessions(TablesDB db) async {
  log('');
  log('── Table: $_kTableSessions ────────────────────────────────────────');

  await _createTableIfAbsent(
    db,
    tableId: _kTableSessions,
    name: 'Nap Sessions',
    // Uprawnienia na poziomie kolekcji:
    // Tylko zalogowani użytkownicy mogą tworzyć dokumenty.
    // Odczyt/aktualizacja/usunięcie — wyłącznie przez uprawnienia per-dokument.
    permissions: [Permission.create(Role.users())],
  );

  await _createColumnIfAbsent(db, _kTableSessions, {
    'key': 'user_id',
    'type': 'varchar',
    'size': 36,
    'required': true,
  });
  await _createColumnIfAbsent(db, _kTableSessions, {
    'key': 'started_at',
    'type': 'varchar',
    'size': 30,
    'required': true,
  });
  await _createColumnIfAbsent(db, _kTableSessions, {
    'key': 'ended_at',
    'type': 'varchar',
    'size': 30,
    'required': true,
  });
  await _createColumnIfAbsent(db, _kTableSessions, {
    'key': 'nap_type',
    'type': 'varchar',
    'size': 20,
    'required': true,
  });
  await _createColumnIfAbsent(db, _kTableSessions, {
    'key': 'completed',
    'type': 'boolean',
    'required': true,
    'default': false,
  });
  await _createColumnIfAbsent(db, _kTableSessions, {
    'key': 'planned_min',
    'type': 'integer',
    'required': true,
    'min': 1,
    'max': 180,
  });
  await _createColumnIfAbsent(db, _kTableSessions, {
    'key': 'quality_rating',
    'type': 'integer',
    'required': false,
    'min': 1,
    'max': 5,
    // null w v1; zarezerwowane na MirrorMind Q3-2026
  });

  // Indeksy wymagane przez zapytania w SessionsService
  await _createIndexIfAbsent(db, _kTableSessions, 'idx_sess_user_id',
      type: 'key', attributes: ['user_id']);
  await _createIndexIfAbsent(db, _kTableSessions, 'idx_sess_started_at',
      type: 'key', attributes: ['started_at', 'user_id']);
}

// ── nap_stack ─────────────────────────────────────────────────────────────────

Future<void> _provisionNapStack(TablesDB db) async {
  log('');
  log('── Table: $_kTableStack ──────────────────────────────────────────');

  await _createTableIfAbsent(
    db,
    tableId: _kTableStack,
    name: 'Nap Stack',
    permissions: [Permission.create(Role.users())],
  );

  await _createColumnIfAbsent(db, _kTableStack, {
    'key': 'user_id',
    'type': 'varchar',
    'size': 36,
    'required': true,
  });
  await _createColumnIfAbsent(db, _kTableStack, {
    'key': 'scheduled_iso',
    'type': 'varchar',
    'size': 30,
    'required': true,
  });
  await _createColumnIfAbsent(db, _kTableStack, {
    'key': 'nap_type',
    'type': 'varchar',
    'size': 20,
    'required': true,
  });
  await _createColumnIfAbsent(db, _kTableStack, {
    'key': 'done',
    'type': 'boolean',
    'required': true,
    'default': false,
  });

  await _createIndexIfAbsent(db, _kTableStack, 'idx_stack_user_done',
      type: 'key', attributes: ['user_id', 'done']);
  await _createIndexIfAbsent(db, _kTableStack, 'idx_stack_scheduled',
      type: 'key', attributes: ['scheduled_iso']);
}

// ── user_prefs ────────────────────────────────────────────────────────────────

Future<void> _provisionUserPrefs(TablesDB db) async {
  log('');
  log('── Table: $_kTableUserPrefs ──────────────────────────────────────');

  await _createTableIfAbsent(
    db,
    tableId: _kTableUserPrefs,
    name: 'User Preferences',
    permissions: [Permission.create(Role.users())],
  );

  await _createColumnIfAbsent(db, _kTableUserPrefs, {
    'key': 'user_id',
    'type': 'varchar',
    'size': 36,
    'required': true,
  });
  await _createColumnIfAbsent(db, _kTableUserPrefs, {
    'key': 'pro_active',
    'type': 'boolean',
    'required': true,
    'default': false,
  });
  await _createColumnIfAbsent(db, _kTableUserPrefs, {
    'key': 'rc_user_id',
    'type': 'varchar',
    'size': 100,
    'required': true,
    'default': '',
  });
  await _createColumnIfAbsent(db, _kTableUserPrefs, {
    'key': 'onboarded',
    'type': 'boolean',
    'required': true,
    'default': false,
  });

  await _createIndexIfAbsent(db, _kTableUserPrefs, 'idx_prefs_user_id',
      type: 'unique', attributes: ['user_id']);
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Future<void> _createTableIfAbsent(
  TablesDB db, {
  required String tableId,
  required String name,
  List<String> permissions = const [],
}) async {
  try {
    await db.getTable(databaseId: _kDbId, tableId: tableId);
    log('  SKIP  table "$tableId" already exists');
  } on AppwriteException catch (e) {
    if (e.code != 404) rethrow;
    await db.createTable(
      databaseId: _kDbId,
      tableId: tableId,
      name: name,
      permissions: permissions,
    );
    log('  CREATE table "$tableId"');
  }
}

Future<void> _createColumnIfAbsent(
  TablesDB db,
  String tableId,
  Map<String, dynamic> column,
) async {
  final key = column['key'] as String;
  try {
    await db.getAttribute(
        databaseId: _kDbId, tableId: tableId, key: key);
    log('  SKIP  column "$key"');
  } on AppwriteException catch (e) {
    if (e.code != 404) rethrow;

    final type = column['type'] as String;

    switch (type) {
      case 'varchar':
        await db.createStringAttribute(
          databaseId: _kDbId,
          tableId: tableId,
          key: key,
          size: column['size'] as int,
          xrequired: column['required'] as bool? ?? false,
          xdefault: column['default'] as String?,
        );
      case 'text':
        await db.createStringAttribute(
          databaseId: _kDbId,
          tableId: tableId,
          key: key,
          size: 16383,
          xrequired: column['required'] as bool? ?? false,
        );
      case 'boolean':
        await db.createBooleanAttribute(
          databaseId: _kDbId,
          tableId: tableId,
          key: key,
          xrequired: column['required'] as bool? ?? false,
          xdefault: column['default'] as bool?,
        );
      case 'integer':
        await db.createIntegerAttribute(
          databaseId: _kDbId,
          tableId: tableId,
          key: key,
          xrequired: column['required'] as bool? ?? false,
          min: column['min'] as int?,
          max: column['max'] as int?,
          xdefault: column['default'] as int?,
        );
      default:
        throw ArgumentError('Nieznany typ kolumny: $type');
    }

    log('  CREATE column "$tableId.$key" ($type)');

    // Appwrite tworzy atrybuty asynchronicznie — poczekaj na status "available"
    await _waitForAttribute(db, tableId, key);
  }
}

Future<void> _waitForAttribute(
  TablesDB db,
  String tableId,
  String key, {
  int maxAttempts = 20,
  Duration delay = const Duration(seconds: 1),
}) async {
  for (var i = 0; i < maxAttempts; i++) {
    await Future<void>.delayed(delay);
    try {
      final attr =
          await db.getAttribute(databaseId: _kDbId, tableId: tableId, key: key);
      final status = attr.toMap()['status'] as String? ?? '';
      if (status == 'available') return;
      log('    ... waiting for "$key" ($status)');
    } catch (_) {}
  }
  log('  WARN  timeout waiting for attribute "$key"');
}

Future<void> _createIndexIfAbsent(
  TablesDB db,
  String tableId,
  String indexKey, {
  required String type,
  required List<String> attributes,
  List<String> orders = const [],
}) async {
  try {
    await db.getIndex(
        databaseId: _kDbId, tableId: tableId, key: indexKey);
    log('  SKIP  index "$indexKey"');
  } on AppwriteException catch (e) {
    if (e.code != 404) rethrow;
    await db.createIndex(
      databaseId: _kDbId,
      tableId: tableId,
      key: indexKey,
      type: IndexType.values.byName(type),
      attributes: attributes,
      orders: orders.isEmpty
          ? attributes.map((_) => 'ASC').toList()
          : orders,
    );
    log('  CREATE index "$indexKey" on [$tableId] (${attributes.join(', ')})');
  }
}

String _requireEnv(String key) {
  final value = Platform.environment[key];
  if (value == null || value.isEmpty) {
    stderr.writeln('ERROR: Brakuje zmiennej środowiskowej: $key');
    exit(1);
  }
  return value;
}

void log(String message) => stdout.writeln(message);

import 'package:appwrite/appwrite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/appwrite/appwrite_constants.dart';
import '../timer/alarm_service.dart';
import '../timer/nap_preset.dart';
import '../nap_stack/nap_stack_item_model.dart';

/// Przywraca alarmy Nap Stack po restarcie urządzenia lub reinstalacji.
///
/// Problem:
/// Android usuwa wszystkie zaplanowane alarmy przy wyłączeniu urządzenia.
/// W v1 (Hive) rozwiązywał to BootReceiver odczytujący lokalną bazę.
/// W NapStack + Appwrite źródłem prawdy jest chmura — baza Hive odpada,
/// ale potrzebujemy lokalnego userId do authenticated requesty Appwrite.
///
/// Rozwiązanie:
/// 1. BootReceiver (Kotlin) budzi FlutterEngine.
/// 2. Dart readuje cached userId z SharedPreferences.
/// 3. Tworzy anonimową sesję Appwrite (ten sam userId).
/// 4. Pobiera nap_stack z Appwrite.
/// 5. Planuje alarmy dla niewykonanych elementów w przyszłości.
///
/// WAŻNE: Ta klasa działa w izolowanym kontekście (bez UI) — nie używa Riverpod.
class BootRecoveryService {
  /// Punkt wejścia wywoływany z BootReceiver przez MethodChannel.
  static Future<void> recoverAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(kPrefUserId);

    if (userId == null) return; // Pierwsze uruchomienie — nic do przywrócenia

    await AlarmService.init();

    final client = Client()
        .setEndpoint(kAppwriteEndpoint)
        .setProject(kAppwriteProjectId);

    // Próba odtworzenia sesji — w BootReceiver nie ma aktywnej sesji cookie
    try {
      final account = Account(client);
      // Utwórz nową anonimową sesję; dane są przypisane do userId w Appwrite
      final session = await account.createAnonymousSession();
      await prefs.setString(kPrefUserId, session.userId);
    } catch (_) {
      // Sieć niedostępna przy restarcie — pomiń sync, alarmy zostaną przywrócone
      // przy następnym otwarciu apki przez normalny authInit
      return;
    }

    final db = TablesDB(client);
    await _rescheduleFromAppwrite(db, userId);
  }

  static Future<void> _rescheduleFromAppwrite(
      TablesDB db, String userId) async {
    try {
      final result = await db.listRows(
        databaseId: kDbId,
        tableId: kTableStack,
        queries: [
          Query.equal('user_id', userId),
          Query.equal('done', false),
          Query.orderAsc('scheduled_iso'),
          Query.limit(100),
        ],
      );

      final now = DateTime.now();
      for (final row in result.rows) {
        final item = NapStackItem.fromAppwrite(row.data);
        final preset = presetByType(item.napType);
        final wakeAt = item.scheduledAt
            .add(Duration(seconds: preset.fallAsleepSeconds));

        if (wakeAt.isAfter(now)) {
          try {
            await AlarmService.scheduleWakeUp(
              alarmId: item.alarmId,
              wakeAt: wakeAt,
              label: '${preset.label} — czas wstawać!',
            );
          } catch (_) {
            // Brak uprawnień do exact alarms — użytkownik zobaczy dialog przy
            // następnym otwarciu apki (obsługa w AlarmService)
          }
        } else {
          // Alarm minął w trakcie restartu — oznacz jako done
          try {
            await db.updateRow(
              databaseId: kDbId,
              tableId: kTableStack,
              rowId: item.id,
              data: {'done': true},
            );
          } catch (_) {}
        }
      }
    } catch (_) {
      // Sieć niedostępna lub błąd Appwrite — alarmy zostaną przywrócone
      // przy następnym otwarciu apki (NapStackNotifier.rescheduleAll)
    }
  }
}

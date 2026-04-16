import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

import 'nap_preset.dart';

/// Jedyna klasa odpowiedzialna za planowanie alarmów systemowych.
///
/// Używa flutter_local_notifications z AndroidScheduleMode.exactAllowWhileIdle
/// — jedynym sposobem na pewne wybudzenie przez Doze Mode (API 23+).
///
/// WAŻNE: Timer.periodic w Dart NIE jest alarmem. Służy wyłącznie do aktualizacji UI.
/// Tym plikiem zarządza Android AlarmManager — niezależnie od stanu Dart VM.
class AlarmService {
  AlarmService._();

  static final _fln = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static RingtoneType _ringtone = RingtoneType.defaultRingtone;

  static void setRingtone(RingtoneType ringtone) => _ringtone = ringtone;

  /// Inicjalizacja — wywoływana raz w main() po initTimezone().
  ///
  /// Rejestruje kanał alarmowy i timezone — nie prosi jeszcze o uprawnienia
  /// runtime (te wymagają kontekstu UI, patrz [requestRuntimePermissions]).
  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // flutter_timezone 5.x returns TimezoneInfo; use .identifier for tz lookup
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _fln.initialize(
      settings: const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Prosi o uprawnienia runtime wymagane na Androidzie 13+ / 14+.
  ///
  /// Wywołać po zamontowaniu UI (np. w _postAuthInit), NIE w main() —
  /// dialogi systemowe wymagają aktywnej Activity.
  ///
  /// - POST_NOTIFICATIONS (API 33+): wymagane od Androida 13.
  ///   Bez tego FLN cicho ignoruje powiadomienia.
  ///
  /// - USE_FULL_SCREEN_INTENT (API 34+): od Androida 14 wymaga jawnego
  ///   przyznania. Bez tego alarm wyświetla się jako zwykłe powiadomienie
  ///   (nie fullscreen), nawet jeśli jest zadeklarowany w Manifeście.
  ///
  /// Oba requesty są idempotentne — kolejne wywołania nie pokazują dialogu
  /// jeśli uprawnienie zostało już przyznane lub odrzucone.
  static Future<void> requestRuntimePermissions() async {
    final android = _fln.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return; // Nie-Android — nic do roboty.

    // 1. POST_NOTIFICATIONS — API 33+ (Android 13+).
    //    Na niższych API metoda zwraca natychmiast bez dialogu.
    await android.requestNotificationsPermission();

    // 2. USE_FULL_SCREEN_INTENT — API 34+ (Android 14+).
    //    Plugin udostępnia tylko request; na starszych API wywołanie jest bezbolesne.
    await android.requestFullScreenIntentPermission();
  }

  /// Planuje alarm wybudzenia.
  ///
  /// [alarmId] — unikalny int; użyj `scheduledTime.hashCode & 0x7FFFFFFF`.
  /// [wakeAt]  — bezwzględny czas wybudzenia.
  /// [label]   — wyświetlana w powiadomieniu (np. "Power Nap — wstawaj!").
  static Future<void> scheduleWakeUp({
    required int alarmId,
    required DateTime wakeAt,
    required String label,
  }) async {
    final androidImpl = _fln.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Sprawdzenie uprawnienia przed każdym schedule — API 31+
    // flutter_local_notifications 21.x: canScheduleExactNotifications()
    final canSchedule =
        await androidImpl?.canScheduleExactNotifications() ?? true;
    if (!canSchedule) {
      await androidImpl?.requestExactAlarmsPermission();
      throw AlarmPermissionDeniedException();
    }

    final tzWakeAt = tz.TZDateTime.from(wakeAt, tz.local);

    // flutter_local_notifications 21.x: wszystkie parametry nazwane,
    // uiLocalNotificationDateInterpretation usunięty (był iOS-only).
    await _fln.zonedSchedule(
      id: alarmId,
      title: 'NapStack',
      body: label,
      scheduledDate: tzWakeAt,
      notificationDetails: _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Anuluje alarm po [alarmId].
  static Future<void> cancel(int alarmId) => _fln.cancel(id: alarmId);

  /// Anuluje wszystkie zaplanowane alarmy NapStack.
  static Future<void> cancelAll() => _fln.cancelAll();

  static AndroidNotificationDetails _buildAndroidDetails() =>
      AndroidNotificationDetails(
        'napstack_alarm',
        'NapStack Alarm',
        channelDescription: 'Alarm wybudzenia po drzemce',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        sound: RawResourceAndroidNotificationSound(_ringtone.resourceId),
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
      );

  static NotificationDetails _buildNotificationDetails() =>
      NotificationDetails(android: _buildAndroidDetails());

  static void _onNotificationTapped(NotificationResponse response) {
    // Opcjonalnie: deep-link do ekranu po alarmie
  }
}

/// Rzucany gdy użytkownik nie przyznał uprawnień do exact alarms.
class AlarmPermissionDeniedException implements Exception {
  @override
  String toString() =>
      'AlarmPermissionDenied: Użytkownik musi zezwolić na alarmy w ustawieniach.';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get alarmExactPermissionSnack =>
      'Brak zgody na alarmy o dokładnym czasie — drzemka może nie wybudzić na czas. Ustawienia → Aplikacje → NapStack → Alarms & reminders / Powiadomienia.';

  @override
  String get notificationsDisabledSnack =>
      'Powiadomienia wyłączone — włącz je dla NapStack w ustawieniach systemu, inaczej alarm i powiadomienia nie zadziałają.';

  @override
  String get alarmPermissionDenied =>
      'Brak uprawnienia do alarmów o dokładnym czasie. Włącz alarmy dla NapStack w ustawieniach systemu, aby wybudzenie działało punktualnie.';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get alarmExactPermissionSnack =>
      'No permission for exact alarms — your nap may not wake on time. Open Settings → Apps → NapStack → Alarms & reminders / Notifications.';

  @override
  String get notificationsDisabledSnack =>
      'Notifications are off — enable them for NapStack in system settings, or alarms and notifications will not work.';

  @override
  String get alarmPermissionDenied =>
      'Exact alarms are disabled. Allow alarms for NapStack in system settings so wake-up works on time.';
}

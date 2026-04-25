import '../../l10n/app_localizations.dart';

/// Wyjątek z treścią do wyświetlenia użytkownikowi (l10n).
abstract class UserFacingException implements Exception {
  const UserFacingException();

  String messageL10n(AppLocalizations l10n);
}

import 'package:flutter/widgets.dart';

import 'legal_document_assets.dart';

/// Krótkie napisy UI dla sekcji „Informacje prawne” i powiązanych ekranów.
class LegalUiStrings {
  LegalUiStrings._(this._en);

  final bool _en;

  static LegalUiStrings of(BuildContext context) =>
      LegalUiStrings._(legalContentLanguageCode(context) == 'en');

  String get legalInfoAppBar =>
      _en ? 'Legal information' : 'Informacje prawne';

  String get legalInfoIntro => _en
      ? 'Below you can read the full privacy policy, terms, and consumer information in the app. '
          'If configured at build time, you can also open optional versions on the web.'
      : 'Poniżej pełne teksty polityki i regulaminu w aplikacji. '
          'Możesz też otworzyć opcjonalną wersję na stronie WWW, jeśli jest skonfigurowana przy buildzie.';

  String get subtitleInApp => _en ? 'In-app content' : 'Treść w aplikacji';

  String get subtitleExternal => _en ? 'External link' : 'Zewnętrzny link';

  String get privacyWwwTitle =>
      _en ? 'Privacy policy (web)' : 'Polityka prywatności (www)';

  String get termsWwwTitle =>
      _en ? 'Terms of Service (web)' : 'Regulamin / Terms (www)';

  String get consumerWwwTitle => _en
      ? 'Consumer information (web)'
      : 'Informacje dla konsumentów (www)';

  String get ossTitle =>
      _en ? 'Open-source licenses' : 'Licencje open source';

  String get ossSubtitle => _en
      ? 'Flutter / Dart libraries'
      : 'Biblioteki Flutter / Dart';

  String get cannotOpen => _en ? 'Could not open: ' : 'Nie można otworzyć: ';

  String get docLoadError => _en
      ? 'Could not load this document.'
      : 'Nie udało się wczytać dokumentu.';

  String get docUnknown => _en ? 'Unknown document: ' : 'Nieznany dokument: ';
}

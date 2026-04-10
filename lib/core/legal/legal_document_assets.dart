/// Mapowanie identyfikatorów ekranów na pliki Markdown w `assets/legal/`.
library;

import 'package:flutter/widgets.dart';

const Map<String, String> _kLegalDocumentAssetPl = {
  'privacy': 'assets/legal/privacy_pl.md',
  'terms': 'assets/legal/terms_pl.md',
  'consumer': 'assets/legal/consumer_pl.md',
};

const Map<String, String> _kLegalDocumentAssetEn = {
  'privacy': 'assets/legal/privacy_en.md',
  'terms': 'assets/legal/terms_en.md',
  'consumer': 'assets/legal/consumer_en.md',
};

const Map<String, String> _kLegalDocumentTitlePl = {
  'privacy': 'Polityka prywatności',
  'terms': 'Regulamin (Terms of Service)',
  'consumer': 'Informacje dla konsumentów',
};

const Map<String, String> _kLegalDocumentTitleEn = {
  'privacy': 'Privacy policy',
  'terms': 'Terms of Service',
  'consumer': 'Consumer information',
};

/// `en` dla języka angielskiego urządzenia/UI; w pozostałych przypadkach `pl`.
String legalContentLanguageCode(BuildContext context) {
  final code =
      Localizations.localeOf(context).languageCode.toLowerCase();
  return code == 'en' ? 'en' : 'pl';
}

String? legalDocumentAsset(String docId, BuildContext context) {
  final lang = legalContentLanguageCode(context);
  final map = lang == 'en' ? _kLegalDocumentAssetEn : _kLegalDocumentAssetPl;
  return map[docId];
}

String legalDocumentTitle(String docId, BuildContext context) {
  final lang = legalContentLanguageCode(context);
  final map = lang == 'en' ? _kLegalDocumentTitleEn : _kLegalDocumentTitlePl;
  return map[docId] ?? (lang == 'en' ? 'Document' : 'Dokument');
}

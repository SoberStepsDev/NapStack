/// URL-e dokumentów prawnych — ustaw przez `--dart-define` lub `dart_defines.local.json`
/// (np. z `tool/sync_dart_defines_from_env.py`). Puste = pozycja ukryta w UI.
library;

const kPrivacyPolicyUrl = String.fromEnvironment(
  'PRIVACY_POLICY_URL',
  defaultValue: '',
);

const kTermsOfServiceUrl = String.fromEnvironment(
  'TERMS_OF_SERVICE_URL',
  defaultValue: '',
);

/// Opcjonalnie osobna strona (np. zwroty / prawa konsumenta). Jeśli pusta, nie pokazujemy.
const kConsumerInfoUrl = String.fromEnvironment(
  'CONSUMER_INFO_URL',
  defaultValue: '',
);

bool get kHasAnyLegalUrl =>
    kPrivacyPolicyUrl.isNotEmpty ||
    kTermsOfServiceUrl.isNotEmpty ||
    kConsumerInfoUrl.isNotEmpty;

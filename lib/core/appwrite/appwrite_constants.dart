/// Centralne stałe Appwrite dla NapStack.
/// Nigdy nie commit prawdziwych wartości — używaj --dart-define lub .env.
library;

const kAppwriteEndpoint = String.fromEnvironment(
  'APPWRITE_ENDPOINT',
  defaultValue: 'https://fra.cloud.appwrite.io/v1',
);

const kAppwriteProjectId = String.fromEnvironment(
  'APPWRITE_PROJECT_ID',
  defaultValue: '69d7218d001dd20138f6',
);

/// Baza danych
const kDbId = 'napstack';

/// Tabele
const kTableSessions = 'nap_sessions';
const kTableStack = 'nap_stack';
const kTableUserPrefs = 'user_prefs';

/// SharedPreferences keys (lokalne cache)
const kPrefUserId = 'appwrite_user_id';
const kPrefSessionSecret = 'appwrite_session_secret';
const kPrefProCached = 'pro_cached';

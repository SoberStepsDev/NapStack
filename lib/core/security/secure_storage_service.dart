import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Klucze przechowywane w bezpiecznym magazynie.
/// NIGDY nie dodawaj tu danych które powinny być widoczne offline bez auth.
abstract final class SecureKeys {
  /// Appwrite User ID — stabilny identyfikator konta anonimowego.
  static const userId = 'appwrite_user_id';

  /// Flaga Pro z ostatniego sprawdzenia RC — bool jako string 'true'/'false'.
  /// Przechowywana tu (a nie w SharedPreferences) bo wpływa na dostęp do funkcji.
  static const proCached = 'pro_cached';

  /// ISO-8601 — kiedy zapisano [proCached] (długożyjące cache = ostrzeżenie).
  static const proCachedAt = 'pro_cached_at';

  /// Email konta (po upgrade z anonimowego do email/password).
  /// Przechowywany tu, by móc odtworzyć sesję email po wygaśnięciu.
  static const accountEmail = 'account_email';

  /// Hasło konta (po upgrade z anonimowego do email/password).
  /// Szyfrowane przez Android Keystore / iOS Keychain — bezpieczne jak userId.
  static const accountPassword = 'account_password';
}

/// Bezpieczny magazyn dla danych wrażliwych.
///
/// Android: EncryptedSharedPreferences (Android Keystore AES-256)
/// iOS:     Keychain (SecItemAdd/SecItemCopyMatching)
///
/// Różnica vs SharedPreferences:
/// SharedPreferences → /data/data/com.app/shared_prefs/*.xml (plaintext, root-readable)
/// SecureStorage     → Android Keystore (hardware-backed na API 23+, software fallback niżej)
///
/// Odczyt lokalnego cache Pro (RevenueCat offline).
class ProCacheSnapshot {
  const ProCacheSnapshot({
    required this.isProUnlocked,
    required this.cachedAt,
    required this.isStale,
  });

  final bool isProUnlocked;
  final DateTime? cachedAt;
  final bool isStale;
}

/// Boot recovery: [BootReceiver] rejestruje pluginy przez GeneratedPluginRegistrant,
/// więc ten magazyn jest dostępny w headless engine tak jak w normalnym procesie.
class SecureStorageService {
  SecureStorageService() : _storage = _buildStorage();

  final FlutterSecureStorage _storage;

  static FlutterSecureStorage _buildStorage() {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(
        keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        // Dane dostępne po pierwszym odblokowaniu urządzenia (nie przy blokadzie)
        // Właściwe dla alarmu który odpala się gdy urządzenie jest zablokowane
      ),
    );
  }

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<bool> containsKey(String key) => _storage.containsKey(key: key);

  /// Czyści WSZYSTKIE wpisy — tylko przy wylogowaniu / resecie aplikacji.
  Future<void> deleteAll() => _storage.deleteAll();

  // ── Typed helpers ───────────────────────────────────────────────────────────

  Future<String?> getUserId() => read(SecureKeys.userId);

  Future<void> setUserId(String userId) => write(SecureKeys.userId, userId);

  Future<void> clearUserId() => delete(SecureKeys.userId);

  /// Odczyt cache Pro z timestampem; brak `pro_cached_at` (stare wersje) = [isStale]=true.
  Future<ProCacheSnapshot> getProCacheSnapshot() async {
    final value = await read(SecureKeys.proCached);
    final isPro = value == 'true';
    final atRaw = await read(SecureKeys.proCachedAt);
    DateTime? cachedAt;
    if (atRaw != null && atRaw.isNotEmpty) {
      cachedAt = DateTime.tryParse(atRaw);
    }
    final isStale = cachedAt == null ||
        DateTime.now().difference(cachedAt) > const Duration(days: 7);
    return ProCacheSnapshot(
      isProUnlocked: isPro,
      cachedAt: cachedAt,
      isStale: isStale,
    );
  }

  Future<void> setProCached(bool isActive) async {
    await write(SecureKeys.proCached, isActive.toString());
    await write(
      SecureKeys.proCachedAt,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  // ── Email/password credentials (po upgrade z konta anonimowego) ────────────

  Future<String?> getAccountEmail() => read(SecureKeys.accountEmail);

  Future<String?> getAccountPassword() => read(SecureKeys.accountPassword);

  Future<void> setAccountCredentials({
    required String email,
    required String password,
  }) async {
    await write(SecureKeys.accountEmail, email);
    await write(SecureKeys.accountPassword, password);
  }

  Future<bool> hasEmailCredentials() async {
    final email = await getAccountEmail();
    final password = await getAccountPassword();
    return email != null && password != null;
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

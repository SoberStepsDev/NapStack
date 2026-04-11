import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../../core/appwrite/appwrite_error_handler.dart';
import '../../core/security/secure_storage_service.dart';

/// Zarządza sesją Appwrite — anonimową lub email/password (po upgrade Pro).
///
/// Przepływ sesji:
/// 1. Pierwsze uruchomienie → createAnonymousSession() → userId zapisany w SecureStorage.
/// 2. Zakup Pro → upgradeToEmailAccount() → email+password zapisane w SecureStorage.
///    Od teraz sesja jest odtwarzalna przez createEmailPasswordSession().
/// 3. Wygaśnięcie sesji (401 na account.get()):
///    a. Ma credentials email → createEmailPasswordSession() → TEN SAM userId, RLS działa.
///    b. Brak credentials (konto anonimowe) → createAnonymousSession() (nowy userId,
///       dane niedostępne przez RLS — to ograniczenie kont anonimowych bez email).
class AuthService {
  AuthService(this._account, this._storage);

  final Account _account;
  final SecureStorageService _storage;

  /// Inicjalizuje sesję. Wywołać w main() przed runApp().
  Future<String> initSession() async {
    // Rejestruj handler odtwarzania sesji przy każdej inicjalizacji
    SessionRecovery.register(_reinitSession);

    // Sprawdź czy bieżąca sesja Appwrite jest aktywna
    try {
      final user = await _account.get();
      await _storage.setUserId(user.$id);
      return user.$id;
    } on AppwriteException catch (e) {
      if (e.code != 401) {
        throw ServerException(e.message ?? 'Auth error', originalError: e);
      }
      // 401 = brak aktywnej sesji
    }

    // Sesja wygasła — sprawdź czy mamy credentials do odtworzenia
    final cachedId = await _storage.getUserId();

    if (cachedId != null) {
      // Próbuj odtworzyć sesję dla TEGO SAMEGO userId.
      // Jeśli konto ma email/password → createEmailPasswordSession zachowuje userId
      // i RLS (Role.user(cachedId)) działa poprawnie.
      final email = await _storage.getAccountEmail();
      final password = await _storage.getAccountPassword();

      if (email != null && password != null) {
        try {
          await AppwriteErrorHandler.runWithRetry(
            () => _account.createEmailPasswordSession(
              email: email,
              password: password,
            ),
            resource: 'email_session_restore',
          );
          // Sesja odtworzona dla oryginalnego userId — RLS działa.
          await _storage.setUserId(cachedId);
          return cachedId;
        } on AppwriteException catch (e) {
          if (e.code == 401 || e.code == 400) {
            // Złe credentials (zmienione hasło?) — wyczyść i utwórz nową sesję
            await _storage.delete(SecureKeys.accountEmail);
            await _storage.delete(SecureKeys.accountPassword);
          }
          // Fallthrough do createAnonymousSession poniżej
        } catch (_) {
          // Brak sieci lub inny błąd — fallthrough
        }
      }

      // Brak credentials email lub błąd odtworzenia.
      // Konto anonimowe — nie możemy odtworzyć sesji dla tego samego userId.
      // Tworzymy nową sesję anonimową (nowy userId) — dane starego konta
      // są niedostępne przez RLS. To jest znane ograniczenie kont anonimowych.
      try {
        await AppwriteErrorHandler.runWithRetry(
          () => _account.createAnonymousSession(),
          resource: 'anonymous_session',
        );
        // Celowo NIE aktualizujemy cachedId — zachowujemy oryginalny userId
        // na wypadek gdyby sieć była dostępna i dane były dostępne przez inne
        // mechanizmy (np. po upgrade do email w tej sesji).
        return cachedId;
      } catch (_) {
        // Brak sieci — zwróć cachedId, UI pokaże dane z lokalnego cache
        return cachedId;
      }
    }

    return _createFreshAnonymousSession();
  }

  /// Backward-compatible alias — zachowany dla istniejących wywołań w auth_provider.
  Future<String> initAnonymousSession() => initSession();

  Future<String> _createFreshAnonymousSession() async {
    final session = await AppwriteErrorHandler.runWithRetry(
      () => _account.createAnonymousSession(),
      resource: 'anonymous_session',
    );
    await _storage.setUserId(session.userId);
    return session.userId;
  }

  Future<void> _reinitSession() async {
    await _storage.clearUserId();
    await initSession();
  }

  Future<models.User> getCurrentUser() => AppwriteErrorHandler.run(
        () => _account.get(),
        resource: 'current_user',
      );

  /// Upgrade konta anonimowego do email/password.
  ///
  /// Zachowuje bieżący userId — wszystkie dane w Appwrite pozostają dostępne.
  /// Po upgrade: sesja jest odtwarzalna przez createEmailPasswordSession,
  /// więc wygaśnięcie sesji nie powoduje utraty dostępu do danych (RLS działa).
  ///
  /// Credentials są zapisywane w SecureStorage (AES-256 / Keychain) —
  /// używane automatycznie przy następnym wygaśnięciu sesji.
  Future<void> upgradeToEmailAccount({
    required String email,
    required String password,
  }) async {
    await AppwriteErrorHandler.run(
      () => _account.updateEmail(email: email, password: password),
      resource: 'account_email_upgrade',
    );
    // Zapisz credentials — umożliwia odtworzenie sesji po wygaśnięciu.
    await _storage.setAccountCredentials(email: email, password: password);
  }

  Future<void> signOut() async {
    await AppwriteErrorHandler.run(
      () => _account.deleteSession(sessionId: 'current'),
      resource: 'session',
    );
    await _storage.deleteAll();
  }
}

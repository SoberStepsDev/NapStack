import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../../core/appwrite/appwrite_error_handler.dart';
import '../../core/security/secure_storage_service.dart';

/// Zarządza anonimowym kontem Appwrite.
///
/// Zmiany bezpieczeństwa v1→v2:
/// - userId przechowywany w flutter_secure_storage (AES-256 / Android Keystore)
///   zamiast SharedPreferences (plaintext XML).
/// - Rejestruje SessionRecovery.handler — błąd 401 w dowolnym serwisie
///   automatycznie wywołuje reinicjalizację sesji.
/// - Sesja anonimowa: żadne PII nie trafia do Appwrite. userId to losowy UUID.
class AuthService {
  AuthService(this._account, this._storage);

  final Account _account;
  final SecureStorageService _storage;

  /// Inicjalizuje sesję anonimową. Wywołać w main() przed runApp().
  Future<String> initAnonymousSession() async {
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

    // Sprawdź cache w secure storage
    final cachedId = await _storage.getUserId();

    if (cachedId != null) {
      // Cache istnieje — sesja wygasła. Tworzymy nową sesję anonimową (nowe konto),
      // ale zachowujemy cachedId jako identyfikator użytkownika w tej apce.
      // Nowa sesja służy tylko do autoryzacji HTTP — NIE nadpisujemy cachedId.
      // Dane w Appwrite są przypisane do cachedId i pozostają dostępne.
      //
      // OGRANICZENIE: Appwrite RLS używa Role.user(cachedId) na rekordach.
      // Nowa sesja anonimowa ma inny auth.uid() — Appwrite zwróci 403 przy
      // próbie odczytu/zapisu rekordów starego użytkownika.
      // Jedyne pełne rozwiązanie: upgrade do email/password przy zakupie Pro
      // (account.updateEmail) — wtedy userId pozostaje stały między sesjami.
      // W v1 (konta anonimowe) utrata sesji = utrata dostępu do danych.
      // Docelowo: upgrade do email/password przy zakupie Pro.
      try {
        await AppwriteErrorHandler.runWithRetry(
          () => _account.createAnonymousSession(),
          resource: 'anonymous_session',
        );
        // Celowo NIE aktualizujemy cachedId — zachowujemy oryginalny userId.
        return cachedId;
      } catch (_) {
        // Brak sieci — zwróć cachedId, UI pokaże dane z lokalnego cache
        return cachedId;
      }
    }

    return _createFreshSession();
  }

  Future<String> _createFreshSession() async {
    final session = await AppwriteErrorHandler.runWithRetry(
      () => _account.createAnonymousSession(),
      resource: 'anonymous_session',
    );
    await _storage.setUserId(session.userId);
    return session.userId;
  }

  Future<void> _reinitSession() async {
    await _storage.clearUserId();
    await initAnonymousSession();
  }

  Future<models.User> getCurrentUser() => AppwriteErrorHandler.run(
        () => _account.get(),
        resource: 'current_user',
      );

  /// Upgrade konta anonimowego do email — zachowuje userId i wszystkie dane.
  /// Wywołać opcjonalnie przy zakupie Pro (umożliwia przywrócenie danych po reinstalacji).
  Future<void> upgradeToEmailAccount({
    required String email,
    required String password,
  }) async {
    await AppwriteErrorHandler.run(
      () => _account.updateEmail(email: email, password: password),
      resource: 'account_email_upgrade',
    );
  }

  Future<void> signOut() async {
    await AppwriteErrorHandler.run(
      () => _account.deleteSession(sessionId: 'current'),
      resource: 'session',
    );
    await _storage.deleteAll();
  }
}

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
      // Cache istnieje — sesja wygasła po restarcie / dłuższej nieaktywności.
      // Utwórz nową anonimową sesję. WAŻNE: nowe konto anonimowe = nowy userId.
      // Dane w Appwrite są przypisane do STAREGO userId — utrata danych.
      //
      // Rozwiązanie docelowe (poza v1): upgrade konta do email/password
      // przy pierwszym uruchomieniu Pro, by mieć stały, przywracanry userId.
      return _createFreshSession();
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

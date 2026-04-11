import 'dart:async';
import 'dart:io';

import 'package:appwrite/appwrite.dart';

/// Mapowanie kodów błędów Appwrite na domenowe wyjątki NapStack.
///
/// Warstwa tłumaczy surowe `AppwriteException` (HTTP code + type string)
/// na typy które UI i Notifery mogą obsługiwać bez znajomości Appwrite.
sealed class NapStackException implements Exception {
  const NapStackException(this.message, {this.originalError});
  final String message;
  final Object? originalError;

  @override
  String toString() => '$runtimeType: $message';
}

/// Brak sesji lub wygasła — wymagane ponowne logowanie.
final class UnauthenticatedException extends NapStackException {
  const UnauthenticatedException({super.originalError})
      : super('Sesja wygasła. Ponowna inicjalizacja...');
}

/// Brak uprawnień do zasobu — naruszenie izolacji danych.
final class ForbiddenException extends NapStackException {
  const ForbiddenException({super.originalError})
      : super('Brak uprawnień do tego zasobu.');
}

/// Zasób nie istnieje — może być już usunięty.
final class NotFoundException extends NapStackException {
  const NotFoundException(String resource, {super.originalError})
      : super('Nie znaleziono: $resource');
}

/// Konflikt — próba tworzenia istniejącego zasobu.
final class ConflictException extends NapStackException {
  const ConflictException(String resource, {super.originalError})
      : super('Konflikt: $resource już istnieje');
}

/// Rate limit — zbyt wiele requestów.
final class RateLimitException extends NapStackException {
  const RateLimitException({super.originalError})
      : super('Za dużo requestów. Spróbuj za chwilę.');
}

/// Brak połączenia internetowego.
final class OfflineException extends NapStackException {
  const OfflineException({super.originalError})
      : super('Brak połączenia. Dane zostaną zsynchronizowane gdy sieć wróci.');
}

/// Nieznany błąd serwera.
final class ServerException extends NapStackException {
  const ServerException(String detail, {super.originalError})
      : super('Błąd serwera: $detail');
}

// ── Error Handler ─────────────────────────────────────────────────────────────

/// Centralna obsługa błędów Appwrite.
///
/// Użycie:
///   final result = await AppwriteErrorHandler.run(
///     () => db.createRow(...),
///     resource: 'nap_sessions',
///   );
abstract final class AppwriteErrorHandler {
  /// Wykonuje [operation] i mapuje wyjątki na [NapStackException].
  /// Automatycznie retryuje przy rate limit (429) i transient network errors.
  static Future<T> run<T>(
    Future<T> Function() operation, {
    String resource = 'resource',
    int maxRetries = 3,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await operation();
      } on AppwriteException catch (e) {
        final mapped = _mapAppwriteException(e, resource);
        if (mapped is UnauthenticatedException) {
          // Próba odtworzenia sesji — jeśli się uda, powtarzamy operację raz.
          await SessionRecovery.recover();
          if (attempt < maxRetries) {
            attempt++;
            continue;
          }
        }
        throw mapped;
      } on SocketException catch (e) {
        throw OfflineException(originalError: e);
      } on TimeoutException catch (e) {
        if (attempt >= maxRetries) throw OfflineException(originalError: e);
        await _backoff(attempt++);
      } on NapStackException {
        rethrow; // już zmapowany — nie owijaj ponownie
      } catch (e) {
        throw ServerException(e.toString(), originalError: e);
      }
    }
  }

  /// Wykonuje [operation] z retry wyłącznie przy RateLimitException i sieciowych.
  static Future<T> runWithRetry<T>(
    Future<T> Function() operation, {
    String resource = 'resource',
    int maxRetries = 3,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await run(operation, resource: resource);
      } on RateLimitException {
        if (attempt >= maxRetries) rethrow;
        await _backoff(attempt++, base: const Duration(seconds: 2));
      } on OfflineException {
        if (attempt >= maxRetries) rethrow;
        await _backoff(attempt++, base: const Duration(seconds: 3));
      }
    }
  }

  static NapStackException _mapAppwriteException(
      AppwriteException e, String resource) {
    return switch (e.code) {
      401 => UnauthenticatedException(originalError: e),
      403 => ForbiddenException(originalError: e),
      404 => NotFoundException(resource, originalError: e),
      409 => ConflictException(resource, originalError: e),
      429 => RateLimitException(originalError: e),
      _ when e.code != null && e.code! >= 500 =>
        ServerException('${e.code}: ${e.message}', originalError: e),
      _ => ServerException(e.message ?? 'Nieznany błąd', originalError: e),
    };
  }

  static Future<void> _backoff(
    int attempt, {
    Duration base = const Duration(milliseconds: 500),
  }) async {
    final delay = base * (1 << attempt.clamp(0, 5)); // max ~16s
    await Future<void>.delayed(delay);
  }
}

// ── Session Recovery ──────────────────────────────────────────────────────────

/// Callback wywoływany gdy wykryto wygasłą sesję (401).
/// AuthService powinien zarejestrować się tutaj przy starcie.
abstract final class SessionRecovery {
  static Future<void> Function()? _onSessionExpired;

  static void register(Future<void> Function() handler) {
    _onSessionExpired = handler;
  }

  /// Wywołuje handler odtwarzania sesji jeśli zarejestrowany.
  static Future<void> recover() async {
    await _onSessionExpired?.call();
  }
}

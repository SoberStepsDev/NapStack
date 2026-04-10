import 'package:appwrite/appwrite.dart';

/// Centralne budowanie uprawnień Appwrite dla NapStack.
///
/// Zasady bezpieczeństwa:
/// 1. Żaden rekord nie jest publiczny (Role.any() zakazany dla danych użytkownika).
/// 2. Każdy rekord należy do dokładnie jednego użytkownika (Role.user(userId)).
/// 3. Kolekcja ma `Permission.create(Role.users())` — tworzenie wymaga sesji.
/// 4. user_prefs: brak `Permission.delete` — rekord jest trwały.
/// 5. Nie ma Permission.write() — używamy granularnych read/update/delete.
///
/// Dlaczego centralizacja:
/// - Jedna zmiana tutaj aktualizuje uprawnienia w całej apce.
/// - Łatwe audytowanie — wszystkie uprawnienia w jednym pliku.
/// - Zapobiega przypadkowemu `Role.any()` na danych zdrowotnych.
abstract final class PermissionsHelper {
  /// Uprawnienia dla sesji drzemek i elementów NapStack.
  /// Właściciel może: czytać, aktualizować, usuwać.
  static List<String> ownerFullAccess(String userId) => [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ];

  /// Uprawnienia dla user_prefs — bez delete (rekord trwały).
  static List<String> ownerReadUpdate(String userId) => [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
      ];

  /// Uprawnienia tylko do odczytu — np. publiczne zasoby statyczne (nie używane w v1).
  static List<String> readOnly(String userId) => [
        Permission.read(Role.user(userId)),
      ];
}

/// Rozszerzenie — weryfikuje czy userId jest prawidłowy przed zbudowaniem uprawnień.
/// Rzuca [InvalidUserIdException] jeśli userId jest pusty lub za krótki (wskazuje na
/// niezainicjalizowaną sesję Appwrite).
extension PermissionsHelperSafe on PermissionsHelper {
  static List<String> ownerFullAccessSafe(String userId) {
    _assertValidUserId(userId);
    return PermissionsHelper.ownerFullAccess(userId);
  }

  static List<String> ownerReadUpdateSafe(String userId) {
    _assertValidUserId(userId);
    return PermissionsHelper.ownerReadUpdate(userId);
  }

  static void _assertValidUserId(String userId) {
    if (userId.isEmpty || userId.length < 8) {
      throw InvalidUserIdException(userId);
    }
  }
}

class InvalidUserIdException implements Exception {
  const InvalidUserIdException(this.userId);
  final String userId;

  @override
  String toString() =>
      'InvalidUserId: userId "$userId" jest nieprawidłowy. '
      'Czy AuthService.initAnonymousSession() został wywołany?';
}

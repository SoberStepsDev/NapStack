import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart' as models;

import '../../core/appwrite/appwrite_client.dart';
import '../../core/security/secure_storage_service.dart';
import 'auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(appwriteAccountProvider),
    ref.watch(secureStorageProvider),
  );
});

/// Inicjalizacja sesji — blokuje runApp() do rozwiązania.
/// Wynik: userId jako String.
final authInitProvider = FutureProvider<String>((ref) async {
  return ref.read(authServiceProvider).initAnonymousSession();
});

/// Aktualnie zalogowany użytkownik.
final currentUserProvider = FutureProvider<models.User>((ref) async {
  await ref.watch(authInitProvider.future);
  return ref.read(authServiceProvider).getCurrentUser();
});

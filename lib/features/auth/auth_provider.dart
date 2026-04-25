import 'dart:async';

import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// [TimeoutException] po 5s: użyj ostatniego [SecureStorageService] userId (praca lokalna),
/// inaczej błąd (ekran „Spróbuj ponownie” w [NapStackApp]).
final authInitProvider = FutureProvider<String>((ref) async {
  final auth = ref.read(authServiceProvider);
  final storage = ref.read(secureStorageProvider);
  try {
    return await auth.initAnonymousSession().timeout(const Duration(seconds: 5));
  } on TimeoutException {
    final cached = await storage.getUserId();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    throw TimeoutException(
      'Brak odpowiedzi Appwrite w 5s i brak zapisanego userId',
      const Duration(seconds: 5),
    );
  }
});

/// Aktualnie zalogowany użytkownik.
final currentUserProvider = FutureProvider<models.User>((ref) async {
  await ref.watch(authInitProvider.future);
  return ref.read(authServiceProvider).getCurrentUser();
});

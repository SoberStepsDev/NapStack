import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'auth_service.dart';

/// Stan procesu upgrade konta anonimowego do email/password.
sealed class AccountUpgradeState {
  const AccountUpgradeState();
}

class AccountUpgradeIdle extends AccountUpgradeState {
  const AccountUpgradeIdle();
}

class AccountUpgradeLoading extends AccountUpgradeState {
  const AccountUpgradeLoading();
}

class AccountUpgradeSuccess extends AccountUpgradeState {
  const AccountUpgradeSuccess();
}

class AccountUpgradeError extends AccountUpgradeState {
  const AccountUpgradeError(this.message);
  final String message;
}

/// Zarządza opcjonalnym upgrade konta po zakupie Pro.
///
/// Upgrade jest dobrowolny — użytkownik może pominąć.
/// Po sukcesie: anonimowy userId staje się trwale powiązany z emailem,
/// co umożliwia przywrócenie danych po reinstalacji lub zmianie urządzenia.
///
/// Appwrite pod spodem: account.updateEmail() zachowuje bieżący userId
/// i wszystkie powiązane rekordy w Appwrite (nap_sessions, nap_stack, user_prefs).
class AccountUpgradeNotifier extends Notifier<AccountUpgradeState> {
  @override
  AccountUpgradeState build() => const AccountUpgradeIdle();

  AuthService get _auth => ref.read(authServiceProvider);

  Future<void> upgrade({
    required String email,
    required String password,
  }) async {
    if (state is AccountUpgradeLoading) return;

    state = const AccountUpgradeLoading();

    try {
      await _auth.upgradeToEmailAccount(email: email, password: password);
      state = const AccountUpgradeSuccess();
    } catch (e) {
      // Mapujemy typowe błędy Appwrite na komunikaty przyjazne użytkownikowi.
      final msg = _mapError(e);
      state = AccountUpgradeError(msg);
    }
  }

  void reset() => state = const AccountUpgradeIdle();

  static String _mapError(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('already') || raw.contains('409')) {
      return 'Ten email jest już przypisany do innego konta. Wybierz inny.';
    }
    if (raw.contains('invalid') || raw.contains('400')) {
      return 'Nieprawidłowy adres email lub hasło (min. 8 znaków).';
    }
    if (raw.contains('network') || raw.contains('offline')) {
      return 'Brak połączenia. Sprawdź internet i spróbuj ponownie.';
    }
    return 'Błąd: $e';
  }
}

final accountUpgradeProvider =
    NotifierProvider<AccountUpgradeNotifier, AccountUpgradeState>(
        AccountUpgradeNotifier.new);

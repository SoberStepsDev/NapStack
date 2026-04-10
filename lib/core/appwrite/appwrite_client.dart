import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'appwrite_constants.dart';

/// Globalny klient Appwrite — endpoint i project z [kAppwriteEndpoint] / [kAppwriteProjectId]
/// (domyślnie Fra Cloud + projekt NapStack; nadpisuj przez --dart-define / plik lokalny).
final Client client = Client()
    .setProject(kAppwriteProjectId)
    .setEndpoint(kAppwriteEndpoint)
    .setSelfSigned(status: false);

/// Ten sam klient w Riverpodzie (Account, TablesDB, Realtime).
final appwriteClientProvider = Provider<Client>((ref) => client);

/// Gotowe instancje serwisów Appwrite — wstrzykiwane przez Riverpod.
final appwriteAccountProvider = Provider<Account>((ref) {
  return Account(ref.watch(appwriteClientProvider));
});

final appwriteTablesDBProvider = Provider<TablesDB>((ref) {
  return TablesDB(ref.watch(appwriteClientProvider));
});

final appwriteRealtimeProvider = Provider<Realtime>((ref) {
  return Realtime(ref.watch(appwriteClientProvider));
});

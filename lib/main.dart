import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/keys/napstack_messenger_key.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/auth_provider.dart';
import 'features/boot_recovery/boot_channel_handler.dart';
import 'features/pro/purchase_service.dart';
import 'features/sync/sync_service.dart';
import 'features/timer/alarm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kanał boot recovery zaraz po bindingu (przed await), żeby headless BootReceiver
  // nie wyścigał z `invokeMethod` na niezarejestrowanym kanale.
  registerBootRecoveryChannel();

  // Wymuszaj tryb portretowy
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI — przeźroczysty pasek stanu, ciemne tło
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF111827),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Alarm Service — timezone + FLN
  await AlarmService.init();

  runApp(const ProviderScope(child: NapStackApp()));
}

class NapStackApp extends ConsumerWidget {
  const NapStackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicjalizacja sesji Appwrite — blokuje do pierwszego userId
    final authState = ref.watch(authInitProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: napstackMessengerKey,
      title: 'NapStack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
      builder: (context, child) {
        // Obsługa stanu auth — splash / error / app
        return authState.when(
          loading: () => const _SplashScreen(),
          error: (e, _) => _AuthErrorScreen(error: e.toString()),
          data: (userId) => _AppReady(userId: userId, child: child!),
        );
      },
    );
  }
}

/// Montuje serwisy wymagające aktywnej sesji
class _AppReady extends ConsumerStatefulWidget {
  const _AppReady({required this.userId, required this.child});
  final String userId;
  final Widget child;

  @override
  ConsumerState<_AppReady> createState() => _AppReadyState();
}

class _AppReadyState extends ConsumerState<_AppReady> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // ignore: discarded_futures
        _postAuthInit();
      }
    });
  }

  Future<void> _postAuthInit() async {
    final l10n = AppLocalizations.of(context);

    // Konfiguracja RevenueCat z aktualnym userId
    await PurchaseService.configure(widget.userId);

    AlarmService.onExactAlarmPermissionDenied = () {
      napstackMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.alarmExactPermissionSnack)),
      );
    };

    // Uprawnienia runtime — POST_NOTIFICATIONS (API 33+) i USE_FULL_SCREEN_INTENT (API 34+).
    final notifOk = await AlarmService.requestRuntimePermissions();
    if (mounted && !notifOk) {
      final messages = AppLocalizations.of(context);
      napstackMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(messages.notificationsDisabledSnack)),
      );
    }

    // Realtime sync — startuje subskrypcje Appwrite
    ref.read(syncListenerProvider);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ── Ekrany pomocnicze ─────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF070B16),
        body: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: Color(0xFF60C5FF),
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthErrorScreen extends StatelessWidget {
  const _AuthErrorScreen({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    color: Color(0xFF8899BB), size: 48),
                const SizedBox(height: 20),
                Text(
                  'Błąd połączenia',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sprawdź połączenie z internetem\ni uruchom aplikację ponownie.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

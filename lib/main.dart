import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'services/app_state.dart';
import 'services/native_bridge.dart';
import 'screens/onboarding_screen.dart';
import 'screens/permission_screen.dart';
import 'screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  await appState.init();

  // Avvia l'ascolto delle notifiche reali (solo su Android, no-op su web)
  NativeBridge.startListening(appState);

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(SuperNotifyApp(
    appState: appState,
    onboardingDone: onboardingDone,
  ));
}

class SuperNotifyApp extends StatefulWidget {
  final AppState appState;
  final bool onboardingDone;
  const SuperNotifyApp({
    super.key,
    required this.appState,
    required this.onboardingDone,
  });

  @override
  State<SuperNotifyApp> createState() => _SuperNotifyAppState();
}

class _SuperNotifyAppState extends State<SuperNotifyApp>
    with WidgetsBindingObserver {
  Timer? _watchdog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // All'avvio: verifica che il servizio sia attivo e, se necessario,
    // lo riavvia automaticamente (importante su Xiaomi/MIUI).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NativeBridge.ensureServiceRunning();
    });
    _startWatchdog();
  }

  /// Controllo periodico ("watchdog"): mentre l'app è aperta, ogni 30s
  /// verifica che il servizio sia connesso e lo riavvia se è caduto.
  void _startWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer.periodic(const Duration(seconds: 30), (_) {
      NativeBridge.ensureServiceRunning();
    });
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Quando l'utente riapre l'app, controlla e riavvia il servizio
      // se il sistema lo aveva ucciso in background.
      NativeBridge.ensureServiceRunning();
      _startWatchdog();
    } else if (state == AppLifecycleState.paused) {
      // Sospendi il watchdog quando l'app è in background per non sprecare batteria
      _watchdog?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.appState,
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'SuperNotify AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            home: _startScreen(state),
          );
        },
      ),
    );
  }

  Widget _startScreen(AppState state) {
    if (!widget.onboardingDone) return const OnboardingScreen();
    if (!state.listenerPermissionGranted) return const PermissionScreen();
    return const HomeShell();
  }
}

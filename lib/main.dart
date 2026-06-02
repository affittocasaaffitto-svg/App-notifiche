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

class SuperNotifyApp extends StatelessWidget {
  final AppState appState;
  final bool onboardingDone;
  const SuperNotifyApp({
    super.key,
    required this.appState,
    required this.onboardingDone,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
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
    if (!onboardingDone) return const OnboardingScreen();
    if (!state.listenerPermissionGranted) return const PermissionScreen();
    return const HomeShell();
  }
}

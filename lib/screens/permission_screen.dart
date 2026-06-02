import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/native_bridge.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'home_shell.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final granted = state.listenerPermissionGranted;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.mainGradient,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Accesso alle notifiche',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              Text(
                'Per leggere, filtrare e classificare le notifiche, '
                'SuperNotify AI ha bisogno dell\'accesso al servizio notifiche di Android.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 28),
              GradientCard(
                child: Column(
                  children: const [
                    _PrivacyRow(
                      icon: Icons.lock_rounded,
                      text: 'Tutto resta sul tuo dispositivo, nessun dato inviato.',
                    ),
                    SizedBox(height: 14),
                    _PrivacyRow(
                      icon: Icons.auto_awesome_rounded,
                      text: 'Classificazione AI elaborata localmente.',
                    ),
                    SizedBox(height: 14),
                    _PrivacyRow(
                      icon: Icons.visibility_off_rounded,
                      text: 'Puoi revocare l\'accesso quando vuoi.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Stato permesso in tempo reale
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (granted ? AppColors.tagGroup : AppColors.tagPromo)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      granted
                          ? Icons.check_circle_rounded
                          : Icons.info_rounded,
                      color: granted ? AppColors.tagGroup : AppColors.tagPromo,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        granted
                            ? 'Accesso attivo. Tutto pronto!'
                            : 'Accesso non ancora attivo',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              granted ? AppColors.tagGroup : AppColors.tagPromo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!granted)
                GradientButton(
                  label: 'Attiva Accesso Notifiche',
                  icon: Icons.notifications_active_rounded,
                  onPressed: () async {
                    // Su dispositivo reale apre le impostazioni di sistema.
                    await NativeBridge.openSettings();
                    final granted = await NativeBridge.isPermissionGranted();
                    if (!context.mounted) return;
                    // In preview/web abilitiamo comunque per la demo.
                    context.read<AppState>().grantPermission();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(granted
                            ? 'Accesso alle notifiche attivato!'
                            : 'Modalità demo attiva. Su dispositivo si aprono le Impostazioni di sistema.'),
                      ),
                    );
                  },
                )
              else
                GradientButton(
                  label: 'Continua',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeShell()),
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PrivacyRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13.5, height: 1.4)),
        ),
      ],
    );
  }
}

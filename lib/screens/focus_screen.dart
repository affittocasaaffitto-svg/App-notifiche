import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final on = state.focusModeOn;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: on
              ? const LinearGradient(
                  colors: [Color(0xFF1B1B2E), Color(0xFF2D2150)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),
              Text('Modalità Focus',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: on ? Colors.white : null)),
              const SizedBox(height: 4),
              Text(
                on
                    ? 'Le notifiche sono in pausa. Goditi la concentrazione.'
                    : 'Blocca le distrazioni e concentrati su ciò che conta.',
                style: TextStyle(
                    color: on ? Colors.white70 : Colors.grey[600],
                    fontSize: 13.5),
              ),
              const SizedBox(height: 28),
              // Cerchio centrale animato
              Center(
                child: GestureDetector(
                  onTap: () => state.setFocusMode(!on),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: on
                          ? AppColors.mainGradient
                          : LinearGradient(colors: [
                              Colors.grey.withValues(alpha: 0.2),
                              Colors.grey.withValues(alpha: 0.1)
                            ]),
                      boxShadow: on
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.secondary.withValues(alpha: 0.5),
                                blurRadius: 50,
                                spreadRadius: 4,
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          on
                              ? Icons.do_not_disturb_on_rounded
                              : Icons.do_not_disturb_off_rounded,
                          size: 64,
                          color: on ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          on ? 'ATTIVO' : 'SPENTO',
                          style: TextStyle(
                            color: on ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Timer
              _section('Durata', on),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [15, 30, 60].map((m) {
                  final sel = state.focusDurationMin == m;
                  return ChoiceChip(
                    label: Text('$m min'),
                    selected: sel,
                    selectedColor: AppColors.primary,
                    backgroundColor:
                        on ? Colors.white.withValues(alpha: 0.1) : null,
                    labelStyle: TextStyle(
                        color: sel
                            ? Colors.white
                            : (on ? Colors.white70 : Colors.grey[700]),
                        fontWeight: FontWeight.w600),
                    onSelected: (_) => state.setFocusDuration(m),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Eccezioni
              _section('Eccezioni (passano comunque)', on),
              const SizedBox(height: 10),
              _exceptionTile(context, on, 'Famiglia', Icons.favorite_rounded,
                  state.focusAllowFamily, 'family'),
              _exceptionTile(context, on, 'Lavoro', Icons.work_rounded,
                  state.focusAllowWork, 'work'),
              _exceptionTile(context, on, 'Preferiti', Icons.star_rounded,
                  state.focusAllowFavorites, 'favorites'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String text, bool on) => Text(text,
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: on ? Colors.white : null));

  Widget _exceptionTile(BuildContext context, bool on, String label,
      IconData icon, bool value, String key) {
    final state = context.read<AppState>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: on
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: on
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: on ? Colors.white : null)),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: (v) => state.setFocusException(key, v),
          ),
        ],
      ),
    );
  }
}

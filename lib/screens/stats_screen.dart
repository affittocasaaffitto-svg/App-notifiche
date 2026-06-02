import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final stress = state.stressPerApp().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final perApp = state.notifPerApp().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final perHour = state.notifPerHour();

    // Trova orario più disturbato
    int peakHour = 0;
    int peakVal = 0;
    for (int h = 0; h < 24; h++) {
      if (perHour[h] > peakVal) {
        peakVal = perHour[h];
        peakHour = h;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            Text('Statistiche emotive',
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Quanto ti stressano le notifiche',
                style: TextStyle(color: Colors.grey[600], fontSize: 13.5)),
            const SizedBox(height: 20),

            // Suggerimento AI
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.softGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Suggerimento AI',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          _aiSuggestion(stress, peakHour),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Grafico stress per app
            Text('Stress per app',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GradientCard(
              child: Column(
                children: stress.take(6).map((e) {
                  final v = e.value / 100;
                  final color = v > 0.7
                      ? AppColors.tagHigh
                      : v > 0.5
                          ? AppColors.tagPromo
                          : AppColors.tagGroup;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(e.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            const Spacer(),
                            Text('${e.value.round()}',
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: v,
                            minHeight: 8,
                            backgroundColor:
                                Colors.grey.withValues(alpha: 0.12),
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Orari più disturbati
            Text('Orari più disturbati',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GradientCard(
              child: SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (perHour.reduce((a, b) => a > b ? a : b) + 1)
                        .toDouble(),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 4,
                          getTitlesWidget: (v, _) {
                            final h = v.toInt();
                            if (h % 4 != 0) return const SizedBox();
                            return Text('${h}h',
                                style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(24, (h) {
                      return BarChartGroupData(x: h, barRods: [
                        BarChartRodData(
                          toY: perHour[h].toDouble(),
                          width: 6,
                          borderRadius: BorderRadius.circular(3),
                          gradient: AppColors.mainGradient,
                        ),
                      ]);
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '⏰ Picco alle ${peakHour.toString().padLeft(2, '0')}:00',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),

            // Classifica app più invasive
            Text('App più invasive',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...perApp.take(5).toList().asMap().entries.map((e) {
              final rank = e.key + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GradientCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: AppColors.mainGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('$rank',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(e.value.key,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                      Text('${e.value.value} notifiche',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12.5)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            // Link impostazioni
            Center(
              child: TextButton.icon(
                onPressed: () => _showSettings(context),
                icon: const Icon(Icons.settings_rounded, size: 18),
                label: const Text('Impostazioni & Tema'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _aiSuggestion(List<MapEntry<String, double>> stress, int peakHour) {
    if (stress.isEmpty) return 'Non ci sono ancora abbastanza dati.';
    final top = stress.first;
    return 'L\'app "${top.key}" genera lo stress più alto. '
        'Considera una regola per silenziarla fuori orario. '
        'Il momento più disturbato è verso le ${peakHour.toString().padLeft(2, '0')}:00 — '
        'prova la Modalità Focus in quella fascia.';
  }

  void _showSettings(BuildContext context) {
    final state = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tema',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Consumer<AppState>(
              builder: (_, s, __) => Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('Automatico (sistema)'),
                    value: ThemeMode.system,
                    groupValue: s.themeMode,
                    activeColor: AppColors.primary,
                    onChanged: (v) => state.setThemeMode(v!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Chiaro'),
                    value: ThemeMode.light,
                    groupValue: s.themeMode,
                    activeColor: AppColors.primary,
                    onChanged: (v) => state.setThemeMode(v!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Scuro'),
                    value: ThemeMode.dark,
                    groupValue: s.themeMode,
                    activeColor: AppColors.primary,
                    onChanged: (v) => state.setThemeMode(v!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final summary = state.summaryNotifications;
    final perApp = <String, int>{};
    for (final n in summary) {
      perApp[n.appName] = (perApp[n.appName] ?? 0) + 1;
    }
    final entries = perApp.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            Text('Riepilogo programmato',
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Aggregato ogni ${state.summaryIntervalMin} minuti',
                style: TextStyle(color: Colors.grey[600], fontSize: 13.5)),
            const SizedBox(height: 20),

            // Card grande con conteggio
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${summary.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w800)),
                      const Text('notifiche filtrate',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.summarize_rounded,
                      color: Colors.white, size: 56),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Selettore intervallo
            GradientCard(
              child: Row(
                children: [
                  const Icon(Icons.timer_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Intervallo riepilogo')),
                  DropdownButton<int>(
                    value: state.summaryIntervalMin,
                    underline: const SizedBox(),
                    items: const [30, 60, 120]
                        .map((m) => DropdownMenuItem(
                            value: m, child: Text('$m min')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) state.setSummaryInterval(v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (entries.isNotEmpty) ...[
              Text('Distribuzione per app',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              GradientCard(
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      sections: _buildSections(entries),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...entries.asMap().entries.map((e) {
                final color = _palette[e.key % _palette.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(e.value.key),
                      const Spacer(),
                      Text('${e.value.value}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 20),

            Text('Notifiche incluse',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...summary.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GradientCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        AppAvatar(
                            emoji: n.appIcon, color: n.appColor, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.sender,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                              Text(n.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.5)),
                            ],
                          ),
                        ),
                        AiTagChip(tag: n.tag, small: true),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  static const _palette = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.tagPromo,
    AppColors.tagGroup,
    AppColors.tagHigh,
    Color(0xFF8C6BFF),
  ];

  List<PieChartSectionData> _buildSections(
      List<MapEntry<String, int>> entries) {
    final total = entries.fold<int>(0, (s, e) => s + e.value);
    return entries.asMap().entries.map((e) {
      final color = _palette[e.key % _palette.length];
      final pct = total == 0 ? 0 : (e.value.value / total * 100).round();
      return PieChartSectionData(
        color: color,
        value: e.value.value.toDouble(),
        title: '$pct%',
        radius: 50,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
      );
    }).toList();
  }
}

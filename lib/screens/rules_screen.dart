import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'rule_editor_screen.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final rules = state.rules;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RuleEditorScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nuova regola',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (b) =>
                        AppColors.mainGradient.createShader(b),
                    child: const Text('Regole personalizzate',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 4),
                  Text('Automazioni IF → THEN per le tue notifiche',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13.5)),
                ],
              ),
            ),
            Expanded(
              child: rules.isEmpty
                  ? _empty(context)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: rules.length,
                      itemBuilder: (_, i) =>
                          _RuleCard(rule: rules[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rule_rounded, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Nessuna regola creata',
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 6),
          Text('Tocca "+" per creare la tua prima automazione',
              style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final NotifRule rule;
  const _RuleCard({required this.rule});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    String actionLabel = rule.actionType.label;
    if (rule.actionType == RuleActionType.delay) {
      actionLabel = 'Ritarda ${rule.delayMinutes} min';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GradientCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.softGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(rule.conditionType.icon,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rule.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15.5)),
                      const SizedBox(height: 2),
                      Text(
                        rule.enabled ? 'Attiva' : 'Disattivata',
                        style: TextStyle(
                          fontSize: 12,
                          color: rule.enabled
                              ? AppColors.tagGroup
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: rule.enabled,
                  activeColor: AppColors.primary,
                  onChanged: (v) => state.toggleRule(rule, v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _badge('SE', AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${rule.conditionType.label}: ${rule.conditionValue}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Icon(Icons.arrow_downward_rounded,
                size: 16, color: Colors.grey[400]),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _badge('ALLORA', AppColors.secondary),
                  const SizedBox(width: 8),
                  Icon(rule.actionType.icon,
                      size: 16, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(actionLabel,
                        style: const TextStyle(fontSize: 12.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => RuleEditorScreen(existing: rule)),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Modifica'),
                ),
                TextButton.icon(
                  onPressed: () => state.deleteRule(rule),
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 16, color: Colors.red),
                  label: const Text('Elimina',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800)),
    );
  }
}

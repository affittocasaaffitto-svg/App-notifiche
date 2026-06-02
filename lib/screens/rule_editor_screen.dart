import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class RuleEditorScreen extends StatefulWidget {
  final NotifRule? existing;
  const RuleEditorScreen({super.key, this.existing});

  @override
  State<RuleEditorScreen> createState() => _RuleEditorScreenState();
}

class _RuleEditorScreenState extends State<RuleEditorScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _valueCtrl;
  RuleConditionType _condType = RuleConditionType.app;
  RuleActionType _actionType = RuleActionType.showNow;
  int _delay = 15;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _valueCtrl = TextEditingController(text: e?.conditionValue ?? '');
    _condType = e?.conditionType ?? RuleConditionType.app;
    _actionType = e?.actionType ?? RuleActionType.showNow;
    _delay = e?.delayMinutes ?? 15;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty || _valueCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compila nome e valore della condizione')),
      );
      return;
    }
    final rule = NotifRule(
      id: widget.existing?.id ??
          'r${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      conditionType: _condType,
      conditionValue: _valueCtrl.text.trim(),
      actionType: _actionType,
      delayMinutes: _delay,
      enabled: widget.existing?.enabled ?? true,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    context.read<AppState>().saveRule(rule);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Regola salvata e applicata ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifica regola' : 'Nuova regola'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Nome
            _label('Nome della regola'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: _inputDecoration('Es. Silenzia promo Amazon',
                  Icons.label_rounded),
            ),
            const SizedBox(height: 24),

            // SE
            Row(
              children: [
                _stepBadge('SE', AppColors.primary),
                const SizedBox(width: 10),
                const Text('Condizione',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RuleConditionType.values.map((c) {
                final sel = _condType == c;
                return GestureDetector(
                  onTap: () => setState(() => _condType = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: sel ? AppColors.mainGradient : null,
                      color: sel ? null : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon,
                            size: 16,
                            color: sel ? Colors.white : Colors.grey[700]),
                        const SizedBox(width: 6),
                        Text(c.label,
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color:
                                    sel ? Colors.white : Colors.grey[700])),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueCtrl,
              decoration: _inputDecoration(
                  _condValueHint(), Icons.search_rounded),
            ),
            const SizedBox(height: 24),

            // ALLORA
            Row(
              children: [
                _stepBadge('ALLORA', AppColors.secondary),
                const SizedBox(width: 10),
                const Text('Azione',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            ...RuleActionType.values.map((a) {
              final sel = _actionType == a;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _actionType = a),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.secondary.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel
                            ? AppColors.secondary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(a.icon,
                            color: sel
                                ? AppColors.secondary
                                : Colors.grey[600]),
                        const SizedBox(width: 12),
                        Text(a.label,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: sel
                                    ? AppColors.secondary
                                    : Colors.grey[800])),
                        const Spacer(),
                        if (sel)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.secondary, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // Selettore ritardo
            if (_actionType == RuleActionType.delay) ...[
              const SizedBox(height: 8),
              _label('Tempo di ritardo'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [5, 15, 30, 60].map((m) {
                  final sel = _delay == m;
                  return ChoiceChip(
                    label: Text('$m min'),
                    selected: sel,
                    selectedColor: AppColors.secondary,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : Colors.grey[700]),
                    onSelected: (_) => setState(() => _delay = m),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 32),
            GradientButton(
              label: isEdit ? 'Salva modifiche' : 'Crea regola',
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  String _condValueHint() {
    switch (_condType) {
      case RuleConditionType.app:
        return 'Nome app (es. Amazon, WhatsApp)';
      case RuleConditionType.contact:
        return 'Nome contatto (es. Mamma)';
      case RuleConditionType.group:
        return 'Nome gruppo (es. Famiglia)';
      case RuleConditionType.time:
        return 'Fascia oraria (es. 22:00-07:00)';
      case RuleConditionType.weekday:
        return 'Giorni (es. Sab, Dom)';
    }
  }

  Widget _label(String text) => Text(text,
      style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600]));

  Widget _stepBadge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800)),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.grey.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'rule_editor_screen.dart';

class HomeInboxScreen extends StatefulWidget {
  const HomeInboxScreen({super.key});

  @override
  State<HomeInboxScreen> createState() => _HomeInboxScreenState();
}

class _HomeInboxScreenState extends State<HomeInboxScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _cats = NotifCategory.values;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _cats.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const RuleEditorScreen()));
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Regola',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header con gradiente
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🔔', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Inbox Intelligente',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      // Pulsante simula notifica AI
                      IconButton(
                        tooltip: 'Simula nuova notifica',
                        onPressed: () => _simulate(context),
                        icon: const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.unreadImportant} importanti • ${state.filteredCount} filtrate dall\'AI',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      controller: _tab,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                      padding: const EdgeInsets.all(4),
                      tabs: _cats
                          .map((c) => Tab(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(c.label),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children:
                    _cats.map((c) => _NotifList(category: c)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulate(BuildContext context) {
    final samples = [
      ('WhatsApp', '💬', const Color(0xFF25D366), 'Anna',
          'Ci sei stasera per la cena? 🍝'),
      ('Amazon', '🛒', const Color(0xFFFF9900), 'Amazon',
          'Offerta lampo: 50% di sconto solo per oggi!'),
      ('Slack', '💼', const Color(0xFF4A154B), 'Team Dev',
          'Marco: urgente, controlla il deploy in produzione'),
      ('Telegram', '✈️', const Color(0xFF229ED9), 'Gruppo Amici',
          'Pietro: organizziamo qualcosa per il weekend?'),
    ];
    final s = (samples..shuffle()).first;
    context.read<AppState>().addIncoming(
          appName: s.$1,
          appIcon: s.$2,
          appColor: s.$3,
          sender: s.$4,
          text: s.$5,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🤖 AI ha classificato una nuova notifica da ${s.$1}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _NotifList extends StatelessWidget {
  final NotifCategory category;
  const _NotifList({required this.category});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.byCategory(category);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Nessuna notifica qui',
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      itemBuilder: (_, i) => _NotifCard(notification: items[i]),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notification;
  const _NotifCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final n = notification;

    return Dismissible(
      key: ValueKey(n.id),
      background: _swipeBg(
        Alignment.centerLeft,
        AppColors.tagHigh,
        Icons.star_rounded,
        'Importante',
      ),
      secondaryBackground: _swipeBg(
        Alignment.centerRight,
        AppColors.catSilenced,
        Icons.notifications_off_rounded,
        'Silenzia',
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          state.markImportant(n, !n.isImportant);
        } else {
          state.silence(n);
        }
        return false; // non rimuoviamo, aggiorniamo solo
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GradientCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(emoji: n.appIcon, color: n.appColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.sender,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formatTime(n.time),
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 11.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      n.appName,
                      style: TextStyle(
                          color: n.appColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n.text,
                      style: TextStyle(
                          color: Colors.grey[700], fontSize: 13.5, height: 1.35),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        AiTagChip(tag: n.tag, small: true),
                        const Spacer(),
                        if (n.isImportant)
                          const Icon(Icons.star_rounded,
                              color: AppColors.tagHigh, size: 18),
                        _ActionMenu(notification: n),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swipeBg(
      Alignment align, Color color, IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: align,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final AppNotification notification;
  const _ActionMenu({required this.notification});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, color: Colors.grey[500], size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (v) {
        switch (v) {
          case 'important':
            state.markImportant(notification, !notification.isImportant);
            break;
          case 'silence':
            state.silence(notification);
            break;
          case 'unsilence':
            state.unsilence(notification);
            break;
          case 'snooze':
            state.snooze(notification, 15);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ritardata di 15 minuti ⏰')),
            );
            break;
          case 'delete':
            state.remove(notification);
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'important',
          child: Row(children: [
            const Icon(Icons.star_rounded, size: 20, color: AppColors.tagHigh),
            const SizedBox(width: 10),
            Text(notification.isImportant
                ? 'Rimuovi importante'
                : 'Segna importante'),
          ]),
        ),
        PopupMenuItem(
          value: notification.isSilenced ? 'unsilence' : 'silence',
          child: Row(children: [
            const Icon(Icons.notifications_off_rounded, size: 20),
            const SizedBox(width: 10),
            Text(notification.isSilenced ? 'Riattiva' : 'Silenzia'),
          ]),
        ),
        const PopupMenuItem(
          value: 'snooze',
          child: Row(children: [
            Icon(Icons.snooze_rounded, size: 20),
            SizedBox(width: 10),
            Text('Ritarda 15 min'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
            SizedBox(width: 10),
            Text('Elimina'),
          ]),
        ),
      ],
    );
  }
}

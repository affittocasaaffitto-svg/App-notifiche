import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_inbox_screen.dart';
import 'rules_screen.dart';
import 'focus_screen.dart';
import 'summary_screen.dart';
import 'stats_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    HomeInboxScreen(),
    RulesScreen(),
    FocusScreen(),
    SummaryScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.cardDark
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              indicatorColor: AppColors.primary.withValues(alpha: 0.14),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            child: NavigationBar(
              height: 64,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.inbox_rounded),
                  selectedIcon: Icon(Icons.inbox_rounded, color: AppColors.primary),
                  label: 'Inbox',
                ),
                NavigationDestination(
                  icon: Icon(Icons.rule_rounded),
                  selectedIcon: Icon(Icons.rule_rounded, color: AppColors.primary),
                  label: 'Regole',
                ),
                NavigationDestination(
                  icon: Icon(Icons.do_not_disturb_on_rounded),
                  selectedIcon:
                      Icon(Icons.do_not_disturb_on_rounded, color: AppColors.primary),
                  label: 'Focus',
                ),
                NavigationDestination(
                  icon: Icon(Icons.summarize_rounded),
                  selectedIcon:
                      Icon(Icons.summarize_rounded, color: AppColors.primary),
                  label: 'Riepilogo',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_rounded),
                  selectedIcon:
                      Icon(Icons.insights_rounded, color: AppColors.primary),
                  label: 'Statistiche',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

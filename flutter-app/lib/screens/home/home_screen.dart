import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/locale/bloc/locale_bloc.dart';
import '../dashboard/dashboard_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// HomeScreen — Shell with IndexedStack bottom navigation.
// Responsibility: tab orchestration only.
//   - Tab state: local _currentIndex (pure UI, no BLoC needed)
//   - Content: delegates to DashboardScreen / HistoryScreen / SettingsScreen
//   - Cross-page navigation: passes onViewHistory callback to DashboardScreen
// ═══════════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(onViewHistory: () => _switchTab(1)),
          const HistoryScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD61A22), Color(0xFFA31219)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _switchTab,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w600),
            items: [
              BottomNavigationBarItem(
                icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_rounded)),
                label: s.dashboard,
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.access_time_rounded)),
                label: s.history,
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.settings_outlined)),
                label: s.setting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

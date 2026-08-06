import 'package:flutter/material.dart';
import 'package:plant_ai/screens/history_screen.dart';
import 'package:plant_ai/screens/home_screen.dart';
import 'package:plant_ai/screens/library_screen.dart';
import 'package:plant_ai/screens/scan_screen.dart';
import 'package:plant_ai/screens/settings_screen.dart';
import 'package:plant_ai/utils/app_route.dart';
import 'package:plant_ai/widgets/bottom_nav_bar.dart';
import 'package:plant_ai/widgets/scan_fab_button.dart';

/// Hosts the Home screen with the persistent bottom navigation bar.
/// Scan gets a raised, docked button front-and-center since it's the
/// app's core action; Library, History and Settings are pushed as
/// full routes (same pattern as the original app) so the working
/// camera flow stays untouched.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _selected = 0;

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _selected = 0);
      return;
    }
    if (index == 1) {
      Navigator.push(context, AppRoute.to(const LibraryScreen()));
      return;
    }
    if (index == 2) {
      Navigator.push(context, AppRoute.to(const HistoryScreen()));
      return;
    }
    if (index == 3) {
      Navigator.push(context, AppRoute.to(const SettingsScreen()));
    }
  }

  void _openScan() {
    Navigator.push(context, AppRoute.to(const ScanScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        bottom: false,
        child: HomeScreen(),
      ),
      floatingActionButton: ScanFabButton(onTap: _openScan),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CardamomBottomNavBar(selected: _selected, onTap: _onNavTap),
    );
  }
}

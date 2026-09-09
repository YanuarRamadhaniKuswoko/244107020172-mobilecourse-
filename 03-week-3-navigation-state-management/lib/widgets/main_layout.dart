import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// MainLayout wraps the top-level screens with a persistent NavigationBar (Refactoring Challenge #3).
/// Allows switching between the main ToDo list ('/') and Statistics ('/stats').
class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  final Widget child;
  final String currentLocation;

  int _calculateSelectedIndex() {
    if (currentLocation.startsWith('/stats')) {
      return 1;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      context.go('/');
    } else if (index == 1) {
      context.go('/stats');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex();

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Daftar Tugas',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  static final List<_NavItem> _items = [
    const _NavItem('/', Icons.home_outlined, Icons.home, 'Accueil'),
    const _NavItem('/exercises', Icons.fitness_center_outlined, Icons.fitness_center, 'Exercices'),
    const _NavItem('/history', Icons.history_outlined, Icons.history, 'Historique'),
  ];

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int selectedIndex = _items.indexWhere((item) => location == item.route);

    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (index) {
        if (location != _items[index].route) {
          context.go(_items[index].route);
        }
      },
      destinations: _items.map((item) => NavigationDestination(
        icon: Icon(item.icon),
        selectedIcon: Icon(item.selectedIcon),
        label: item.label,
      )).toList(),
    );
  }
}

class _NavItem {
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem(this.route, this.icon, this.selectedIcon, this.label);
} 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    NavigationItem(
      icon: Icons.calendar_today,
      label: 'Calendar',
      route: '/calendar',
    ),
    NavigationItem(icon: Icons.map, label: 'Maps', route: '/maps'),
    NavigationItem(icon: Icons.work, label: 'Jobs', route: '/jobs'),
    NavigationItem(icon: Icons.settings, label: 'Settings', route: '/settings'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final String location = GoRouterState.of(context).uri.path;
    final int index = _navigationItems.indexWhere(
      (item) => item.route == location,
    );
    if (index != -1) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;

    if (isTablet) {
      // For tablets: Use Row with NavigationRail on the side
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onNavigationItemSelected,
              labelType: NavigationRailLabelType.all,
              destinations:
                  _navigationItems
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // The screen content takes the remaining space
            Expanded(child: widget.child),
          ],
        ),
      );
    } else {
      // For phones: Use traditional bottom navigation
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavigationItemSelected,
          type: BottomNavigationBarType.fixed,
          items:
              _navigationItems
                  .map(
                    (item) => BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
        ),
      );
    }
  }

  void _onNavigationItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate using GoRouter
    context.go(_navigationItems[index].route);
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

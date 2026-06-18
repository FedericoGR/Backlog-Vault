import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex =
        location.startsWith('/home')
            ? 0
            : location.startsWith('/statistics')
            ? 2
            : location.startsWith('/settings')
            ? 3
            : 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: selectedIndex,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: (index) {
                      context.go(switch (index) {
                        0 => '/home',
                        1 => '/',
                        2 => '/statistics',
                        _ => '/settings',
                      });
                    },
                    destinations: [
                      NavigationRailDestination(
                        icon: const Icon(Icons.home_outlined),
                        selectedIcon: const Icon(Icons.home),
                        label: Text(l10n.navigationHome),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.library_books_outlined),
                        selectedIcon: const Icon(Icons.library_books),
                        label: Text(l10n.navigationLibrary),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.bar_chart_outlined),
                        selectedIcon: const Icon(Icons.bar_chart),
                        label: Text(l10n.navigationStatistics),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.settings_outlined),
                        selectedIcon: const Icon(Icons.settings),
                        label: Text(l10n.navigationSettings),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              context.go(switch (index) {
                0 => '/home',
                1 => '/',
                2 => '/statistics',
                _ => '/settings',
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n.navigationHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.library_books_outlined),
                selectedIcon: const Icon(Icons.library_books),
                label: l10n.navigationLibrary,
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: l10n.navigationStatistics,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l10n.navigationSettings,
              ),
            ],
          ),
        );
      },
    );
  }
}

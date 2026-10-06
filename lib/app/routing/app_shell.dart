import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/bv_theme_extension.dart';
import '../../l10n/l10n.dart';

/// Compact, keyboard-accessible navigation shared by the primary routes.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final statistics = location.startsWith('/statistics');
    final settings = location.startsWith('/settings');
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    return Scaffold(
      body: Column(
        children: [
          Material(
            color: bv.canvas,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: bv.border)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    if (MediaQuery.sizeOf(context).width >= 600) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Backlog Vault',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 36),
                    ] else
                      const SizedBox(width: 4),
                    _NavigationLink(
                      label: context.l10n.navigationLibrary,
                      selected: !statistics && !settings,
                      path: '/',
                      key: const ValueKey('nav-games'),
                    ),
                    const SizedBox(width: 8),
                    _NavigationLink(
                      label: context.l10n.navigationStatistics,
                      selected: statistics,
                      path: '/statistics',
                      key: const ValueKey('nav-statistics'),
                    ),
                    const Spacer(),
                    IconButton(
                      key: const ValueKey('nav-settings'),
                      tooltip: context.l10n.navigationSettings,
                      isSelected: settings,
                      color: settings ? theme.colorScheme.primary : null,
                      onPressed: () => context.go('/settings'),
                      icon: const Icon(Icons.settings_outlined, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavigationLink extends StatelessWidget {
  const _NavigationLink({
    required this.label,
    required this.selected,
    required this.path,
    super.key,
  });
  final String label;
  final bool selected;
  final String path;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color: selected ? colors.primary : Colors.transparent,
            ),
          ),
        ),
        child: TextButton(
          onPressed: () => context.go(path),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            foregroundColor:
                selected ? colors.primary : colors.onSurfaceVariant,
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'bv_spacing.dart';
import 'bv_theme_extension.dart';

class BvEmptyState extends StatelessWidget {
  const BvEmptyState({
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHeight =
            constraints.hasBoundedHeight && constraints.maxHeight < 220;
        final padding = compactHeight ? BvSpacing.sm : BvSpacing.xl;
        final iconSize = compactHeight ? 40.0 : 48.0;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: iconSize, color: bv.textMuted),
                  SizedBox(height: compactHeight ? BvSpacing.sm : BvSpacing.md),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: BvSpacing.xs),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (action != null) ...[
                    SizedBox(
                      height: compactHeight ? BvSpacing.sm : BvSpacing.md,
                    ),
                    action!,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

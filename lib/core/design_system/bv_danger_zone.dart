import 'package:flutter/material.dart';

import 'bv_panel.dart';
import 'bv_spacing.dart';
import 'bv_theme_extension.dart';

class BvDangerZone extends StatelessWidget {
  const BvDangerZone({
    required this.title,
    required this.message,
    required this.actions,
    super.key,
  });

  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    return BvPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(color: bv.danger),
          ),
          const SizedBox(height: BvSpacing.xs),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: BvSpacing.md),
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: actions,
          ),
        ],
      ),
    );
  }
}

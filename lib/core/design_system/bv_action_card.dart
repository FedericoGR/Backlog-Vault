import 'package:flutter/material.dart';

import 'bv_panel.dart';
import 'bv_spacing.dart';
import 'bv_theme_extension.dart';

class BvActionCard extends StatelessWidget {
  const BvActionCard({
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.actions,
    this.trailing,
    this.emphasized = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final Widget? trailing;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color:
                      emphasized
                          ? theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.78,
                          )
                          : bv.surfaceHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(BvSpacing.xs),
                  child: Icon(
                    icon,
                    size: 18,
                    color:
                        emphasized
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: BvSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: BvSpacing.xxs),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: BvSpacing.sm),
              trailing!,
            ],
          ],
        ),
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(height: BvSpacing.md),
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: actions!,
          ),
        ],
      ],
    );

    if (onTap == null) {
      return BvPanel(child: content);
    }

    return BvPanel(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
}

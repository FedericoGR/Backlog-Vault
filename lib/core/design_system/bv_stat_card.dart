import 'package:flutter/material.dart';

import 'bv_spacing.dart';
import 'bv_surface.dart';
import 'bv_theme_extension.dart';

class BvStatCard extends StatelessWidget {
  const BvStatCard({
    required this.label,
    required this.value,
    this.icon,
    this.minWidth = 140,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;
  final double minWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: BvSurface(
        padding: const EdgeInsets.symmetric(
          horizontal: BvSpacing.sm,
          vertical: BvSpacing.sm,
        ),
        backgroundColor: bv.surfaceRaised,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: bv.textMuted),
                  const SizedBox(width: BvSpacing.xxs),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: bv.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BvSpacing.xxs),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

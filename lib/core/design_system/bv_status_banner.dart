import 'package:flutter/material.dart';

import 'bv_panel.dart';
import 'bv_spacing.dart';
import 'bv_theme_extension.dart';

enum BvBannerTone { info, success, warning, danger }

class BvStatusBanner extends StatelessWidget {
  const BvStatusBanner({
    required this.message,
    this.title,
    this.tone = BvBannerTone.info,
    this.action,
    super.key,
  });

  final String? title;
  final String message;
  final BvBannerTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    final colors = switch (tone) {
      BvBannerTone.info => (
        background: bv.surfaceHighest,
        foreground: theme.colorScheme.onSurface,
        icon: Icons.info_outline,
      ),
      BvBannerTone.success => (
        background: theme.colorScheme.primaryContainer.withValues(alpha: 0.68),
        foreground: theme.colorScheme.onPrimaryContainer,
        icon: Icons.check_circle_outline,
      ),
      BvBannerTone.warning => (
        background: bv.warningContainer,
        foreground: bv.warning,
        icon: Icons.warning_amber_outlined,
      ),
      BvBannerTone.danger => (
        background: bv.dangerContainer,
        foreground: bv.danger,
        icon: Icons.error_outline,
      ),
    };

    return BvPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(colors.icon, color: colors.foreground),
          const SizedBox(width: BvSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(title!, style: theme.textTheme.titleSmall),
                if (title != null) const SizedBox(height: BvSpacing.xxs),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(BvSpacing.sm),
                    child: Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.foreground,
                      ),
                    ),
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: BvSpacing.sm),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'bv_spacing.dart';
import 'bv_theme_extension.dart';
import 'bv_tokens.dart';

enum BvChipTone { neutral, primary, warning, danger }

class BvChip extends StatelessWidget {
  const BvChip({
    required this.label,
    this.icon,
    this.tone = BvChipTone.neutral,
    this.onDeleted,
    this.selected = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final BvChipTone tone;
  final VoidCallback? onDeleted;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colors(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(BvRadii.pill),
        border: Border.all(color: colors.border),
      ),
      padding: BvSpacing.chip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors.foreground),
            const SizedBox(width: BvSpacing.xxs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.foreground,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: BvSpacing.xxs),
            InkResponse(
              onTap: onDeleted,
              radius: 14,
              child: Icon(Icons.close, size: 14, color: colors.foreground),
            ),
          ],
        ],
      ),
    );
  }

  _ChipColors _colors(BuildContext context) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    final scheme = theme.colorScheme;
    return switch (tone) {
      BvChipTone.primary => _ChipColors(
        background: scheme.primaryContainer.withValues(alpha: 0.82),
        foreground: scheme.onPrimaryContainer,
        border: selected ? bv.focus : scheme.primary.withValues(alpha: 0.35),
      ),
      BvChipTone.warning => _ChipColors(
        background: bv.warningContainer,
        foreground:
            theme.brightness == Brightness.dark
                ? const Color(0xFFFFD59A)
                : bv.warning,
        border: bv.warning.withValues(alpha: 0.42),
      ),
      BvChipTone.danger => _ChipColors(
        background: bv.dangerContainer,
        foreground:
            theme.brightness == Brightness.dark
                ? const Color(0xFFFFB3B9)
                : bv.danger,
        border: bv.danger.withValues(alpha: 0.42),
      ),
      BvChipTone.neutral => _ChipColors(
        background: bv.surfaceHighest,
        foreground: scheme.onSurfaceVariant,
        border: selected ? bv.borderStrong : bv.border,
      ),
    };
  }
}

class _ChipColors {
  const _ChipColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

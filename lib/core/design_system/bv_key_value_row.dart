import 'package:flutter/material.dart';

import 'bv_spacing.dart';
import 'bv_theme_extension.dart';

class BvKeyValueRow extends StatelessWidget {
  const BvKeyValueRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.leading,
    super.key,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BvSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            Icon(leading, size: 16, color: bv.textMuted),
            const SizedBox(width: BvSpacing.xs),
          ],
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: BvSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

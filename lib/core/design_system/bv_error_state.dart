import 'package:flutter/material.dart';

import 'bv_panel.dart';
import 'bv_spacing.dart';
import 'bv_theme_extension.dart';

/// Recoverable error presentation that never renders an exception directly.
class BvErrorState extends StatelessWidget {
  const BvErrorState({
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(BvSpacing.xs),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: BvPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: bv.danger),
                    const SizedBox(width: BvSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: theme.textTheme.titleMedium),
                          const SizedBox(height: BvSpacing.xs),
                          Text(
                            message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (onRetry != null && retryLabel != null) ...[
                  const SizedBox(height: BvSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(retryLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

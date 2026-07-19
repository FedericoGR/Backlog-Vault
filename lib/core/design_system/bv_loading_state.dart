import 'package:flutter/material.dart';

import 'bv_spacing.dart';
import 'bv_theme_extension.dart';

/// Centered loading state with localized progress copy supplied by its owner.
class BvLoadingState extends StatelessWidget {
  const BvLoadingState({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final bv = BvThemeExtension.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BvSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(height: BvSpacing.sm),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: bv.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

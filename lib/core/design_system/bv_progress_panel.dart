import 'package:flutter/material.dart';

import 'bv_panel.dart';
import 'bv_spacing.dart';

/// Progress summary with an optional, explicitly localized cancel action.
class BvProgressPanel extends StatelessWidget {
  const BvProgressPanel({
    required this.title,
    this.progress,
    this.subtitle,
    this.trailing,
    this.onCancel,
    this.cancelLabel,
    super.key,
  });

  final String title;
  final double? progress;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onCancel;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (trailing != null) Text(trailing!),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: BvSpacing.xs),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: BvSpacing.sm),
          LinearProgressIndicator(value: progress?.clamp(0, 1)),
          if (onCancel != null && cancelLabel != null) ...[
            const SizedBox(height: BvSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close),
                label: Text(cancelLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

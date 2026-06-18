import 'package:flutter/material.dart';

import 'bv_panel.dart';
import 'bv_section.dart';
import 'bv_spacing.dart';
import 'bv_surface.dart';

class BvWizardStep extends StatelessWidget {
  const BvWizardStep({
    required this.step,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String step;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BvSurface(
                padding: const EdgeInsets.symmetric(
                  horizontal: BvSpacing.sm,
                  vertical: BvSpacing.xs,
                ),
                child: Text(
                  step,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          const SizedBox(height: BvSpacing.sm),
          BvSection(
            title: title,
            subtitle: subtitle,
            padding: EdgeInsets.zero,
            child: child,
          ),
        ],
      ),
    );
  }
}

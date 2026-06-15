import 'package:flutter/material.dart';

import 'bv_spacing.dart';
import 'bv_surface.dart';
import 'bv_theme_extension.dart';
import 'bv_tokens.dart';

class BvPanel extends StatelessWidget {
  const BvPanel({
    required this.child,
    this.padding = BvSpacing.panel,
    this.margin,
    this.dense = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final bv = BvThemeExtension.of(context);
    return BvSurface(
      margin: margin,
      padding: dense ? BvSpacing.panelDense : padding,
      backgroundColor: bv.surfaceRaised,
      borderColor: bv.border,
      borderRadius: BvRadii.md,
      child: child,
    );
  }
}

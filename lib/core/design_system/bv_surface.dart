import 'package:flutter/material.dart';

import 'bv_spacing.dart';
import 'bv_theme_extension.dart';
import 'bv_tokens.dart';

class BvSurface extends StatelessWidget {
  const BvSurface({
    required this.child,
    this.padding = BvSpacing.panel,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = BvRadii.md,
    this.onTap,
    this.selected = false,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool selected;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final bv = BvThemeExtension.of(context);
    final radius = BorderRadius.circular(borderRadius);
    final content = AnimatedContainer(
      duration: BvDurations.fast,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? bv.surface,
        borderRadius: radius,
        border: Border.all(
          color: selected ? bv.focus : borderColor ?? bv.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        hoverColor: bv.focus.withValues(alpha: 0.06),
        focusColor: bv.focus.withValues(alpha: 0.10),
        splashColor: bv.focus.withValues(alpha: 0.12),
        child: content,
      ),
    );
  }
}

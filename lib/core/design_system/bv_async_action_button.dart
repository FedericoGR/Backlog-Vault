import 'package:flutter/material.dart';

/// A primary action that disables itself and exposes progress accessibly.
///
/// [busyLabel] should describe the active operation for screen readers; the
/// visible [label] remains stable so the button does not jump while loading.
class BvAsyncActionButton extends StatelessWidget {
  const BvAsyncActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.busy,
    required this.busyLabel,
    this.minimumWidth,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool busy;
  final String busyLabel;
  final double? minimumWidth;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: busy ? null : onPressed,
      icon:
          busy
              ? Semantics(
                label: busyLabel,
                child: const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : Icon(icon),
      label: Text(label),
    );

    final accessibleButton =
        busy
            ? Semantics(
              container: true,
              button: true,
              enabled: false,
              label: busyLabel,
              child: ExcludeSemantics(child: button),
            )
            : button;

    if (minimumWidth == null) return accessibleButton;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minimumWidth!),
      child: accessibleButton,
    );
  }
}

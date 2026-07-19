import 'package:flutter/material.dart';

/// Shows one transient message at a time for an explicit user action.
///
/// This helper deliberately stays presentation-only: it does not subscribe to
/// global events and never receives exceptions or credential values.
abstract final class BvFeedback {
  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

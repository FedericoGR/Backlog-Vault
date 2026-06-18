import 'package:flutter/material.dart';

import 'bv_breakpoints.dart';
import 'bv_spacing.dart';

class BvPageScaffold extends StatelessWidget {
  const BvPageScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.maxContentWidth,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      floatingActionButton: floatingActionButton,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = BvBreakpoints.isCompact(constraints.maxWidth);
          final content = Padding(
            padding: compact ? BvSpacing.pageCompact : BvSpacing.page,
            child: body,
          );

          if (maxContentWidth == null) return content;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth!),
              child: content,
            ),
          );
        },
      ),
    );
  }
}

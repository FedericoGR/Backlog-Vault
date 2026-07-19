part of '../bulk_metadata_import_page.dart';

class _ApplyConfirmationDialog extends StatefulWidget {
  const _ApplyConfirmationDialog({
    required this.plan,
    required this.requiredText,
    required this.replaces,
  });

  final BulkMetadataImportPlan? plan;
  final String requiredText;
  final bool replaces;

  @override
  State<_ApplyConfirmationDialog> createState() =>
      _ApplyConfirmationDialogState();
}

class _ApplyConfirmationDialogState extends State<_ApplyConfirmationDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final requiredText = widget.requiredText;
    final canConfirm = _controller.text.trim().toUpperCase() == requiredText;

    return AlertDialog(
      title: Text(context.l10n.bulkConfirmTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.bulkConfirmMessage),
            if (plan != null) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.bulkConfirmSummary(
                  plan.selectedItems,
                  plan.selectedNewFieldChanges,
                  plan.selectedReplacementFieldChanges,
                  plan.selectedNewCovers,
                  plan.selectedReplacementCovers,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(context.l10n.bulkTypeConfirmation(requiredText)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: context.l10n.libraryConfirmation,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: canConfirm ? () => Navigator.pop(context, true) : null,
          child: Text(
            widget.replaces ? context.l10n.bulkReplace : context.l10n.bulkApply,
          ),
        ),
      ],
    );
  }
}

part of '../game_detail_page.dart';

Future<void> _showMetadataDialog(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
) async {
  final applied = await showDialog<bool>(
    context: context,
    builder: (context) => MetadataSearchDialog(item: item),
  );
  if (applied != true || !context.mounted) return;
  ref.invalidate(libraryGameProvider(item.entry.id));
  BvFeedback.show(context, context.l10n.metadataApplied);
}

Future<void> _showMediaDialog(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => MediaSearchDialog(item: item),
  );
  if (saved != true || !context.mounted) return;
  ref.invalidate(libraryGameProvider(item.entry.id));
  ref.invalidate(libraryRowsProvider);
  BvFeedback.show(context, context.l10n.coverUpdated);
}

Future<void> _confirmDeleteCover(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
) async {
  final cover = item.selectedCover;
  if (cover == null) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          scrollable: true,
          title: Text(context.l10n.coverRemoveTitle),
          content: Text(context.l10n.coverRemoveMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.remove),
            ),
          ],
        ),
  );
  if (confirmed != true || !context.mounted) return;
  await ref.read(deleteMediaAssetUseCaseProvider).call(cover.id);
  ref.invalidate(libraryGameProvider(item.entry.id));
  ref.invalidate(libraryRowsProvider);
  if (!context.mounted) return;
  BvFeedback.show(context, context.l10n.coverRemoved);
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          scrollable: true,
          title: Text(context.l10n.libraryDeleteGameTitle),
          content: Text(context.l10n.libraryDeleteGameMessage(item.game.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.delete),
            ),
          ],
        ),
  );
  if (confirmed != true || !context.mounted) return;
  await ref.read(gameDetailViewModelProvider).deleteGame(item.entry.id);
  if (context.mounted) context.go('/');
}

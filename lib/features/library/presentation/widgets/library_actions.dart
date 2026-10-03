part of '../game_list_page.dart';

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BvEmptyState(
        title: context.l10n.libraryEmptyTitle,
        message: context.l10n.libraryEmptyMessage,
        icon: Icons.library_add_outlined,
        action: FilledButton.icon(
          onPressed: () => context.go('/games/new'),
          icon: const Icon(Icons.add),
          label: Text(context.l10n.homeCreateFirstGame),
        ),
      ),
    );
  }
}

class _EmptyFilteredState extends ConsumerWidget {
  const _EmptyFilteredState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: BvEmptyState(
        title: context.l10n.libraryEmptyFilteredTitle,
        message: context.l10n.libraryEmptyFilteredMessage,
        icon: Icons.search_off_outlined,
        action: OutlinedButton.icon(
          onPressed: () => _resetTableState(ref),
          icon: const Icon(Icons.restart_alt),
          label: Text(context.l10n.libraryClearFilters),
        ),
      ),
    );
  }
}

Future<void> _showFiltersPanel(
  BuildContext context,
  WidgetRef ref,
  List<LibraryCatalogItem> platforms,
  List<LibraryCatalogItem> genres,
) async {
  if (MediaQuery.sizeOf(context).width < BvBreakpoints.mobile) {
    final current = ref.read(libraryViewModelProvider).table;
    final result = await showModalBottomSheet<LibraryFilterState>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (context) => FractionallySizedBox(
            heightFactor: 0.92,
            child: _FiltersDialog(
              initialFilter: current.filter,
              platforms: platforms,
              genres: genres,
            ),
          ),
    );
    if (result == null) return;
    ref
        .read(libraryViewModelProvider.notifier)
        .setTableState(current.copyWith(filter: result));
    return;
  }

  await _showFiltersDialog(context, ref, platforms, genres);
}

Future<void> _showFiltersDialog(
  BuildContext context,
  WidgetRef ref,
  List<LibraryCatalogItem> platforms,
  List<LibraryCatalogItem> genres,
) async {
  final current = ref.read(libraryViewModelProvider).table;
  final result = await showDialog<LibraryFilterState>(
    context: context,
    builder:
        (context) => _FiltersDialog(
          initialFilter: current.filter,
          platforms: platforms,
          genres: genres,
        ),
  );
  if (result == null) return;
  ref
      .read(libraryViewModelProvider.notifier)
      .setTableState(current.copyWith(filter: result));
}

Future<void> _showColumnsDialog(BuildContext context, WidgetRef ref) async {
  final current = ref.read(libraryViewModelProvider).table;
  final result = await showDialog<LibraryColumnConfig>(
    context: context,
    builder: (context) => _ColumnsDialog(initialConfig: current.columnConfig),
  );
  if (result == null) return;
  ref
      .read(libraryViewModelProvider.notifier)
      .setTableState(current.copyWith(columnConfig: result));
}

Future<void> _saveCurrentView(BuildContext context, WidgetRef ref) async {
  final name = await _askViewName(context, title: context.l10n.saveView);
  if (name == null) return;
  final state = ref.read(libraryViewModelProvider).table;
  final id = await ref
      .read(libraryViewModelProvider.notifier)
      .createView(name: name, table: state);
  ref
      .read(libraryViewModelProvider.notifier)
      .setTableState(state.copyWith(activeViewId: id));
}

Future<void> _updateCurrentView(
  BuildContext context,
  WidgetRef ref,
  SavedLibraryView view,
) async {
  final state = ref.read(libraryViewModelProvider).table;
  await ref
      .read(libraryViewModelProvider.notifier)
      .updateView(
        view.copyWith(
          filter: state.filter,
          sort: state.sort,
          columnConfig: state.columnConfig,
        ),
      );
  if (context.mounted) {
    BvFeedback.show(context, context.l10n.libraryViewUpdated);
  }
}

Future<void> _renameCurrentView(
  BuildContext context,
  WidgetRef ref,
  SavedLibraryView view,
) async {
  final name = await _askViewName(
    context,
    title: context.l10n.libraryRenameView,
    initialName: view.name,
  );
  if (name == null) return;
  await ref
      .read(libraryViewModelProvider.notifier)
      .updateView(view.copyWith(name: name));
}

Future<void> _deleteCurrentView(
  BuildContext context,
  WidgetRef ref,
  SavedLibraryView view,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          scrollable: true,
          title: Text(context.l10n.libraryDeleteView),
          content: Text(context.l10n.libraryDeleteViewMessage(view.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.deleteAction),
            ),
          ],
        ),
  );
  if (confirmed != true) return;
  await ref.read(libraryViewModelProvider.notifier).deleteView(view.id);
  _resetTableState(ref);
}

Future<String?> _askViewName(
  BuildContext context, {
  required String title,
  String? initialName,
}) async {
  final controller = TextEditingController(text: initialName ?? '');
  final result = await showDialog<String>(
    context: context,
    builder:
        (context) => AlertDialog(
          scrollable: true,
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: context.l10n.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context, name);
              },
              child: Text(context.l10n.save),
            ),
          ],
        ),
  );
  controller.dispose();
  return result;
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  LibraryGameRow row,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          scrollable: true,
          title: Text(context.l10n.libraryDeleteGameTitle),
          content: Text(context.l10n.libraryDeleteGameMessage(row.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.deleteAction),
            ),
          ],
        ),
  );
  if (confirmed != true || !context.mounted) return;
  await ref
      .read(libraryViewModelProvider.notifier)
      .deleteGame(row.libraryEntryId);
}

Widget _tableCell(
  BuildContext context,
  LibraryGameRow row,
  LibraryColumnKey column,
) {
  if (column == LibraryColumnKey.cover) {
    return Center(
      child: LibraryCoverThumbnail(
        localPath: row.selectedCoverLocalPath,
        width: 36,
        height: 48,
      ),
    );
  }

  final text = switch (column) {
    LibraryColumnKey.title => row.title,
    LibraryColumnKey.status => context.l10n.gameStatusLabel(row.status),
    LibraryColumnKey.platforms => _names(
      row.platforms.map((platform) => platform.name),
    ),
    LibraryColumnKey.genres => _names(row.genres.map((genre) => genre.name)),
    LibraryColumnKey.rating => formatStarRating(row.personalRating),
    LibraryColumnKey.releaseDate => formatVisibleDate(row.releaseDate),
    LibraryColumnKey.completedDate => formatVisibleDate(row.completedAt),
    LibraryColumnKey.hours =>
      row.hoursPlayed == null ? '-' : row.hoursPlayed!.toStringAsFixed(1),
    LibraryColumnKey.type => context.l10n.displayGameType(row.type),
    LibraryColumnKey.notes =>
      row.personalNotes?.trim().isEmpty ?? true
          ? '-'
          : row.personalNotes!.trim(),
    LibraryColumnKey.updatedAt => formatVisibleDate(row.updatedAt),
    LibraryColumnKey.playedPlatform => row.playedPlatform?.name ?? '-',
    LibraryColumnKey.cover => '',
  };

  return Tooltip(
    message: text,
    waitDuration: const Duration(milliseconds: 500),
    child: Text(
      text,
      maxLines: column == LibraryColumnKey.notes ? 2 : 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

DropdownButtonFormField<int?> _ratingDropdown({
  required BuildContext context,
  required String label,
  required int? value,
  required ValueChanged<int?> onChanged,
}) {
  return DropdownButtonFormField<int?>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      DropdownMenuItem(value: null, child: Text(context.l10n.libraryNoLimit)),
      const DropdownMenuItem(value: 1, child: Text('1')),
      const DropdownMenuItem(value: 2, child: Text('2')),
      const DropdownMenuItem(value: 3, child: Text('3')),
      const DropdownMenuItem(value: 4, child: Text('4')),
      const DropdownMenuItem(value: 5, child: Text('5')),
    ],
    onChanged: onChanged,
  );
}

void _toggleSort(WidgetRef ref, LibraryColumnKey column) {
  final sortField = _sortFieldForColumn(column);
  if (sortField == null) return;
  final current = ref.read(libraryViewModelProvider).table;
  ref
      .read(libraryViewModelProvider.notifier)
      .setTableState(current.copyWith(sort: current.sort.toggle(sortField)));
}

LibrarySortField? _sortFieldForColumn(LibraryColumnKey column) {
  return switch (column) {
    LibraryColumnKey.title => LibrarySortField.title,
    LibraryColumnKey.status => LibrarySortField.status,
    LibraryColumnKey.rating => LibrarySortField.rating,
    LibraryColumnKey.releaseDate => LibrarySortField.releaseDate,
    LibraryColumnKey.completedDate => LibrarySortField.completedDate,
    LibraryColumnKey.hours => LibrarySortField.hours,
    LibraryColumnKey.updatedAt => LibrarySortField.updatedAt,
    LibraryColumnKey.cover ||
    LibraryColumnKey.platforms ||
    LibraryColumnKey.genres ||
    LibraryColumnKey.type ||
    LibraryColumnKey.notes ||
    LibraryColumnKey.playedPlatform => null,
  };
}

void _resetTableState(WidgetRef ref) {
  ref
      .read(libraryViewModelProvider.notifier)
      .setTableState(LibraryTableState.initial());
}

SavedLibraryView? _viewById(List<SavedLibraryView> views, String id) {
  for (final view in views) {
    if (view.id == id) return view;
  }
  return null;
}

String _names(Iterable<String> values) {
  final list = values.toList();
  if (list.isEmpty) return '-';
  return list.join(', ');
}

String _namesForIds(Set<String> ids, List<LibraryCatalogItem> items) {
  final namesById = {for (final item in items) item.id: item.name};
  final names = ids.map((id) => namesById[id] ?? id).toList();
  return names.isEmpty ? '-' : names.join(', ');
}

String _localizedViewName(BuildContext context, SavedLibraryView view) {
  return switch (view.id) {
    defaultAllGamesViewId => context.l10n.libraryDefaultAll,
    'default:pending' => context.l10n.libraryDefaultPending,
    'default:completed' => context.l10n.libraryDefaultCompleted,
    defaultCompletedYearViewId => context.l10n.libraryDefaultByYear,
    _ => view.name,
  };
}

double? _parseDouble(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

part of '../game_list_page.dart';

class _FiltersDialog extends StatefulWidget {
  const _FiltersDialog({
    required this.initialFilter,
    required this.platforms,
    required this.genres,
  });

  final LibraryFilterState initialFilter;
  final List<LibraryCatalogItem> platforms;
  final List<LibraryCatalogItem> genres;

  @override
  State<_FiltersDialog> createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<_FiltersDialog> {
  late Set<GameStatus> _statuses;
  late Set<String> _platformIds;
  late Set<String> _genreIds;
  int? _minRating;
  int? _maxRating;
  DateTime? _releaseDateFrom;
  DateTime? _releaseDateTo;
  DateTime? _completedDateFrom;
  DateTime? _completedDateTo;
  late bool _hasRating;
  late bool _missingRating;
  late bool _hasPlatform;
  late bool _missingPlatform;
  late bool _hasGenre;
  late bool _missingGenre;
  late bool _hasCompletedDate;
  late bool _missingCompletedDate;
  late final TextEditingController _minHoursController;
  late final TextEditingController _maxHoursController;
  late final TextEditingController _typeController;

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter;
    _statuses = {...filter.statuses};
    _platformIds = {...filter.platformIds};
    _genreIds = {...filter.genreIds};
    _minRating = filter.minRating;
    _maxRating = filter.maxRating;
    _releaseDateFrom = filter.releaseDateFrom;
    _releaseDateTo = filter.releaseDateTo;
    _completedDateFrom = filter.completedDateFrom;
    _completedDateTo = filter.completedDateTo;
    _hasRating = filter.hasRating;
    _missingRating = filter.missingRating;
    _hasPlatform = filter.hasPlatform;
    _missingPlatform = filter.missingPlatform;
    _hasGenre = filter.hasGenre;
    _missingGenre = filter.missingGenre;
    _hasCompletedDate = filter.hasCompletedDate;
    _missingCompletedDate = filter.missingCompletedDate;
    _minHoursController = TextEditingController(
      text: filter.minHours?.toString() ?? '',
    );
    _maxHoursController = TextEditingController(
      text: filter.maxHours?.toString() ?? '',
    );
    _typeController = TextEditingController(text: filter.type ?? '');
  }

  @override
  void dispose() {
    _minHoursController.dispose();
    _maxHoursController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.filters),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _sectionTitle(context, context.l10n.libraryStatus),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final status in GameStatus.values)
                    FilterChip(
                      label: Text(context.l10n.gameStatusLabel(status)),
                      selected: _statuses.contains(status),
                      onSelected: (selected) {
                        setState(() {
                          selected
                              ? _statuses.add(status)
                              : _statuses.remove(status);
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionTitle(context, context.l10n.libraryPlatforms),
              _catalogChips(widget.platforms, _platformIds),
              const SizedBox(height: 16),
              _sectionTitle(context, context.l10n.libraryGenres),
              _catalogChips(widget.genres, _genreIds),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ratingDropdown(
                      context: context,
                      label: context.l10n.libraryMinimumRating,
                      value: _minRating,
                      onChanged: (value) => setState(() => _minRating = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ratingDropdown(
                      context: context,
                      label: context.l10n.libraryMaximumRating,
                      value: _maxRating,
                      onChanged: (value) => setState(() => _maxRating = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minHoursController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.libraryMinimumHours,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxHoursController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.libraryMaximumHours,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: context.l10n.libraryType,
                ),
              ),
              const SizedBox(height: 12),
              _DateFilterTile(
                label: context.l10n.libraryReleaseFrom,
                value: _releaseDateFrom,
                onChanged: (value) => setState(() => _releaseDateFrom = value),
              ),
              _DateFilterTile(
                label: context.l10n.libraryReleaseTo,
                value: _releaseDateTo,
                onChanged: (value) => setState(() => _releaseDateTo = value),
              ),
              _DateFilterTile(
                label: context.l10n.libraryCompletedFrom,
                value: _completedDateFrom,
                onChanged:
                    (value) => setState(() => _completedDateFrom = value),
              ),
              _DateFilterTile(
                label: context.l10n.libraryCompletedTo,
                value: _completedDateTo,
                onChanged: (value) => setState(() => _completedDateTo = value),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 0,
                children: [
                  _flag(
                    context.l10n.libraryWithRating,
                    _hasRating,
                    (value) => _hasRating = value,
                  ),
                  _flag(
                    context.l10n.missingRating,
                    _missingRating,
                    (value) => _missingRating = value,
                  ),
                  _flag(
                    context.l10n.libraryWithPlatform,
                    _hasPlatform,
                    (value) => _hasPlatform = value,
                  ),
                  _flag(
                    context.l10n.missingPlatform,
                    _missingPlatform,
                    (value) => _missingPlatform = value,
                  ),
                  _flag(
                    context.l10n.libraryWithGenre,
                    _hasGenre,
                    (value) => _hasGenre = value,
                  ),
                  _flag(
                    context.l10n.missingGenre,
                    _missingGenre,
                    (value) => _missingGenre = value,
                  ),
                  _flag(
                    context.l10n.libraryWithCompletedDate,
                    _hasCompletedDate,
                    (value) => _hasCompletedDate = value,
                  ),
                  _flag(
                    context.l10n.libraryMissingCompletedDate,
                    _missingCompletedDate,
                    (value) => _missingCompletedDate = value,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, const LibraryFilterState()),
          child: Text(context.l10n.clear),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _buildFilter()),
          child: Text(context.l10n.apply),
        ),
      ],
    );
  }

  Widget _catalogChips(
    List<LibraryCatalogItem> items,
    Set<String> selectedIds,
  ) {
    if (items.isEmpty) return Text(context.l10n.libraryNoOptions);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          FilterChip(
            label: Text(item.name),
            selected: selectedIds.contains(item.id),
            onSelected: (selected) {
              setState(() {
                selected
                    ? selectedIds.add(item.id)
                    : selectedIds.remove(item.id);
              });
            },
          ),
      ],
    );
  }

  Widget _flag(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: (selected) => setState(() => onChanged(selected)),
    );
  }

  LibraryFilterState _buildFilter() {
    return widget.initialFilter.copyWith(
      statuses: _statuses,
      platformIds: _platformIds,
      genreIds: _genreIds,
      minRating: _minRating,
      maxRating: _maxRating,
      releaseDateFrom: _releaseDateFrom,
      releaseDateTo: _releaseDateTo,
      completedDateFrom: _completedDateFrom,
      completedDateTo: _completedDateTo,
      minHours: _parseDouble(_minHoursController.text),
      maxHours: _parseDouble(_maxHoursController.text),
      type: _blankToNull(_typeController.text),
      hasRating: _hasRating,
      missingRating: _missingRating,
      hasPlatform: _hasPlatform,
      missingPlatform: _missingPlatform,
      hasGenre: _hasGenre,
      missingGenre: _missingGenre,
      hasCompletedDate: _hasCompletedDate,
      missingCompletedDate: _missingCompletedDate,
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _DateFilterTile extends StatelessWidget {
  const _DateFilterTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(formatVisibleDate(value)),
      trailing: Wrap(
        children: [
          IconButton(
            tooltip: context.l10n.libraryClearDate,
            onPressed: value == null ? null : () => onChanged(null),
            icon: const Icon(Icons.clear),
          ),
          IconButton(
            tooltip: context.l10n.libraryChooseDate,
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(1970),
                lastDate: DateTime(2100),
              );
              if (picked != null) onChanged(picked);
            },
            icon: const Icon(Icons.calendar_today_outlined),
          ),
        ],
      ),
    );
  }
}

class _ColumnsDialog extends StatefulWidget {
  const _ColumnsDialog({required this.initialConfig});

  final LibraryColumnConfig initialConfig;

  @override
  State<_ColumnsDialog> createState() => _ColumnsDialogState();
}

class _ColumnsDialogState extends State<_ColumnsDialog> {
  late LibraryColumnConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(context.l10n.libraryVisibleColumns),
      content: SizedBox(
        width: 360,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final column in LibraryColumnConfig.allColumns)
              CheckboxListTile(
                value: _config.isVisible(column),
                onChanged:
                    column == LibraryColumnKey.title
                        ? null
                        : (value) =>
                            setState(() => _config = _config.toggle(column)),
                title: Text(context.l10n.libraryColumnLabel(column)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _config),
          child: Text(context.l10n.apply),
        ),
      ],
    );
  }
}

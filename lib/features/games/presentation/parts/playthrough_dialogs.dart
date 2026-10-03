part of '../game_detail_page.dart';

class _CompletionDialog extends StatefulWidget {
  const _CompletionDialog({required this.item});

  final LibraryGameDetails item;

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  DateTime? _completedAt;
  String? _platformId;
  int? _rating;
  final _hoursController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _platformId = widget.item.entry.playedPlatformId;
    _completedAt = widget.item.entry.completedAt;
    _hoursController.text = widget.item.entry.hoursPlayed?.toString() ?? '';
    _notesController.text = widget.item.entry.personalNotes ?? '';
    _rating = widget.item.entry.personalRating;
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(context.l10n.gameMarkCompletedTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DatePickerTile(
              label: context.l10n.gameCompletionDate,
              value: _completedAt,
              allowClear: true,
              onChanged: (value) {
                setState(() => _completedAt = value);
              },
            ),
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.gameHoursPlayed,
              ),
            ),
            const SizedBox(height: 12),
            _RatingField(
              value: _rating,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 12),
            _PlatformField(
              platformId: _platformId,
              platforms: widget.item.platforms,
              onChanged: (value) => setState(() => _platformId = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: context.l10n.gameNote),
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
          onPressed:
              () => Navigator.pop(
                context,
                CompletionFormModel(
                  libraryEntryId: widget.item.entry.id,
                  completedAt: _completedAt,
                  platformId: _platformId,
                  hoursPlayed: double.tryParse(
                    _hoursController.text.trim().replaceAll(',', '.'),
                  ),
                  rating: _rating,
                  notes: _notesController.text,
                ),
              ),
          child: Text(context.l10n.gameComplete),
        ),
      ],
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.allowClear = true,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(formatVisibleDate(value)),
      trailing: Wrap(
        children: [
          if (allowClear)
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

class _RatingField extends StatelessWidget {
  const _RatingField({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      initialValue: value,
      decoration: InputDecoration(labelText: context.l10n.columnRating),
      items: [
        DropdownMenuItem(value: null, child: Text(context.l10n.ratingNone)),
        DropdownMenuItem(value: 1, child: Text(context.l10n.ratingOneStar)),
        for (var rating = 2; rating <= 5; rating++)
          DropdownMenuItem(
            value: rating,
            child: Text(context.l10n.ratingStars(rating)),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _PlatformField extends StatelessWidget {
  const _PlatformField({
    required this.platformId,
    required this.platforms,
    required this.onChanged,
  });

  final String? platformId;
  final List<CatalogItem> platforms;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final safePlatformId =
        platforms.any((platform) => platform.id == platformId)
            ? platformId
            : null;
    return DropdownButtonFormField<String?>(
      isExpanded: true,
      initialValue: safePlatformId,
      decoration: InputDecoration(labelText: context.l10n.gamePlatform),
      items: [
        DropdownMenuItem(value: null, child: Text(context.l10n.gameNoPlatform)),
        for (final platform in platforms)
          DropdownMenuItem(value: platform.id, child: Text(platform.name)),
      ],
      onChanged: onChanged,
    );
  }
}

String _playthroughSubtitle(
  BuildContext context,
  PlaythroughDetails playthrough,
  List<CatalogItem> platforms,
) {
  final parts =
      [
        _platformName(platforms, playthrough.platformId),
        if (playthrough.startedAt != null)
          context.l10n.gamePlaythroughStart(
            formatVisibleDate(playthrough.startedAt),
          ),
        if (playthrough.completedAt != null)
          context.l10n.gamePlaythroughEnd(
            formatVisibleDate(playthrough.completedAt),
          ),
        if (playthrough.hoursPlayed != null)
          context.l10n.hoursShort(playthrough.hoursPlayed!.toStringAsFixed(1)),
        if (playthrough.rating != null) '${playthrough.rating}/5',
        if (playthrough.notes?.trim().isNotEmpty ?? false)
          playthrough.notes!.trim(),
      ].where((value) => value != '-').toList();
  return parts.isEmpty ? '-' : parts.join(' · ');
}

String _platformName(List<CatalogItem> platforms, String? platformId) {
  if (platformId == null) return '-';
  for (final platform in platforms) {
    if (platform.id == platformId) return platform.name;
  }
  return '-';
}

BvChipTone _statusTone(GameStatus status) {
  return switch (status) {
    GameStatus.completed || GameStatus.playing => BvChipTone.primary,
    GameStatus.paused => BvChipTone.warning,
    GameStatus.dropped || GameStatus.retired => BvChipTone.danger,
    GameStatus.wishlist || GameStatus.backlog => BvChipTone.neutral,
  };
}

String _names(Iterable<String> values) {
  final list = values.toList();
  if (list.isEmpty) return '-';
  return list.join(', ');
}

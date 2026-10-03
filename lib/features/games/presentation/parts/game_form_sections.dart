part of '../game_form_page.dart';

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      child: BvSection(
        title: title,
        subtitle: subtitle,
        padding: EdgeInsets.zero,
        child: child,
      ),
    );
  }
}

class _FormFieldGrid extends StatelessWidget {
  const _FormFieldGrid({required this.children, required this.twoColumns});

  final List<Widget> children;
  final bool twoColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!twoColumns || constraints.maxWidth < 560) {
          return Column(
            children: [
              for (final child in children) ...[
                child,
                if (child != children.last)
                  const SizedBox(height: BvSpacing.sm),
              ],
            ],
          );
        }
        return Wrap(
          spacing: BvSpacing.sm,
          runSpacing: BvSpacing.sm,
          children: [
            for (final child in children)
              SizedBox(
                width: (constraints.maxWidth - BvSpacing.sm) / 2,
                child: child,
              ),
          ],
        );
      },
    );
  }
}

class _MetadataSearchButton extends StatelessWidget {
  const _MetadataSearchButton({
    required this.saving,
    required this.pendingCoverAsset,
    required this.onSearch,
    required this.onClearCover,
  });

  final bool saving;
  final ExternalMediaAsset? pendingCoverAsset;
  final VoidCallback onSearch;
  final VoidCallback onClearCover;

  @override
  Widget build(BuildContext context) {
    return BvSurface(
      padding: const EdgeInsets.all(BvSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: saving ? null : onSearch,
            icon: const Icon(Icons.auto_fix_high_outlined),
            label: Text(context.l10n.gameSearchMetadata),
          ),
          if (pendingCoverAsset != null) ...[
            const SizedBox(height: BvSpacing.xs),
            BvChip(
              icon: Icons.image_outlined,
              label: context.l10n.gamePendingCover(
                pendingCoverAsset!.providerName,
              ),
              tone: BvChipTone.primary,
              onDeleted: onClearCover,
            ),
          ],
        ],
      ),
    );
  }
}

class _SaveActionBar extends StatelessWidget {
  const _SaveActionBar({required this.saving, required this.onSave});

  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      dense: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BvAsyncActionButton(
            label: context.l10n.save,
            icon: Icons.save_outlined,
            onPressed: onSave,
            busy: saving,
            busyLabel: context.l10n.loading,
            minimumWidth: 180,
          ),
        ],
      ),
    );
  }
}

String _joinNames(Iterable<String> values) {
  final list = values.where((value) => value.trim().isNotEmpty).toList();
  if (list.isEmpty) return '-';
  return list.join(', ');
}

List<DropdownMenuItem<int?>> _ratingItems(BuildContext context) {
  return [
    DropdownMenuItem(value: null, child: Text(context.l10n.ratingNone)),
    DropdownMenuItem(value: 1, child: Text(context.l10n.ratingOneStar)),
    for (var rating = 2; rating <= 5; rating++)
      DropdownMenuItem(
        value: rating,
        child: Text(context.l10n.ratingStars(rating)),
      ),
  ];
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 280;
          final actions = [
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: value ?? DateTime.now(),
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2100),
                );
                if (picked != null) onChanged(picked);
              },
              child: Text(context.l10n.choose),
            ),
            if (value != null)
              IconButton(
                tooltip: context.l10n.clear,
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.clear),
              ),
          ];

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatVisibleDate(value)),
                const SizedBox(height: BvSpacing.xs),
                Wrap(
                  spacing: BvSpacing.xs,
                  runSpacing: BvSpacing.xs,
                  children: actions,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: Text(formatVisibleDate(value))),
              ...actions,
            ],
          );
        },
      ),
    );
  }
}

class _CatalogSelector extends StatelessWidget {
  const _CatalogSelector({
    required this.title,
    required this.addLabel,
    required this.controller,
    required this.items,
    required this.selectedIds,
    required this.pendingNames,
    required this.onToggle,
    required this.onCreate,
    required this.onRemovePending,
  });

  final String title;
  final String addLabel;
  final TextEditingController controller;
  final Map<String, String> items;
  final Set<String> selectedIds;
  final Set<String> pendingNames;
  final void Function(String id, bool selected) onToggle;
  final Future<void> Function() onCreate;
  final ValueChanged<String> onRemovePending;

  @override
  Widget build(BuildContext context) {
    final bv = BvThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: BvSpacing.xs),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items.entries)
              FilterChip(
                label: Text(item.value),
                selected: selectedIds.contains(item.key),
                onSelected: (selected) => onToggle(item.key, selected),
              ),
            for (final name in pendingNames)
              BvChip(
                label: name,
                icon: Icons.auto_fix_high_outlined,
                tone: BvChipTone.primary,
                onDeleted: () => onRemovePending(name),
              ),
          ],
        ),
        const SizedBox(height: BvSpacing.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 360;
            final addButton = IconButton.filledTonal(
              tooltip: addLabel,
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: bv.surfaceHighest,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            );

            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: addLabel),
                  ),
                  const SizedBox(height: BvSpacing.xs),
                  Align(alignment: Alignment.centerRight, child: addButton),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: addLabel),
                  ),
                ),
                const SizedBox(width: BvSpacing.xs),
                addButton,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PersonalTrackingFields extends StatelessWidget {
  const _PersonalTrackingFields({
    required this.completedAt,
    required this.hoursController,
    required this.platformId,
    required this.platforms,
    required this.twoColumns,
    required this.onDateChanged,
    required this.onPlatformChanged,
  });

  final DateTime? completedAt;
  final TextEditingController hoursController;
  final String? platformId;
  final Map<String, String> platforms;
  final bool twoColumns;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<String?> onPlatformChanged;

  @override
  Widget build(BuildContext context) {
    final safePlatformId = safeDropdownValue<String?>(platformId, [
      null,
      ...platforms.keys,
    ]);
    return _FormFieldGrid(
      twoColumns: twoColumns,
      children: [
        _DateField(
          label: context.l10n.gameCompletionDate,
          value: completedAt,
          onChanged: onDateChanged,
        ),
        TextFormField(
          controller: hoursController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final hours = double.tryParse(value.trim().replaceAll(',', '.'));
            return hours == null || !hours.isFinite || hours < 0
                ? context.l10n.gameHoursInvalid
                : null;
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: context.l10n.gameHoursPlayed),
        ),
        DropdownButtonFormField<String?>(
          isExpanded: true,
          initialValue: safePlatformId,
          decoration: InputDecoration(
            labelText: context.l10n.gamePlayedPlatform,
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(context.l10n.gameNoPlatform),
            ),
            for (final platform in platforms.entries)
              DropdownMenuItem(
                value: platform.key,
                child: Text(platform.value),
              ),
          ],
          onChanged: onPlatformChanged,
        ),
      ],
    );
  }
}

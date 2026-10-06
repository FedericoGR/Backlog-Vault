part of '../settings_page.dart';

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.loading});
  final bool loading;

  @override
  Widget build(BuildContext context) => BvSection(
    title: context.l10n.settingsLibraryData,
    padding: EdgeInsets.zero,
    child: Text(
      context.l10n.settingsLocalStatusSubtitle,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _ActionShortcuts extends ConsumerStatefulWidget {
  const _ActionShortcuts({required this.loading});
  final bool loading;
  @override
  ConsumerState<_ActionShortcuts> createState() => _ActionShortcutsState();
}

class _ActionShortcutsState extends ConsumerState<_ActionShortcuts> {
  bool _exporting = false;

  Future<void> _exportLibrary() async {
    setState(() => _exporting = true);
    final outcome = await ref.read(libraryExportControllerProvider).execute();
    if (!mounted) return;
    setState(() => _exporting = false);

    final l10n = context.l10n;
    final message = switch (outcome.status) {
      LibraryExportStatus.saved => l10n.libraryExportSucceeded,
      LibraryExportStatus.cancelled => l10n.libraryExportCancelled,
      LibraryExportStatus.failed => l10n.libraryExportFailed,
    };
    BvFeedback.show(context, message);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BvAsyncActionButton(
        label: context.l10n.settingsExportLibrary,
        icon: Icons.file_download_outlined,
        onPressed: widget.loading ? null : _exportLibrary,
        busy: _exporting,
        busyLabel: context.l10n.loading,
      ),
      const SizedBox(height: 8),
      Text(
        context.l10n.settingsLibraryDataSubtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: BvThemeExtension.of(context).textMuted,
        ),
      ),
    ],
  );
}

class _ConfigurationPanel extends StatelessWidget {
  const _ConfigurationPanel({
    required this.title,
    required this.subtitle,
    required this.configured,
    required this.loading,
    required this.error,
    required this.fields,
    required this.actions,
  });
  final String title;
  final String subtitle;
  final bool configured;
  final bool loading;
  final bool error;
  final List<Widget> fields;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: Column(
      children: [
        ExpansionTile(
          key: ValueKey('settings-$title'),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 8, bottom: 24),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            error
                ? context.l10n.errorTitle
                : loading
                ? context.l10n.loading
                : configured
                ? context.l10n.settingsConfigured
                : context.l10n.settingsPending,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BvThemeExtension.of(context).textMuted,
            ),
          ),
          children: [
            Align(alignment: Alignment.centerLeft, child: Text(subtitle)),
            const SizedBox(height: 16),
            ...fields,
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(spacing: 8, runSpacing: 8, children: actions),
            ),
          ],
        ),
        const Divider(),
      ],
    ),
  );
}

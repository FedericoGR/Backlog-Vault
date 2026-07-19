part of '../settings_page.dart';

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bv = BvThemeExtension.of(context);
    final l10n = context.l10n;
    return BvPanel(
      child: BvSection(
        title: l10n.settingsLocalStatusTitle,
        subtitle: l10n.settingsLocalStatusSubtitle,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BvKeyValueRow(
              label: l10n.settingsAccountRequired,
              value: l10n.no,
              leading: Icons.lock_outline,
            ),
            BvKeyValueRow(
              label: l10n.settingsUsageMode,
              value: 'Offline-first',
              leading: Icons.wifi_off_outlined,
            ),
            BvKeyValueRow(
              label: l10n.settingsLocalDatabase,
              value: 'SQLite + Drift',
              leading: Icons.storage_outlined,
            ),
            BvKeyValueRow(
              label: l10n.settingsLoadingStatus,
              value: loading ? l10n.settingsLoadingConfiguration : l10n.ready,
              valueColor: loading ? bv.warning : null,
              leading: Icons.hourglass_top_outlined,
            ),
            const SizedBox(height: BvSpacing.sm),
            BvStatusBanner(
              tone: BvBannerTone.warning,
              title: l10n.settingsPrivacyProtection,
              message: l10n.settingsPrivacyProtectionMessage,
            ),
          ],
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final compact = MediaQuery.sizeOf(context).width < 860;
    final dataCard = BvActionCard(
      title: l10n.settingsLibraryData,
      subtitle: l10n.settingsLibraryDataSubtitle,
      icon: Icons.download_outlined,
      emphasized: true,
      actions: [
        BvAsyncActionButton(
          label: l10n.settingsExportLibrary,
          icon: Icons.file_download_outlined,
          onPressed: widget.loading ? null : _exportLibrary,
          busy: _exporting,
          busyLabel: l10n.loading,
        ),
      ],
    );
    final notesCard = BvActionCard(
      title: l10n.settingsGoodPractices,
      subtitle: l10n.settingsGoodPracticesSubtitle,
      icon: Icons.shield_outlined,
    );

    if (compact) {
      return Column(
        children: [dataCard, const SizedBox(height: BvSpacing.md), notesCard],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: dataCard),
        const SizedBox(width: BvSpacing.md),
        Expanded(child: notesCard),
      ],
    );
  }
}

class _ConfigurationPanel extends StatelessWidget {
  const _ConfigurationPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.configured,
    required this.loading,
    required this.fields,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool configured;
  final bool loading;
  final List<Widget> fields;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      child: BvSection(
        title: title,
        subtitle: subtitle,
        padding: EdgeInsets.zero,
        trailing: _ConfigPill(configured: configured, loading: loading),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: BvSpacing.sm),
                Expanded(
                  child: Text(
                    configured
                        ? context.l10n.settingsConfigurationPresent
                        : context.l10n.settingsConfigurationPending,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BvSpacing.md),
            ...fields,
            const SizedBox(height: BvSpacing.md),
            Wrap(
              spacing: BvSpacing.xs,
              runSpacing: BvSpacing.xs,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigPill extends StatelessWidget {
  const _ConfigPill({required this.configured, required this.loading});

  final bool configured;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bv = BvThemeExtension.of(context);
    final theme = Theme.of(context);
    final background =
        loading
            ? bv.surfaceHighest
            : configured
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.74)
            : bv.dangerContainer;
    final foreground =
        loading
            ? theme.colorScheme.onSurfaceVariant
            : configured
            ? theme.colorScheme.onPrimaryContainer
            : bv.danger;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BvSpacing.sm,
          vertical: BvSpacing.xs,
        ),
        child: Text(
          loading
              ? context.l10n.loading
              : configured
              ? context.l10n.settingsConfigured
              : context.l10n.settingsPending,
          style: theme.textTheme.labelLarge?.copyWith(color: foreground),
        ),
      ),
    );
  }
}

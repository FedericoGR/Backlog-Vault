import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_action_card.dart';
import '../../../core/design_system/bv_danger_zone.dart';
import '../../../core/design_system/bv_key_value_row.dart';
import '../../../core/design_system/bv_page_scaffold.dart';
import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_status_banner.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../l10n/l10n.dart';
import '../../metadata/data/metadata_api_key_storage.dart';
import '../../sync/presentation/manual_sync_section.dart';
import '../application/app_language.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _rawgApiKeyController = TextEditingController();
  final _igdbClientIdController = TextEditingController();
  final _igdbClientSecretController = TextEditingController();
  final _steamGridDbApiKeyController = TextEditingController();
  bool _loading = true;
  bool _rawgConfigured = false;
  bool _igdbConfigured = false;
  bool _steamGridDbConfigured = false;

  @override
  void initState() {
    super.initState();
    _loadApiKeyState();
  }

  @override
  void dispose() {
    _rawgApiKeyController.dispose();
    _igdbClientIdController.dispose();
    _igdbClientSecretController.dispose();
    _steamGridDbApiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = ref
        .watch(appLanguageProvider)
        .when(
          data: (value) => value,
          loading: () => AppLanguagePreference.system,
          error: (_, _) => AppLanguagePreference.system,
        );
    return BvPageScaffold(
      title: l10n.settingsTitle,
      body: ListView(
        children: [
          _OverviewSection(loading: _loading),
          const SizedBox(height: BvSpacing.md),
          _ActionShortcuts(loading: _loading),
          const SizedBox(height: BvSpacing.md),
          const ManualSyncSection(),
          const SizedBox(height: BvSpacing.md),
          _ConfigurationPanel(
            title: 'RAWG',
            subtitle: l10n.settingsRawgSubtitle,
            icon: Icons.vpn_key_outlined,
            configured: _rawgConfigured,
            loading: _loading,
            fields: [
              TextField(
                controller: _rawgApiKeyController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.settingsNewApiKey,
                  helperText: l10n.settingsApiKeyHelper,
                ),
              ),
            ],
            actions: [
              FilledButton.icon(
                onPressed: _loading ? null : _saveRawgApiKey,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.save),
              ),
              OutlinedButton.icon(
                onPressed:
                    _loading || !_rawgConfigured ? null : _deleteRawgApiKey,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.delete),
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          _ConfigurationPanel(
            title: 'IGDB / Twitch',
            subtitle: l10n.settingsIgdbSubtitle,
            icon: Icons.cloud_sync_outlined,
            configured: _igdbConfigured,
            loading: _loading,
            fields: [
              TextField(
                controller: _igdbClientIdController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Client ID',
                  helperText: l10n.settingsClientIdHelper,
                ),
              ),
              const SizedBox(height: BvSpacing.sm),
              TextField(
                controller: _igdbClientSecretController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Client Secret',
                  helperText: l10n.settingsClientSecretHelper,
                ),
              ),
            ],
            actions: [
              FilledButton.icon(
                onPressed: _loading ? null : _saveIgdbCredentials,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.save),
              ),
              OutlinedButton.icon(
                onPressed:
                    _loading || !_igdbConfigured
                        ? null
                        : _deleteIgdbCredentials,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.delete),
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          _ConfigurationPanel(
            title: 'SteamGridDB',
            subtitle: l10n.settingsSteamGridDbSubtitle,
            icon: Icons.image_search_outlined,
            configured: _steamGridDbConfigured,
            loading: _loading,
            fields: [
              TextField(
                controller: _steamGridDbApiKeyController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.settingsNewApiKey,
                  helperText: l10n.settingsMediaApiKeyHelper,
                ),
              ),
            ],
            actions: [
              FilledButton.icon(
                onPressed: _loading ? null : _saveSteamGridDbApiKey,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.save),
              ),
              OutlinedButton.icon(
                onPressed:
                    _loading || !_steamGridDbConfigured
                        ? null
                        : _deleteSteamGridDbApiKey,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.delete),
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          BvPanel(
            child: BvSection(
              title: l10n.language,
              subtitle: l10n.languageDescription,
              padding: EdgeInsets.zero,
              child: DropdownButtonFormField<AppLanguagePreference>(
                key: ValueKey(language),
                initialValue: language,
                decoration: InputDecoration(labelText: l10n.language),
                items: [
                  DropdownMenuItem(
                    value: AppLanguagePreference.system,
                    child: Text(l10n.languageSystem),
                  ),
                  DropdownMenuItem(
                    value: AppLanguagePreference.spanish,
                    child: Text(l10n.languageSpanish),
                  ),
                  DropdownMenuItem(
                    value: AppLanguagePreference.english,
                    child: Text(l10n.languageEnglish),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(appLanguageProvider.notifier).setPreference(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: BvSpacing.md),
          BvDangerZone(
            title: l10n.settingsExternalKeysDeletion,
            message: l10n.settingsExternalKeysDeletionMessage,
            actions: [
              OutlinedButton.icon(
                onPressed:
                    _loading ||
                            (!_rawgConfigured &&
                                !_igdbConfigured &&
                                !_steamGridDbConfigured)
                        ? null
                        : _deleteAllExternalApiKeys,
                icon: const Icon(Icons.key_off_outlined),
                label: Text(l10n.settingsDeleteAllKeys),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadApiKeyState() async {
    final storage = ref.read(metadataApiKeyStorageProvider);
    final rawgValue = await storage.readRawgApiKey();
    final igdbClientId = await storage.readIgdbClientId();
    final igdbClientSecret = await storage.readIgdbClientSecret();
    final steamGridDbValue = await storage.readSteamGridDbApiKey();
    if (!mounted) return;
    setState(() {
      _rawgConfigured = rawgValue != null;
      _igdbConfigured = igdbClientId != null && igdbClientSecret != null;
      _steamGridDbConfigured = steamGridDbValue != null;
      _loading = false;
    });
  }

  Future<void> _saveRawgApiKey() async {
    final value = _rawgApiKeyController.text.trim();
    if (value.isEmpty) {
      _showMessage(context.l10n.settingsEnterApiKey);
      return;
    }
    setState(() => _loading = true);
    await ref.read(metadataApiKeyStorageProvider).saveRawgApiKey(value);
    _rawgApiKeyController.clear();
    if (!mounted) return;
    setState(() {
      _rawgConfigured = true;
      _loading = false;
    });
    _showMessage(context.l10n.settingsRawgSaved);
  }

  Future<void> _deleteRawgApiKey() async {
    setState(() => _loading = true);
    await ref.read(metadataApiKeyStorageProvider).deleteRawgApiKey();
    if (!mounted) return;
    setState(() {
      _rawgConfigured = false;
      _loading = false;
    });
    _showMessage(context.l10n.settingsRawgDeleted);
  }

  Future<void> _saveIgdbCredentials() async {
    final clientId = _igdbClientIdController.text.trim();
    final clientSecret = _igdbClientSecretController.text.trim();
    if (clientId.isEmpty || clientSecret.isEmpty) {
      _showMessage(context.l10n.settingsEnterIgdbCredentials);
      return;
    }
    setState(() => _loading = true);
    final storage = ref.read(metadataApiKeyStorageProvider);
    await storage.saveIgdbClientId(clientId);
    await storage.saveIgdbClientSecret(clientSecret);
    await storage.deleteIgdbAccessToken();
    _igdbClientIdController.clear();
    _igdbClientSecretController.clear();
    if (!mounted) return;
    setState(() {
      _igdbConfigured = true;
      _loading = false;
    });
    _showMessage(context.l10n.settingsIgdbSaved);
  }

  Future<void> _deleteIgdbCredentials() async {
    setState(() => _loading = true);
    final storage = ref.read(metadataApiKeyStorageProvider);
    await storage.deleteIgdbClientId();
    await storage.deleteIgdbClientSecret();
    await storage.deleteIgdbAccessToken();
    if (!mounted) return;
    setState(() {
      _igdbConfigured = false;
      _loading = false;
    });
    _showMessage(context.l10n.settingsIgdbDeleted);
  }

  Future<void> _saveSteamGridDbApiKey() async {
    final value = _steamGridDbApiKeyController.text.trim();
    if (value.isEmpty) {
      _showMessage(context.l10n.settingsEnterApiKey);
      return;
    }
    setState(() => _loading = true);
    await ref.read(metadataApiKeyStorageProvider).saveSteamGridDbApiKey(value);
    _steamGridDbApiKeyController.clear();
    if (!mounted) return;
    setState(() {
      _steamGridDbConfigured = true;
      _loading = false;
    });
    _showMessage(context.l10n.settingsSteamGridDbSaved);
  }

  Future<void> _deleteSteamGridDbApiKey() async {
    setState(() => _loading = true);
    await ref.read(metadataApiKeyStorageProvider).deleteSteamGridDbApiKey();
    if (!mounted) return;
    setState(() {
      _steamGridDbConfigured = false;
      _loading = false;
    });
    _showMessage(context.l10n.settingsSteamGridDbDeleted);
  }

  Future<void> _deleteAllExternalApiKeys() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.settingsDeleteExternalKeysTitle),
            content: Text(l10n.settingsDeleteExternalKeysConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.settingsDeleteKeys),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    setState(() => _loading = true);
    await ref.read(metadataApiKeyStorageProvider).deleteAllExternalApiKeys();
    _rawgApiKeyController.clear();
    _igdbClientIdController.clear();
    _igdbClientSecretController.clear();
    _steamGridDbApiKeyController.clear();
    if (!mounted) return;
    setState(() {
      _rawgConfigured = false;
      _igdbConfigured = false;
      _steamGridDbConfigured = false;
      _loading = false;
    });
    _showMessage(context.l10n.settingsExternalKeysDeleted);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

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
              leading: Icons.sync_outlined,
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

class _ActionShortcuts extends StatelessWidget {
  const _ActionShortcuts({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final compact = MediaQuery.sizeOf(context).width < 860;
    final backupCard = BvActionCard(
      title: l10n.settingsDataBackups,
      subtitle: l10n.settingsDataBackupsSubtitle,
      icon: Icons.archive_outlined,
      emphasized: true,
      actions: [
        FilledButton.icon(
          onPressed: loading ? null : () => context.go('/settings/backups'),
          icon: const Icon(Icons.chevron_right),
          label: Text(l10n.settingsOpenBackups),
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
        children: [backupCard, const SizedBox(height: BvSpacing.md), notesCard],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: backupCard),
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

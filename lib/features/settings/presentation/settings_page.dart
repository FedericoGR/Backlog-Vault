import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/bv_async_action_button.dart';
import '../../../core/design_system/bv_feedback.dart';
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../l10n/l10n.dart';
import '../../import_export/library_export/application/library_export_controller.dart';
import '../application/app_language.dart';
import '../application/external_credentials_view_model.dart';

part 'parts/settings_sections.dart';

/// Presents local preferences, provider credentials, and maintenance actions.
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
    final credentials = ref.watch(externalCredentialsProvider);
    final credentialState =
        credentials.value ?? const ExternalCredentialsState();
    final loading = credentials.isLoading;
    final language = ref
        .watch(appLanguageProvider)
        .when(
          data: (value) => value,
          loading: () => AppLanguagePreference.system,
          error: (_, _) => AppLanguagePreference.system,
        );
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                l10n.settingsTitle.toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(letterSpacing: 1.6),
              ),
              const SizedBox(height: 28),
              _OverviewSection(loading: loading),
              const SizedBox(height: BvSpacing.md),
              _ActionShortcuts(loading: loading),
              const SizedBox(height: BvSpacing.md),
              const SizedBox(height: 20),
              Text(
                l10n.settingsMetadataSources,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              _ConfigurationPanel(
                title: 'RAWG',
                subtitle: l10n.settingsRawgSubtitle,

                configured: credentialState.rawgConfigured,
                loading: loading,
                error: credentials.hasError,
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
                    onPressed: loading ? null : _saveRawgApiKey,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(l10n.save),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        loading || !credentialState.rawgConfigured
                            ? null
                            : _deleteRawgApiKey,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.delete),
                  ),
                ],
              ),
              const SizedBox(height: BvSpacing.md),
              _ConfigurationPanel(
                title: 'IGDB / Twitch',
                subtitle: l10n.settingsIgdbSubtitle,

                configured: credentialState.igdbConfigured,
                loading: loading,
                error: credentials.hasError,
                fields: [
                  TextField(
                    controller: _igdbClientIdController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.settingsClientId,
                      helperText: l10n.settingsClientIdHelper,
                    ),
                  ),
                  const SizedBox(height: BvSpacing.sm),
                  TextField(
                    controller: _igdbClientSecretController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.settingsClientSecret,
                      helperText: l10n.settingsClientSecretHelper,
                    ),
                  ),
                ],
                actions: [
                  FilledButton.icon(
                    onPressed: loading ? null : _saveIgdbCredentials,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(l10n.save),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        loading || !credentialState.igdbConfigured
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

                configured: credentialState.steamGridDbConfigured,
                loading: loading,
                error: credentials.hasError,
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
                    onPressed: loading ? null : _saveSteamGridDbApiKey,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(l10n.save),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        loading || !credentialState.steamGridDbConfigured
                            ? null
                            : _deleteSteamGridDbApiKey,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.delete),
                  ),
                ],
              ),
              const SizedBox(height: BvSpacing.md),
              Text(
                l10n.settingsApplication,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppLanguagePreference>(
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
              const SizedBox(height: BvSpacing.md),
              const SizedBox(height: 20),
              Text(
                l10n.settingsPrivacyProtectionMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed:
                        loading ||
                                (!credentialState.rawgConfigured &&
                                    !credentialState.igdbConfigured &&
                                    !credentialState.steamGridDbConfigured)
                            ? null
                            : _deleteAllExternalApiKeys,
                    icon: const Icon(Icons.key_off_outlined),
                    label: Text(l10n.settingsDeleteAllKeys),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveRawgApiKey() async {
    final value = _rawgApiKeyController.text.trim();
    if (value.isEmpty) {
      _showMessage(context.l10n.settingsEnterApiKey);
      return;
    }
    await ref.read(externalCredentialsProvider.notifier).saveRawg(value);
    _rawgApiKeyController.clear();
    if (!mounted) return;
    _showMessage(context.l10n.settingsRawgSaved);
  }

  Future<void> _deleteRawgApiKey() async {
    await ref.read(externalCredentialsProvider.notifier).deleteRawg();
    if (!mounted) return;
    _showMessage(context.l10n.settingsRawgDeleted);
  }

  Future<void> _saveIgdbCredentials() async {
    final clientId = _igdbClientIdController.text.trim();
    final clientSecret = _igdbClientSecretController.text.trim();
    if (clientId.isEmpty || clientSecret.isEmpty) {
      _showMessage(context.l10n.settingsEnterIgdbCredentials);
      return;
    }
    await ref
        .read(externalCredentialsProvider.notifier)
        .saveIgdb(clientId, clientSecret);
    _igdbClientIdController.clear();
    _igdbClientSecretController.clear();
    if (!mounted) return;
    _showMessage(context.l10n.settingsIgdbSaved);
  }

  Future<void> _deleteIgdbCredentials() async {
    await ref.read(externalCredentialsProvider.notifier).deleteIgdb();
    if (!mounted) return;
    _showMessage(context.l10n.settingsIgdbDeleted);
  }

  Future<void> _saveSteamGridDbApiKey() async {
    final value = _steamGridDbApiKeyController.text.trim();
    if (value.isEmpty) {
      _showMessage(context.l10n.settingsEnterApiKey);
      return;
    }
    await ref.read(externalCredentialsProvider.notifier).saveSteamGridDb(value);
    _steamGridDbApiKeyController.clear();
    if (!mounted) return;
    _showMessage(context.l10n.settingsSteamGridDbSaved);
  }

  Future<void> _deleteSteamGridDbApiKey() async {
    await ref.read(externalCredentialsProvider.notifier).deleteSteamGridDb();
    if (!mounted) return;
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
    await ref.read(externalCredentialsProvider.notifier).deleteAll();
    _rawgApiKeyController.clear();
    _igdbClientIdController.clear();
    _igdbClientSecretController.clear();
    _steamGridDbApiKeyController.clear();
    if (!mounted) return;
    _showMessage(context.l10n.settingsExternalKeysDeleted);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    BvFeedback.show(context, message);
  }
}

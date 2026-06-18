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
import '../../metadata/data/metadata_api_key_storage.dart';

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
    return BvPageScaffold(
      title: 'Ajustes',
      body: ListView(
        children: [
          _OverviewSection(loading: _loading),
          const SizedBox(height: BvSpacing.md),
          _ActionShortcuts(loading: _loading),
          const SizedBox(height: BvSpacing.md),
          _ConfigurationPanel(
            title: 'RAWG',
            subtitle:
                'Fuente opcional para completar metadata de juegos. La clave se guarda localmente en el secure storage del sistema.',
            icon: Icons.vpn_key_outlined,
            configured: _rawgConfigured,
            loading: _loading,
            fields: [
              TextField(
                controller: _rawgApiKeyController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva API key',
                  helperText:
                      'No se exporta en backups, no se muestra en claro y no debe terminar en commits.',
                ),
              ),
            ],
            actions: [
              FilledButton.icon(
                onPressed: _loading ? null : _saveRawgApiKey,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar'),
              ),
              OutlinedButton.icon(
                onPressed:
                    _loading || !_rawgConfigured ? null : _deleteRawgApiKey,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Borrar'),
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          _ConfigurationPanel(
            title: 'IGDB / Twitch',
            subtitle:
                'Client credentials para consultar IGDB. El access token se renueva localmente y el secret no se expone en pantalla.',
            icon: Icons.cloud_sync_outlined,
            configured: _igdbConfigured,
            loading: _loading,
            fields: [
              TextField(
                controller: _igdbClientIdController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Client ID',
                  helperText:
                      'Se guarda solo en el equipo actual y no viaja en backups.',
                ),
              ),
              const SizedBox(height: BvSpacing.sm),
              TextField(
                controller: _igdbClientSecretController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Client Secret',
                  helperText: 'No lo pegues en logs, README, tests ni issues.',
                ),
              ),
            ],
            actions: [
              FilledButton.icon(
                onPressed: _loading ? null : _saveIgdbCredentials,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar'),
              ),
              OutlinedButton.icon(
                onPressed:
                    _loading || !_igdbConfigured
                        ? null
                        : _deleteIgdbCredentials,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Borrar'),
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          _ConfigurationPanel(
            title: 'SteamGridDB',
            subtitle:
                'Clave opcional para buscar portadas. Backlog Vault sigue pidiendo confirmación explícita antes de guardar covers.',
            icon: Icons.image_search_outlined,
            configured: _steamGridDbConfigured,
            loading: _loading,
            fields: [
              TextField(
                controller: _steamGridDbApiKeyController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva API key',
                  helperText:
                      'Se usa solo para búsqueda de media y se mantiene local.',
                ),
              ),
            ],
            actions: [
              FilledButton.icon(
                onPressed: _loading ? null : _saveSteamGridDbApiKey,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar'),
              ),
              OutlinedButton.icon(
                onPressed:
                    _loading || !_steamGridDbConfigured
                        ? null
                        : _deleteSteamGridDbApiKey,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Borrar'),
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          BvDangerZone(
            title: 'Borrado de claves externas',
            message:
                'Solo elimina credenciales guardadas localmente. No toca juegos, metadata ya aplicada, external IDs ni portadas almacenadas.',
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
                label: const Text('Borrar todas las claves'),
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
      _showMessage('Ingresá una API key antes de guardar.');
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
    _showMessage('API key de RAWG guardada localmente.');
  }

  Future<void> _deleteRawgApiKey() async {
    setState(() => _loading = true);
    await ref.read(metadataApiKeyStorageProvider).deleteRawgApiKey();
    if (!mounted) return;
    setState(() {
      _rawgConfigured = false;
      _loading = false;
    });
    _showMessage('API key de RAWG borrada.');
  }

  Future<void> _saveIgdbCredentials() async {
    final clientId = _igdbClientIdController.text.trim();
    final clientSecret = _igdbClientSecretController.text.trim();
    if (clientId.isEmpty || clientSecret.isEmpty) {
      _showMessage('Ingresá Client ID y Client Secret antes de guardar.');
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
    _showMessage('Credenciales de IGDB guardadas localmente.');
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
    _showMessage('Credenciales de IGDB borradas.');
  }

  Future<void> _saveSteamGridDbApiKey() async {
    final value = _steamGridDbApiKeyController.text.trim();
    if (value.isEmpty) {
      _showMessage('Ingresá una API key antes de guardar.');
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
    _showMessage('API key de SteamGridDB guardada localmente.');
  }

  Future<void> _deleteSteamGridDbApiKey() async {
    setState(() => _loading = true);
    await ref.read(metadataApiKeyStorageProvider).deleteSteamGridDbApiKey();
    if (!mounted) return;
    setState(() {
      _steamGridDbConfigured = false;
      _loading = false;
    });
    _showMessage('API key de SteamGridDB borrada.');
  }

  Future<void> _deleteAllExternalApiKeys() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Borrar claves externas'),
            content: const Text(
              'Se borrarán las claves de RAWG, IGDB y SteamGridDB guardadas localmente. No se modifican tus juegos, metadata aplicada, external IDs ni portadas.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Borrar claves'),
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
    _showMessage('Claves externas borradas.');
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
    return BvPanel(
      child: BvSection(
        title: 'Estado local',
        subtitle:
            'Backlog Vault sigue siendo una app offline-first: la biblioteca vive en tu equipo y las integraciones externas son opcionales.',
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BvKeyValueRow(
              label: 'Cuenta obligatoria',
              value: 'No',
              leading: Icons.lock_outline,
            ),
            const BvKeyValueRow(
              label: 'Modo de uso',
              value: 'Offline-first',
              leading: Icons.wifi_off_outlined,
            ),
            const BvKeyValueRow(
              label: 'Base local',
              value: 'SQLite + Drift',
              leading: Icons.storage_outlined,
            ),
            BvKeyValueRow(
              label: 'Estado de carga',
              value: loading ? 'Cargando configuración…' : 'Listo',
              valueColor: loading ? bv.warning : null,
              leading: Icons.sync_outlined,
            ),
            const SizedBox(height: BvSpacing.sm),
            const BvStatusBanner(
              tone: BvBannerTone.warning,
              title: 'Privacidad y protección',
              message:
                  'La DB local y los archivos media siguen sin cifrado en disco. Los backups cifrados ya están disponibles para exportación y restauración.',
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
    final compact = MediaQuery.sizeOf(context).width < 860;
    final backupCard = BvActionCard(
      title: 'Datos y backups',
      subtitle:
          'Exportá JSON/CSV, generá backups normales o cifrados y restaurá archivos locales.',
      icon: Icons.archive_outlined,
      emphasized: true,
      actions: [
        FilledButton.icon(
          onPressed: loading ? null : () => context.go('/settings/backups'),
          icon: const Icon(Icons.chevron_right),
          label: const Text('Abrir backups'),
        ),
      ],
    );
    final notesCard = BvActionCard(
      title: 'Buenas prácticas',
      subtitle:
          'No pegues claves reales en README, issues, logs, tests ni commits. Todo queda guardado localmente en secure storage.',
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
                        ? 'Configuración presente'
                        : 'Configuración pendiente',
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
              ? 'Cargando'
              : configured
              ? 'Configurado'
              : 'Pendiente',
          style: theme.textTheme.labelLarge?.copyWith(color: foreground),
        ),
      ),
    );
  }
}

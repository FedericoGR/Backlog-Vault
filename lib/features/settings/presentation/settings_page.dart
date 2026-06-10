import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../metadata/data/metadata_api_key_storage.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _rawgApiKeyController = TextEditingController();
  final _steamGridDbApiKeyController = TextEditingController();
  bool _loading = true;
  bool _rawgConfigured = false;
  bool _steamGridDbConfigured = false;

  @override
  void initState() {
    super.initState();
    _loadApiKeyState();
  }

  @override
  void dispose() {
    _rawgApiKeyController.dispose();
    _steamGridDbApiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Sin cuenta obligatoria'),
            subtitle: Text('Backlog Vault funciona localmente en este equipo.'),
          ),
          const ListTile(
            leading: Icon(Icons.wifi_off_outlined),
            title: Text('Offline-first'),
            subtitle: Text(
              'La biblioteca funciona sin internet. La metadata externa es opcional.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Base local'),
            subtitle: Text('Los datos se guardan en SQLite mediante Drift.'),
          ),
          const SizedBox(height: 12),
          Text(
            'Metadata externa',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.vpn_key_outlined),
                    title: const Text('RAWG API key'),
                    subtitle: Text(
                      _loading
                          ? 'Cargando estado...'
                          : _rawgConfigured
                          ? 'Configurada localmente.'
                          : 'No configurada.',
                    ),
                  ),
                  TextField(
                    controller: _rawgApiKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva API key',
                      helperText:
                          'Se guarda localmente en el storage seguro del sistema.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _loading ? null : _saveRawgApiKey,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar'),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            _loading || !_rawgConfigured
                                ? null
                                : _deleteRawgApiKey,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Borrar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No pegues claves reales en issues, logs, README, tests ni commits.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.image_search_outlined),
                    title: const Text('SteamGridDB API key'),
                    subtitle: Text(
                      _loading
                          ? 'Cargando estado...'
                          : _steamGridDbConfigured
                          ? 'Configurada localmente.'
                          : 'No configurada.',
                    ),
                  ),
                  TextField(
                    controller: _steamGridDbApiKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva API key',
                      helperText:
                          'Se usa solo para buscar portadas y se guarda localmente.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
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
                  const SizedBox(height: 12),
                  const Text(
                    'Backlog Vault no descarga portadas automáticamente: vos elegís qué guardar localmente.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadApiKeyState() async {
    final storage = ref.read(metadataApiKeyStorageProvider);
    final rawgValue = await storage.readRawgApiKey();
    final steamGridDbValue = await storage.readSteamGridDbApiKey();
    if (!mounted) return;
    setState(() {
      _rawgConfigured = rawgValue != null;
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

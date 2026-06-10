import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/privacy/privacy_redactor.dart';
import '../application/backup_restore_providers.dart';
import '../data/backup_service.dart';
import '../domain/backup_models.dart';

class BackupRestorePage extends ConsumerStatefulWidget {
  const BackupRestorePage({super.key});

  @override
  ConsumerState<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends ConsumerState<BackupRestorePage> {
  bool _busy = false;
  String? _lastOperation;
  List<BackupWarning> _lastWarnings = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos y backups')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Portabilidad local',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '.vaultbackup no está cifrado en este entregable. Puede contener notas personales, juegos, estados y media local. No incluye API keys ni secure storage.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '.vaultbackup.enc cifra el backup completo con una password que no se guarda en la app. Si la olvidás, el archivo no se puede recuperar.',
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
                  Text(
                    'Exportar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _busy ? null : _createBackup,
                        icon: const Icon(Icons.archive_outlined),
                        label: const Text('Crear backup completo'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _busy ? null : _createEncryptedBackup,
                        icon: const Icon(Icons.enhanced_encryption_outlined),
                        label: const Text('Crear backup cifrado'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _exportJson,
                        icon: const Icon(Icons.data_object_outlined),
                        label: const Text('Exportar JSON'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _exportCsv,
                        icon: const Icon(Icons.table_view_outlined),
                        label: const Text('Exportar CSV'),
                      ),
                    ],
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
                  Text(
                    'Restaurar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'La restauración reemplaza la biblioteca de forma lógica: inserta/actualiza lo que trae el backup y marca como borrado lo que no está en el archivo. Antes de restaurar se crea un backup previo automático.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : _restoreBackup,
                    icon: const Icon(Icons.restore_outlined),
                    label: const Text('Restaurar backup'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _restoreEncryptedBackup,
                    icon: const Icon(Icons.lock_open_outlined),
                    label: const Text('Restaurar backup cifrado'),
                  ),
                ],
              ),
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          if (_lastOperation != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Última operación',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_lastOperation!),
                    if (_lastWarnings.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Warnings',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      for (final warning in _lastWarnings)
                        Text('- ${warning.message}'),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    await _saveGeneratedFile(
      allowedExtensions: ['vaultbackup'],
      create: ref.read(backupServiceProvider).createBackup,
      success: 'Backup completo creado.',
    );
  }

  Future<void> _createEncryptedBackup() async {
    final password = await _askEncryptionPassword(confirm: true);
    if (password == null) return;
    await _saveGeneratedFile(
      allowedExtensions: ['enc'],
      create:
          () => ref
              .read(backupServiceProvider)
              .createEncryptedBackup(password: password),
      success: 'Backup cifrado creado.',
    );
  }

  Future<void> _exportJson() async {
    await _saveGeneratedFile(
      allowedExtensions: ['json'],
      create: ref.read(backupServiceProvider).exportJson,
      success: 'Export JSON creado.',
    );
  }

  Future<void> _exportCsv() async {
    await _saveGeneratedFile(
      allowedExtensions: ['csv'],
      create: ref.read(backupServiceProvider).exportCsv,
      success: 'Export CSV creado.',
    );
  }

  Future<void> _saveGeneratedFile({
    required List<String> allowedExtensions,
    required Future<ExportResult> Function() create,
    required String success,
  }) async {
    setState(() => _busy = true);
    try {
      final result = await create();
      final picker = ref.read(backupFilePickerServiceProvider);
      final path = await picker.pickSavePath(
        fileName: result.fileName,
        allowedExtensions: allowedExtensions,
      );
      if (path == null) {
        setState(() => _busy = false);
        return;
      }
      await picker.writeBytes(path, result.bytes);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _lastOperation = success;
        _lastWarnings = result.warnings;
      });
      _showMessage(success);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showMessage(_friendlyError(error));
    }
  }

  Future<void> _restoreBackup() async {
    setState(() => _busy = true);
    try {
      final picker = ref.read(backupFilePickerServiceProvider);
      final path = await picker.pickBackupPath();
      if (path == null) {
        setState(() => _busy = false);
        return;
      }
      final bytes = await picker.readBytes(path);
      final service = ref.read(backupServiceProvider);
      final preview = await service.previewBackup(bytes);
      if (!mounted) return;
      final confirmation = await _askRestoreConfirmation(preview);
      if (confirmation == null) {
        setState(() => _busy = false);
        return;
      }
      final result = await service.restoreBackup(
        bytes,
        confirmation: confirmation,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _lastWarnings = result.warnings;
        _lastOperation =
            'Backup restaurado. Se creó un backup previo automático.';
      });
      ref.invalidate(backupServiceProvider);
      _showMessage('Backup restaurado.');
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showMessage(_friendlyError(error));
    }
  }

  Future<void> _restoreEncryptedBackup() async {
    setState(() => _busy = true);
    try {
      final picker = ref.read(backupFilePickerServiceProvider);
      final path = await picker.pickEncryptedBackupPath();
      if (path == null) {
        setState(() => _busy = false);
        return;
      }
      final bytes = await picker.readBytes(path);
      if (!mounted) return;
      setState(() => _busy = false);
      final password = await _askEncryptionPassword(confirm: false);
      if (password == null) return;
      if (!mounted) return;
      setState(() => _busy = true);

      final service = ref.read(backupServiceProvider);
      final preview = await service.previewEncryptedBackup(
        bytes,
        password: password,
      );
      if (!mounted) return;
      final confirmation = await _askRestoreConfirmation(preview);
      if (confirmation == null) {
        setState(() => _busy = false);
        return;
      }
      final result = await service.restoreEncryptedBackup(
        bytes,
        password: password,
        confirmation: confirmation,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _lastWarnings = result.warnings;
        _lastOperation =
            'Backup cifrado restaurado. Se creó un backup previo cifrado automático.';
      });
      ref.invalidate(backupServiceProvider);
      _showMessage('Backup cifrado restaurado.');
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showMessage(_friendlyError(error));
    }
  }

  Future<String?> _askRestoreConfirmation(BackupPreview preview) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar restauración'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${preview.manifest.createdAt.toLocal()}'),
                Text('Juegos: ${preview.manifest.counts.games}'),
                Text('Playthroughs: ${preview.manifest.counts.playthroughs}'),
                Text('Media: ${preview.manifest.counts.mediaFiles} archivos'),
                Text('Schema: ${preview.manifest.appSchemaVersion}'),
                if (preview.warnings.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Warnings: ${preview.warnings.length}'),
                ],
                const SizedBox(height: 12),
                const Text('Escribí RESTAURAR para continuar.'),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Confirmación'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: const Text('Restaurar'),
              ),
            ],
          ),
    ).whenComplete(controller.dispose);
  }

  String _friendlyError(Object error) {
    if (error is BackupException) return privacyRedactor.redact(error.message);
    return privacyRedactor.redact('No se pudo completar la operación.');
  }

  Future<String?> _askEncryptionPassword({required bool confirm}) {
    final passwordController = TextEditingController();
    final confirmationController = TextEditingController();
    String? errorText;
    return showDialog<String>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(
                    confirm ? 'Crear backup cifrado' : 'Abrir backup cifrado',
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'La password no se guarda. Si la perdés, el backup cifrado no se puede recuperar.',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        autofocus: true,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: errorText,
                        ),
                      ),
                      if (confirm) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: confirmationController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Repetir password',
                          ),
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () {
                        final password = passwordController.text;
                        if (password.isEmpty) {
                          setDialogState(
                            () => errorText = 'Ingresá una password.',
                          );
                          return;
                        }
                        if (confirm &&
                            password != confirmationController.text) {
                          setDialogState(
                            () => errorText = 'Las passwords no coinciden.',
                          );
                          return;
                        }
                        Navigator.pop(context, password);
                      },
                      child: Text(confirm ? 'Crear' : 'Abrir'),
                    ),
                  ],
                ),
          ),
    ).whenComplete(() {
      passwordController.dispose();
      confirmationController.dispose();
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/bv_action_card.dart';
import '../../../core/design_system/bv_danger_zone.dart';
import '../../../core/design_system/bv_page_scaffold.dart';
import '../../../core/design_system/bv_progress_panel.dart';
import '../../../core/design_system/bv_status_banner.dart';
import '../../../core/design_system/bv_spacing.dart';
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
    return BvPageScaffold(
      title: 'Datos y backups',
      body: ListView(
        children: [
          const BvStatusBanner(
            title: 'Portabilidad local',
            tone: BvBannerTone.warning,
            message:
                '.vaultbackup no está cifrado y puede incluir notas personales, juegos, estados y media local. .vaultbackup.enc cifra el backup completo con una password que la app no guarda.',
          ),
          const SizedBox(height: BvSpacing.md),
          _ActionGrid(
            busy: _busy,
            onCreateBackup: _createBackup,
            onCreateEncryptedBackup: _createEncryptedBackup,
            onExportJson: _exportJson,
            onExportCsv: _exportCsv,
            onRestoreBackup: _restoreBackup,
            onRestoreEncryptedBackup: _restoreEncryptedBackup,
          ),
          if (_busy) ...[
            const SizedBox(height: BvSpacing.md),
            const BvProgressPanel(
              title: 'Procesando archivo',
              subtitle:
                  'Esperá mientras Backlog Vault prepara o valida el contenido seleccionado.',
            ),
          ],
          if (_lastOperation != null) ...[
            const SizedBox(height: BvSpacing.md),
            _OperationResultPanel(
              title: 'Última operación',
              message: _lastOperation!,
              warnings: _lastWarnings,
            ),
          ],
          const SizedBox(height: BvSpacing.md),
          BvDangerZone(
            title: 'Restauración y reemplazo lógico',
            message:
                'Antes de restaurar, la app crea un backup previo automático. La restauración inserta o actualiza lo que está en el archivo y marca como borrado lógico lo que quedó afuera.',
            actions: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _restoreBackup,
                icon: const Icon(Icons.restore_outlined),
                label: const Text('Restaurar backup'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _restoreEncryptedBackup,
                icon: const Icon(Icons.lock_open_outlined),
                label: const Text('Restaurar cifrado'),
              ),
            ],
          ),
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
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fecha: ${preview.manifest.createdAt.toLocal()}'),
                  Text('Juegos: ${preview.manifest.counts.games}'),
                  Text('Playthroughs: ${preview.manifest.counts.playthroughs}'),
                  Text('Media: ${preview.manifest.counts.mediaFiles} archivos'),
                  Text('Schema: ${preview.manifest.appSchemaVersion}'),
                  if (preview.warnings.isNotEmpty) ...[
                    const SizedBox(height: BvSpacing.sm),
                    Text('Warnings: ${preview.warnings.length}'),
                  ],
                  const SizedBox(height: BvSpacing.md),
                  const Text('Escribí RESTAURAR para continuar.'),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmación',
                    ),
                  ),
                ],
              ),
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
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'La password no se guarda. Si la perdés, el backup cifrado no se puede recuperar.',
                        ),
                        const SizedBox(height: BvSpacing.md),
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
                          const SizedBox(height: BvSpacing.sm),
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

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.busy,
    required this.onCreateBackup,
    required this.onCreateEncryptedBackup,
    required this.onExportJson,
    required this.onExportCsv,
    required this.onRestoreBackup,
    required this.onRestoreEncryptedBackup,
  });

  final bool busy;
  final VoidCallback onCreateBackup;
  final VoidCallback onCreateEncryptedBackup;
  final VoidCallback onExportJson;
  final VoidCallback onExportCsv;
  final VoidCallback onRestoreBackup;
  final VoidCallback onRestoreEncryptedBackup;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: BvSpacing.md,
      runSpacing: BvSpacing.md,
      children: [
        SizedBox(
          width: 320,
          child: BvActionCard(
            title: 'Backup completo',
            subtitle:
                'Genera un .vaultbackup con juegos, partidas, metadata aplicada y media local sin cifrado.',
            icon: Icons.archive_outlined,
            emphasized: true,
            actions: [
              FilledButton.icon(
                onPressed: busy ? null : onCreateBackup,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Crear backup'),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 320,
          child: BvActionCard(
            title: 'Backup cifrado',
            subtitle:
                'Genera un .vaultbackup.enc protegido con password. La password no queda almacenada.',
            icon: Icons.enhanced_encryption_outlined,
            actions: [
              FilledButton.tonalIcon(
                onPressed: busy ? null : onCreateEncryptedBackup,
                icon: const Icon(Icons.lock_outlined),
                label: const Text('Crear cifrado'),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 320,
          child: BvActionCard(
            title: 'Exportar JSON',
            subtitle:
                'Exporta la biblioteca en un formato legible y útil para revisión o scripting local.',
            icon: Icons.data_object_outlined,
            actions: [
              OutlinedButton.icon(
                onPressed: busy ? null : onExportJson,
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Exportar JSON'),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 320,
          child: BvActionCard(
            title: 'Exportar CSV',
            subtitle:
                'Genera una exportación tabular compacta para hojas de cálculo o intercambio manual.',
            icon: Icons.table_view_outlined,
            actions: [
              OutlinedButton.icon(
                onPressed: busy ? null : onExportCsv,
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Exportar CSV'),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 320,
          child: BvActionCard(
            title: 'Restaurar backup',
            subtitle:
                'Abre un .vaultbackup, muestra preview y pide confirmación fuerte antes de aplicar cambios.',
            icon: Icons.restore_outlined,
            actions: [
              FilledButton.tonalIcon(
                onPressed: busy ? null : onRestoreBackup,
                icon: const Icon(Icons.restore_outlined),
                label: const Text('Restaurar backup'),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 320,
          child: BvActionCard(
            title: 'Restaurar cifrado',
            subtitle:
                'Abre un .vaultbackup.enc, pide password y valida el contenido antes de reemplazar datos.',
            icon: Icons.lock_open_outlined,
            actions: [
              FilledButton.tonalIcon(
                onPressed: busy ? null : onRestoreEncryptedBackup,
                icon: const Icon(Icons.lock_open_outlined),
                label: const Text('Restaurar cifrado'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OperationResultPanel extends StatelessWidget {
  const _OperationResultPanel({
    required this.title,
    required this.message,
    required this.warnings,
  });

  final String title;
  final String message;
  final List<BackupWarning> warnings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BvStatusBanner(
          title: title,
          tone: BvBannerTone.success,
          message: message,
        ),
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: BvSpacing.sm),
          BvStatusBanner(
            title: 'Warnings',
            tone: BvBannerTone.warning,
            message: warnings.map((warning) => warning.message).join('\n'),
          ),
        ],
      ],
    );
  }
}

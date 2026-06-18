import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/bv_action_card.dart';
import '../../../core/design_system/bv_danger_zone.dart';
import '../../../core/design_system/bv_page_scaffold.dart';
import '../../../core/design_system/bv_progress_panel.dart';
import '../../../core/design_system/bv_status_banner.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/privacy/privacy_redactor.dart';
import '../../../l10n/l10n.dart';
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
      title: context.l10n.backupTitle,
      body: ListView(
        children: [
          BvStatusBanner(
            title: context.l10n.backupLocalPortability,
            tone: BvBannerTone.warning,
            message: context.l10n.backupLocalPortabilityMessage,
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
            BvProgressPanel(
              title: context.l10n.backupProcessingTitle,
              subtitle: context.l10n.backupProcessingMessage,
            ),
          ],
          if (_lastOperation != null) ...[
            const SizedBox(height: BvSpacing.md),
            _OperationResultPanel(
              title: context.l10n.backupLastOperation,
              message: _lastOperation!,
              warnings: _lastWarnings,
            ),
          ],
          const SizedBox(height: BvSpacing.md),
          BvDangerZone(
            title: context.l10n.backupRestoreLogicTitle,
            message: context.l10n.backupRestoreLogicMessage,
            actions: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _restoreBackup,
                icon: const Icon(Icons.restore_outlined),
                label: Text(context.l10n.backupRestore),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _restoreEncryptedBackup,
                icon: const Icon(Icons.lock_open_outlined),
                label: Text(context.l10n.backupRestoreEncrypted),
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
      success: context.l10n.backupCreated,
    );
  }

  Future<void> _createEncryptedBackup() async {
    final success = context.l10n.backupEncryptedCreated;
    final password = await _askEncryptionPassword(confirm: true);
    if (password == null) return;
    await _saveGeneratedFile(
      allowedExtensions: ['enc'],
      create:
          () => ref
              .read(backupServiceProvider)
              .createEncryptedBackup(password: password),
      success: success,
    );
  }

  Future<void> _exportJson() async {
    await _saveGeneratedFile(
      allowedExtensions: ['json'],
      create: ref.read(backupServiceProvider).exportJson,
      success: context.l10n.backupJsonCreated,
    );
  }

  Future<void> _exportCsv() async {
    await _saveGeneratedFile(
      allowedExtensions: ['csv'],
      create: ref.read(backupServiceProvider).exportCsv,
      success: context.l10n.backupCsvCreated,
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
        _lastOperation = context.l10n.backupRestoredWithSafety;
      });
      ref.invalidate(backupServiceProvider);
      _showMessage(context.l10n.backupRestored);
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
        _lastOperation = context.l10n.backupEncryptedRestoredWithSafety;
      });
      ref.invalidate(backupServiceProvider);
      _showMessage(context.l10n.backupEncryptedRestored);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showMessage(_friendlyError(error));
    }
  }

  Future<String?> _askRestoreConfirmation(BackupPreview preview) async {
    final expectedKeyword = context.l10n.backupRestoreKeyword;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.backupConfirmRestore),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.backupDate(
                      preview.manifest.createdAt.toLocal().toString(),
                    ),
                  ),
                  Text(context.l10n.backupGames(preview.manifest.counts.games)),
                  Text(
                    context.l10n.backupPlaythroughs(
                      preview.manifest.counts.playthroughs,
                    ),
                  ),
                  Text(
                    context.l10n.backupMediaFiles(
                      preview.manifest.counts.mediaFiles,
                    ),
                  ),
                  Text(
                    context.l10n.backupSchema(
                      preview.manifest.appSchemaVersion,
                    ),
                  ),
                  if (preview.warnings.isNotEmpty) ...[
                    const SizedBox(height: BvSpacing.sm),
                    Text(context.l10n.backupWarnings(preview.warnings.length)),
                  ],
                  const SizedBox(height: BvSpacing.md),
                  Text(context.l10n.backupTypeRestore),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.libraryConfirmation,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: Text(context.l10n.backupRestore),
              ),
            ],
          ),
    ).whenComplete(controller.dispose);
    if (result?.trim().toUpperCase() == expectedKeyword) {
      return 'RESTAURAR';
    }
    return result;
  }

  String _friendlyError(Object error) {
    if (error is BackupException) return privacyRedactor.redact(error.message);
    return privacyRedactor.redact(context.l10n.backupOperationFailed);
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
                    confirm
                        ? context.l10n.backupCreateEncrypted
                        : context.l10n.backupOpenEncrypted,
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.backupPasswordWarning),
                        const SizedBox(height: BvSpacing.md),
                        TextField(
                          controller: passwordController,
                          autofocus: true,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: context.l10n.backupPassword,
                            errorText: errorText,
                          ),
                        ),
                        if (confirm) ...[
                          const SizedBox(height: BvSpacing.sm),
                          TextField(
                            controller: confirmationController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: context.l10n.backupRepeatPassword,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: () {
                        final password = passwordController.text;
                        if (password.isEmpty) {
                          setDialogState(
                            () => errorText = context.l10n.backupEnterPassword,
                          );
                          return;
                        }
                        if (confirm &&
                            password != confirmationController.text) {
                          setDialogState(
                            () =>
                                errorText =
                                    context.l10n.backupPasswordsMismatch,
                          );
                          return;
                        }
                        Navigator.pop(context, password);
                      },
                      child: Text(
                        confirm ? context.l10n.create : context.l10n.openAction,
                      ),
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
            title: context.l10n.backupCompleteTitle,
            subtitle: context.l10n.backupCompleteDescription,
            icon: Icons.archive_outlined,
            emphasized: true,
            actions: [
              FilledButton.icon(
                onPressed: busy ? null : onCreateBackup,
                icon: const Icon(Icons.download_outlined),
                label: Text(context.l10n.backupCreate),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 320,
          child: BvActionCard(
            title: context.l10n.backupEncryptedTitle,
            subtitle: context.l10n.backupEncryptedDescription,
            icon: Icons.enhanced_encryption_outlined,
            actions: [
              FilledButton.tonalIcon(
                onPressed: busy ? null : onCreateEncryptedBackup,
                icon: const Icon(Icons.lock_outlined),
                label: Text(context.l10n.backupCreateEncrypted),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 320,
          child: BvActionCard(
            title: context.l10n.backupExportJson,
            subtitle: context.l10n.backupExportJsonDescription,
            icon: Icons.data_object_outlined,
            actions: [
              OutlinedButton.icon(
                onPressed: busy ? null : onExportJson,
                icon: const Icon(Icons.file_download_outlined),
                label: Text(context.l10n.backupExportJson),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 320,
          child: BvActionCard(
            title: context.l10n.backupExportCsv,
            subtitle: context.l10n.backupExportCsvDescription,
            icon: Icons.table_view_outlined,
            actions: [
              OutlinedButton.icon(
                onPressed: busy ? null : onExportCsv,
                icon: const Icon(Icons.file_download_outlined),
                label: Text(context.l10n.backupExportCsv),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 320,
          child: BvActionCard(
            title: context.l10n.backupRestore,
            subtitle: context.l10n.backupRestoreDescription,
            icon: Icons.restore_outlined,
            actions: [
              FilledButton.tonalIcon(
                onPressed: busy ? null : onRestoreBackup,
                icon: const Icon(Icons.restore_outlined),
                label: Text(context.l10n.backupRestore),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 320,
          child: BvActionCard(
            title: context.l10n.backupRestoreEncrypted,
            subtitle: context.l10n.backupRestoreEncryptedDescription,
            icon: Icons.lock_open_outlined,
            actions: [
              FilledButton.tonalIcon(
                onPressed: busy ? null : onRestoreEncryptedBackup,
                icon: const Icon(Icons.lock_open_outlined),
                label: Text(context.l10n.backupRestoreEncrypted),
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
            title: context.l10n.warnings,
            tone: BvBannerTone.warning,
            message: warnings.map((warning) => warning.message).join('\n'),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_progress_panel.dart';
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_status_banner.dart';
import '../../../l10n/l10n.dart';
import '../application/sync_providers.dart';
import '../domain/sync_package_models.dart';

class ManualSyncSection extends ConsumerStatefulWidget {
  const ManualSyncSection({super.key});

  @override
  ConsumerState<ManualSyncSection> createState() => _ManualSyncSectionState();
}

class _ManualSyncSectionState extends ConsumerState<ManualSyncSection> {
  bool _busy = false;
  String? _result;

  @override
  Widget build(BuildContext context) {
    final foundation = ref.watch(syncFoundationReadyProvider);
    return BvPanel(
      child: BvSection(
        title: context.l10n.syncSectionTitle,
        subtitle: context.l10n.syncSectionDescription,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            foundation.when(
              data:
                  (device) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BvStatusBanner(
                        title: context.l10n.syncFoundationReady,
                        tone: BvBannerTone.success,
                        message: context.l10n.syncManualAvailable,
                      ),
                      const SizedBox(height: BvSpacing.sm),
                      Text(
                        '${context.l10n.syncLocalDevice}: '
                        '${device.displayName} · ${device.platform} · '
                        '${_shortId(device.id)}',
                      ),
                    ],
                  ),
              loading:
                  () => BvProgressPanel(
                    title: context.l10n.loading,
                    subtitle: context.l10n.syncSectionDescription,
                  ),
              error:
                  (_, _) => BvStatusBanner(
                    title: context.l10n.syncNotReady,
                    tone: BvBannerTone.warning,
                    message: context.l10n.syncOperationFailed,
                  ),
            ),
            const SizedBox(height: BvSpacing.md),
            BvStatusBanner(
              title: context.l10n.syncEncryptedNotice,
              tone: BvBannerTone.warning,
              message:
                  '${context.l10n.syncConflictNotice}\n'
                  '${context.l10n.syncMediaNotice}\n'
                  '${context.l10n.syncPackageVsBackup}',
            ),
            const SizedBox(height: BvSpacing.md),
            Wrap(
              spacing: BvSpacing.sm,
              runSpacing: BvSpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed:
                      _busy || !foundation.hasValue ? null : _exportPackage,
                  icon: const Icon(Icons.lock_outline),
                  label: Text(context.l10n.syncExportPackage),
                ),
                OutlinedButton.icon(
                  onPressed:
                      _busy || !foundation.hasValue ? null : _importPackage,
                  icon: const Icon(Icons.lock_open_outlined),
                  label: Text(context.l10n.syncImportPackage),
                ),
              ],
            ),
            if (_busy) ...[
              const SizedBox(height: BvSpacing.md),
              BvProgressPanel(
                title: context.l10n.loading,
                subtitle: context.l10n.syncEncryptedNotice,
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: BvSpacing.md),
              BvStatusBanner(
                title: context.l10n.syncImportResultTitle,
                tone: BvBannerTone.success,
                message: _result!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _exportPackage() async {
    final password = await _askPassword(confirm: true);
    if (password == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final exported = await ref
          .read(syncPackageServiceProvider)
          .export(password: password);
      if (!mounted) return;
      final files = ref.read(syncPackageFileServiceProvider);
      final path = await files.pickSavePath(
        fileName: exported.fileName,
        dialogTitle: context.l10n.syncSaveDialogTitle,
      );
      if (path == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      await files.writeBytes(path, exported.bytes);
      if (!mounted) return;
      final message = context.l10n.syncExportCreated(exported.changeCount);
      setState(() {
        _busy = false;
        _result = message;
      });
      _showMessage(message);
    } on Object {
      _handleFailure();
    }
  }

  Future<void> _importPackage() async {
    try {
      final files = ref.read(syncPackageFileServiceProvider);
      final path = await files.pickImportPath();
      if (path == null || !mounted) return;
      final password = await _askPassword(confirm: false);
      if (password == null || !mounted) return;
      setState(() => _busy = true);
      final bytes = await files.readBytes(path);
      final service = ref.read(syncPackageServiceProvider);
      final preview = await service.preview(bytes, password: password);
      if (!mounted) return;
      setState(() => _busy = false);
      final apply = await _showPreview(preview);
      if (apply != true || !mounted) return;
      setState(() => _busy = true);
      final result = await service.applySafeChanges(bytes, password: password);
      if (!mounted) return;
      final message =
          result.applied == 0
              ? context.l10n.syncNoSafeChanges
              : context.l10n.syncAppliedCount(result.applied);
      setState(() {
        _busy = false;
        _result = message;
      });
      _showMessage(message);
    } on Object {
      _handleFailure();
    }
  }

  Future<bool?> _showPreview(SyncImportPreview preview) {
    final l10n = context.l10n;
    final applicable = preview.count(SyncImportDisposition.applicable);
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.syncPreviewTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.syncFromDevice(
                      preview.document.fromDevice.displayName,
                    ),
                  ),
                  Text(
                    l10n.syncPackageDate(
                      preview.document.createdAt.toLocal().toString(),
                    ),
                  ),
                  const SizedBox(height: BvSpacing.sm),
                  Text(l10n.syncPreviewChanges(preview.items.length)),
                  Text(
                    l10n.syncPreviewAlreadyApplied(
                      preview.count(SyncImportDisposition.alreadyApplied),
                    ),
                  ),
                  Text(l10n.syncPreviewApplicable(applicable)),
                  Text(
                    l10n.syncPreviewConflicts(
                      preview.count(SyncImportDisposition.conflict),
                    ),
                  ),
                  Text(
                    l10n.syncPreviewUnsupported(
                      preview.count(SyncImportDisposition.unsupported),
                    ),
                  ),
                  Text(
                    l10n.syncPreviewInvalid(
                      preview.count(SyncImportDisposition.invalid),
                    ),
                  ),
                  Text(
                    l10n.syncPreviewPendingMedia(
                      preview.count(SyncImportDisposition.pendingMedia),
                    ),
                  ),
                  const SizedBox(height: BvSpacing.md),
                  Text(l10n.syncConflictNotice),
                  Text(l10n.syncMediaNotice),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed:
                    applicable == 0 ? null : () => Navigator.pop(context, true),
                child: Text(l10n.syncApplySafeChanges),
              ),
            ],
          ),
    );
  }

  Future<String?> _askPassword({required bool confirm}) {
    final password = TextEditingController();
    final repeated = TextEditingController();
    String? error;
    return showDialog<String>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(
                    confirm
                        ? context.l10n.syncPasswordExportTitle
                        : context.l10n.syncPasswordImportTitle,
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.syncPasswordForgotten),
                        const SizedBox(height: BvSpacing.md),
                        TextField(
                          controller: password,
                          autofocus: true,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: context.l10n.syncPassword,
                            errorText: error,
                          ),
                        ),
                        if (confirm) ...[
                          const SizedBox(height: BvSpacing.sm),
                          TextField(
                            controller: repeated,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: context.l10n.syncRepeatPassword,
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
                        if (password.text.isEmpty) {
                          setDialogState(
                            () => error = context.l10n.syncPasswordRequired,
                          );
                          return;
                        }
                        if (confirm && password.text != repeated.text) {
                          setDialogState(
                            () => error = context.l10n.syncPasswordMismatch,
                          );
                          return;
                        }
                        Navigator.pop(context, password.text);
                      },
                      child: Text(
                        confirm
                            ? context.l10n.syncExportPackage
                            : context.l10n.openAction,
                      ),
                    ),
                  ],
                ),
          ),
    ).whenComplete(() {
      password.dispose();
      repeated.dispose();
    });
  }

  String _shortId(String id) => id.length <= 8 ? id : '${id.substring(0, 8)}…';

  void _handleFailure() {
    if (!mounted) return;
    final message = context.l10n.syncOperationFailed;
    setState(() {
      _busy = false;
      _result = null;
    });
    _showMessage(message);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

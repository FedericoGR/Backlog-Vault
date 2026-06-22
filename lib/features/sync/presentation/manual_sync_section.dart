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
import '../domain/sync_pairing_models.dart';

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
    final pairing = ref.watch(syncPairingStateProvider);
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
            _buildPairingState(pairing),
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

  Widget _buildPairingState(AsyncValue<SyncPairingState> pairing) {
    return pairing.when(
      loading:
          () => BvProgressPanel(
            title: context.l10n.syncPairingTitle,
            subtitle: context.l10n.syncPairingDescription,
          ),
      error:
          (_, _) => BvStatusBanner(
            title: context.l10n.syncPairingTitle,
            tone: BvBannerTone.warning,
            message: context.l10n.syncPairingOperationFailed,
          ),
      data: (state) {
        final group = state.group;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BvStatusBanner(
              title:
                  group == null
                      ? context.l10n.syncNoGroup
                      : context.l10n.syncGroupConfigured,
              tone:
                  group == null
                      ? BvBannerTone.info
                      : state.hasGroupKey
                      ? BvBannerTone.success
                      : BvBannerTone.warning,
              message:
                  '${context.l10n.syncPairingDescription}\n'
                  '${context.l10n.syncNoAutomaticSync}',
            ),
            if (group != null) ...[
              const SizedBox(height: BvSpacing.sm),
              Text(context.l10n.syncGroupName(group.displayName)),
              Text(context.l10n.syncPairedDevices(state.pairedDeviceCount)),
              Text(
                state.hasGroupKey
                    ? context.l10n.syncGroupKeyAvailable
                    : context.l10n.syncGroupKeyMissing,
              ),
            ],
            const SizedBox(height: BvSpacing.sm),
            Text(context.l10n.syncInvitationNotice),
            const SizedBox(height: BvSpacing.sm),
            Wrap(
              spacing: BvSpacing.sm,
              runSpacing: BvSpacing.sm,
              children: [
                if (group == null)
                  FilledButton.icon(
                    onPressed: _busy ? null : _createGroup,
                    icon: const Icon(Icons.group_add_outlined),
                    label: Text(context.l10n.syncCreateGroup),
                  ),
                if (group != null)
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _exportPairingInvitation,
                    icon: const Icon(Icons.ios_share_outlined),
                    label: Text(context.l10n.syncExportInvitation),
                  ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _importPairingInvitation,
                  icon: const Icon(Icons.file_open_outlined),
                  label: Text(context.l10n.syncImportInvitation),
                ),
                if (group != null && state.hasGroupKey) ...[
                  FilledButton.icon(
                    onPressed: _busy ? null : _exportGroupPackage,
                    icon: const Icon(Icons.lock_outline),
                    label: Text(context.l10n.syncExportGroupPackage),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _importGroupPackage,
                    icon: const Icon(Icons.lock_open_outlined),
                    label: Text(context.l10n.syncImportGroupPackage),
                  ),
                ],
                if (group != null)
                  TextButton.icon(
                    onPressed: _busy ? null : _leaveGroup,
                    icon: const Icon(Icons.link_off_outlined),
                    label: Text(context.l10n.syncLeaveGroup),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _createGroup() async {
    final name = await _askGroupName();
    if (name == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(syncPairingServiceProvider).createGroup(name);
      if (!mounted) return;
      ref.invalidate(syncPairingStateProvider);
      _finishWithMessage(context.l10n.syncGroupConfigured);
    } on Object catch (error) {
      _handlePairingFailure(error);
    }
  }

  Future<void> _exportPairingInvitation() async {
    final passphrase = await _askPassword(
      confirm: true,
      title: context.l10n.syncPairingPasswordTitle,
      helper: context.l10n.syncInvitationNotice,
      submitLabel: context.l10n.syncExportInvitation,
    );
    if (passphrase == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final exported = await ref
          .read(syncPairingServiceProvider)
          .exportInvitation(passphrase: passphrase);
      if (!mounted) return;
      final files = ref.read(syncPairingFileServiceProvider);
      final path = await files.pickSavePath(
        fileName: exported.fileName,
        dialogTitle: context.l10n.syncPairingSaveDialogTitle,
      );
      if (path == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      await files.writeBytes(path, exported.bytes);
      if (!mounted) return;
      _finishWithMessage(context.l10n.syncInvitationCreated);
    } on Object catch (error) {
      _handlePairingFailure(error);
    }
  }

  Future<void> _importPairingInvitation() async {
    try {
      final files = ref.read(syncPairingFileServiceProvider);
      final path = await files.pickImportPath();
      if (path == null || !mounted) return;
      final passphrase = await _askPassword(
        confirm: false,
        title: context.l10n.syncPairingPasswordOpenTitle,
        helper: context.l10n.syncInvitationNotice,
        submitLabel: context.l10n.openAction,
      );
      if (passphrase == null || !mounted) return;
      setState(() => _busy = true);
      final bytes = await files.readBytes(path);
      await ref
          .read(syncPairingServiceProvider)
          .importInvitation(bytes, passphrase: passphrase);
      if (!mounted) return;
      ref.invalidate(syncPairingStateProvider);
      _finishWithMessage(context.l10n.syncInvitationImported);
    } on Object catch (error) {
      _handlePairingFailure(error);
    }
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.syncLeaveGroupTitle),
            content: Text(context.l10n.syncLeaveGroupWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.syncLeaveGroup),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(syncGroupManagerProvider).leaveGroup();
      if (!mounted) return;
      ref.invalidate(syncPairingStateProvider);
      _finishWithMessage(context.l10n.syncLeaveGroupDone);
    } on Object catch (error) {
      _handlePairingFailure(error);
    }
  }

  Future<void> _exportGroupPackage() async {
    setState(() => _busy = true);
    try {
      final exported =
          await ref.read(syncPackageServiceProvider).exportWithGroupKey();
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
      _finishWithMessage(
        context.l10n.syncGroupPackageCreated(exported.changeCount),
      );
    } on Object catch (error) {
      _handlePairingFailure(error);
    }
  }

  Future<void> _importGroupPackage() async {
    try {
      final files = ref.read(syncPackageFileServiceProvider);
      final path = await files.pickImportPath();
      if (path == null || !mounted) return;
      setState(() => _busy = true);
      final bytes = await files.readBytes(path);
      final service = ref.read(syncPackageServiceProvider);
      final preview = await service.previewWithGroupKey(bytes);
      if (!mounted) return;
      setState(() => _busy = false);
      final apply = await _showPreview(preview);
      if (apply != true || !mounted) return;
      setState(() => _busy = true);
      final result = await service.applySafeChangesWithGroupKey(bytes);
      if (!mounted) return;
      ref.invalidate(syncPairingStateProvider);
      _finishWithMessage(
        result.applied == 0
            ? context.l10n.syncNoSafeChanges
            : context.l10n.syncAppliedCount(result.applied),
      );
    } on Object catch (error) {
      _handlePairingFailure(error);
    }
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

  Future<String?> _askPassword({
    required bool confirm,
    String? title,
    String? helper,
    String? submitLabel,
  }) {
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
                    title ??
                        (confirm
                            ? context.l10n.syncPasswordExportTitle
                            : context.l10n.syncPasswordImportTitle),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(helper ?? context.l10n.syncPasswordForgotten),
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
                        submitLabel ??
                            (confirm
                                ? context.l10n.syncExportPackage
                                : context.l10n.openAction),
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

  Future<String?> _askGroupName() {
    final controller = TextEditingController();
    String? error;
    return showDialog<String>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(context.l10n.syncCreateGroupTitle),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText: context.l10n.syncGroupNameLabel,
                      errorText: error,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: () {
                        final value = controller.text.trim();
                        if (value.isEmpty) {
                          setDialogState(
                            () => error = context.l10n.syncGroupNameRequired,
                          );
                          return;
                        }
                        Navigator.pop(context, value);
                      },
                      child: Text(context.l10n.syncCreateGroup),
                    ),
                  ],
                ),
          ),
    ).whenComplete(controller.dispose);
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

  void _handlePairingFailure(Object error) {
    if (!mounted) return;
    final message = switch (error) {
      SyncPairingException(failure: SyncPairingFailure.invitationExpired) =>
        context.l10n.syncInvitationExpired,
      SyncPairingException(failure: SyncPairingFailure.existingGroup) =>
        context.l10n.syncPairingExistingGroup,
      SyncPairingException(failure: SyncPairingFailure.keyMissing) =>
        context.l10n.syncGroupKeyMissing,
      SyncPairingException(failure: SyncPairingFailure.groupMismatch) =>
        context.l10n.syncGroupPackageMismatch,
      SyncPairingException(failure: SyncPairingFailure.keyIdMismatch) =>
        context.l10n.syncGroupKeyMismatch,
      _ => context.l10n.syncPairingOperationFailed,
    };
    setState(() {
      _busy = false;
      _result = null;
    });
    _showMessage(message);
  }

  void _finishWithMessage(String message) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = message;
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

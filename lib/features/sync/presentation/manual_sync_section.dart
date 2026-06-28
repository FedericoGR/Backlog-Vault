import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_progress_panel.dart';
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_status_banner.dart';
import '../../../l10n/l10n.dart';
import '../application/sync_providers.dart';
import '../data/lan_sync_service.dart';
import '../data/sync_qr_payload_codec.dart';
import '../domain/lan_sync_models.dart';
import '../domain/sync_package_models.dart';
import '../domain/sync_pairing_models.dart';
import 'sync_qr_scanner_page.dart';

class ManualSyncSection extends ConsumerStatefulWidget {
  const ManualSyncSection({super.key});

  @override
  ConsumerState<ManualSyncSection> createState() => _ManualSyncSectionState();
}

class _ManualSyncSectionState extends ConsumerState<ManualSyncSection> {
  bool _busy = false;
  String? _result;
  LanSyncHostSession? _hostSession;

  @override
  void dispose() {
    final session = _hostSession;
    if (session != null) unawaited(session.stop());
    super.dispose();
  }

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
              data: (_) => _buildSyncContent(pairing),
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

  Widget _buildSyncContent(AsyncValue<SyncPairingState> pairing) {
    return pairing.when(
      loading:
          () => BvProgressPanel(
            title: context.l10n.loading,
            subtitle: context.l10n.syncSectionDescription,
          ),
      error:
          (_, _) => BvStatusBanner(
            title: context.l10n.syncNotReady,
            tone: BvBannerTone.warning,
            message: context.l10n.syncPairingOperationFailed,
          ),
      data:
          (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(state),
              const SizedBox(height: BvSpacing.md),
              _buildWifiSyncCard(state),
              const SizedBox(height: BvSpacing.md),
              _buildPairingCard(state),
              const SizedBox(height: BvSpacing.md),
              _buildAdvancedOptions(state),
            ],
          ),
    );
  }

  Widget _buildStatusCard(SyncPairingState state) {
    final group = state.group;
    final hasReadyGroup = group != null && state.hasGroupKey;
    return BvStatusBanner(
      title:
          hasReadyGroup
              ? context.l10n.syncGroupConfigured
              : context.l10n.syncNoGroup,
      tone:
          group == null
              ? BvBannerTone.info
              : hasReadyGroup
              ? BvBannerTone.success
              : BvBannerTone.warning,
      message:
          group == null
              ? context.l10n.syncUxNoGroupMessage
              : hasReadyGroup
              ? [
                context.l10n.syncUxReadyMessage,
                context.l10n.syncPairedDevices(state.pairedDeviceCount),
                context.l10n.syncUxNoCloud,
                context.l10n.syncUxLocalDevice(
                  state.localDevice.displayName,
                  state.localDevice.platform,
                  _shortId(state.localDevice.deviceId),
                ),
              ].join('\n')
              : context.l10n.syncUxReconnectNeeded,
    );
  }

  Widget _buildWifiSyncCard(SyncPairingState state) {
    final session = _hostSession;
    final canUseLan = state.group != null && state.hasGroupKey;
    return _SyncUxCard(
      icon: Icons.wifi_outlined,
      title: context.l10n.syncLanTitle,
      description:
          '${context.l10n.syncUxWifiDescription}\n'
          '${context.l10n.syncLanMediaNotice}\n'
          '${context.l10n.syncManualConnectionFallback}\n'
          '${context.l10n.syncQrDoesNotReplaceEncryption}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!canUseLan)
            Text(
              context.l10n.syncUxWifiDisabledHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (session != null) ...[
            Text(context.l10n.syncLanWaiting),
            Text(context.l10n.syncLanHostAddress(session.host)),
            Text(context.l10n.syncLanPort(session.port)),
            Text(context.l10n.syncLanSessionCode(session.sessionCode)),
            Text(
              context.l10n.syncLanHostDevice(session.localDevice.displayName),
            ),
            const SizedBox(height: BvSpacing.sm),
          ],
          Wrap(
            spacing: BvSpacing.sm,
            runSpacing: BvSpacing.sm,
            children: [
              if (session == null)
                FilledButton.icon(
                  onPressed: _busy || !canUseLan ? null : _startLanSession,
                  icon: const Icon(Icons.wifi_tethering_outlined),
                  label: Text(context.l10n.syncLanStartSession),
                ),
              if (session != null)
                OutlinedButton.icon(
                  onPressed: _busy ? null : _stopLanSession,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(context.l10n.syncLanStopSession),
                ),
              if (session != null)
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _showLanSessionQr(state),
                  icon: const Icon(Icons.qr_code_2_outlined),
                  label: Text(context.l10n.syncShowLanQr),
                ),
              OutlinedButton.icon(
                onPressed:
                    _busy || !canUseLan
                        ? null
                        : () => _connectLanSession(state),
                icon: const Icon(Icons.lan_outlined),
                label: Text(context.l10n.syncLanConnectSession),
              ),
              OutlinedButton.icon(
                onPressed:
                    _busy || !canUseLan
                        ? null
                        : () => _connectLanSession(state, scanFirst: true),
                icon: const Icon(Icons.qr_code_scanner_outlined),
                label: Text(context.l10n.syncScanLanQr),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPairingCard(SyncPairingState state) {
    final group = state.group;
    return _SyncUxCard(
      icon: Icons.devices_other_outlined,
      title: context.l10n.syncUxPairDeviceTitle,
      description:
          '${context.l10n.syncUxPairDeviceDescription}\n'
          '${context.l10n.syncInvitationNotice}\n'
          '${context.l10n.syncPairingQrHelp}',
      child: Wrap(
        spacing: BvSpacing.sm,
        runSpacing: BvSpacing.sm,
        children: [
          if (group == null)
            FilledButton.icon(
              onPressed: _busy ? null : _createGroup,
              icon: const Icon(Icons.group_add_outlined),
              label: Text(context.l10n.syncUxConnectDeviceCta),
            ),
          if (group != null)
            FilledButton.icon(
              onPressed: _busy ? null : _showPairingQr,
              icon: const Icon(Icons.qr_code_2_outlined),
              label: Text(context.l10n.syncShowPairingQr),
            ),
          if (group != null)
            OutlinedButton.icon(
              onPressed: _busy ? null : _exportPairingInvitation,
              icon: const Icon(Icons.ios_share_outlined),
              label: Text(context.l10n.syncExportInvitation),
            ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _scanPairingQr,
            icon: const Icon(Icons.qr_code_scanner_outlined),
            label: Text(context.l10n.syncScanPairingQr),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pastePairingQr,
            icon: const Icon(Icons.content_paste_outlined),
            label: Text(context.l10n.syncPastePairingCode),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _importPairingInvitation,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(context.l10n.syncImportInvitation),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions(SyncPairingState state) {
    final canUseGroupPackage = state.group != null && state.hasGroupKey;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(context.l10n.syncUxAdvancedTitle),
        subtitle: Text(context.l10n.syncUxAdvancedDescription),
        childrenPadding: const EdgeInsets.fromLTRB(
          BvSpacing.md,
          0,
          BvSpacing.md,
          BvSpacing.md,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(context.l10n.syncPackageVsBackup),
          ),
          const SizedBox(height: BvSpacing.sm),
          Wrap(
            spacing: BvSpacing.sm,
            runSpacing: BvSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed:
                    _busy
                        ? null
                        : canUseGroupPackage
                        ? _exportGroupPackage
                        : _exportPackage,
                icon: const Icon(Icons.lock_outline),
                label: Text(context.l10n.syncExportPackage),
              ),
              OutlinedButton.icon(
                onPressed:
                    _busy
                        ? null
                        : canUseGroupPackage
                        ? _importGroupPackage
                        : _importPackage,
                icon: const Icon(Icons.lock_open_outlined),
                label: Text(context.l10n.syncImportPackage),
              ),
              if (canUseGroupPackage) ...[
                OutlinedButton.icon(
                  onPressed: _busy ? null : _exportPackage,
                  icon: const Icon(Icons.password_outlined),
                  label: Text(context.l10n.syncUxExportPasswordPackage),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _importPackage,
                  icon: const Icon(Icons.password_outlined),
                  label: Text(context.l10n.syncUxImportPasswordPackage),
                ),
              ],
              if (state.group != null)
                TextButton.icon(
                  onPressed: _busy ? null : _leaveGroup,
                  icon: const Icon(Icons.link_off_outlined),
                  label: Text(context.l10n.syncLeaveGroup),
                ),
            ],
          ),
        ],
      ),
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

  Future<void> _showPairingQr() async {
    final passphrase = await _askPassword(
      confirm: true,
      title: context.l10n.syncPairingPasswordTitle,
      helper:
          '${context.l10n.syncInvitationNotice}\n'
          '${context.l10n.syncPairingQrHelp}',
      submitLabel: context.l10n.syncShowPairingQr,
    );
    if (passphrase == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final exported = await ref
          .read(syncPairingServiceProvider)
          .exportInvitation(passphrase: passphrase);
      final payload = ref
          .read(syncQrPayloadCodecProvider)
          .encodePairingInvitation(
            invitationBytes: exported.bytes,
            createdAt: DateTime.now().toUtc(),
          );
      if (!mounted) return;
      setState(() => _busy = false);
      await _showQrPayloadDialog(
        title: context.l10n.syncPairingQrTitle,
        message:
            '${context.l10n.syncPairingQrHelp}\n\n'
            '${context.l10n.syncQrNoPlaintextSecrets}\n\n'
            '${context.l10n.syncQrDoesNotReplaceEncryption}',
        payload: payload,
      );
    } on Object catch (error) {
      if (error is SyncQrException) {
        _handleQrFailure(error);
      } else {
        _handlePairingFailure(error);
      }
    }
  }

  Future<void> _scanPairingQr() async {
    final payload = await _scanQrPayload(context.l10n.syncScanPairingQr);
    if (payload == null || !mounted) return;
    await _importPairingQrPayload(payload);
  }

  Future<void> _pastePairingQr() async {
    final payload = await _askQrPayload(
      title: context.l10n.syncPastePairingCode,
      helper:
          '${context.l10n.syncPairingQrHelp}\n'
          '${context.l10n.syncQrTemporaryPasswordSeparate}',
    );
    if (payload == null || !mounted) return;
    await _importPairingQrPayload(payload);
  }

  Future<void> _importPairingQrPayload(String payload) async {
    try {
      final decoded = ref
          .read(syncQrPayloadCodecProvider)
          .decodePairingInvitation(payload);
      final passphrase = await _askPassword(
        confirm: false,
        title: context.l10n.syncPairingPasswordOpenTitle,
        helper: context.l10n.syncInvitationNotice,
        submitLabel: context.l10n.openAction,
      );
      if (passphrase == null || !mounted) return;
      setState(() => _busy = true);
      await ref
          .read(syncPairingServiceProvider)
          .importInvitation(decoded.invitationBytes, passphrase: passphrase);
      if (!mounted) return;
      ref.invalidate(syncPairingStateProvider);
      _finishWithMessage(context.l10n.syncInvitationImported);
    } on Object catch (error) {
      if (error is SyncQrException) {
        _handleQrFailure(error);
      } else {
        _handlePairingFailure(error);
      }
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

  Future<void> _startLanSession() async {
    setState(() => _busy = true);
    try {
      final session = await ref.read(lanSyncServiceProvider).startHost();
      if (!mounted) {
        await session.stop();
        return;
      }
      setState(() {
        _busy = false;
        _hostSession = session;
        _result = context.l10n.syncLanWaiting;
      });
      unawaited(
        session.completed
            .then((result) {
              if (!mounted || _hostSession != session) return;
              setState(() => _hostSession = null);
              ref.invalidate(syncPairingStateProvider);
              _finishWithMessage(_formatLanResult(result));
            })
            .catchError((Object error) {
              if (!mounted || _hostSession != session) return;
              setState(() {
                _busy = false;
                _hostSession = null;
              });
              if (error is LanSyncException &&
                  error.failure == LanSyncFailure.stopped) {
                _finishWithMessage(context.l10n.syncLanStopped);
              } else {
                _handleLanFailure(error);
              }
            }),
      );
    } on Object catch (error) {
      _handleLanFailure(error);
    }
  }

  Future<void> _stopLanSession() async {
    final session = _hostSession;
    if (session == null) return;
    setState(() => _busy = true);
    await session.stop();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _hostSession = null;
      _result = context.l10n.syncLanStopped;
    });
  }

  Future<void> _showLanSessionQr(SyncPairingState state) async {
    final group = state.group;
    final session = _hostSession;
    if (group == null || session == null) return;
    try {
      final now = DateTime.now().toUtc();
      final payload = ref
          .read(syncQrPayloadCodecProvider)
          .encodeLanSession(
            host: session.host,
            port: session.port,
            sessionCode: session.sessionCode,
            syncGroupId: group.id,
            keyId: group.keyId,
            createdAt: now,
            expiresAt: now.add(const Duration(minutes: 5)),
          );
      await _showQrPayloadDialog(
        title: context.l10n.syncLanQrTitle,
        message:
            '${context.l10n.syncLanQrHelp}\n\n'
            '${context.l10n.syncQrDoesNotReplaceEncryption}',
        payload: payload,
      );
    } on Object catch (error) {
      if (error is SyncQrException) {
        _handleQrFailure(error);
      } else {
        _handleLanFailure(error);
      }
    }
  }

  Future<void> _connectLanSession(
    SyncPairingState state, {
    bool scanFirst = false,
  }) async {
    LanSessionQrPayload? initial;
    if (scanFirst) {
      initial = await _scanLanSessionQr(state);
      if (initial == null || !mounted) return;
    }
    final input = await _askLanConnection(state, initial: initial);
    if (input == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(lanSyncServiceProvider)
          .connectAndSync(
            host: input.host,
            port: input.port,
            sessionCode: input.sessionCode,
          );
      if (!mounted) return;
      ref.invalidate(syncPairingStateProvider);
      _finishWithMessage(_formatLanResult(result));
    } on Object catch (error) {
      _handleLanFailure(error);
    }
  }

  Future<LanSessionQrPayload?> _scanLanSessionQr(SyncPairingState state) async {
    final payload = await _scanQrPayload(context.l10n.syncScanLanQr);
    if (payload == null || !mounted) return null;
    return _decodeLanSessionQr(state, payload);
  }

  Future<LanSessionQrPayload?> _pasteLanSessionQr(
    SyncPairingState state,
  ) async {
    final payload = await _askQrPayload(
      title: context.l10n.syncPasteLanQr,
      helper: context.l10n.syncLanQrHelp,
    );
    if (payload == null || !mounted) return null;
    return _decodeLanSessionQr(state, payload);
  }

  LanSessionQrPayload? _decodeLanSessionQr(
    SyncPairingState state,
    String payload,
  ) {
    final group = state.group;
    if (group == null) {
      _handleLanFailure(const LanSyncException(LanSyncFailure.notPaired));
      return null;
    }
    try {
      return ref
          .read(syncQrPayloadCodecProvider)
          .decodeLanSession(
            payload,
            expectedGroupId: group.id,
            expectedKeyId: group.keyId,
          );
    } on SyncQrException catch (error) {
      _handleQrFailure(error);
      return null;
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

  Future<_LanConnectionInput?> _askLanConnection(
    SyncPairingState state, {
    LanSessionQrPayload? initial,
  }) {
    final host = TextEditingController(text: initial?.host);
    final port = TextEditingController(text: initial?.port.toString());
    final code = TextEditingController(text: initial?.sessionCode);
    String? error;
    return showDialog<_LanConnectionInput>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(context.l10n.syncLanConnectSession),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.syncLanClientHelp),
                        const SizedBox(height: BvSpacing.xs),
                        Text(context.l10n.syncManualConnectionFallback),
                        Text(context.l10n.syncQrDoesNotReplaceEncryption),
                        const SizedBox(height: BvSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final parsed = await _pasteLanSessionQr(state);
                            if (parsed == null) return;
                            host.text = parsed.host;
                            port.text = parsed.port.toString();
                            code.text = parsed.sessionCode;
                            setDialogState(() => error = null);
                          },
                          icon: const Icon(Icons.content_paste_outlined),
                          label: Text(context.l10n.syncPasteLanQr),
                        ),
                        const SizedBox(height: BvSpacing.md),
                        TextField(
                          controller: host,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: context.l10n.syncLanHostField,
                            errorText: error,
                          ),
                        ),
                        const SizedBox(height: BvSpacing.sm),
                        TextField(
                          controller: port,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: context.l10n.syncLanPortField,
                          ),
                        ),
                        const SizedBox(height: BvSpacing.sm),
                        TextField(
                          controller: code,
                          decoration: InputDecoration(
                            labelText: context.l10n.syncLanSessionCodeField,
                          ),
                        ),
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
                        final parsedPort = int.tryParse(port.text.trim());
                        if (host.text.trim().isEmpty ||
                            parsedPort == null ||
                            parsedPort <= 0 ||
                            parsedPort > 65535 ||
                            code.text.trim().isEmpty) {
                          setDialogState(
                            () => error = context.l10n.syncLanInvalidInput,
                          );
                          return;
                        }
                        Navigator.pop(
                          context,
                          _LanConnectionInput(
                            host: host.text.trim(),
                            port: parsedPort,
                            sessionCode: code.text.trim(),
                          ),
                        );
                      },
                      child: Text(context.l10n.syncLanConnectAndSync),
                    ),
                  ],
                ),
          ),
    ).whenComplete(() {
      host.dispose();
      port.dispose();
      code.dispose();
    });
  }

  Future<String?> _scanQrPayload(String title) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder:
            (context) => SyncQrScannerPage(
              title: title,
              unavailableMessage: context.l10n.syncQrScannerUnavailable,
            ),
      ),
    );
  }

  Future<String?> _askQrPayload({
    required String title,
    required String helper,
  }) {
    final controller = TextEditingController();
    String? error;
    return showDialog<String>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(title),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(helper),
                        const SizedBox(height: BvSpacing.md),
                        TextField(
                          controller: controller,
                          autofocus: true,
                          minLines: 3,
                          maxLines: 6,
                          decoration: InputDecoration(
                            labelText: context.l10n.syncQrPayloadField,
                            errorText: error,
                          ),
                        ),
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
                        final value = controller.text.trim();
                        if (value.isEmpty) {
                          setDialogState(
                            () => error = context.l10n.syncQrPayloadInvalid,
                          );
                          return;
                        }
                        Navigator.pop(context, value);
                      },
                      child: Text(context.l10n.continueAction),
                    ),
                  ],
                ),
          ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _showQrPayloadDialog({
    required String title,
    required String message,
    required String payload,
  }) {
    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message),
                  const SizedBox(height: BvSpacing.md),
                  Center(
                    child: QrImageView(
                      data: payload,
                      version: QrVersions.auto,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      size: 240,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: BvSpacing.md),
                  Text(context.l10n.syncQrCopyHelp),
                  const SizedBox(height: BvSpacing.xs),
                  SelectableText(payload),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: payload));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.syncQrCopied)),
                  );
                },
                child: Text(context.l10n.syncQrCopyPayload),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.close),
              ),
            ],
          ),
    );
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

  void _handleQrFailure(SyncQrException error) {
    if (!mounted) return;
    final message = switch (error.failure) {
      SyncQrFailure.payloadTooLarge => context.l10n.syncQrPayloadTooLarge,
      SyncQrFailure.groupMismatch => context.l10n.syncLanGroupMismatch,
      SyncQrFailure.keyIdMismatch => context.l10n.syncLanKeyMismatch,
      SyncQrFailure.incompatibleVersion => context.l10n.syncLanProtocolMismatch,
      SyncQrFailure.invalidLanSession => context.l10n.syncLanInvalidInput,
      _ => context.l10n.syncQrPayloadInvalid,
    };
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

  void _handleLanFailure(Object error) {
    if (!mounted) return;
    final message = switch (error) {
      LanSyncException(failure: LanSyncFailure.notPaired) =>
        context.l10n.syncLanPairFirst,
      LanSyncException(failure: LanSyncFailure.keyMissing) =>
        context.l10n.syncGroupKeyMissing,
      LanSyncException(failure: LanSyncFailure.invalidSessionCode) =>
        context.l10n.syncLanInvalidSessionCode,
      LanSyncException(failure: LanSyncFailure.groupMismatch) =>
        context.l10n.syncLanGroupMismatch,
      LanSyncException(failure: LanSyncFailure.keyIdMismatch) =>
        context.l10n.syncLanKeyMismatch,
      LanSyncException(failure: LanSyncFailure.protocolMismatch) =>
        context.l10n.syncLanProtocolMismatch,
      LanSyncException(failure: LanSyncFailure.requestTooLarge) =>
        context.l10n.syncLanRequestTooLarge,
      LanSyncException(failure: LanSyncFailure.packageRejected) =>
        context.l10n.syncLanPackageRejected,
      LanSyncException(failure: LanSyncFailure.networkUnavailable) =>
        context.l10n.syncLanNetworkUnavailable,
      LanSyncException(failure: LanSyncFailure.connectionInterrupted) =>
        context.l10n.syncLanConnectionInterrupted,
      LanSyncException(failure: LanSyncFailure.timeout) =>
        context.l10n.syncLanTimeout,
      LanSyncException(failure: LanSyncFailure.stopped) =>
        context.l10n.syncLanStopped,
      _ => context.l10n.syncLanFailed,
    };
    setState(() {
      _busy = false;
      _result = null;
    });
    _showMessage(message);
  }

  String _formatLanResult(LanSyncResult result) {
    final l10n = context.l10n;
    final local = result.local;
    final lines = [
      l10n.syncLanResultPeer(result.peerDevice.displayName),
      l10n.syncLanResultSent(local.changesSent),
      l10n.syncLanResultReceived(local.changesReceived),
      l10n.syncLanResultApplied(local.applied),
      l10n.syncLanResultAlreadyApplied(local.alreadyApplied),
      l10n.syncLanResultConflicts(local.conflicts),
      l10n.syncLanResultPendingMedia(local.pendingMedia),
      l10n.syncLanResultMediaRequested(local.mediaRequested),
      l10n.syncLanResultMediaReceived(local.mediaReceived),
      l10n.syncLanResultMediaSkipped(local.mediaSkipped),
      l10n.syncLanResultMediaFailed(local.mediaFailed),
      l10n.syncLanResultMediaBytes(local.mediaBytesTransferred),
    ];
    final peer = result.peer;
    if (peer != null) {
      lines.add(l10n.syncLanPeerApplied(peer.applied));
      lines.add(l10n.syncLanPeerConflicts(peer.conflicts));
      lines.add(l10n.syncLanPeerPendingMedia(peer.pendingMedia));
      lines.add(l10n.syncLanPeerMediaReceived(peer.mediaReceived));
      lines.add(l10n.syncLanPeerMediaFailed(peer.mediaFailed));
    }
    return lines.join('\n');
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

class _LanConnectionInput {
  const _LanConnectionInput({
    required this.host,
    required this.port,
    required this.sessionCode,
  });

  final String host;
  final int port;
  final String sessionCode;
}

class _SyncUxCard extends StatelessWidget {
  const _SyncUxCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BvSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon),
                const SizedBox(width: BvSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: BvSpacing.xs),
                      Text(description),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: BvSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

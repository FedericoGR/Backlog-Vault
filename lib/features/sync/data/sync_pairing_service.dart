import 'dart:convert';

import '../../../core/time/clock.dart';
import '../../../core/version/app_versions.dart';
import '../domain/sync_pairing_models.dart';
import 'canonical_json.dart';
import 'encrypted_pairing_codec.dart';
import 'sync_group_management.dart';
import 'sync_payload_sanitizer.dart';

class SyncPairingService {
  const SyncPairingService({
    required SyncGroupManager groupManager,
    required EncryptedPairingCodec codec,
    CanonicalJson serializer = canonicalJson,
    SyncPayloadSanitizer sanitizer = syncPayloadSanitizer,
    Clock clock = systemClock,
  }) : _groupManager = groupManager,
       _codec = codec,
       _serializer = serializer,
       _sanitizer = sanitizer,
       _clock = clock;

  final SyncGroupManager _groupManager;
  final EncryptedPairingCodec _codec;
  final CanonicalJson _serializer;
  final SyncPayloadSanitizer _sanitizer;
  final Clock _clock;

  Future<SyncGroupInfo> createGroup(String displayName) {
    _validatePublicText(displayName);
    return _groupManager.createGroup(displayName);
  }

  Future<PairingExportResult> exportInvitation({
    required String passphrase,
    Duration validity = const Duration(hours: 24),
  }) async {
    final state = await _groupManager.state();
    final group = state.group;
    if (group == null) {
      throw const SyncPairingException(SyncPairingFailure.noGroup);
    }
    final key = await _groupManager.requireActiveGroupKey();
    _validatePublicText(group.displayName);
    _validatePublicText(state.localDevice.displayName);
    final now = _clock.now().toUtc();
    final invitation = PairingInvitation(
      formatVersion: pairingPackageFormatVersion,
      syncProtocolVersion: syncProtocolVersion,
      createdAt: now,
      expiresAt: now.add(validity),
      group: PairingInvitationGroup(
        groupId: group.id,
        displayName: group.displayName,
        keyId: key.keyId,
        groupKey: key.bytes,
      ),
      inviterDevice: state.localDevice,
    );
    final clear = utf8.encode(_serializer.encode(invitation.toJson()));
    final encrypted = await _codec.encrypt(clear, passphrase);
    return PairingExportResult(fileName: _fileName(now), bytes: encrypted);
  }

  Future<PairingInvitation> previewInvitation(
    List<int> bytes, {
    required String passphrase,
  }) async {
    final invitation = await _decode(bytes, passphrase);
    if (invitation.isExpiredAt(_clock.now())) {
      throw const SyncPairingException(SyncPairingFailure.invitationExpired);
    }
    return invitation;
  }

  Future<void> importInvitation(
    List<int> bytes, {
    required String passphrase,
  }) async {
    final invitation = await previewInvitation(bytes, passphrase: passphrase);
    await _groupManager.importInvitation(invitation);
  }

  Future<PairingInvitation> _decode(List<int> bytes, String passphrase) async {
    final clear = await _codec.decrypt(bytes, passphrase);
    try {
      final decoded = jsonDecode(utf8.decode(clear));
      if (decoded is! Map<String, Object?>) {
        throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
      }
      final invitation = PairingInvitation.fromJson(decoded);
      _validatePublicText(invitation.group.displayName);
      _validatePublicText(invitation.inviterDevice.displayName);
      return invitation;
    } on SyncPairingException {
      rethrow;
    } on Object {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
  }

  void _validatePublicText(String value) {
    if (_sanitizer.sanitize(value) != value) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
  }

  String _fileName(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return 'BacklogVault-pairing-'
        '${value.year}${two(value.month)}${two(value.day)}-'
        '${two(value.hour)}${two(value.minute)}${two(value.second)}.'
        '$pairingPackageExtension';
  }
}

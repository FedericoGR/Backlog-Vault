import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../../core/version/app_versions.dart';
import '../domain/sync_pairing_models.dart';

class EncryptedPairingCodec {
  EncryptedPairingCodec({
    AesGcm? cipher,
    Pbkdf2? kdf,
    Random? random,
    int iterations = defaultIterations,
  }) : _cipher = cipher ?? AesGcm.with256bits(),
       _kdf =
           kdf ??
           Pbkdf2(
             macAlgorithm: Hmac.sha256(),
             iterations: iterations,
             bits: 256,
           ),
       _random = random ?? Random.secure(),
       _iterations = iterations;

  static const defaultIterations = 210000;
  static const _magic = [0x42, 0x56, 0x50, 0x31]; // BVP1
  static const _format = 'backlog-vault-encrypted-pairing-invitation';
  static const _version = 1;
  static const _algorithm = 'AES-256-GCM';
  static const _kdfName = 'PBKDF2-HMAC-SHA256';
  static const _saltLength = 16;

  final AesGcm _cipher;
  final Pbkdf2 _kdf;
  final Random _random;
  final int _iterations;

  Future<List<int>> encrypt(List<int> clearBytes, String passphrase) async {
    _validatePassphrase(passphrase);
    final salt = _randomBytes(_saltLength);
    final secretKey = await _kdf.deriveKeyFromPassword(
      password: passphrase,
      nonce: salt,
    );
    final nonce = _cipher.newNonce();
    final headerBytes = utf8.encode(jsonEncode(_header(salt)));
    final box = await _cipher.encrypt(
      clearBytes,
      secretKey: secretKey,
      nonce: nonce,
      aad: headerBytes,
    );
    return [
      ..._magic,
      ..._uint32(headerBytes.length),
      ...headerBytes,
      ...box.concatenation(),
    ];
  }

  Future<List<int>> decrypt(List<int> encryptedBytes, String passphrase) async {
    _validatePassphrase(passphrase);
    try {
      final parsed = _parse(encryptedBytes);
      _validateHeader(parsed.header);
      final salt = base64Decode(parsed.header['salt']! as String);
      if (salt.length != _saltLength) {
        throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
      }
      final nonceLength = parsed.header['nonceLength']! as int;
      final macLength = parsed.header['macLength']! as int;
      if (parsed.payload.length <= nonceLength + macLength) {
        throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
      }
      final secretKey = await _kdf.deriveKeyFromPassword(
        password: passphrase,
        nonce: salt,
      );
      final box = SecretBox.fromConcatenation(
        parsed.payload,
        nonceLength: nonceLength,
        macLength: macLength,
      );
      return await _cipher.decrypt(
        box,
        secretKey: secretKey,
        aad: parsed.headerBytes,
      );
    } on SyncPairingException {
      rethrow;
    } on SecretBoxAuthenticationError {
      throw const SyncPairingException(
        SyncPairingFailure.wrongPassphraseOrTampered,
      );
    } on Object {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
  }

  Map<String, Object?> _header(List<int> salt) => {
    'format': _format,
    'version': _version,
    'syncProtocolVersion': syncProtocolVersion,
    'algorithm': _algorithm,
    'kdf': _kdfName,
    'iterations': _iterations,
    'keyBits': 256,
    'salt': base64Encode(salt),
    'nonceLength': _cipher.nonceLength,
    'macLength': _cipher.macAlgorithm.macLength,
  };

  _ParsedPairingPackage _parse(List<int> bytes) {
    if (bytes.length < _magic.length + 4) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
    for (var index = 0; index < _magic.length; index++) {
      if (bytes[index] != _magic[index]) {
        throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
      }
    }
    final headerLength = _readUint32(bytes, _magic.length);
    final headerStart = _magic.length + 4;
    final headerEnd = headerStart + headerLength;
    if (headerLength <= 0 || headerEnd >= bytes.length) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
    final headerBytes = Uint8List.fromList(
      bytes.sublist(headerStart, headerEnd),
    );
    final decoded = jsonDecode(utf8.decode(headerBytes));
    if (decoded is! Map<String, Object?>) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
    return _ParsedPairingPackage(
      header: decoded,
      headerBytes: headerBytes,
      payload: Uint8List.fromList(bytes.sublist(headerEnd)),
    );
  }

  void _validateHeader(Map<String, Object?> header) {
    if (header['format'] != _format ||
        header['version'] != _version ||
        header['syncProtocolVersion'] != syncProtocolVersion ||
        header['algorithm'] != _algorithm ||
        header['kdf'] != _kdfName ||
        header['iterations'] != _iterations ||
        header['keyBits'] != 256 ||
        header['nonceLength'] != _cipher.nonceLength ||
        header['macLength'] != _cipher.macAlgorithm.macLength ||
        header['salt'] is! String) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
  }

  void _validatePassphrase(String passphrase) {
    if (passphrase.isEmpty) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
  }

  List<int> _randomBytes(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256));

  List<int> _uint32(int value) {
    final data = ByteData(4)..setUint32(0, value);
    return data.buffer.asUint8List();
  }

  int _readUint32(List<int> bytes, int offset) {
    return ByteData.sublistView(
      Uint8List.fromList(bytes),
      offset,
      offset + 4,
    ).getUint32(0);
  }
}

class _ParsedPairingPackage {
  const _ParsedPairingPackage({
    required this.header,
    required this.headerBytes,
    required this.payload,
  });

  final Map<String, Object?> header;
  final List<int> headerBytes;
  final List<int> payload;
}

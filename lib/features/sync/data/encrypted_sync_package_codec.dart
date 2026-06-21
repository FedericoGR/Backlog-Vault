import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../../core/version/app_versions.dart';
import '../domain/sync_package_models.dart';

class EncryptedSyncPackageCodec {
  EncryptedSyncPackageCodec({
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
  static const _magic = [0x42, 0x56, 0x53, 0x31]; // BVS1
  static const _format = 'backlog-vault-encrypted-sync-package';
  static const _version = 1;
  static const _algorithm = 'AES-256-GCM';
  static const _kdfName = 'PBKDF2-HMAC-SHA256';
  static const _saltLength = 16;

  final AesGcm _cipher;
  final Pbkdf2 _kdf;
  final Random _random;
  final int _iterations;

  Future<List<int>> encrypt(List<int> clearBytes, String password) async {
    _validatePassword(password);
    final salt = _randomBytes(_saltLength);
    final secretKey = await _deriveKey(password, salt);
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

  Future<List<int>> decrypt(List<int> encryptedBytes, String password) async {
    _validatePassword(password);
    try {
      final parsed = _parse(encryptedBytes);
      _validateHeader(parsed.header);
      final salt = base64Decode(parsed.header['salt']! as String);
      if (salt.length != _saltLength) {
        throw const SyncPackageException('Invalid sync package salt.');
      }
      final iterations = parsed.header['iterations']! as int;
      final nonceLength = parsed.header['nonceLength']! as int;
      final macLength = parsed.header['macLength']! as int;
      if (parsed.payload.length <= nonceLength + macLength) {
        throw const SyncPackageException('The sync package is incomplete.');
      }
      final secretKey = await _deriveKey(
        password,
        salt,
        iterations: iterations,
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
    } on SyncPackageException {
      rethrow;
    } on SecretBoxAuthenticationError {
      throw const SyncPackageException(
        'The password is incorrect or the sync package was modified.',
      );
    } on Object {
      throw const SyncPackageException(
        'The encrypted sync package is invalid or corrupted.',
      );
    }
  }

  Future<SecretKey> _deriveKey(
    String password,
    List<int> salt, {
    int? iterations,
  }) {
    final kdf =
        iterations == null || iterations == _iterations
            ? _kdf
            : Pbkdf2(
              macAlgorithm: Hmac.sha256(),
              iterations: iterations,
              bits: 256,
            );
    return kdf.deriveKeyFromPassword(password: password, nonce: salt);
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

  _ParsedSyncPackage _parse(List<int> bytes) {
    if (bytes.length < _magic.length + 4) {
      throw const SyncPackageException('The sync package is incomplete.');
    }
    for (var index = 0; index < _magic.length; index++) {
      if (bytes[index] != _magic[index]) {
        throw const SyncPackageException(
          'This file is not a Backlog Vault sync package.',
        );
      }
    }
    final headerLength = _readUint32(bytes, _magic.length);
    final headerStart = _magic.length + 4;
    final headerEnd = headerStart + headerLength;
    if (headerLength <= 0 || headerEnd >= bytes.length) {
      throw const SyncPackageException('The sync package header is invalid.');
    }
    final headerBytes = Uint8List.fromList(
      bytes.sublist(headerStart, headerEnd),
    );
    final decoded = jsonDecode(utf8.decode(headerBytes));
    if (decoded is! Map<String, Object?>) {
      throw const SyncPackageException('The sync package header is invalid.');
    }
    return _ParsedSyncPackage(
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
        header['keyBits'] != 256 ||
        header['iterations'] != _iterations ||
        header['nonceLength'] != _cipher.nonceLength ||
        header['macLength'] != _cipher.macAlgorithm.macLength ||
        header['salt'] is! String) {
      throw const SyncPackageException(
        'The sync package encryption header is not supported.',
      );
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

  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw const SyncPackageException('A password is required.');
    }
  }
}

class _ParsedSyncPackage {
  const _ParsedSyncPackage({
    required this.header,
    required this.headerBytes,
    required this.payload,
  });

  final Map<String, Object?> header;
  final List<int> headerBytes;
  final List<int> payload;
}

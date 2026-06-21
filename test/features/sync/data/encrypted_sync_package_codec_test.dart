import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:backlog_vault/features/sync/data/encrypted_sync_package_codec.dart';
import 'package:backlog_vault/features/sync/domain/sync_package_models.dart';
import 'package:test/test.dart';

void main() {
  late EncryptedSyncPackageCodec codec;

  setUp(() {
    codec = EncryptedSyncPackageCodec(iterations: 1, random: Random(7));
  });

  test('BVS1 encrypted package roundtrips without plaintext leakage', () async {
    final clear = utf8.encode(
      '{"changes":[{"title":"Secret Game Name"}],"formatVersion":1}',
    );

    final encrypted = await codec.encrypt(clear, 'test package password');
    final decrypted = await codec.decrypt(encrypted, 'test package password');

    expect(encrypted.take(4), [0x42, 0x56, 0x53, 0x31]);
    expect(
      String.fromCharCodes(encrypted),
      isNot(contains('Secret Game Name')),
    );
    expect(decrypted, clear);
  });

  test('wrong password fails without exposing the password', () async {
    final encrypted = await codec.encrypt([1, 2, 3], 'test correct password');

    await expectLater(
      codec.decrypt(encrypted, 'test wrong password'),
      throwsA(
        isA<SyncPackageException>().having(
          (error) => error.message,
          'message',
          isNot(contains('test wrong password')),
        ),
      ),
    );
  });

  test('tampered ciphertext and auth tag fail authentication', () async {
    final encrypted = await codec.encrypt([1, 2, 3, 4], 'test password');
    final ciphertextChanged = [...encrypted]..[encrypted.length - 18] ^= 0x40;
    final tagChanged = [...encrypted]..[encrypted.length - 1] ^= 0x40;

    await expectLater(
      codec.decrypt(ciphertextChanged, 'test password'),
      throwsA(isA<SyncPackageException>()),
    );
    await expectLater(
      codec.decrypt(tagChanged, 'test password'),
      throwsA(isA<SyncPackageException>()),
    );
  });

  test('invalid magic and truncated package fail safely', () async {
    final encrypted = await codec.encrypt([1, 2, 3], 'test password');
    final invalidMagic = [...encrypted]..[0] = 0;

    await expectLater(
      codec.decrypt(invalidMagic, 'test password'),
      throwsA(isA<SyncPackageException>()),
    );
    await expectLater(
      codec.decrypt(encrypted.sublist(0, 7), 'test password'),
      throwsA(isA<SyncPackageException>()),
    );
  });

  test(
    'invalid KDF, salt and nonce metadata fail before payload use',
    () async {
      final encrypted = await codec.encrypt([1, 2, 3], 'test password');
      final invalidIterations = _rewriteHeader(encrypted, (header) {
        header['iterations'] = 2000000000;
      });
      final invalidSalt = _rewriteHeader(encrypted, (header) {
        header['salt'] = base64Encode([1, 2]);
      });
      final invalidNonce = _rewriteHeader(encrypted, (header) {
        header['nonceLength'] = 1;
      });

      await expectLater(
        codec.decrypt(invalidIterations, 'test password'),
        throwsA(isA<SyncPackageException>()),
      );
      await expectLater(
        codec.decrypt(invalidSalt, 'test password'),
        throwsA(isA<SyncPackageException>()),
      );
      await expectLater(
        codec.decrypt(invalidNonce, 'test password'),
        throwsA(isA<SyncPackageException>()),
      );
    },
  );
}

List<int> _rewriteHeader(
  List<int> bytes,
  void Function(Map<String, Object?> header) mutate,
) {
  final data = Uint8List.fromList(bytes);
  final oldLength = ByteData.sublistView(data, 4, 8).getUint32(0);
  final oldEnd = 8 + oldLength;
  final header =
      jsonDecode(utf8.decode(bytes.sublist(8, oldEnd))) as Map<String, Object?>;
  mutate(header);
  final encoded = utf8.encode(jsonEncode(header));
  final length = ByteData(4)..setUint32(0, encoded.length);
  return [
    ...bytes.take(4),
    ...length.buffer.asUint8List(),
    ...encoded,
    ...bytes.skip(oldEnd),
  ];
}

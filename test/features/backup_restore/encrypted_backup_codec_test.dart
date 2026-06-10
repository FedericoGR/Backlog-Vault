import 'dart:convert';
import 'dart:typed_data';

import 'package:backlog_vault/features/backup_restore/data/encrypted_backup_codec.dart';
import 'package:backlog_vault/features/backup_restore/domain/backup_models.dart';
import 'package:test/test.dart';

void main() {
  late EncryptedBackupCodec codec;

  setUp(() {
    codec = EncryptedBackupCodec();
  });

  test('decrypt rejects invalid magic and truncated files safely', () async {
    await expectLater(
      codec.decrypt([0x00, 0x56, 0x45, 0x31], 'password'),
      throwsA(isA<BackupException>()),
    );

    await expectLater(
      codec.decrypt([0x42, 0x56, 0x45, 0x31, 0x00], 'password'),
      throwsA(isA<BackupException>()),
    );
  });

  test('decrypt rejects incompatible or malformed headers safely', () async {
    final encrypted = await codec.encrypt(utf8.encode('payload'), 'password');

    await expectLater(
      codec.decrypt(_replaceHeader(encrypted, {'version': 99}), 'password'),
      throwsA(isA<BackupException>()),
    );

    await expectLater(
      codec.decrypt(
        _replaceHeader(encrypted, {'salt': 'not base64'}),
        'password',
      ),
      throwsA(isA<BackupException>()),
    );

    await expectLater(
      codec.decrypt(_replaceHeader(encrypted, {'nonceLength': 1}), 'password'),
      throwsA(isA<BackupException>()),
    );
  });

  test('decrypt rejects altered ciphertext and auth tag safely', () async {
    final encrypted = await codec.encrypt(utf8.encode('payload'), 'password');

    final alteredCiphertext = [...encrypted];
    alteredCiphertext[alteredCiphertext.length - 20] ^= 0xFF;
    await expectLater(
      codec.decrypt(alteredCiphertext, 'password'),
      throwsA(isA<BackupException>()),
    );

    final alteredAuthTag = [...encrypted];
    alteredAuthTag[alteredAuthTag.length - 1] ^= 0xFF;
    await expectLater(
      codec.decrypt(alteredAuthTag, 'password'),
      throwsA(isA<BackupException>()),
    );
  });

  test('decrypt rejects truncated payload safely', () async {
    final encrypted = await codec.encrypt(utf8.encode('payload'), 'password');
    final truncated = encrypted.take(encrypted.length - 8).toList();

    await expectLater(
      codec.decrypt(truncated, 'password'),
      throwsA(isA<BackupException>()),
    );
  });

  test('errors do not expose the password or clear payload', () async {
    final encrypted = await codec.encrypt(
      utf8.encode('manifest.json library.json Hades Nota privada'),
      'correct-password',
    );

    try {
      await codec.decrypt(encrypted, 'wrong-password');
      fail('Expected decrypt to fail.');
    } on BackupException catch (error) {
      expect(error.message, isNot(contains('wrong-password')));
      expect(error.message, isNot(contains('correct-password')));
      expect(error.message, isNot(contains('manifest.json')));
      expect(error.message, isNot(contains('Nota privada')));
    }
  });
}

List<int> _replaceHeader(List<int> encrypted, Map<String, Object?> changes) {
  final bytes = Uint8List.fromList(encrypted);
  final headerLength = ByteData.sublistView(bytes, 4, 8).getUint32(0);
  final headerStart = 8;
  final headerEnd = headerStart + headerLength;
  final header =
      jsonDecode(utf8.decode(bytes.sublist(headerStart, headerEnd)))
          as Map<String, Object?>;
  final newHeader = {...header, ...changes};
  final newHeaderBytes = utf8.encode(jsonEncode(newHeader));
  final lengthBytes = ByteData(4)..setUint32(0, newHeaderBytes.length);
  return [
    ...bytes.take(4),
    ...lengthBytes.buffer.asUint8List(),
    ...newHeaderBytes,
    ...bytes.skip(headerEnd),
  ];
}

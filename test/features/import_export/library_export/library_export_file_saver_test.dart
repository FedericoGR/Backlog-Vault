import 'dart:convert';
import 'dart:typed_data';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/import_export/library_export/application/library_export_controller.dart';
import 'package:backlog_vault/features/import_export/library_export/data/library_export_file_saver.dart';
import 'package:backlog_vault/features/import_export/library_export/data/library_export_repository.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  for (final platform in ['windows', 'android']) {
    test('$platform save forwards JSON bytes to file_picker', () async {
      late String receivedName;
      late Uint8List receivedBytes;
      final saver = FilePickerLibraryExportFileSaver(
        saveFile: ({required String fileName, required Uint8List bytes}) async {
          receivedName = fileName;
          receivedBytes = bytes;
          return '$platform-destination/$fileName';
        },
      );
      final bytes = Uint8List.fromList(utf8.encode('{"formatVersion":1}'));

      final destination = await saver.save(
        fileName: 'backlog-vault-library-20260717-183045.json',
        bytes: bytes,
      );

      expect(receivedName, endsWith('.json'));
      expect(receivedName, isNot(contains(':')));
      expect(receivedBytes, same(bytes));
      expect(destination, contains('destination'));
    });
  }

  group('LibraryExportController', () {
    late AppDatabase db;
    late LibraryExportRepository repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = LibraryExportRepository(
        db,
        sourcePlatform: 'android',
        clock: const _FixedClock(),
      );
    });

    tearDown(() => db.close());

    test('reports success after saving a parseable JSON document', () async {
      final saver = _FakeSaver('/chosen/library.json');
      final outcome =
          await LibraryExportController(
            repository: repository,
            fileSaver: saver,
          ).execute();

      expect(outcome.status, LibraryExportStatus.saved);
      expect(outcome.fileName, 'backlog-vault-library-20260717-183045.json');
      expect(saver.fileName, outcome.fileName);
      expect(
        jsonDecode(utf8.decode(saver.bytes!)),
        isA<Map<String, Object?>>(),
      );
    });

    test('treats picker cancellation as cancellation, not failure', () async {
      final outcome =
          await LibraryExportController(
            repository: repository,
            fileSaver: _FakeSaver(null),
          ).execute();

      expect(outcome.status, LibraryExportStatus.cancelled);
      expect(outcome.fileName, isNull);
    });

    test('converts save errors into a controlled failure', () async {
      final outcome =
          await LibraryExportController(
            repository: repository,
            fileSaver: _ThrowingSaver(),
          ).execute();

      expect(outcome.status, LibraryExportStatus.failed);
      expect(outcome.fileName, isNull);
    });
  });
}

class _FakeSaver implements LibraryExportFileSaver {
  _FakeSaver(this.destination);

  final String? destination;
  String? fileName;
  Uint8List? bytes;

  @override
  Future<String?> save({
    required String fileName,
    required Uint8List bytes,
  }) async {
    this.fileName = fileName;
    this.bytes = bytes;
    return destination;
  }
}

class _ThrowingSaver implements LibraryExportFileSaver {
  @override
  Future<String?> save({required String fileName, required Uint8List bytes}) {
    throw StateError('synthetic save error');
  }
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 7, 17, 18, 30, 45);
}

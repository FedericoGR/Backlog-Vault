import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/privacy/privacy_redactor.dart';
import '../data/library_export_file_saver.dart';
import '../data/library_export_repository.dart';
import '../domain/library_export_document.dart';

final libraryExportControllerProvider = Provider<LibraryExportCommand>((ref) {
  return LibraryExportController(
    repository: ref.watch(libraryExportRepositoryProvider),
    fileSaver: ref.watch(libraryExportFileSaverProvider),
  );
});

enum LibraryExportStatus { saved, cancelled, failed }

class LibraryExportOutcome {
  const LibraryExportOutcome._(this.status, {this.fileName});

  const LibraryExportOutcome.saved(String fileName)
    : this._(LibraryExportStatus.saved, fileName: fileName);

  const LibraryExportOutcome.cancelled()
    : this._(LibraryExportStatus.cancelled);

  const LibraryExportOutcome.failed() : this._(LibraryExportStatus.failed);

  final LibraryExportStatus status;
  final String? fileName;
}

abstract interface class LibraryExportCommand {
  Future<LibraryExportOutcome> execute();
}

class LibraryExportController implements LibraryExportCommand {
  const LibraryExportController({
    required LibraryExportRepository repository,
    required LibraryExportFileSaver fileSaver,
  }) : _repository = repository,
       _fileSaver = fileSaver;

  final LibraryExportRepository _repository;
  final LibraryExportFileSaver _fileSaver;

  @override
  Future<LibraryExportOutcome> execute() async {
    try {
      final document = await _repository.createDocument();
      final fileName = libraryExportFileName(document.exportedAt);
      final destination = await _fileSaver.save(
        fileName: fileName,
        bytes: document.toUtf8Bytes(),
      );
      if (destination == null) return const LibraryExportOutcome.cancelled();
      return LibraryExportOutcome.saved(fileName);
    } on Object catch (error) {
      developer.log(
        'Library export failed: ${privacyRedactor.redact(error.toString())}',
        name: 'BacklogVault.LibraryExport',
      );
      return const LibraryExportOutcome.failed();
    }
  }
}

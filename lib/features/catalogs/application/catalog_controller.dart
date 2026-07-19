import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog_repository.dart';
import '../domain/catalog_item.dart';

final catalogControllerProvider = Provider<CatalogController>((ref) {
  return CatalogController(ref.watch(catalogRepositoryProvider));
});

final platformCatalogProvider = StreamProvider.autoDispose<List<CatalogItem>>((
  ref,
) {
  return ref.watch(catalogControllerProvider).watchPlatforms();
});

final genreCatalogProvider = StreamProvider.autoDispose<List<CatalogItem>>((
  ref,
) {
  return ref.watch(catalogControllerProvider).watchGenres();
});

/// Application boundary for catalog reads, normalization and creation.
class CatalogController {
  const CatalogController(this._repository);

  final CatalogRepository _repository;

  Stream<List<CatalogItem>> watchPlatforms() {
    return _repository.watchPlatforms().map(
      (rows) => [
        for (final row in rows)
          CatalogItem(id: row.id, name: row.name, shortName: row.shortName),
      ],
    );
  }

  Stream<List<CatalogItem>> watchGenres() {
    return _repository.watchGenres().map(
      (rows) => [
        for (final row in rows) CatalogItem(id: row.id, name: row.name),
      ],
    );
  }

  Future<String> createPlatform(String name, {String? shortName}) {
    return _repository.createPlatform(name, shortName: shortName);
  }

  Future<String> createGenre(String name) => _repository.createGenre(name);

  Future<void> seedDefaultsIfEmpty() => _repository.seedDefaultsIfEmpty();
}

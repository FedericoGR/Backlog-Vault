import 'package:backlog_vault/features/catalogs/domain/catalog_item.dart';
import 'package:backlog_vault/features/metadata/application/build_metadata_diff_use_case.dart';
import 'package:backlog_vault/features/metadata/domain/external_game_details.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_field.dart';
import 'package:backlog_vault/features/metadata/domain/local_metadata_snapshot.dart';
import 'package:test/test.dart';

void main() {
  const buildDiff = BuildMetadataDiffUseCase();

  test('preselects empty local fields and protects manual values', () {
    final diff = buildDiff(
      local: _details(releaseDate: null, platforms: const [], genres: const []),
      external: ExternalGameDetails(
        providerId: 'rawg',
        providerName: 'RAWG',
        externalId: '1',
        title: 'External Title',
        releaseDate: _externalReleaseDate,
        genres: ['Action'],
        platforms: ['PC'],
      ),
    );

    expect(
      _change(diff.changes, MetadataField.title).selectedByDefault,
      isFalse,
    );
    expect(
      _change(diff.changes, MetadataField.releaseDate).selectedByDefault,
      isTrue,
    );
    expect(
      _change(diff.changes, MetadataField.genres).selectedByDefault,
      isTrue,
    );
    expect(
      _change(diff.changes, MetadataField.platforms).selectedByDefault,
      isTrue,
    );
  });

  test('does not preselect fields that already have local values', () {
    final diff = buildDiff(
      local: _details(
        releaseDate: DateTime(2026, 1, 1),
        platforms: [_platform('PC')],
        genres: [_genre('RPG')],
      ),
      external: ExternalGameDetails(
        providerId: 'rawg',
        providerName: 'RAWG',
        externalId: '1',
        title: 'External Title',
        releaseDate: _externalReleaseDate,
        genres: ['Action', 'RPG'],
        platforms: ['Nintendo Switch', 'PC'],
      ),
    );

    for (final change in diff.changes) {
      expect(change.selectedByDefault, isFalse);
    }
    expect(_change(diff.changes, MetadataField.genres).externalValue, 'Action');
    expect(
      _change(diff.changes, MetadataField.platforms).externalValue,
      'Nintendo Switch',
    );
  });
}

final _externalReleaseDate = DateTime(2026, 6, 10);
LocalMetadataSnapshot _details({
  required DateTime? releaseDate,
  required List<CatalogItem> platforms,
  required List<CatalogItem> genres,
}) {
  return LocalMetadataSnapshot(
    title: 'Local Title',
    releaseDate: releaseDate,
    type: 'game',
    platforms: [for (final platform in platforms) platform.name],
    genres: [for (final genre in genres) genre.name],
  );
}

CatalogItem _platform(String name) {
  return CatalogItem(id: name, name: name, shortName: null);
}

CatalogItem _genre(String name) {
  return CatalogItem(id: name, name: name);
}

dynamic _change(List<dynamic> changes, MetadataField field) {
  return changes.singleWhere((change) => change.field == field);
}

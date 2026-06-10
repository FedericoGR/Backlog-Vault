import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/games/application/library_game_details.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/metadata/application/build_metadata_diff_use_case.dart';
import 'package:backlog_vault/features/metadata/domain/external_game_details.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_field.dart';
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
final _now = DateTime(2026, 6, 10);

LibraryGameDetails _details({
  required DateTime? releaseDate,
  required List<Platform> platforms,
  required List<Genre> genres,
}) {
  return LibraryGameDetails(
    game: Game(
      id: 'game-1',
      title: 'Local Title',
      sortTitle: null,
      releaseDate: releaseDate,
      type: 'game',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    entry: LibraryEntry(
      id: 'entry-1',
      gameId: 'game-1',
      status: GameStatus.backlog.name,
      personalRating: 4,
      personalNotes: 'Manual',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    platforms: platforms,
    genres: genres,
    playthroughs: const [],
  );
}

Platform _platform(String name) {
  return Platform(
    id: name,
    name: name,
    shortName: null,
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  );
}

Genre _genre(String name) {
  return Genre(
    id: name,
    name: name,
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  );
}

dynamic _change(List<dynamic> changes, MetadataField field) {
  return changes.singleWhere((change) => change.field == field);
}

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/bulk_metadata_import/application/apply_bulk_metadata_plan_use_case.dart';
import 'package:backlog_vault/features/bulk_metadata_import/application/build_bulk_metadata_plan_use_case.dart';
import 'package:backlog_vault/features/bulk_metadata_import/application/bulk_import_scope_filter.dart';
import 'package:backlog_vault/features/bulk_metadata_import/application/bulk_match_scorer.dart';
import 'package:backlog_vault/features/bulk_metadata_import/domain/bulk_metadata_import_models.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/media/domain/media_asset_models.dart';
import 'package:backlog_vault/features/metadata/data/metadata_repository.dart';
import 'package:backlog_vault/features/metadata/domain/external_game_details.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_exception.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_field.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_provider.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_search_candidate.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  group('BulkImportScopeFilter', () {
    test('filters active rows by metadata, cover and incomplete fields', () {
      const filter = BulkImportScopeFilter();
      final complete = _row(
        gameId: 'game-complete',
        title: 'Complete',
        hasExternalMetadata: true,
        selectedCoverLocalPath: 'media/games/game-complete/cover.png',
        releaseDate: DateTime(2020),
        platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
        genres: const [LibraryCatalogItem(id: 'rpg', name: 'RPG')],
      );
      final missingMetadata = _row(
        gameId: 'game-metadata',
        title: 'Missing metadata',
        selectedCoverLocalPath: 'media/games/game-metadata/cover.png',
        releaseDate: DateTime(2020),
        platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
        genres: const [LibraryCatalogItem(id: 'rpg', name: 'RPG')],
      );
      final missingCover = _row(
        gameId: 'game-cover',
        title: 'Missing cover',
        hasExternalMetadata: true,
        releaseDate: DateTime(2020),
        platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
        genres: const [LibraryCatalogItem(id: 'rpg', name: 'RPG')],
      );

      expect(
        filter.apply(
          rows: [complete, missingMetadata, missingCover],
          scope: BulkMetadataImportScope.all,
        ),
        hasLength(3),
      );
      expect(
        filter
            .apply(
              rows: [complete, missingMetadata, missingCover],
              scope: BulkMetadataImportScope.onlyWithoutMetadata,
            )
            .map((row) => row.gameId),
        ['game-metadata'],
      );
      expect(
        filter
            .apply(
              rows: [complete, missingMetadata, missingCover],
              scope: BulkMetadataImportScope.onlyWithoutCover,
            )
            .map((row) => row.gameId),
        ['game-cover'],
      );
      expect(
        filter
            .apply(
              rows: [complete, missingMetadata, missingCover],
              scope: BulkMetadataImportScope.onlyIncompleteFields,
            )
            .map((row) => row.gameId),
        ['game-metadata'],
      );
    });
  });

  group('BulkMatchScorer', () {
    test('marks exact single title match as safe', () {
      const scorer = BulkMatchScorer();
      final scored = scorer.scoreCandidates(
        row: _row(title: 'Hades'),
        candidates: [
          MetadataSearchCandidate(
            providerId: 'igdb',
            providerName: 'IGDB',
            externalId: '1',
            title: 'Hades',
          ),
        ],
      );

      expect(scored.single.confidence, BulkMetadataConfidence.safe);
      expect(scored.single.reasons, contains('título exacto'));
    });

    test('does not auto-safe close ties', () {
      const scorer = BulkMatchScorer();
      final scored = scorer.scoreCandidates(
        row: _row(title: 'Hades'),
        candidates: [
          MetadataSearchCandidate(
            providerId: 'igdb',
            providerName: 'IGDB',
            externalId: '1',
            title: 'Hades',
          ),
          MetadataSearchCandidate(
            providerId: 'igdb',
            providerName: 'IGDB',
            externalId: '2',
            title: 'Hades',
          ),
        ],
      );

      expect(scored.first.confidence, BulkMetadataConfidence.ambiguous);
    });

    test('existing external id makes the matching candidate safe', () {
      const scorer = BulkMatchScorer();
      final scored = scorer.scoreCandidates(
        row: _row(title: 'Local title'),
        existingExternalId: '2',
        candidates: [
          MetadataSearchCandidate(
            providerId: 'igdb',
            providerName: 'IGDB',
            externalId: '1',
            title: 'Local Title',
          ),
          MetadataSearchCandidate(
            providerId: 'igdb',
            providerName: 'IGDB',
            externalId: '2',
            title: 'Different Provider Title',
          ),
        ],
      );

      expect(scored.first.candidate.externalId, '2');
      expect(scored.first.confidence, BulkMetadataConfidence.safe);
      expect(scored.first.reasons, contains('external ID existente'));
    });

    test('similar title with secondary signals is probable, not safe', () {
      const scorer = BulkMatchScorer();
      final scored = scorer.scoreCandidates(
        row: _row(
          title: 'Final Fantasy XIII-2',
          releaseDate: DateTime(2012),
          platforms: const [
            LibraryCatalogItem(id: 'ps3', name: 'PlayStation 3'),
          ],
        ),
        candidates: [
          MetadataSearchCandidate(
            providerId: 'igdb',
            providerName: 'IGDB',
            externalId: 'ff',
            title: 'Final Fantasy XIII-2 HD',
            releaseDate: DateTime(2012),
            platforms: ['PlayStation 3'],
          ),
        ],
      );

      expect(scored.single.confidence, BulkMetadataConfidence.probable);
    });

    test(
      'normalizes safe edition suffixes without creating obvious false positives',
      () {
        expect(
          normalizeTitle('Hades Definitive Edition'),
          normalizeTitle('Hades'),
        );
        expect(
          normalizeTitle("Hades Collector's Edition"),
          normalizeTitle('Hades'),
        );
        expect(
          normalizeTitle('Hades Game of the Year'),
          normalizeTitle('Hades'),
        );
        expect(normalizeTitle('Hades Remastered'), normalizeTitle('Hades'));

        const scorer = BulkMatchScorer();
        final scored = scorer.scoreCandidates(
          row: _row(title: 'Hades'),
          candidates: const [
            MetadataSearchCandidate(
              providerId: 'igdb',
              providerName: 'IGDB',
              externalId: 'halo',
              title: 'Halo Infinite',
            ),
          ],
        );

        expect(scored.single.confidence, isNot(BulkMetadataConfidence.safe));
      },
    );
  });

  group('BuildBulkMetadataPlanUseCase', () {
    test(
      'builds safe preview with selected empty fields and IGDB cover',
      () async {
        final provider = _FakeMetadataProvider(
          candidates: {
            'Hades': const [
              MetadataSearchCandidate(
                providerId: 'igdb',
                providerName: 'IGDB',
                externalId: '1',
                title: 'Hades',
              ),
            ],
          },
          details: {'1': _details()},
        );

        final plan = await const BuildBulkMetadataPlanUseCase().call(
          rows: [_row(title: 'Hades')],
          provider: provider,
          options: const BulkMetadataImportOptions(providerId: 'igdb'),
        );

        final item = plan.items.single;
        expect(item.included, isTrue);
        expect(item.confidence, BulkMetadataConfidence.safe);
        expect(
          item.fieldPlans.map((plan) => plan.field),
          contains(MetadataField.releaseDate),
        );
        expect(
          item.fieldPlans
              .singleWhere((plan) => plan.field == MetadataField.releaseDate)
              .selected,
          isTrue,
        );
        expect(item.coverPlan?.selected, isTrue);
        expect(item.coverPlan?.asset?.providerId, 'igdb');
      },
    );

    test('does not replace existing cover by default', () async {
      final provider = _FakeMetadataProvider(
        candidates: {
          'Hades': const [
            MetadataSearchCandidate(
              providerId: 'igdb',
              providerName: 'IGDB',
              externalId: '1',
              title: 'Hades',
            ),
          ],
        },
        details: {'1': _details()},
      );

      final plan = await const BuildBulkMetadataPlanUseCase().call(
        rows: [
          _row(title: 'Hades', selectedCoverLocalPath: 'media/existing.png'),
        ],
        provider: provider,
        options: const BulkMetadataImportOptions(providerId: 'igdb'),
      );

      expect(plan.items.single.coverPlan?.canApply, isFalse);
      expect(plan.items.single.coverPlan?.selected, isFalse);
    });

    test('allows cover replacement only with explicit option', () async {
      final provider = _FakeMetadataProvider(
        candidates: {
          'Hades': const [
            MetadataSearchCandidate(
              providerId: 'igdb',
              providerName: 'IGDB',
              externalId: '1',
              title: 'Hades',
            ),
          ],
        },
        details: {'1': _details()},
      );

      final plan = await const BuildBulkMetadataPlanUseCase().call(
        rows: [
          _row(title: 'Hades', selectedCoverLocalPath: 'media/existing.png'),
        ],
        provider: provider,
        options: const BulkMetadataImportOptions(
          providerId: 'igdb',
          replaceExistingCovers: true,
        ),
      );

      expect(plan.items.single.coverPlan?.canApply, isTrue);
      expect(plan.items.single.coverPlan?.selected, isTrue);
    });

    test(
      'probable or ambiguous matches are not included automatically',
      () async {
        final provider = _FakeMetadataProvider(
          candidates: {
            'Hades': const [
              MetadataSearchCandidate(
                providerId: 'igdb',
                providerName: 'IGDB',
                externalId: '1',
                title: 'Hades II',
              ),
            ],
          },
          details: {'1': _details(title: 'Hades II')},
        );

        final plan = await const BuildBulkMetadataPlanUseCase().call(
          rows: [_row(title: 'Hades')],
          provider: provider,
          options: const BulkMetadataImportOptions(providerId: 'igdb'),
        );

        expect(plan.items.single.included, isFalse);
        expect(plan.items.single.selectedDetails, isNull);
        expect(
          plan.items.single.issues.single.severity,
          BulkImportIssueSeverity.warning,
        );
      },
    );

    test(
      'existing external id can select a safe candidate despite local title drift',
      () async {
        final provider = _FakeMetadataProvider(
          candidates: {
            'Local title': const [
              MetadataSearchCandidate(
                providerId: 'igdb',
                providerName: 'IGDB',
                externalId: '1',
                title: 'Local Title',
              ),
              MetadataSearchCandidate(
                providerId: 'igdb',
                providerName: 'IGDB',
                externalId: '2',
                title: 'Canonical Title',
              ),
            ],
          },
          details: {'2': _details(title: 'Canonical Title', externalId: '2')},
        );

        final plan = await const BuildBulkMetadataPlanUseCase().call(
          rows: [_row(title: 'Local title')],
          provider: provider,
          options: const BulkMetadataImportOptions(providerId: 'igdb'),
          loadExternalIds: (_) async => [_externalId('2')],
        );

        final item = plan.items.single;
        expect(item.included, isTrue);
        expect(item.candidates.first.candidate.externalId, '2');
        expect(item.candidates.first.confidence, BulkMetadataConfidence.safe);
      },
    );

    test('different existing external id blocks bulk replacement', () async {
      final provider = _FakeMetadataProvider(
        candidates: {
          'Hades': const [
            MetadataSearchCandidate(
              providerId: 'igdb',
              providerName: 'IGDB',
              externalId: '1',
              title: 'Hades',
            ),
          ],
        },
        details: {'1': _details()},
      );

      final plan = await const BuildBulkMetadataPlanUseCase().call(
        rows: [_row(title: 'Hades')],
        provider: provider,
        options: const BulkMetadataImportOptions(providerId: 'igdb'),
        loadExternalIds: (_) async => [_externalId('different')],
      );

      final item = plan.items.single;
      expect(item.included, isFalse);
      expect(item.hasErrorIssue, isTrue);
      expect(item.issues.single.message, contains('otro match externo'));
    });

    test('provider errors are reported per item with secrets redacted', () async {
      final provider = _FakeMetadataProvider(
        searchError: const MetadataException(
          'Authorization: Bearer test_access_token client_secret=test_client_secret',
          type: MetadataErrorType.invalidApiKey,
        ),
      );

      final plan = await const BuildBulkMetadataPlanUseCase().call(
        rows: [_row(title: 'Hades')],
        provider: provider,
        options: const BulkMetadataImportOptions(providerId: 'igdb'),
      );

      final message = plan.items.single.issues.single.message;
      expect(message, contains('Bearer [REDACTED]'));
      expect(message, isNot(contains('test_access_token')));
      expect(message, isNot(contains('test_client_secret')));
    });
  });

  group('ApplyBulkMetadataPlanUseCase', () {
    late AppDatabase db;
    late MetadataRepository metadataRepository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      metadataRepository = MetadataRepository(db);
      await _seedGame(db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'applies selected metadata without touching personal fields',
      () async {
        final savedCovers = <ExternalMediaAsset>[];
        final useCase = ApplyBulkMetadataPlanUseCase(
          applyMetadata: metadataRepository.applyMetadata,
          saveCover: ({required gameId, required asset}) async {
            savedCovers.add(asset);
          },
        );
        final item = BulkMetadataImportItem(
          row: _row(
            gameId: 'game-1',
            libraryEntryId: 'entry-1',
            title: 'Hades',
          ),
          included: true,
          selectedDetails: _details(),
          fieldPlans: const [
            BulkMetadataFieldPlan(
              field: MetadataField.releaseDate,
              currentValue: '-',
              externalValue: '17-09-2020',
              selected: true,
            ),
            BulkMetadataFieldPlan(
              field: MetadataField.title,
              currentValue: 'Hades',
              externalValue: 'Hades',
              selected: false,
            ),
          ],
          coverPlan: BulkCoverPlan(
            asset: _coverAsset(),
            selected: true,
            canApply: true,
          ),
        );

        final result = await useCase.call(
          BulkMetadataImportPlan(
            options: const BulkMetadataImportOptions(providerId: 'igdb'),
            items: [item],
          ),
        );

        final game = await db.select(db.games).getSingle();
        final entry = await db.select(db.libraryEntries).getSingle();
        final externalIds = await db.select(db.externalGameIds).get();

        expect(result.metadataApplied, 1);
        expect(result.fieldChangesApplied, 1);
        expect(result.externalLinksSaved, 1);
        expect(result.coversSaved, 1);
        expect(savedCovers.single.providerId, 'igdb');
        expect(game.releaseDate, DateTime(2020, 9, 17));
        expect(game.title, 'Hades');
        expect(entry.status, GameStatus.playing.name);
        expect(entry.personalRating, 5);
        expect(entry.personalNotes, 'Manual note');
        expect(externalIds.single.provider, 'igdb');
      },
    );

    test('continues partial import after item error', () async {
      var calls = 0;
      final useCase = ApplyBulkMetadataPlanUseCase(
        applyMetadata: (request) async {
          calls++;
          if (request.gameId == 'game-error') {
            throw Exception('Authorization: Bearer test_access_token');
          }
        },
        saveCover: ({required gameId, required asset}) async {},
      );

      final result = await useCase.call(
        BulkMetadataImportPlan(
          options: const BulkMetadataImportOptions(providerId: 'igdb'),
          items: [
            _applyItem('game-error', 'entry-error'),
            _applyItem('game-ok', 'entry-ok'),
          ],
        ),
      );

      expect(calls, 2);
      expect(result.metadataApplied, 1);
      expect(
        result.errors.single.message,
        isNot(contains('test_access_token')),
      );
      expect(result.errors.single.message, contains('Bearer [REDACTED]'));
    });

    test('metadata can succeed when cover fails', () async {
      var metadataCalls = 0;
      final useCase = ApplyBulkMetadataPlanUseCase(
        applyMetadata: (request) async {
          metadataCalls++;
        },
        saveCover: ({required gameId, required asset}) async {
          throw Exception('download failed token=test_access_token');
        },
      );

      final result = await useCase.call(
        BulkMetadataImportPlan(
          options: const BulkMetadataImportOptions(providerId: 'igdb'),
          items: [
            _applyItem('game-ok', 'entry-ok').copyWith(
              coverPlan: BulkCoverPlan(
                asset: _coverAsset(),
                selected: true,
                canApply: true,
              ),
            ),
          ],
        ),
      );

      expect(metadataCalls, 1);
      expect(result.metadataApplied, 1);
      expect(result.coversSaved, 0);
      expect(result.errors.single.message, contains('portada no guardada'));
      expect(
        result.errors.single.message,
        isNot(contains('test_access_token')),
      );
    });

    test('cover can be omitted while metadata applies', () async {
      var metadataCalls = 0;
      var coverCalls = 0;
      final useCase = ApplyBulkMetadataPlanUseCase(
        applyMetadata: (request) async {
          metadataCalls++;
        },
        saveCover: ({required gameId, required asset}) async {
          coverCalls++;
        },
      );

      final result = await useCase.call(
        BulkMetadataImportPlan(
          options: const BulkMetadataImportOptions(providerId: 'igdb'),
          items: [
            _applyItem('game-ok', 'entry-ok').copyWith(
              coverPlan: BulkCoverPlan(
                asset: _coverAsset(),
                selected: false,
                canApply: true,
              ),
            ),
          ],
        ),
      );

      expect(metadataCalls, 1);
      expect(coverCalls, 0);
      expect(result.metadataApplied, 1);
      expect(result.coversSaved, 0);
    });

    test('skipped warnings are included in final result', () async {
      final useCase = ApplyBulkMetadataPlanUseCase(
        applyMetadata: (request) async {},
        saveCover: ({required gameId, required asset}) async {},
      );

      final result = await useCase.call(
        BulkMetadataImportPlan(
          options: const BulkMetadataImportOptions(providerId: 'igdb'),
          items: [
            BulkMetadataImportItem(
              row: _row(title: 'Ambiguous'),
              included: false,
              issues: const [
                BulkImportIssue(message: 'Match ambiguo: requiere revisión.'),
              ],
            ),
          ],
        ),
      );

      expect(result.skipped, 1);
      expect(result.warnings.single.message, contains('Match ambiguo'));
      expect(result.warnings.single.displayMessage, contains('Ambiguous'));
      expect(result.warnings.single.displayMessage, contains('igdb'));
      expect(result.warnings.single.displayMessage, contains('Match ambiguo'));
      expect(result.errors, isEmpty);
    });

    test(
      'separates external links, field changes and covers in result',
      () async {
        final useCase = ApplyBulkMetadataPlanUseCase(
          applyMetadata: (request) async {},
          saveCover: ({required gameId, required asset}) async {},
        );

        final result = await useCase.call(
          BulkMetadataImportPlan(
            options: const BulkMetadataImportOptions(providerId: 'igdb'),
            items: [
              BulkMetadataImportItem(
                row: _row(title: 'Link only'),
                included: true,
                selectedDetails: _details(title: 'Link only'),
                coverPlan: BulkCoverPlan(
                  asset: _coverAsset(),
                  selected: true,
                  canApply: true,
                ),
              ),
            ],
          ),
        );

        expect(result.metadataApplied, 0);
        expect(result.fieldChangesApplied, 0);
        expect(result.externalLinksSaved, 1);
        expect(result.coversSaved, 1);
      },
    );
  });
}

LibraryGameRow _row({
  String gameId = 'game-1',
  String libraryEntryId = 'entry-1',
  String title = 'Hades',
  bool hasExternalMetadata = false,
  String? selectedCoverLocalPath,
  DateTime? releaseDate,
  List<LibraryCatalogItem> platforms = const [],
  List<LibraryCatalogItem> genres = const [],
}) {
  return LibraryGameRow(
    gameId: gameId,
    libraryEntryId: libraryEntryId,
    title: title,
    selectedCoverLocalPath: selectedCoverLocalPath,
    hasExternalMetadata: hasExternalMetadata,
    status: GameStatus.backlog,
    releaseDate: releaseDate,
    type: 'game',
    platforms: platforms,
    genres: genres,
    playthroughCount: 0,
    updatedAt: DateTime(2026, 6, 13),
  );
}

ExternalGameDetails _details({
  String title = 'Hades',
  String externalId = '1',
}) {
  return ExternalGameDetails(
    providerId: 'igdb',
    providerName: 'IGDB',
    externalId: externalId,
    externalSlug: 'hades',
    externalUrl: 'https://www.igdb.com/games/hades',
    title: title,
    releaseDate: DateTime(2020, 9, 17),
    genres: const ['Role-playing (RPG)', 'Adventure'],
    platforms: const ['PC (Microsoft Windows)'],
    cover: const ExternalGameCover(
      externalId: 'cover-1',
      imageId: 'cofixture',
      remoteUrl:
          'https://images.igdb.com/igdb/image/upload/t_cover_big/cofixture.jpg',
      width: 600,
      height: 800,
    ),
  );
}

ExternalMediaAsset _coverAsset() {
  return const ExternalMediaAsset(
    providerId: 'igdb',
    providerName: 'IGDB',
    externalId: 'cover-1',
    kind: MediaAssetKind.cover,
    remoteUrl:
        'https://images.igdb.com/igdb/image/upload/t_cover_big/cofixture.jpg',
    mimeType: 'image/jpeg',
  );
}

ExternalGameId _externalId(String externalId) {
  final now = DateTime(2026, 6, 13);
  return ExternalGameId(
    id: 'external-$externalId',
    gameId: 'game-1',
    provider: 'igdb',
    externalId: externalId,
    externalSlug: null,
    externalUrl: null,
    matchedTitle: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}

BulkMetadataImportItem _applyItem(String gameId, String entryId) {
  return BulkMetadataImportItem(
    row: _row(gameId: gameId, libraryEntryId: entryId, title: gameId),
    included: true,
    selectedDetails: _details(title: gameId),
    fieldPlans: const [
      BulkMetadataFieldPlan(
        field: MetadataField.releaseDate,
        currentValue: '-',
        externalValue: '17-09-2020',
        selected: true,
      ),
    ],
  );
}

Future<void> _seedGame(AppDatabase db) async {
  final now = DateTime(2026, 6, 13);
  await db
      .into(db.games)
      .insert(
        GamesCompanion.insert(
          id: 'game-1',
          title: 'Hades',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.libraryEntries)
      .insert(
        LibraryEntriesCompanion.insert(
          id: 'entry-1',
          gameId: 'game-1',
          status: GameStatus.playing.name,
          personalRating: const Value(5),
          personalNotes: const Value('Manual note'),
          createdAt: now,
          updatedAt: now,
        ),
      );
}

class _FakeMetadataProvider implements MetadataProvider {
  const _FakeMetadataProvider({
    this.candidates = const {},
    this.details = const {},
    this.searchError,
  });

  final Map<String, List<MetadataSearchCandidate>> candidates;
  final Map<String, ExternalGameDetails> details;
  final MetadataException? searchError;

  @override
  String get providerId => 'igdb';

  @override
  String get displayName => 'IGDB';

  @override
  bool get requiresApiKey => true;

  @override
  Future<List<MetadataSearchCandidate>> searchGames(String query) async {
    final error = searchError;
    if (error != null) throw error;
    return candidates[query] ?? const [];
  }

  @override
  Future<ExternalGameDetails> getGameDetails(String externalId) async {
    return details[externalId] ?? _details();
  }
}

import 'package:backlog_vault/app/bootstrap/backlog_vault_app.dart';
import 'package:backlog_vault/app/routing/app_router.dart';
import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/database/database_providers.dart';
import 'package:backlog_vault/features/catalogs/application/catalog_controller.dart';
import 'package:backlog_vault/features/games/application/game_form_model.dart';
import 'package:backlog_vault/features/games/application/game_view_models.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/games/presentation/widgets/personal_rating_field.dart';
import 'package:backlog_vault/features/library/application/annual_game_log.dart';
import 'package:backlog_vault/features/library/application/library_providers.dart';
import 'package:backlog_vault/features/library/presentation/widgets/library_catalog_widgets.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/settings/application/app_language.dart';
import 'package:backlog_vault/features/statistics/application/library_statistics_calculator.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Spanish extends AppLanguageController {
  @override
  Future<AppLanguagePreference> build() async => AppLanguagePreference.spanish;
}

class _Clock extends Clock {
  @override
  DateTime now() => DateTime(2026, 10, 6);
}

Future<void> chooseDate(
  WidgetTester tester,
  DateTime date, {
  int index = 0,
}) async {
  final choose = find.text('Elegir').at(index);
  await tester.ensureVisible(choose);
  await tester.tap(choose);
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(DatePickerDialog),
      matching: find.byIcon(Icons.edit_outlined),
    ),
  );
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(
      of: find.byType(InputDatePickerFormField),
      matching: find.byType(TextFormField),
    ),
    '${date.day}/${date.month}/${date.year}',
  );
  final ok =
      MaterialLocalizations.of(
        tester.element(find.byType(DatePickerDialog)),
      ).okButtonLabel;
  await tester.tap(find.text(ok));
  await tester.pumpAndSettle();
}

void main() {
  for (final wasCompleted in [false, true]) {
    for (final completed in [false, true]) {
      testWidgets(
        'edit $wasCompleted -> $completed persists and refreshes detail, form, gallery and statistics',
        (tester) async {
          tester.view.physicalSize = const Size(1440, 960);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final db = AppDatabase(NativeDatabase.memory());
          final container = ProviderContainer(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              appLanguageProvider.overrideWith(_Spanish.new),
              annualLogClockProvider.overrideWithValue(_Clock()),
            ],
          );
          addTearDown(() async {
            container.dispose();
            await db.close();
          });
          final catalogs = container.read(catalogControllerProvider);
          final pc = await catalogs.createPlatform('PC');
          final ps5 = await catalogs.createPlatform('PlayStation 5');
          final genre = await catalogs.createGenre('Adventure');
          final games = container.read(gameRepositoryProvider);
          final id = await container
              .read(gameFormViewModelProvider)
              .save(
                GameFormSaveRequest(
                  model: GameFormModel(
                    title: 'Existing game',
                    isCompleted: wasCompleted,
                    playedYear: 2025,
                    completedAt: DateTime(2025, 1, 1),
                    hoursPlayed: 12,
                    personalRating: 3,
                    playedPlatformId: pc,
                    personalNotes: 'Original notes',
                    platformIds: [pc],
                    genreIds: [genre],
                  ),
                ),
              );
          final original = (await games.getByEntryId(id))!;
          await games.save(
            GameFormModel(
              title: 'January game',
              isCompleted: true,
              playedYear: 2026,
              completedAt: DateTime(2026, 1, 1),
            ),
          );
          // Keep the same live stream the annual gallery/statistics consume subscribed.
          final rowsSubscription = container.listen(
            libraryRowsProvider,
            (_, _) {},
          );
          addTearDown(rowsSubscription.close);
          await container.read(libraryRowsProvider.future);
          final router = container.read(appRouterProvider);
          router.go('/games/$id');
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: const BacklogVaultApp(),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Editar'));
          await tester.pumpAndSettle();
          Finder field(String key) => find.byKey(ValueKey(key));
          expect(
            tester.widget<TextFormField>(field('hours-field')).controller!.text,
            '12.0',
          );
          expect(
            tester
                .widget<TextFormField>(field('played-year-field'))
                .controller!
                .text,
            '2025',
          );
          expect(
            tester
                .widget<PersonalRatingField>(find.byType(PersonalRatingField))
                .value,
            3,
          );
          if (wasCompleted != completed) {
            await tester.tap(
              find.text(completed ? 'Terminado' : 'No terminado'),
            );
            await tester.pumpAndSettle();
          }
          final expectedDate =
              completed ? DateTime(2026, 9, 26) : DateTime(2025, 1, 1);
          if (completed) await chooseDate(tester, expectedDate);
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Nombre'),
            'Edited game',
          );
          await tester.enterText(field('played-year-field'), '2026');
          await tester.enterText(field('hours-field'), '45.5');
          await tester.tap(field('rating-5'));
          await tester.tap(field('played-platform-field'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('PS5').last);
          await tester.pumpAndSettle();
          await tester.enterText(field('notes-field'), 'Edited notes');
          await tester.ensureVisible(find.text('Guardar'));
          await tester.tap(find.text('Guardar'));
          await tester.pumpAndSettle();
          final persisted = (await games.getByEntryId(id))!;
          expect(persisted.entry.playedYear, 2026);
          expect(persisted.entry.hoursPlayed, 45.5);
          expect(persisted.entry.personalRating, 5);
          expect(persisted.entry.playedPlatformId, ps5);
          expect(persisted.entry.personalNotes, 'Edited notes');
          expect(persisted.entry.isCompleted, completed);
          expect(persisted.entry.completedAt, expectedDate);
          expect(persisted.game.title, 'Edited game');
          expect(persisted.game.id, original.game.id);
          expect(persisted.entry.gameId, original.game.id);
          expect(persisted.platforms.single.id, pc);
          expect(persisted.genres.single.id, genre);
          expect(await db.select(db.libraryEntries).get(), hasLength(2));
          expect(await db.select(db.playthroughs).get(), isEmpty);
          expect(find.text('Edited notes'), findsOneWidget);
          expect(find.text('Jugado en 2026'), findsOneWidget);
          expect(find.text('45,5 h'), findsOneWidget);
          expect(find.text('PS5'), findsOneWidget);
          final savedRows = container.read(libraryRowsProvider).requireValue;
          final stats = const LibraryStatisticsCalculator().calculate(
            rows: savedRows,
            year: 2026,
          );
          expect(stats.totalGames, 2);
          expect(stats.completedCount, completed ? 2 : 1);
          expect(stats.totalHours, 45.5);
          expect(stats.averageRating, 5);
          expect(stats.platformBreakdown.single.id, ps5);
          final filtered = AnnualGameLogState(
            year: 2026,
            query: 'Edited',
            playedPlatformIds: {ps5},
            ratingFilter: LibraryRatingFilter.fourPlus,
          ).visibleRows(savedRows);
          expect(filtered.single.libraryEntryId, id);
          expect(
            AnnualGameLogState(
              year: 2026,
              playedPlatformIds: {pc},
            ).visibleRows(savedRows),
            isEmpty,
          );
          await tester.tap(find.text('Editar'));
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextFormField>(field('hours-field')).controller!.text,
            '45.5',
          );
          expect(
            tester.widget<TextFormField>(field('notes-field')).controller!.text,
            'Edited notes',
          );
          expect(
            tester
                .widget<PersonalRatingField>(find.byType(PersonalRatingField))
                .value,
            5,
          );
          expect(
            tester
                .widget<DropdownButtonFormField<String?>>(
                  field('played-platform-field'),
                )
                .initialValue,
            ps5,
          );
          // A second save must use the refreshed model, preserving all prior edits.
          await tester.tap(field('clear-rating'));
          await tester.enterText(field('notes-field'), '');
          await tester.ensureVisible(find.text('Información del juego'));
          await tester.tap(find.text('Información del juego'));
          await tester.pumpAndSettle();
          await chooseDate(
            tester,
            DateTime(2020, 9, 17),
            index: completed ? 1 : 0,
          );
          await tester.ensureVisible(find.text('Guardar'));
          await tester.tap(find.text('Guardar'));
          await tester.pumpAndSettle();
          final cleared = (await games.getByEntryId(id))!;
          expect(cleared.entry.personalRating, isNull);
          expect(cleared.entry.personalNotes, isNull);
          expect(cleared.entry.hoursPlayed, 45.5);
          expect(cleared.entry.playedYear, 2026);
          expect(cleared.entry.completedAt, expectedDate);
          expect(cleared.game.releaseDate, DateTime(2020, 9, 17));
          expect(find.text('Edited notes'), findsNothing);
          expect(find.text('Fecha de salida: 2020'), findsOneWidget);
          final rows = container.read(libraryRowsProvider).requireValue;
          expect(
            rows.singleWhere((r) => r.libraryEntryId == id).hoursPlayed,
            45.5,
          );
          expect(
            const AnnualGameLogState(year: 2025).visibleRows(rows),
            isEmpty,
          );
          router.go('/');
          await tester.pumpAndSettle();
          final gallery = tester.widget<LibraryCatalogGrid>(
            find.byType(LibraryCatalogGrid),
          );
          expect(
            gallery.rows.map((r) => r.title).toList(),
            completed
                ? ['Edited game', 'January game']
                : ['January game', 'Edited game'],
          );
          await tester.tap(find.text('Estadísticas'));
          await tester.pumpAndSettle();
          String kpi(String key) =>
              tester.widget<Text>(field('statistics-$key')).data!;
          expect(kpi('games'), '2');
          expect(kpi('completed'), completed ? '2' : '1');
          expect(kpi('hours'), '45,5');
          expect(kpi('rating'), 'Sin datos');
          expect(find.text('PS5'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        },
      );
    }
  }
  for (final completed in [false, true]) {
    testWidgets(
      'create $completed saves optional-date personal record through real route and repository',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 960);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = AppDatabase(NativeDatabase.memory());
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            appLanguageProvider.overrideWith(_Spanish.new),
          ],
        );
        addTearDown(() async {
          container.dispose();
          await db.close();
        });
        final pc = await container
            .read(catalogControllerProvider)
            .createPlatform('PC');
        final router = container.read(appRouterProvider);
        router.go('/games/new?year=2026');
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const BacklogVaultApp(),
          ),
        );
        await tester.pumpAndSettle();
        Finder field(String key) => find.byKey(ValueKey(key));
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre'),
          'Created game',
        );
        if (completed) await tester.tap(find.text('Terminado'));
        await tester.pumpAndSettle();
        await tester.enterText(field('hours-field'), '18,5');
        await tester.tap(field('rating-4'));
        await tester.enterText(field('notes-field'), 'Created notes');
        await tester.tap(field('played-platform-field'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('PC').last);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Información del juego'));
        await tester.tap(find.text('Información del juego'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.widgetWithText(FilterChip, 'PC'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilterChip, 'PC'));
        await tester.ensureVisible(find.text('Guardar'));
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();
        final entry = await db.select(db.libraryEntries).getSingle();
        expect(entry.isCompleted, completed);
        expect(entry.completedAt, isNull);
        expect(entry.playedYear, 2026);
        expect(entry.hoursPlayed, 18.5);
        expect(entry.personalRating, 4);
        expect(entry.personalNotes, 'Created notes');
        expect(entry.playedPlatformId, pc);
        expect(await db.select(db.games).get(), hasLength(1));
        expect(await db.select(db.playthroughs).get(), isEmpty);
        final saved =
            (await container
                .read(gameRepositoryProvider)
                .getByEntryId(entry.id))!;
        expect(saved.platforms.single.id, pc);
        expect(saved.game.id, entry.gameId);
        expect(find.text('Created notes'), findsOneWidget);
        await tester.tap(find.text('Editar'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextFormField>(field('hours-field')).controller!.text,
          '18.5',
        );
        expect(
          tester.widget<TextFormField>(field('notes-field')).controller!.text,
          'Created notes',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}

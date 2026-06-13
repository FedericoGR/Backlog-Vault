import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/games/presentation/game_detail_page.dart';
import '../features/games/presentation/game_form_page.dart';
import '../features/backup_restore/presentation/backup_restore_page.dart';
import '../features/bulk_metadata_import/presentation/bulk_metadata_import_page.dart';
import '../features/import_export/notion_csv/presentation/import_notion_csv_page.dart';
import '../features/library/presentation/game_list_page.dart';
import '../features/library/presentation/home_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/statistics/presentation/statistics_page.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/statistics',
            builder: (context, state) => const StatisticsPage(),
          ),
          GoRoute(
            path: '/metadata/bulk-import',
            builder: (context, state) => const BulkMetadataImportPage(),
          ),
          GoRoute(
            path: '/',
            builder: (context, state) => const GameListPage(),
            routes: [
              GoRoute(
                path: 'games/new',
                builder: (context, state) => const GameFormPage(),
              ),
              GoRoute(
                path: 'import/notion-csv',
                builder: (context, state) => const ImportNotionCsvPage(),
              ),
              GoRoute(
                path: 'games/:entryId',
                builder:
                    (context, state) => GameDetailPage(
                      entryId: state.pathParameters['entryId']!,
                    ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder:
                        (context, state) => GameFormPage(
                          entryId: state.pathParameters['entryId']!,
                        ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'backups',
                builder: (context, state) => const BackupRestorePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

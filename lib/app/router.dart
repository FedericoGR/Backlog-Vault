import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/games/presentation/game_detail_page.dart';
import '../features/games/presentation/game_form_page.dart';
import '../features/library/presentation/game_list_page.dart';
import '../features/settings/presentation/settings_page.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const GameListPage(),
            routes: [
              GoRoute(
                path: 'games/new',
                builder: (context, state) => const GameFormPage(),
              ),
              GoRoute(
                path: 'games/:entryId',
                builder: (context, state) => GameDetailPage(
                  entryId: state.pathParameters['entryId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => GameFormPage(
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
          ),
        ],
      ),
    ],
  );
});

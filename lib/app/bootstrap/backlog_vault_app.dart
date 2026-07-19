import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/application/app_language.dart';
import '../../l10n/l10n.dart';
import '../routing/app_router.dart';
import '../theme/app_theme.dart';

class BacklogVaultApp extends ConsumerWidget {
  const BacklogVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final language = ref
        .watch(appLanguageProvider)
        .when(
          data: (value) => value,
          loading: () => AppLanguagePreference.system,
          error: (_, _) => AppLanguagePreference.system,
        );

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildBacklogVaultTheme(),
      darkTheme: buildBacklogVaultDarkTheme(),
      themeMode: ThemeMode.system,
      locale: language.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}

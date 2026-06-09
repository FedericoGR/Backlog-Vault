import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

class BacklogVaultApp extends ConsumerWidget {
  const BacklogVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Backlog Vault',
      debugShowCheckedModeBanner: false,
      theme: buildBacklogVaultTheme(),
      routerConfig: router,
    );
  }
}

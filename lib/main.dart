import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  // `ProviderScope` is the single Riverpod container for the whole app and the
  // root of dependency injection. Add global `overrides` here (e.g. for flavors
  // or integration tests).
  runApp(const ProviderScope(child: MoriApp()));
}

class MoriApp extends ConsumerWidget {
  const MoriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Mori',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

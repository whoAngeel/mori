import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/counter/presentation/screens/counter_screen.dart';

part 'app_router.g.dart';

/// Named routes. Reference these instead of hard-coding path strings:
/// `context.goNamed(AppRoute.home.name)`.
enum AppRoute { home }

/// The app's [GoRouter], exposed as a Riverpod provider so routing can react to
/// other providers (auth state, feature flags, …) via `ref.watch` +
/// `refreshListenable`.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) => const CounterScreen(),
      ),
    ],
  );
}

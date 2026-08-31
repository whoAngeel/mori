import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/challenge/presentation/screens/board_screen.dart';
import '../../features/challenge/presentation/screens/home_screen.dart';
import '../../features/pairing/presentation/providers/pairing_notifier.dart';
import '../../features/pairing/presentation/screens/onboarding_screen.dart';
import '../../features/pairing/presentation/screens/pair_scan_screen.dart';
import '../../features/pairing/presentation/screens/pair_show_screen.dart';

part 'app_router.g.dart';

/// Named routes. Reference these instead of hard-coding path strings:
/// `context.goNamed(AppRoute.home.name)`.
enum AppRoute {
  /// `/onboarding`
  onboarding,

  /// `/pair/show`
  pairShow,

  /// `/pair/scan`
  pairScan,

  /// `/restore/scan` — reached only from onboarding (placeholder until 6.12).
  restoreScan,

  /// `/`
  home,

  /// `/board`
  board,
}

/// The app's [GoRouter]. Redirects by pairing state (design §6): an unpaired
/// device is pinned to onboarding/pairing; a paired device leaves onboarding
/// for home.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  // Bridge the pairing stream to a Listenable so the redirect re-runs when the
  // pairing state changes (e.g. after creating or joining a challenge).
  final refresh = ValueNotifier<int>(0);
  ref.listen(pairingStateProvider, (previous, next) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: (context, state) {
      final pairing = ref.read(pairingStateProvider);
      // Until the first value arrives, don't redirect.
      final paired = pairing.value?.isPaired ?? false;
      final path = state.uri.path;

      final inPairingFlow = path.startsWith('/onboarding') ||
          path.startsWith('/pair') ||
          path.startsWith('/restore');

      if (!paired && !inPairingFlow) return '/onboarding';
      if (paired && path == '/onboarding') return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/pair/show',
        name: AppRoute.pairShow.name,
        builder: (context, state) => const PairShowScreen(),
      ),
      GoRoute(
        path: '/pair/scan',
        name: AppRoute.pairScan.name,
        builder: (context, state) => const PairScanScreen(),
      ),
      GoRoute(
        path: '/restore/scan',
        name: AppRoute.restoreScan.name,
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/board',
        name: AppRoute.board.name,
        builder: (context, state) => const BoardScreen(),
      ),
    ],
  );
}

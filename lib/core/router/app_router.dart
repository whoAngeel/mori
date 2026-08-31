import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/challenge/presentation/screens/board_screen.dart';
import '../../features/challenge/presentation/screens/home_screen.dart';
import '../../features/pairing/presentation/providers/pairing_notifier.dart';
import '../../features/pairing/presentation/screens/onboarding_screen.dart';
import '../../features/pairing/presentation/screens/pair_confirm_screen.dart';
import '../../features/pairing/presentation/screens/pair_respond_screen.dart';
import '../../features/pairing/presentation/screens/pair_scan_screen.dart';
import '../../features/pairing/presentation/screens/pair_show_screen.dart';
import '../../features/sync/presentation/screens/partner_board_screen.dart';
import '../../features/sync/presentation/screens/restore_scan_screen.dart';
import '../../features/sync/presentation/screens/restore_show_screen.dart';
import '../../features/sync/presentation/screens/sync_hub_screen.dart';
import '../../features/sync/presentation/screens/sync_scan_screen.dart';
import '../../features/sync/presentation/screens/sync_show_screen.dart';

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

  /// `/onboarding/pair/respond` — slot B shows its response QR.
  pairRespond,

  /// `/onboarding/pair/confirm` — slot A scans slot B's response.
  pairConfirm,

  /// `/restore/scan` — reached only from onboarding.
  restoreScan,

  /// `/restore/show` — reached only from settings.
  restoreShow,

  /// `/`
  home,

  /// `/board`
  board,

  /// `/sync`
  sync,

  /// `/sync/show`
  syncShow,

  /// `/sync/scan`
  syncScan,

  /// `/partner`
  partner,
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
      // No decision until the pairing state is actually known. A StreamProvider
      // can be momentarily value-less (first listen, a re-subscribe); treating
      // that as "unpaired" bounces a paired user out of a deep screen and then
      // back to home once the value returns.
      if (!pairing.hasValue) return null;
      final paired = pairing.requireValue.isPaired;
      final path = state.uri.path;

      // The whole onboarding flow (pairing + restore-scan) is nested under
      // /onboarding, so a single prefix check covers it.
      final inOnboarding = path.startsWith('/onboarding');

      // Only one rule: an unpaired device cannot leave the onboarding flow.
      //
      // There is deliberately NO "paired && at /onboarding -> go home" rule.
      // `context.push` does not change `state.uri` in go_router, so every
      // pushed pairing screen still reports path == '/onboarding'. That rule
      // would fire the instant `createChallenge`/`joinChallenge` flips the
      // pairing stream to Paired and eject the user from their own QR screen.
      // Screens navigate home themselves when the ceremony is done.
      if (!paired && !inOnboarding) return '/onboarding';
      return null;
    },
    routes: [
      // Onboarding subtree. The pairing/restore screens are children so that
      // pushing them keeps onboarding underneath, and the back gesture pops to
      // it instead of exiting the app.
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
        routes: [
          GoRoute(
            path: 'pair/show',
            name: AppRoute.pairShow.name,
            builder: (context, state) => const PairShowScreen(),
          ),
          GoRoute(
            path: 'pair/scan',
            name: AppRoute.pairScan.name,
            builder: (context, state) => const PairScanScreen(),
          ),
          GoRoute(
            path: 'pair/respond',
            name: AppRoute.pairRespond.name,
            builder: (context, state) => const PairRespondScreen(),
          ),
          GoRoute(
            path: 'pair/confirm',
            name: AppRoute.pairConfirm.name,
            builder: (context, state) => const PairConfirmScreen(),
          ),
          GoRoute(
            path: 'restore/scan',
            name: AppRoute.restoreScan.name,
            builder: (context, state) => const RestoreScanScreen(),
          ),
        ],
      ),
      // Home subtree. Everything reachable from home is a child route, so each
      // push has home underneath and the back gesture returns to it.
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'board',
            name: AppRoute.board.name,
            builder: (context, state) => const BoardScreen(),
          ),
          GoRoute(
            path: 'partner',
            name: AppRoute.partner.name,
            builder: (context, state) => const PartnerBoardScreen(),
          ),
          GoRoute(
            path: 'restore/show',
            name: AppRoute.restoreShow.name,
            builder: (context, state) => const RestoreShowScreen(),
          ),
          GoRoute(
            path: 'sync',
            name: AppRoute.sync.name,
            builder: (context, state) => const SyncHubScreen(),
            routes: [
              GoRoute(
                path: 'show',
                name: AppRoute.syncShow.name,
                builder: (context, state) => const SyncShowScreen(),
              ),
              GoRoute(
                path: 'scan',
                name: AppRoute.syncScan.name,
                builder: (context, state) => const SyncScanScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

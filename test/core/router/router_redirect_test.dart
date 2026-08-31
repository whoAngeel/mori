import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mori/core/database/app_database.dart';
import 'package:mori/core/database/database_providers.dart';
import 'package:mori/core/router/app_router.dart';
import 'package:mori/core/theme/app_theme.dart';
import 'package:mori/features/challenge/presentation/screens/home_screen.dart';
import 'package:mori/features/pairing/domain/entities/pairing_state.dart';
import 'package:mori/features/pairing/presentation/providers/pairing_notifier.dart';
import 'package:mori/features/pairing/presentation/screens/pair_show_screen.dart';

/// Regression: `context.push` does not change `state.uri` in go_router, so a
/// pushed pairing screen still reports `path == '/onboarding'`. When
/// `createChallenge` flips the pairing stream to `Paired`, the global redirect
/// must NOT read that as "paired user sitting on onboarding" and eject them
/// from their own QR screen back to home.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  String path(GoRouter r) => r.routerDelegate.currentConfiguration.uri.path;

  Future<(GoRouter, StreamController<PairingState>)> boot(
    WidgetTester tester,
  ) async {
    final ctrl = StreamController<PairingState>.broadcast();
    final container = ProviderContainer(
      overrides: [
        pairingStateProvider.overrideWith((ref) => ctrl.stream),
        appDatabaseProvider
            .overrideWithValue(AppDatabase(NativeDatabase.memory())),
      ],
    );
    addTearDown(ctrl.close);
    addTearDown(container.dispose);

    final router = container.read(goRouterProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    return (router, ctrl);
  }

  const paired = Paired(
    pairingId: 1,
    localSlot: 0,
    localInstallId: 1,
    localName: 'A',
    startEpochDay: 20000,
    stateVersion: 0,
  );

  testWidgets('creating a challenge on the pushed pair/show screen keeps it up',
      (tester) async {
    final (router, ctrl) = await boot(tester);

    ctrl.add(const Unpaired());
    await tester.pumpAndSettle();
    expect(path(router), '/onboarding');

    // The real app pushes (not goes) into the pairing flow, so the URL stays
    // at '/onboarding' the whole time.
    router.pushNamed(AppRoute.pairShow.name);
    await tester.pumpAndSettle();
    expect(find.byType(PairShowScreen), findsOneWidget);
    expect(path(router), '/onboarding');

    // createChallenge succeeded -> stream flips to Paired mid-flow.
    ctrl.add(paired);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.byType(PairShowScreen),
      findsOneWidget,
      reason: 'the QR screen must survive the pairing stream turning Paired',
    );
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('go into pair/show is idempotent and leaves onboarding under it',
      (tester) async {
    final (router, ctrl) = await boot(tester);
    ctrl.add(const Unpaired());
    await tester.pumpAndSettle();

    // Onboarding navigates with `go`, not `push`.
    router.goNamed(AppRoute.pairShow.name);
    await tester.pumpAndSettle();
    router.goNamed(AppRoute.pairShow.name); // a second tap: no-op
    await tester.pumpAndSettle();
    expect(find.byType(PairShowScreen), findsOneWidget);
    expect(path(router), '/onboarding/pair/show');

    // Becoming Paired mid-flow does not eject.
    ctrl.add(paired);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(PairShowScreen), findsOneWidget);

    // Back returns straight to onboarding — a single pop, not many.
    expect(await router.routerDelegate.popRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(path(router), '/onboarding');
    expect(find.byType(PairShowScreen), findsNothing);
  });

  testWidgets('an unresolved pairing stream leaves the location untouched',
      (tester) async {
    final (router, _) = await boot(tester);
    // Home renders a loading spinner here, so a couple of frames is enough to
    // catch a spurious redirect without waiting for it to settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(path(router), '/');
  });
}

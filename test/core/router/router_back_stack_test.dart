import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Reproduces the reported bug at the routing level: navigating forward into a
/// child route must leave the parent underneath, so a back gesture (pop) pops
/// to the parent instead of emptying the stack and closing the app.
///
/// This mirrors the app's nested structure (a home parent with pushable child
/// routes) without pulling in the real screens and their providers.
GoRouter _router() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (c, s) => const Scaffold(body: Text('HOME')),
      routes: [
        GoRoute(
          path: 'board',
          name: 'board',
          builder: (c, s) => const Scaffold(body: Text('BOARD')),
        ),
        GoRoute(
          path: 'sync',
          name: 'sync',
          builder: (c, s) => const Scaffold(body: Text('SYNC')),
          routes: [
            GoRoute(
              path: 'scan',
              name: 'syncScan',
              builder: (c, s) => const Scaffold(body: Text('SCAN')),
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() {
  testWidgets('pushing a child route then popping returns to home', (t) async {
    final router = _router();
    await t.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.text('HOME'), findsOneWidget);

    router.pushNamed('board');
    await t.pumpAndSettle();
    expect(find.text('BOARD'), findsOneWidget);

    // Simulate the back gesture / system back.
    final popped = await router.routerDelegate.popRoute();
    await t.pumpAndSettle();
    expect(popped, isTrue, reason: 'pop should be handled, not exit the app');
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('a two-level push pops one screen at a time', (t) async {
    final router = _router();
    await t.pumpWidget(MaterialApp.router(routerConfig: router));

    router.pushNamed('sync');
    await t.pumpAndSettle();
    router.pushNamed('syncScan');
    await t.pumpAndSettle();
    expect(find.text('SCAN'), findsOneWidget);

    expect(await router.routerDelegate.popRoute(), isTrue);
    await t.pumpAndSettle();
    expect(find.text('SYNC'), findsOneWidget);

    expect(await router.routerDelegate.popRoute(), isTrue);
    await t.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('at the root, popRoute reports it cannot pop (app would exit)', (
    t,
  ) async {
    final router = _router();
    await t.pumpWidget(MaterialApp.router(routerConfig: router));
    // At the root there is nothing to pop: the OS decides. This documents that
    // only the root should ever hand the pop back to the system.
    expect(await router.routerDelegate.popRoute(), isFalse);
  });
}

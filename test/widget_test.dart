import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mori/core/utils/result.dart';
import 'package:mori/features/counter/data/repositories/counter_repository_impl.dart';
import 'package:mori/features/counter/domain/entities/counter.dart';
import 'package:mori/features/counter/domain/repositories/counter_repository.dart';
import 'package:mori/features/counter/presentation/screens/counter_screen.dart';

/// In-memory fake — no Drift, no platform channels. Shows how each layer is
/// swappable through Riverpod overrides.
class _FakeCounterRepository implements CounterRepository {
  int _value = 0;

  @override
  Future<Result<Counter>> getCounter() async => Ok(Counter(value: _value));

  @override
  Future<Result<Counter>> incrementCounter() async =>
      Ok(Counter(value: ++_value));
}

void main() {
  testWidgets('increments the persisted counter through all layers',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          counterRepositoryProvider.overrideWithValue(_FakeCounterRepository()),
        ],
        child: const MaterialApp(home: CounterScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/counter_notifier.dart';

/// End-to-end demo screen. Reads state from [counterProvider] and calls
/// the notifier to mutate it — no business logic lives here.
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Clean Architecture Template')),
      body: Center(
        child: switch (counter) {
          AsyncData(:final value) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Persisted count', style: textTheme.titleMedium),
                Text('$value', style: textTheme.displayLarge),
              ],
            ),
          AsyncError(:final error) => Text('Error: $error'),
          _ => const CircularProgressIndicator(),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(counterProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

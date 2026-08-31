import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/theme/app_theme.dart';
import 'package:mori/features/challenge/domain/entities/box_status.dart';
import 'package:mori/features/challenge/presentation/widgets/ink_box.dart';

Widget _harness({required ThemeData theme}) {
  return MaterialApp(
    theme: theme,
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) {
            final ink = Theme.of(context).colorScheme.primary;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final status in BoxStatus.values)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: InkBox(day: 45, status: status, ink: ink, size: 48),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('InkBox — three states, light theme', (tester) async {
    await tester.pumpWidget(_harness(theme: AppTheme.light));
    await expectLater(
      find.byType(Row),
      matchesGoldenFile('goldens/ink_box_light.png'),
    );
  });

  testWidgets('InkBox — three states, dark theme', (tester) async {
    await tester.pumpWidget(_harness(theme: AppTheme.dark));
    await expectLater(
      find.byType(Row),
      matchesGoldenFile('goldens/ink_box_dark.png'),
    );
  });

  testWidgets('InkBox exposes a Semantics label naming state and amount', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(theme: AppTheme.light));
    expect(find.bySemanticsLabel('Día 45, \$45, libre'), findsOneWidget);
    expect(find.bySemanticsLabel('Día 45, \$45, sorteada'), findsOneWidget);
    expect(find.bySemanticsLabel('Día 45, \$45, pagada'), findsOneWidget);
  });
}

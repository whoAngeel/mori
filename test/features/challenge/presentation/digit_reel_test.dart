import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mori/features/challenge/presentation/widgets/digit_reel.dart';

void main() {
  Future<void> pumpReel(WidgetTester tester, double value) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DigitReel(
                value: value,
                style: const TextStyle(fontSize: 40),
                height: 48,
              ),
            ),
          ),
        ),
      );

  testWidgets('shows the digit at the integer position', (tester) async {
    await pumpReel(tester, 5);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('wraps past 9 — position 14 shows a 4', (tester) async {
    await pumpReel(tester, 14);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('a rested reel lands on turns*10 + target', (tester) async {
    // 5 whole turns then digit 7 -> continuous position 57, visible digit 7.
    await pumpReel(tester, 57);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('renders only the three digits around the position', (tester) async {
    await pumpReel(tester, 8);
    expect(find.byType(Text), findsNWidgets(3)); // 7, 8, 9
    expect(find.text('8'), findsOneWidget);
  });
}

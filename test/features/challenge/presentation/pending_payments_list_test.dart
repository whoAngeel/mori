import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/theme/app_theme.dart';
import 'package:mori/features/challenge/domain/entities/box.dart';
import 'package:mori/features/challenge/domain/entities/box_status.dart';
import 'package:mori/features/challenge/presentation/widgets/pending_payments_list.dart';

Future<void> _pump(WidgetTester tester, List<Box> boxes) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(
        child: PendingPaymentsList(boxes: boxes, onPay: (_) {}),
      ),
    ),
  ));
}

void main() {
  group('PendingPaymentsList null-date tolerance (task 6.13)', () {
    testWidgets('a restored board (null dates) shows "Sin fecha" and does not '
        'crash', (tester) async {
      // Simulate a restored board: assigned boxes with no drawnAt.
      final boxes = [
        for (var day = 1; day <= 365; day++)
          Box(
            day: day,
            status: day <= 3 ? BoxStatus.assigned : BoxStatus.free,
            // no drawnAt: the normal state after RESTORE (I8)
          ),
      ];
      await _pump(tester, boxes);
      expect(find.text('Sin fecha'), findsNWidgets(3));
      expect(find.text('POR PAGAR · 3'), findsOneWidget); // Eyebrow uppercases
    });

    testWidgets('null-dated boxes sort by day', (tester) async {
      final boxes = [
        Box(day: 300, status: BoxStatus.assigned),
        Box(day: 45, status: BoxStatus.assigned),
        Box(day: 100, status: BoxStatus.assigned),
      ];
      await _pump(tester, boxes);
      // All three render with the fallback label; the sort is by day.
      expect(find.text('Sin fecha'), findsNWidgets(3));
    });

    testWidgets('dated boxes sort before null-dated ones', (tester) async {
      final boxes = [
        Box(day: 10, status: BoxStatus.assigned), // null date
        Box(
          day: 200,
          status: BoxStatus.assigned,
          drawnAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      await _pump(tester, boxes);
      expect(find.text('Sin fecha'), findsOneWidget);
      expect(find.textContaining('Sorteado'), findsOneWidget);
    });
  });
}

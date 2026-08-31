import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/theme/app_theme.dart';
import 'package:mori/features/challenge/domain/entities/box.dart';
import 'package:mori/features/challenge/domain/entities/box_status.dart';
import 'package:mori/features/challenge/domain/entities/challenge_progress.dart';
import 'package:mori/features/challenge/presentation/widgets/draw_button.dart';

List<Box> _board({int drawn = 0}) => [
      for (var day = 1; day <= 365; day++)
        Box(
          day: day,
          status: day <= drawn ? BoxStatus.assigned : BoxStatus.free,
        ),
    ];

ChallengeProgress _progress({required int drawn, required int elapsed}) =>
    ChallengeProgress.from(
      boxes: _board(drawn: drawn),
      todayEpochDay: 20000 + elapsed,
      startEpochDay: 20000,
    );

Future<void> _pump(
  WidgetTester tester, {
  required ChallengeProgress progress,
  required bool busy,
  required VoidCallback onDraw,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: DrawButton(progress: progress, busy: busy, onDraw: onDraw),
    ),
  ));
}

void main() {
  group('DrawButton (task 5.7)', () {
    testWidgets('enabled and fires when there are pending draws',
        (tester) async {
      var taps = 0;
      await _pump(
        tester,
        progress: _progress(drawn: 0, elapsed: 0), // pending 1
        busy: false,
        onDraw: () => taps++,
      );
      expect(find.text('SORTEAR'), findsOneWidget);
      expect(find.text('1 sorteo pendiente'), findsOneWidget);
      await tester.tap(find.text('SORTEAR'));
      expect(taps, 1);
    });

    testWidgets('disabled while busy does not fire', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        progress: _progress(drawn: 0, elapsed: 0),
        busy: true,
        onDraw: () => taps++,
      );
      expect(find.text('UN MOMENTO'), findsOneWidget);
      await tester.tap(find.text('UN MOMENTO'));
      expect(taps, 0);
    });

    testWidgets('disabled with no pending draws', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        progress: _progress(drawn: 1, elapsed: 0), // earned 1, drawn 1 -> 0
        busy: false,
        onDraw: () => taps++,
      );
      expect(find.text('Vuelve mañana por el tuyo'), findsOneWidget);
      await tester.tap(find.text('SORTEAR'));
      expect(taps, 0);
    });
  });

  group('DrawButton completed board (task 5.9)', () {
    testWidgets('shows the final copy and is disabled forever', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        progress: _progress(drawn: 365, elapsed: 499),
        busy: false,
        onDraw: () => taps++,
      );
      expect(find.text('TERMINASTE LOS 365'), findsOneWidget);
      expect(find.text(r'$66,795.'), findsOneWidget);
      await tester.tap(find.text('TERMINASTE LOS 365'));
      expect(taps, 0);
    });
  });
}

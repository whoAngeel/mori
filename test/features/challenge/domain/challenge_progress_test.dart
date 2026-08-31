import 'package:flutter_test/flutter_test.dart';
import 'package:mori/features/challenge/domain/entities/box.dart';
import 'package:mori/features/challenge/domain/entities/box_status.dart';
import 'package:mori/features/challenge/domain/entities/challenge_progress.dart';

/// Builds a 365-box board where the first [drawn] boxes are assigned and the
/// first [paid] of those are paid.
List<Box> board({int drawn = 0, int paid = 0}) {
  return [
    for (var day = 1; day <= 365; day++)
      Box(
        day: day,
        status: day <= paid
            ? BoxStatus.paid
            : day <= drawn
            ? BoxStatus.assigned
            : BoxStatus.free,
      ),
  ];
}

ChallengeProgress progress({required List<Box> boxes, required int elapsed}) {
  const start = 20000;
  return ChallengeProgress.from(
    boxes: boxes,
    todayEpochDay: start + elapsed,
    startEpochDay: start,
  );
}

void main() {
  group('pendingDraws — the six edge cases (data-model §4)', () {
    test('first day, nothing drawn -> pending 1', () {
      final p = progress(boxes: board(), elapsed: 0);
      expect(p.pendingDraws, 1);
    });

    test('day 10, drew 4 times -> pending 6 (accumulated)', () {
      final p = progress(boxes: board(drawn: 4), elapsed: 9);
      expect(p.pendingDraws, 6);
    });

    test('day 10, drew all 10 -> pending 0', () {
      final p = progress(boxes: board(drawn: 10), elapsed: 9);
      expect(p.pendingDraws, 0);
    });

    test('clock moved backwards -> pending 0, never negative', () {
      final p = progress(boxes: board(), elapsed: -5);
      expect(p.pendingDraws, 0);
    });

    test('calendar day 500 -> earned capped at 365', () {
      // Nothing drawn yet, elapsed 499: earned tops at 365, so pending == 365.
      final p = progress(boxes: board(), elapsed: 499);
      expect(p.pendingDraws, 365);
    });

    test('all 365 drawn -> pending 0 and isComplete', () {
      final p = progress(boxes: board(drawn: 365), elapsed: 499);
      expect(p.pendingDraws, 0);
      expect(p.isComplete, isTrue);
    });
  });

  group('pendingDraws — upper clamp to (365 - drawn)', () {
    test('long absence cannot empty the board beyond what exists', () {
      // Drew 360, elapsed huge: only 5 boxes remain, so pending == 5.
      final p = progress(boxes: board(drawn: 360), elapsed: 10000);
      expect(p.pendingDraws, 5);
    });
  });

  group('money math (data-model §4)', () {
    test('empty board: nothing saved or committed, all remaining', () {
      final p = progress(boxes: board(), elapsed: 0);
      expect(p.savedMxn, 0);
      expect(p.committedMxn, 0);
      expect(p.owedMxn, 0);
      expect(p.remainingMxn, ChallengeProgress.totalMxn);
    });

    test('drew days 1..3, paid day 1 and 2', () {
      final p = progress(boxes: board(drawn: 3, paid: 2), elapsed: 5);
      expect(p.savedMxn, 1 + 2); // paid
      expect(p.committedMxn, 1 + 2 + 3); // drawn
      expect(p.owedMxn, 3); // committed - saved
      expect(p.remainingMxn, ChallengeProgress.totalMxn - 6);
      expect(p.drawn, 3);
      expect(p.paid, 2);
    });

    test('a fully paid board saves the full total', () {
      final p = progress(boxes: board(drawn: 365, paid: 365), elapsed: 499);
      expect(p.savedMxn, ChallengeProgress.totalMxn);
      expect(p.remainingMxn, 0);
      expect(p.owedMxn, 0);
    });
  });

  group('challengeDay', () {
    test('first day is day 1', () {
      expect(progress(boxes: board(), elapsed: 0).challengeDay, 1);
    });

    test('backwards clock floors challengeDay at 1', () {
      expect(progress(boxes: board(), elapsed: -5).challengeDay, 1);
    });

    test('day 500 caps challengeDay at 365', () {
      expect(progress(boxes: board(), elapsed: 499).challengeDay, 365);
    });
  });
}

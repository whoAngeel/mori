import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/theme/ink_colors.dart';
import 'package:mori/core/time/clock.dart';
import 'package:mori/features/challenge/presentation/widgets/ink_box.dart';
import 'package:mori/features/sync/domain/entities/box_state.dart';
import 'package:mori/features/sync/domain/entities/partner_snapshot.dart';
import 'package:mori/features/sync/presentation/providers/sync_notifier.dart';
import 'package:mori/features/sync/presentation/screens/partner_board_screen.dart';

import '../../../helpers/fake_clock.dart';

void main() {
  final now = DateTime(2026, 9, 21, 12);

  // A partner board with the first 5 boxes drawn (1 paid, 4 assigned).
  List<PartnerBox> partnerBoxes() => [
    for (var day = 1; day <= 365; day++)
      PartnerBox(
        day: day,
        status: day == 1
            ? WireBoxState.paid
            : day <= 5
            ? WireBoxState.assigned
            : WireBoxState.free,
      ),
  ];

  final snapshot = PartnerSnapshot(
    stateVersion: 3,
    installId: 0xAAAA,
    startEpochDay: 20000,
    receivedAtMillis: now
        .subtract(const Duration(hours: 2))
        .millisecondsSinceEpoch,
  );

  Widget harness() => ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(FakeClock(now)),
      partnerSnapshotProvider.overrideWith((ref) => Stream.value(snapshot)),
      partnerBoxesProvider.overrideWith((ref) => Stream.value(partnerBoxes())),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: const [InkColors.light]),
      home: const PartnerBoardScreen(),
    ),
  );

  testWidgets('renders the 365 partner boxes after a sync', (tester) async {
    await tester.pumpWidget(harness());
    // Let the overridden streams emit.
    await tester.pump();
    await tester.pump();

    // The empty/loading states must be gone.
    expect(find.text('Todavía no escaneas su código'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // The grid must actually build InkBox widgets. A collapsed (zero-height)
    // grid would build none — that was the bug.
    expect(find.byType(InkBox), findsWidgets);
  });
}

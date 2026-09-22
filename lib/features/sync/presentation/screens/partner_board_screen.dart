import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ink_colors.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/widgets/rule_of_365.dart';
import '../../../challenge/domain/entities/box_status.dart';
import '../../../challenge/presentation/widgets/ink_box.dart';
import '../../domain/entities/box_state.dart';
import '../providers/sync_notifier.dart';
import '../widgets/patina_panel.dart';

/// The partner's replica board, rendered in partner ink under the patina.
class PartnerBoardScreen extends ConsumerWidget {
  /// Creates the partner board screen.
  const PartnerBoardScreen({super.key});

  static BoxStatus _toBoxStatus(WireBoxState s) => switch (s) {
    WireBoxState.paid => BoxStatus.paid,
    WireBoxState.assigned => BoxStatus.assigned,
    WireBoxState.free => BoxStatus.free,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final snapshot = ref.watch(partnerSnapshotProvider).value;
    final boxes = ref.watch(partnerBoxesProvider).value ?? const [];

    // The snapshot is the source of truth for "have we ever synced" (see
    // partner_snapshot_table.dart): its row exists iff a sync was accepted.
    // The boxes stream can still be null on the first frame even when data is
    // stored, so keying the empty state on `boxes.isEmpty` would flash the
    // "nunca sincronizado" copy over a board that does have data.
    final neverSynced = snapshot == null;

    final lastScan = snapshot == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(snapshot.receivedAtMillis);
    final done = boxes
        .where((b) => b.status != WireBoxState.free)
        .map((b) => b.day)
        .toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Su tablero')),
      body: SafeArea(
        child: neverSynced
            ? const Center(child: Text('Todavía no escaneas su código'))
            : boxes.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: PatinaPanel(
                      lastScan: lastScan,
                      now: ref.watch(clockProvider).now(),
                      builder: (context, inkOpacity) {
                        return CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.all(20),
                              sliver: SliverGrid.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 12,
                                      mainAxisSpacing: 4,
                                      crossAxisSpacing: 4,
                                    ),
                                itemCount: boxes.length,
                                itemBuilder: (context, i) {
                                  final b = boxes[i];
                                  return InkBox(
                                    day: b.day,
                                    status: _toBoxStatus(b.status),
                                    ink: colors.inkPartner,
                                    size: 24,
                                    opacity: inkOpacity,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: RuleOf365(doneDays: done, ink: colors.inkPartner),
                  ),
                ],
              ),
      ),
    );
  }
}

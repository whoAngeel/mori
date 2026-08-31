import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ink_colors.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/rule_of_365.dart';
import '../../domain/entities/box.dart';
import '../../domain/entities/box_status.dart';
import '../providers/challenge_notifier.dart';
import '../widgets/ink_box.dart';

/// Which boxes the board shows.
enum BoardFilter {
  /// Every box.
  all,

  /// Assigned but not paid.
  pending,

  /// Paid.
  paid,
}

/// The full board: a lazy 12-column grid (7 columns when text scales past
/// 1.3×), filters, and the rule of 365 at the foot.
class BoardScreen extends ConsumerStatefulWidget {
  /// Creates the board screen.
  const BoardScreen({super.key});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  BoardFilter _filter = BoardFilter.all;

  bool _matches(Box b) => switch (_filter) {
        BoardFilter.all => true,
        BoardFilter.pending => b.status == BoxStatus.assigned,
        BoardFilter.paid => b.status == BoxStatus.paid,
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final state = ref.watch(challengeProvider);
    // Drop from 12 to 7 columns when the user scales text past 1.3x (§9).
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final columns = scale > 1.3 ? 7 : 12;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi tablero')),
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (data) {
            final visible = data.boxes.where(_matches).toList();
            final done = data.boxes
                .where((b) => b.status != BoxStatus.free)
                .map((b) => b.day)
                .toSet();

            return Column(
              children: [
                _Filters(
                  current: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemCount: visible.length,
                          itemBuilder: (context, i) {
                            final box = visible[i];
                            return InkBox(
                              day: box.day,
                              status: box.status,
                              ink: colors.inkSelf,
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: RuleOf365(doneDays: done, ink: colors.inkSelf),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.current, required this.onChanged});

  final BoardFilter current;
  final ValueChanged<BoardFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    Widget chip(String label, BoardFilter f) {
      final active = f == current;
      return GestureDetector(
        onTap: () => onChanged(f),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active
                    ? colors.inkBlack
                    : colors.inkBlack.withValues(alpha: 0),
                width: 1.5,
              ),
            ),
          ),
          child: Eyebrow(label, color: active ? colors.inkBlack : colors.inkMuted),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          chip('Todas', BoardFilter.all),
          chip('Por pagar', BoardFilter.pending),
          chip('Pagadas', BoardFilter.paid),
        ],
      ),
    );
  }
}

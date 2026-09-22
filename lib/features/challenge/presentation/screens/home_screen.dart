import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../sync/presentation/widgets/discrepancy_notice.dart';
import '../../../sync/presentation/widgets/partner_panel.dart';
import '../providers/challenge_notifier.dart';
import '../widgets/draw_button.dart';
import '../widgets/draw_ceremony.dart';
import '../widgets/pending_payments_list.dart';
import '../widgets/progress_header.dart';

/// The home screen: progress header, the day's draw, and the pending list.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _drawing = false;

  Future<void> _draw() async {
    setState(() => _drawing = true);
    final result = await ref.read(challengeProvider.notifier).draw();
    if (!mounted) return;
    setState(() => _drawing = false);
    switch (result) {
      case Ok(:final value):
        final again = await Navigator.of(context).push<bool>(
          PageRouteBuilder(
            opaque: true,
            transitionDuration: const Duration(milliseconds: 180),
            pageBuilder: (_, _, _) => DrawCeremony(day: value.day),
            transitionsBuilder: (_, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
        if ((again ?? false) && mounted) await _draw();
      case Err(:final failure):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final state = ref.watch(challengeProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (data) => ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.settings, color: colors.inkBlack),
                        onPressed: () =>
                            context.pushNamed(AppRoute.settings.name),
                      ),
                    ],
                  ),
                  ProgressHeader(progress: data.progress),
                  const SizedBox(height: 24),
                  DrawButton(
                    progress: data.progress,
                    busy: _drawing,
                    onDraw: _draw,
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => context.pushNamed(AppRoute.board.name),
                    child: PendingPaymentsList(
                      boxes: data.boxes,
                      onPay: (day) =>
                          ref.read(challengeProvider.notifier).markPaid(day),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: colors.rule, height: 1),
                  const SizedBox(height: 24),
                  const DiscrepancyNotice(),
                  const PartnerPanel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ink_colors.dart';
import '../../../pairing/domain/entities/pairing_state.dart';
import '../../../pairing/presentation/providers/pairing_notifier.dart';
import '../providers/discrepancy_provider.dart';

/// Persistent notices for the two silent discrepancies: a different start date
/// (§8.4) and a partner reinstall (§7.10). Rendered flat, no colour alarm — a
/// framed line that stays until the challenge is reset.
class DiscrepancyNotice extends ConsumerWidget {
  /// Creates the notice block.
  const DiscrepancyNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mismatch = ref.watch(startDateMismatchProvider).value ?? false;
    final reinstalled = ref.watch(partnerReinstalledProvider).value ?? false;
    final partnerName = switch (ref.watch(pairingStateProvider).value) {
      Paired(:final partnerName) => partnerName ?? 'Tu pareja',
      _ => 'Tu pareja',
    };

    if (!mismatch && !reinstalled) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (reinstalled) _Notice(text: '$partnerName reinstaló la app'),
        if (mismatch)
          _Notice(
            text:
                'Tu pareja empezó su reto en otra fecha. Su avance se mide '
                'contra su propio calendario.',
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colors.inkBlack, width: 1.5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkBlack),
      ),
    );
  }
}

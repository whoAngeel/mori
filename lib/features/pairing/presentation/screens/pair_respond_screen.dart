import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../sync/presentation/widgets/qr_plate.dart';
import '../providers/pair_qr_codec.dart';
import '../providers/pairing_notifier.dart';

/// Second half of the pairing ceremony, slot B side.
///
/// After joining, B has the shared `pairingId` but A still does not know B.
/// B shows this response QR (slot 1) so A can scan it and record B's name and
/// installId. Only then is the pair complete on both devices.
class PairRespondScreen extends ConsumerStatefulWidget {
  /// Creates the respond screen.
  const PairRespondScreen({super.key});

  @override
  ConsumerState<PairRespondScreen> createState() => _PairRespondScreenState();
}

class _PairRespondScreenState extends ConsumerState<PairRespondScreen> {
  String? _qrData;
  String? _error;
  bool _armed = false;

  @override
  void initState() {
    super.initState();
    _build();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _armed = true);
    });
  }

  Future<void> _build() async {
    final result =
        await ref.read(pairingControllerProvider.notifier).buildInvite();
    if (!mounted) return;
    setState(() {
      switch (result) {
        case Ok(:final value):
          _qrData = PairQrCodec.encode(value);
        case Err(:final failure):
          _error = failure.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Me uno')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Eyebrow('Ya casi'),
                  const SizedBox(height: 8),
                  Text(
                    _error ??
                        'Ahora muéstrale este código para que te vea a ti.',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: _error != null ? colors.inkBlack : colors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_error == null) QrPlate(data: _qrData ?? ''),
                  const Spacer(),
                  GhostButton(
                    label: 'Listo',
                    onPressed: _armed
                        ? () => context.goNamed(AppRoute.home.name)
                        : null,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

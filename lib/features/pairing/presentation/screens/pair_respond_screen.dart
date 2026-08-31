import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/ghost_button.dart';
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

  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    final result = await ref.read(pairingControllerProvider.notifier).buildInvite();
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
      appBar: AppBar(title: const Text('Me uno')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Eyebrow('Ya casi'),
                  const SizedBox(height: 8),
                  Text(
                    'Ahora muéstrale este código para que te vea a ti.',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: colors.inkMuted),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: colors.inkBlack),
                    )
                  else
                    // The plate is drawn immediately at its final size; the QR
                    // fills in once built, so nothing jumps or flashes.
                    Center(
                      child: Container(
                        color: colors.plate,
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: 240,
                          height: 240,
                          child: _qrData == null
                              ? null
                              : QrImageView(
                                  data: _qrData!,
                                  version: QrVersions.auto,
                                  size: 240,
                                  padding: EdgeInsets.zero,
                                  backgroundColor: colors.plate,
                                  // ignore: deprecated_member_use
                                  foregroundColor: colors.inkBlack,
                                ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  GhostButton(
                    label: 'Listo',
                    onPressed: () => context.goNamed(AppRoute.home.name),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

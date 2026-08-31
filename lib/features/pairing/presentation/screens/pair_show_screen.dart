import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../domain/name_validation.dart';
import '../providers/pair_qr_codec.dart';
import '../providers/pairing_notifier.dart';

/// Slot A shows their invite QR here for the partner to scan.
///
/// The name is entered first (validated 1..24 UTF-8 bytes, task 4.7); once the
/// challenge is created the QR is drawn in black on `plate` with a quiet zone.
class PairShowScreen extends ConsumerStatefulWidget {
  /// Creates the pair-show screen.
  const PairShowScreen({super.key});

  @override
  ConsumerState<PairShowScreen> createState() => _PairShowScreenState();
}

class _PairShowScreenState extends ConsumerState<PairShowScreen> {
  final _controller = TextEditingController();
  String? _qrData;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _controller.text;
    final validationError = NameValidation.validate(name);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    final result = await ref
        .read(pairingControllerProvider.notifier)
        .createChallenge(name.trim());
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        setState(() {
          _qrData = PairQrCodec.encode(value);
          _busy = false;
        });
      case Err(:final failure):
        setState(() {
          _error = failure.message;
          _busy = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Yo empiezo')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _qrData == null
                  ? _nameForm(theme, colors)
                  : _qrView(theme, colors),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameForm(ThemeData theme, InkColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('Tu nombre'),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          maxLength: 24,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            errorText: _error,
            hintText: 'Cómo te llamas',
          ),
        ),
        const SizedBox(height: 16),
        GhostButton(
          label: _busy ? 'Un momento' : 'Mostrar mi código',
          onPressed: _busy ? null : _create,
        ),
      ],
    );
  }

  Widget _qrView(ThemeData theme, InkColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('Muestra este código'),
        const SizedBox(height: 8),
        Text(
          'Para que tu pareja te escanee.',
          style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 24),
        // Black on plate with a 16 dp quiet zone: cheap cameras read black on
        // white, so the QR never carries ink.
        Center(
          child: Container(
            color: colors.plate,
            padding: const EdgeInsets.all(16),
            child: QrImageView(
              data: _qrData!,
              version: QrVersions.auto,
              size: 240,
              backgroundColor: colors.plate,
              // ignore: deprecated_member_use
              foregroundColor: colors.inkBlack,
            ),
          ),
        ),
        const SizedBox(height: 24),
        GhostButton(
          label: 'Listo',
          onPressed: () => context.goNamed(AppRoute.home.name),
        ),
      ],
    );
  }
}

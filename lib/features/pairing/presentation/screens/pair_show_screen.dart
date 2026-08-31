import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../../core/widgets/ink_button.dart';
import '../../domain/name_validation.dart';
import '../providers/pair_qr_codec.dart';
import '../providers/pairing_notifier.dart';

/// Slot A shows their invite QR here for the partner to scan.
///
/// The name is entered first (validated 1..24 UTF-8 bytes, task 4.7); once the
/// challenge is created the QR is drawn in pure black on white — cheap cameras,
/// and phone-to-screen scans, need maximum contrast.
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

  /// The actions under the QR stay inert for a moment after they appear, so a
  /// stray tap right after "Mostrar mi código" cannot dismiss the QR.
  bool _actionsArmed = false;

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
    FocusScope.of(context).unfocus();
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
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) setState(() => _actionsArmed = true);
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
      resizeToAvoidBottomInset: false,
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
      children: [
        const SizedBox(height: 8),
        const Eyebrow('Muestra este código'),
        const SizedBox(height: 8),
        Text(
          'Que tu pareja lo escanee desde "Me uno al de mi pareja".',
          style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 20),
        _qrBlock(),
        // Push the actions to the bottom, well away from the QR and from where
        // "Mostrar mi código" was tapped.
        const Spacer(),
        InkButton(
          label: 'Ya me escaneó',
          primary: true,
          onPressed: _actionsArmed
              ? () => context.goNamed(AppRoute.pairConfirm.name)
              : null,
        ),
        const SizedBox(height: 12),
        GhostButton(
          label: 'Terminar sin confirmar',
          onPressed: _actionsArmed
              ? () => context.goNamed(AppRoute.home.name)
              : null,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _qrBlock() => _qrData == null
      ? const SizedBox.shrink()
      : Center(
          child: Container(
            color: const Color(0xFFFFFFFF),
            padding: const EdgeInsets.all(16),
            child: QrImageView(
              data: _qrData!,
              version: QrVersions.auto,
              size: 260,
              padding: EdgeInsets.zero,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              backgroundColor: const Color(0xFFFFFFFF),
              // ignore: deprecated_member_use
              foregroundColor: const Color(0xFF000000),
            ),
          ),
        );
}

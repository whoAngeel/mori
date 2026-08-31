import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../../core/widgets/ink_button.dart';
import '../../domain/name_validation.dart';
import '../providers/pair_qr_codec.dart';
import '../providers/pairing_notifier.dart';

/// Slot B enters their name, then scans the inviter's QR to join.
///
/// Scanner rules (design §7): QR-only, `noDuplicates`, debounced to stop on the
/// first code, controller disposed in [dispose], permission explained on screen
/// before the system prompt.
class PairScanScreen extends ConsumerStatefulWidget {
  /// Creates the pair-scan screen.
  const PairScanScreen({super.key});

  @override
  ConsumerState<PairScanScreen> createState() => _PairScanScreenState();
}

class _PairScanScreenState extends ConsumerState<PairScanScreen> {
  final _nameController = TextEditingController();
  MobileScannerController? _scanner;
  bool _scanning = false;
  bool _handled = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _scanner?.dispose();
    super.dispose();
  }

  void _startScanning() {
    final validationError = NameValidation.validate(_nameController.text);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    setState(() {
      _error = null;
      _handled = false;
      _scanning = true;
      _scanner = MobileScannerController(
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    });
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return; // debounce: first code wins
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    _handled = true;
    await _scanner?.stop();

    final invite = PairQrCodec.decode(raw);
    if (invite == null) {
      setState(() => _error = 'Ese código no es de este reto');
      return;
    }

    final result = await ref
        .read(pairingControllerProvider.notifier)
        .joinChallenge(
          inviterInvite: invite,
          localName: _nameController.text.trim(),
        );
    if (!mounted) return;
    switch (result) {
      case Ok():
        context.goNamed(AppRoute.home.name);
      case Err(:final failure):
        setState(() => _error = failure.message);
    }
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
              child: _scanning
                  ? _scannerView(theme, colors)
                  : _preScanView(theme, colors),
            ),
          ),
        ),
      ),
    );
  }

  Widget _preScanView(ThemeData theme, InkColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('Tu nombre'),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          maxLength: 24,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            errorText: _error,
            hintText: 'Cómo te llamas',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Vamos a usar la cámara para leer el código de tu pareja.',
          style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 16),
        InkButton(label: 'Escanear su código', onPressed: _startScanning),
      ],
    );
  }

  Widget _scannerView(ThemeData theme, InkColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Eyebrow('Escanea el código de tu pareja'),
        const SizedBox(height: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: MobileScanner(controller: _scanner, onDetect: _onDetect),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkSelf),
          ),
        ],
        const SizedBox(height: 12),
        GhostButton(
          label: 'Cancelar',
          onPressed: () {
            _scanner?.dispose();
            setState(() {
              _scanner = null;
              _scanning = false;
            });
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

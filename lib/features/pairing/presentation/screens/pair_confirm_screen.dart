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
import '../../domain/repositories/pairing_repository.dart';
import '../providers/pair_qr_codec.dart';
import '../providers/pairing_notifier.dart';

/// Second half of the pairing ceremony, slot A side.
///
/// A created the challenge and showed the invite; now A scans B's response QR
/// so it can record B's name and installId ([ApplyPairOutcome.partnerLinked]).
/// Only then is the pair complete on both devices.
///
/// Scanner rules (design §7): QR-only, `noDuplicates`, debounced to the first
/// code, controller disposed in [dispose], permission explained on screen.
class PairConfirmScreen extends ConsumerStatefulWidget {
  /// Creates the confirm screen.
  const PairConfirmScreen({super.key});

  @override
  ConsumerState<PairConfirmScreen> createState() => _PairConfirmScreenState();
}

class _PairConfirmScreenState extends ConsumerState<PairConfirmScreen> {
  MobileScannerController? _scanner;
  bool _scanning = false;
  bool _handled = false;
  String? _message;
  bool _done = false;

  @override
  void dispose() {
    _scanner?.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _message = null;
      _handled = false;
      _scanning = true;
      _scanner = MobileScannerController(
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    });
  }

  Future<void> _rescan() async {
    await _scanner?.dispose();
    if (!mounted) return;
    setState(() {
      _message = null;
      _handled = false;
      _scanner = MobileScannerController(
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    });
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    _handled = true;
    await _scanner?.stop();

    final invite = PairQrCodec.decode(raw);
    if (invite == null) {
      setState(() => _message = 'No se pudo leer. Inténtalo otra vez.');
      return;
    }

    final result =
        await ref.read(pairingControllerProvider.notifier).applyPartner(invite);
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        final ok = value != ApplyPairOutcome.rejectedForeign;
        setState(() {
          _done = ok;
          _message = ok
              ? 'Listo, ya se vieron los dos'
              : 'Ese código no es de este reto';
        });
      case Err(:final failure):
        setState(() => _message = failure.message);
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
              child: !_scanning
                  ? _preScan(theme, colors)
                  : _scanView(theme, colors),
            ),
          ),
        ),
      ),
    );
  }

  Widget _preScan(ThemeData theme, InkColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('Último paso'),
        const SizedBox(height: 12),
        Text(
          'Cuando tu pareja ya escaneó tu código, escanea el suyo para '
          'terminar de emparejar.',
          style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 16),
        InkButton(label: 'Abrir la cámara', onPressed: _start),
      ],
    );
  }

  Widget _scanView(ThemeData theme, InkColors colors) {
    if (_message != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _message!,
            style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkBlack),
          ),
          const SizedBox(height: 16),
          if (_done)
            InkButton(
              label: 'Ir a mi tablero',
              onPressed: () => context.goNamed(AppRoute.home.name),
            )
          else ...[
            InkButton(label: 'Escanear otra vez', onPressed: _rescan),
            const SizedBox(height: 8),
            GhostButton(
              label: 'Ahora no',
              onPressed: () => context.goNamed(AppRoute.home.name),
            ),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: MobileScanner(controller: _scanner, onDetect: _onDetect),
          ),
        ),
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

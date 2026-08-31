import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../../core/widgets/ink_button.dart';
import '../../../pairing/domain/entities/pairing_state.dart';
import '../../../pairing/presentation/providers/pairing_notifier.dart';
import '../sync_messages.dart';
import '../providers/sync_notifier.dart';

/// Scans the partner's SYNC QR and applies it. Rejects RESTORE and PAIR kinds
/// (the repository returns UnsupportedKind for a RESTORE here, §8.3).
///
/// Scanner rules (§7): QR-only, noDuplicates, debounced to the first code,
/// controller disposed, permission explained before the system prompt.
class SyncScanScreen extends ConsumerStatefulWidget {
  /// Creates the sync-scan screen.
  const SyncScanScreen({super.key});

  @override
  ConsumerState<SyncScanScreen> createState() => _SyncScanScreenState();
}

class _SyncScanScreenState extends ConsumerState<SyncScanScreen> {
  MobileScannerController? _scanner;
  bool _scanning = false;
  bool _handled = false;
  String? _message;
  bool _messageIsTerminal = false;

  @override
  void dispose() {
    _scanner?.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _message = null;
      _messageIsTerminal = false;
      _handled = false;
      _scanning = true;
      _scanner = MobileScannerController(
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    });
  }

  /// Discards the current controller and arms a fresh scan after a failure.
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
    if (_handled) return; // debounce: first code wins
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    _handled = true;
    await _scanner?.stop();

    final partnerName = switch (ref.read(pairingStateProvider).value) {
      Paired(:final partnerName) => partnerName ?? 'tu pareja',
      _ => 'tu pareja',
    };

    final result = await ref
        .read(syncControllerProvider.notifier)
        .applySync(raw);
    if (!mounted) return;
    final message = switch (result) {
      Ok(:final value) => SyncMessages.forOutcome(
        value,
        partnerName: partnerName,
      ),
      Err(:final failure) =>
        failure is SyncFailure
            ? SyncMessages.forFailure(failure)
            : failure.message,
    };
    setState(() {
      _message = message;
      // Ok outcomes are done; a failure can be retried with another code.
      _messageIsTerminal = result is Ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Escanear su código')),
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
        const Eyebrow('Escanear su código'),
        const SizedBox(height: 12),
        Text(
          'Vamos a usar la cámara para leer el código de tu pareja.',
          style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 16),
        InkButton(label: 'Abrir la cámara', onPressed: _start),
      ],
    );
  }

  Widget _scanView(ThemeData theme, InkColors colors) {
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
        if (_message != null) ...[
          const SizedBox(height: 12),
          Text(
            _message!,
            style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkBlack),
          ),
          const SizedBox(height: 12),
          if (!_messageIsTerminal) ...[
            InkButton(label: 'Escanear otra vez', onPressed: _rescan),
            const SizedBox(height: 8),
          ],
          GhostButton(label: 'Listo', onPressed: () => context.pop()),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

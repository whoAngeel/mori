import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../../core/widgets/ink_button.dart';
import '../../../pairing/domain/name_validation.dart';
import '../sync_messages.dart';
import '../providers/sync_notifier.dart';

/// Recovers this device's board from a partner's RESTORE QR (reached only from
/// onboarding). Accepts only the RESTORE kind: SYNC and PAIR are rejected by
/// the repository. The person types their own name (it does not travel).
class RestoreScanScreen extends ConsumerStatefulWidget {
  /// Creates the restore-scan screen.
  const RestoreScanScreen({super.key});

  @override
  ConsumerState<RestoreScanScreen> createState() => _RestoreScanScreenState();
}

class _RestoreScanScreenState extends ConsumerState<RestoreScanScreen> {
  final _nameController = TextEditingController();
  MobileScannerController? _scanner;
  bool _scanning = false;
  bool _handled = false;
  String? _error;
  String? _message;

  @override
  void dispose() {
    _nameController.dispose();
    _scanner?.dispose();
    super.dispose();
  }

  void _start() {
    final err = NameValidation.validate(_nameController.text);
    if (err != null) {
      setState(() => _error = err);
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
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    _handled = true;
    await _scanner?.stop();

    final result =
        await ref.read(syncControllerProvider.notifier).applyRestore(
              text: raw,
              localName: _nameController.text.trim(),
            );
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        setState(() => _message = SyncMessages.forOutcome(
              value,
              partnerName: 'tu pareja',
            ));
      case Err(:final failure):
        setState(() => _message = failure is SyncFailure
            ? SyncMessages.forFailure(failure)
            : failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar mi reto')),
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
          'Escanea el código de recuperación de tu pareja.',
          style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 16),
        InkButton(label: 'Escanear el código', onPressed: _start),
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
          InkButton(
            label: 'Ir a mi tablero',
            onPressed: () => context.goNamed(AppRoute.home.name),
          ),
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

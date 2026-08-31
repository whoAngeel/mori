import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../sync_messages.dart';
import '../providers/sync_notifier.dart';
import '../widgets/qr_plate.dart';

/// Emits a RESTORE QR for the partner (from Settings). Accepts only the RESTORE
/// kind — it builds one; it never scans SYNC or PAIR.
class RestoreShowScreen extends ConsumerStatefulWidget {
  /// Creates the restore-show screen.
  const RestoreShowScreen({super.key});

  @override
  ConsumerState<RestoreShowScreen> createState() => _RestoreShowScreenState();
}

class _RestoreShowScreenState extends ConsumerState<RestoreShowScreen> {
  String? _payload;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    final result = await ref.read(syncControllerProvider.notifier).buildRestore();
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Ok(:final value):
          _payload = value;
        case Err(:final failure):
          _error = failure is SyncFailure
              ? SyncMessages.forFailure(failure)
              : failure.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayudar a recuperar')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium!
                                .copyWith(color: colors.inkBlack),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Eyebrow('Devuélvele su reto'),
                            const SizedBox(height: 8),
                            Text(
                              'Que escanee este código desde "Recuperar mi '
                              'reto".',
                              style: theme.textTheme.bodyMedium!
                                  .copyWith(color: colors.inkMuted),
                            ),
                            const SizedBox(height: 24),
                            QrPlate(data: _payload!),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../../core/widgets/ink_button.dart';
import '../../domain/entities/pairing_state.dart';
import '../providers/pairing_notifier.dart';

/// The settings screen: partner names, the RESTORE-help entry, and the
/// destructive challenge reset.
///
/// Reached from the home gear. `/restore/show` is only reachable from here
/// (design §6, router table).
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    final pairing = ref.watch(pairingStateProvider).value;

    final localName = switch (pairing) {
      Paired(:final localName) => localName,
      _ => null,
    };
    final partnerName = switch (pairing) {
      Paired(:final partnerName) => partnerName,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                const Eyebrow('El reto'),
                const SizedBox(height: 8),
                Text(
                  partnerName == null
                      ? 'Llevas el reto tú solo por ahora.'
                      : 'Llevas el reto con $partnerName.',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: colors.inkBlack,
                  ),
                ),
                if (localName != null && localName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tú apareces como $localName.',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: colors.inkMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                const Eyebrow('Respaldo'),
                const SizedBox(height: 8),
                Text(
                  'Si tu pareja perdió su reto, muéstrale este código para '
                  'devolvérselo.',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
                const SizedBox(height: 12),
                GhostButton(
                  label: 'Ayudar a recuperar',
                  onPressed: () => context.pushNamed(AppRoute.restoreShow.name),
                ),
                const SizedBox(height: 32),
                const Eyebrow('Zona de riesgo'),
                const SizedBox(height: 8),
                Text(
                  'Reiniciar borra tu tablero y te saca del reto. No se puede '
                  'deshacer.',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
                const SizedBox(height: 12),
                InkButton(
                  label: 'Reiniciar el reto',
                  ink: colors.inkBlack,
                  onPressed: () => _confirmReset(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _ResetConfirmDialog(),
    );

    if (confirmed != true) return;

    final result = await ref.read(pairingControllerProvider.notifier).reset();
    if (!context.mounted) return;
    switch (result) {
      case Ok():
        // The router redirect sends an unpaired device to onboarding.
        context.goNamed(AppRoute.onboarding.name);
      case Err(:final failure):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
}

/// Confirmation for the irreversible challenge reset.
///
/// A single tap is not enough for something that destroys the board with no
/// undo: the user must type the confirmation word before the destructive
/// action unlocks. This makes an accidental reset practically impossible.
class _ResetConfirmDialog extends StatefulWidget {
  const _ResetConfirmDialog();

  @override
  State<_ResetConfirmDialog> createState() => _ResetConfirmDialogState();
}

class _ResetConfirmDialogState extends State<_ResetConfirmDialog> {
  /// The word the user must type, letter for letter, to unlock the reset.
  static const _confirmWord = 'BORRAR';

  final _controller = TextEditingController();
  bool _matches = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final next = _controller.text.trim() == _confirmWord;
      if (next != _matches) setState(() => _matches = next);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).extension<InkColors>()!;

    return AlertDialog(
      title: const Text('¿Reiniciar el reto?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Se borra tu tablero completo y vuelves al inicio. Esto no se '
            'puede deshacer.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Escribe $_confirmWord para confirmar.',
            style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: _confirmWord,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: BorderSide(color: colors.rule, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: BorderSide(color: colors.inkBlack, width: 1.5),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          // Null while the word does not match: the button stays disabled, so
          // an accidental tap can never reset the challenge.
          onPressed: _matches ? () => context.pop(true) : null,
          child: Text(
            'Borrar todo',
            style: TextStyle(
              color: _matches ? colors.inkBlack : colors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/ink_colors.dart';
import '../widgets/eyebrow.dart';
import '../widgets/ghost_button.dart';
import '../widgets/ink_button.dart';

/// One-time opt-in for crash reporting, shown before onboarding.
///
/// The app is offline by design; this is the only thing that can send anything
/// off the device, so the default is "no" and the copy says exactly what
/// travels.
class TelemetryConsentScreen extends StatelessWidget {
  /// Creates the consent screen. [onDecide] is called with the choice.
  const TelemetryConsentScreen({super.key, required this.onDecide});

  /// Invoked with `true` to allow crash reports, `false` to decline.
  final ValueChanged<bool> onDecide;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);

    return Scaffold(
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
                  const Eyebrow('Antes de empezar'),
                  const SizedBox(height: 12),
                  Text(
                    'Mori funciona sin conexión. Lo único que puede salir del '
                    'teléfono es un reporte cuando la app truena.',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: colors.inkBlack),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'El reporte lleva el error y el modelo del teléfono. No '
                    'lleva nombres, montos ni tu tablero. Puedes cambiarlo '
                    'después en Ajustes.',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: colors.inkMuted),
                  ),
                  const SizedBox(height: 28),
                  InkButton(
                    label: 'Sí, enviar reportes',
                    primary: true,
                    onPressed: () => onDecide(true),
                  ),
                  const SizedBox(height: 12),
                  GhostButton(
                    label: 'No, gracias',
                    onPressed: () => onDecide(false),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../../core/widgets/ink_button.dart';

/// The first screen for an unpaired device: three ways in.
///
/// Copy is exact from `docs/design-system.md` §8. The third option (restore)
/// routes to the restore scanner (task 6.12); until then it is wired to a
/// placeholder route.
class OnboardingScreen extends ConsumerWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  const Eyebrow('Reto 365'),
                  const SizedBox(height: 12),
                  Text(
                    'Un reto, dos personas.',
                    style: theme.textTheme.headlineMedium!
                        .copyWith(color: colors.inkBlack),
                  ),
                  const SizedBox(height: 32),
                  InkButton(
                    label: 'Yo empiezo',
                    primary: true,
                    onPressed: () =>
                        context.goNamed(AppRoute.pairShow.name),
                  ),
                  const SizedBox(height: 12),
                  GhostButton(
                    label: 'Me uno al de mi pareja',
                    onPressed: () =>
                        context.goNamed(AppRoute.pairScan.name),
                  ),
                  const SizedBox(height: 12),
                  GhostButton(
                    label: 'Recuperar mi reto',
                    onPressed: () =>
                        context.goNamed(AppRoute.restoreScan.name),
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

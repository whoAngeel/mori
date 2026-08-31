import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ink_colors.dart';
import '../../../../core/widgets/amount.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../../core/widgets/ink_button.dart';
import '../providers/challenge_notifier.dart';
import 'digit_reel.dart';

/// Full-bleed reveal for a freshly drawn day.
///
/// Three digit reels roll like a mechanical counter and lock left to right
/// (`0.55 / 0.78 / 1.0` of the run), then the number is "stamped": a short
/// overshoot that snaps to registration while the ink turns from black to
/// `inkSelf` — the press language of `docs/design-system.md` §7, not a casino
/// spin. Honest: the reels roll straight to the real result.
///
/// Pops `true` when the person asks to draw again, `false` otherwise.
class DrawCeremony extends ConsumerStatefulWidget {
  /// Reveals [day] (which is also the amount in MXN).
  const DrawCeremony({super.key, required this.day});

  /// The drawn day, `1..365`.
  final int day;

  @override
  ConsumerState<DrawCeremony> createState() => _DrawCeremonyState();
}

class _DrawCeremonyState extends ConsumerState<DrawCeremony>
    with TickerProviderStateMixin {
  static const _turns = [2, 3, 5];
  static const _lockAt = [0.55, 0.78, 1.0];
  static const _digitHeight = 76.0;

  late final AnimationController _main = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  late final AnimationController _stamp = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  final _ticked = [false, false, false];
  bool _settled = false;
  bool _paying = false;

  List<int> get _targets => [
        (widget.day ~/ 100) % 10,
        (widget.day ~/ 10) % 10,
        widget.day % 10,
      ];

  @override
  void initState() {
    super.initState();
    _main.addListener(_onTick);
    _main.addStatusListener(_onStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) {
        _ticked.fillRange(0, 3, true);
        _main.value = 1;
        _stamp.value = 1;
        setState(() => _settled = true);
        HapticFeedback.mediumImpact();
      } else {
        _main.forward();
      }
    });
  }

  @override
  void dispose() {
    _main.dispose();
    _stamp.dispose();
    super.dispose();
  }

  void _onTick() {
    for (var i = 0; i < 3; i++) {
      if (!_ticked[i] && _main.value >= _lockAt[i]) {
        _ticked[i] = true;
        if (i < 2) HapticFeedback.selectionClick();
      }
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_settled) {
      HapticFeedback.mediumImpact();
      setState(() => _settled = true);
      _stamp.forward();
    }
  }

  double _reelValue(int i) {
    final local = (_main.value / _lockAt[i]).clamp(0.0, 1.0);
    final eased = Curves.easeOutQuint.transform(local);
    return eased * (_turns[i] * 10 + _targets[i]);
  }

  Future<void> _pay() async {
    setState(() => _paying = true);
    await ref.read(challengeProvider.notifier).markPaid(widget.day);
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    final pending =
        ref.watch(challengeProvider).value?.progress.pendingDraws ?? 0;

    return Scaffold(
      backgroundColor: colors.paper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Eyebrow('Tu día'),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: Listenable.merge([_main, _stamp]),
                    builder: (context, _) {
                      final strike = _settled ? (1 - _stamp.value) : 0.0;
                      final digitStyle = theme.textTheme.displayLarge!.copyWith(
                        fontSize: _digitHeight,
                        height: 1,
                        color: Color.lerp(
                          colors.inkBlack,
                          colors.inkSelf,
                          _settled ? _stamp.value : 0.0,
                        ),
                      );
                      return Transform.translate(
                        offset: Offset(0, 5 * strike),
                        child: Transform.scale(
                          scale: 1 + 0.05 * strike,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < 3; i++)
                                DigitReel(
                                  value: _reelValue(i),
                                  style: digitStyle,
                                  height: _digitHeight,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  AnimatedOpacity(
                    opacity: _settled ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        Text(
                          'Día ${widget.day}',
                          style: theme.textTheme.titleMedium!
                              .copyWith(color: colors.inkMuted),
                        ),
                        const SizedBox(height: 4),
                        Amount(widget.day, style: theme.textTheme.displaySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_settled) ...[
                    InkButton(
                      label: 'Ya lo aparté',
                      subtitle: 'Día ${widget.day} · ${Amount.format(widget.day)}',
                      primary: true,
                      onPressed: _paying ? null : _pay,
                    ),
                    const SizedBox(height: 12),
                    if (pending > 0) ...[
                      GhostButton(
                        label: 'Sortear otro',
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                      const SizedBox(height: 12),
                    ],
                    GhostButton(
                      label: 'Listo',
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

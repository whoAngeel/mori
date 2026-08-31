import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/router/app_router.dart';
import 'core/telemetry/telemetry_consent.dart';
import 'core/telemetry/telemetry_consent_screen.dart';
import 'core/theme/app_theme.dart';

/// The user's crash-reporting choice, loaded once at startup. Mutated in place
/// when the user decides, so Sentry's `beforeSend` sees the change immediately.
late final TelemetryConsent _consent;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _consent = await TelemetryConsent.load();

  await SentryFlutter.init(
    (options) {
      options.dsn = kSentryDsn;
      // Errors only — no performance tracing, no release-health sessions.
      options.tracesSampleRate = 0;
      options.enableAutoSessionTracking = false;
      // Nothing that could carry user data.
      options.sendDefaultPii = false;
      options.attachScreenshot = false;
      options.maxBreadcrumbs = 30;
      options.environment = kReleaseMode ? 'release' : 'debug';
      // The consent gate: no event leaves the device until the user opts in.
      options.beforeSend = (event, hint) => _consent.enabled ? event : null;
    },
    // `ProviderScope` is the single Riverpod container and the root of DI.
    appRunner: () => runApp(const ProviderScope(child: MoriApp())),
  );
}

/// Root widget. Shows the one-time telemetry consent prompt before anything
/// else, then hands off to the router.
class MoriApp extends ConsumerStatefulWidget {
  /// Creates the app root.
  const MoriApp({super.key});

  @override
  ConsumerState<MoriApp> createState() => _MoriAppState();
}

class _MoriAppState extends ConsumerState<MoriApp> {
  late bool _asked = _consent.asked;

  Future<void> _decide(bool enabled) async {
    await _consent.set(enabled: enabled);
    if (mounted) setState(() => _asked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_asked) {
      return MaterialApp(
        title: 'Mori',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: TelemetryConsentScreen(onDecide: _decide),
      );
    }

    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Mori',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

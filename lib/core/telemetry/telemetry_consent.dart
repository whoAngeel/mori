import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// The Sentry DSN. A client-side key, safe to ship in the app.
const kSentryDsn =
    'https://d77049c51a7a2e247d272d8b5b5b9893@o4511675592867840.ingest.us.sentry.io/4512007858880512';

/// Whether the user has agreed to send crash reports.
///
/// This is the one thing in the app that can cause a network request, so it is
/// strictly opt-in: nothing leaves the device until [enabled] is true, and the
/// user is asked once, on the first launch. The choice is a small JSON file in
/// the app support directory — no database migration, no cloud.
class TelemetryConsent {
  TelemetryConsent._(this._file, {required this.asked, required this.enabled});

  final File _file;

  /// True once the user has answered the consent prompt (either way).
  bool asked;

  /// True when the user allowed crash reporting. Read live by Sentry's
  /// `beforeSend`, so toggling it takes effect without a restart.
  bool enabled;

  static const _fileName = 'telemetry_consent.json';

  /// Loads the stored choice, defaulting to "not asked, disabled".
  static Future<TelemetryConsent> load() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/$_fileName');
    try {
      final map = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return TelemetryConsent._(
        file,
        asked: map['asked'] == true,
        enabled: map['enabled'] == true,
      );
    } catch (_) {
      return TelemetryConsent._(file, asked: false, enabled: false);
    }
  }

  /// Records the user's decision and persists it.
  Future<void> set({required bool enabled}) async {
    asked = true;
    this.enabled = enabled;
    try {
      await _file.writeAsString(
        jsonEncode({'asked': true, 'enabled': enabled}),
        flush: true,
      );
    } catch (_) {
      // A failed write just means we ask again next launch — acceptable.
    }
  }
}

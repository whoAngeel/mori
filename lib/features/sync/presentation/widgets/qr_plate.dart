import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A QR drawn in pure black on pure white with a 16 dp quiet zone and error
/// correction M (`docs/design-system.md` §6). The QR never carries ink: cheap
/// cameras — and phone-to-screen scans — need the maximum possible contrast,
/// not the near-black/near-white ink tokens.
class QrPlate extends StatelessWidget {
  /// Creates a QR plate for [data].
  const QrPlate({super.key, required this.data, this.size = 240});

  /// The payload text to encode.
  final String data;

  /// Edge length of the QR itself, in dp.
  final double size;

  static const _white = Color(0xFFFFFFFF);
  static const _black = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: _white,
        padding: const EdgeInsets.all(16),
        // The plate keeps its final size before the payload arrives, so the QR
        // fills in without the layout jumping.
        child: SizedBox(
          width: size,
          height: size,
          child: data.isEmpty
              ? null
              : QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: size,
                  // The 16 dp quiet zone is the Container's padding;
                  // QrImageView adds its own 10 dp by default, zeroed here to
                  // keep exactly 16.
                  padding: EdgeInsets.zero,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  backgroundColor: _white,
                  // ignore: deprecated_member_use
                  foregroundColor: _black,
                ),
        ),
      ),
    );
  }
}

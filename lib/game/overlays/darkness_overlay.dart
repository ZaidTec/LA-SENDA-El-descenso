import 'dart:ui';

import '../../utils/constants.dart';

class DarknessOverlay {
  const DarknessOverlay._();

  static void paint(
    Canvas canvas, {
    required Size size,
    required Offset lightCenter,
    required double lightRadius,
  }) {
    final bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());
    canvas.drawRect(
      bounds,
      Paint()..color = GameColors.darkness.withValues(alpha: GameConstants.darknessOpacity),
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.dstOut
        ..shader = Gradient.radial(
          lightCenter,
          lightRadius,
          const [Color(0xFF000000), Color(0x00000000)],
          const [.78, 1],
        ),
    );
    canvas.restore();
  }
}

import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Anchor Lock Visualization: Lock glyph showing anchor stability.
///
/// Displays a lock icon at the frozen anchor position:
/// - Green lock = stable (delta < 0.1px)
/// - Red lock = drift detected (delta >= 0.1px)
///
/// This makes anchor drift immediately visible in screen recordings.
class AnchorLockDebugPainter extends CustomPainter {
  /// Frozen anchor position
  final Offset anchorPosition;

  /// Current anchor delta (distance from original anchor)
  final double anchorDelta;

  /// Lock icon size
  final double lockSize;

  /// Stability threshold (delta below this is considered stable)
  static const double stabilityThreshold = 0.1;

  AnchorLockDebugPainter({
    required this.anchorPosition,
    required this.anchorDelta,
    this.lockSize = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(capabilities.UIDebugCapability.anchorLock)) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = anchorDelta < stabilityThreshold ? Colors.green : Colors.red;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 2.0;

    // Draw lock icon at anchor position
    _drawLockIcon(canvas, anchorPosition, paint, strokePaint);
  }

  void _drawLockIcon(
    Canvas canvas,
    Offset center,
    Paint fillPaint,
    Paint strokePaint,
  ) {
    // Lock body (rounded rectangle)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: lockSize * 0.6,
        height: lockSize * 0.5,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(bodyRect, fillPaint);
    canvas.drawRRect(bodyRect, strokePaint);

    // Lock shackle (semicircle on top)
    final shackleRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - lockSize * 0.25),
      width: lockSize * 0.5,
      height: lockSize * 0.4,
    );
    canvas.drawArc(
      shackleRect,
      0,
      3.14159, // 180 degrees
      false,
      strokePaint,
    );

    // Draw delta text below lock
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Δ${anchorDelta.toStringAsFixed(2)}px',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + lockSize * 0.4,
      ),
    );
  }

  @override
  bool shouldRepaint(AnchorLockDebugPainter oldDelegate) {
    return oldDelegate.anchorPosition != anchorPosition ||
        oldDelegate.anchorDelta != anchorDelta;
  }
}

/// Widget wrapper for Anchor Lock Visualization.
class AnchorLockDebug extends StatelessWidget {
  /// Frozen anchor position
  final Offset anchorPosition;

  /// Current anchor delta (distance from original anchor)
  final double anchorDelta;

  /// Lock icon size
  final double lockSize;

  const AnchorLockDebug({
    super.key,
    required this.anchorPosition,
    required this.anchorDelta,
    this.lockSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!capabilities.UIDebugConfig.isEnabled(capabilities.UIDebugCapability.anchorLock)) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: AnchorLockDebugPainter(
        anchorPosition: anchorPosition,
        anchorDelta: anchorDelta,
        lockSize: lockSize,
      ),
      size: Size.infinite,
    );
  }
}

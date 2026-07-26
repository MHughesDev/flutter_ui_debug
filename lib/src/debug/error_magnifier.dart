import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;
import 'ui_debug_severity.dart';

/// Error Magnifier: 3× zoom inset with crosshairs.
///
/// Auto-appears when alignment error exceeds threshold (e.g., 2px).
/// Displays pixel delta label and positions near error location.
///
/// This makes small alignment errors immediately visible in screen recordings.
class ErrorMagnifierPainter extends CustomPainter {
  /// Error position (where the error occurs)
  final Offset errorPosition;

  /// Error delta in pixels
  final double errorDelta;

  /// Magnifier size
  final double magnifierSize;

  /// Zoom level (e.g., 3.0 for 3× zoom)
  final double zoomLevel;

  /// Error threshold for auto-appearing
  static const double errorThreshold = 2.0;

  ErrorMagnifierPainter({
    required this.errorPosition,
    required this.errorDelta,
    this.magnifierSize = 120.0,
    this.zoomLevel = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.errorMagnifier)) {
      return;
    }

    // Only show if error exceeds threshold
    if (errorDelta < errorThreshold) {
      return;
    }

    // Calculate magnifier position (near error, but not overlapping)
    final magnifierCenter = _calculateMagnifierPosition(errorPosition, size);

    // Draw magnifier background
    _drawMagnifierBackground(canvas, magnifierCenter);

    // Draw zoomed content (simplified - shows crosshairs at error position)
    _drawZoomedContent(canvas, magnifierCenter, errorPosition);

    // Draw crosshairs
    _drawCrosshairs(canvas, magnifierCenter);

    // Draw error label
    _drawErrorLabel(canvas, magnifierCenter, errorDelta);
  }

  Offset _calculateMagnifierPosition(Offset errorPos, Size screenSize) {
    // Position magnifier near error, but ensure it stays on screen
    final offset = Offset(60.0, 60.0);
    var position = errorPos + offset;

    // Clamp to screen bounds
    position = Offset(
      position.dx.clamp(magnifierSize / 2, screenSize.width - magnifierSize / 2),
      position.dy.clamp(magnifierSize / 2, screenSize.height - magnifierSize / 2),
    );

    return position;
  }

  void _drawMagnifierBackground(Canvas canvas, Offset center) {
    // Draw outer circle (border)
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, magnifierSize / 2, borderPaint);

    // Draw inner circle (background)
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, magnifierSize / 2 - 2, backgroundPaint);

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center + const Offset(2, 2),
      magnifierSize / 2,
      shadowPaint,
    );
  }

  void _drawZoomedContent(Canvas canvas, Offset magnifierCenter, Offset errorPos) {
    // Calculate the offset from error position to magnifier center
    // In a real implementation, this would sample pixels from the screen
    // For now, we'll draw a simplified representation

    // Draw grid to show zoom effect
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final gridSize = magnifierSize / zoomLevel;
    final startX = magnifierCenter.dx - magnifierSize / 2;
    final startY = magnifierCenter.dy - magnifierSize / 2;

    // Draw vertical grid lines
    for (double x = startX; x < magnifierCenter.dx + magnifierSize / 2; x += gridSize) {
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, magnifierCenter.dy + magnifierSize / 2),
        gridPaint,
      );
    }

    // Draw horizontal grid lines
    for (double y = startY; y < magnifierCenter.dy + magnifierSize / 2; y += gridSize) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(magnifierCenter.dx + magnifierSize / 2, y),
        gridPaint,
      );
    }

    // Draw center point (error position in magnified view)
    final centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(magnifierCenter, 3, centerPaint);
  }

  void _drawCrosshairs(Canvas canvas, Offset center) {
    final crosshairPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final crosshairLength = magnifierSize / 4;

    // Draw horizontal line
    canvas.drawLine(
      Offset(center.dx - crosshairLength, center.dy),
      Offset(center.dx + crosshairLength, center.dy),
      crosshairPaint,
    );

    // Draw vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - crosshairLength),
      Offset(center.dx, center.dy + crosshairLength),
      crosshairPaint,
    );

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, 4, centerPaint);
  }

  void _drawErrorLabel(Canvas canvas, Offset magnifierCenter, double errorDelta) {
    final severity = errorDelta < errorThreshold
        ? UIDebugSeverity.cosmetic
        : errorDelta < 5.0
            ? UIDebugSeverity.perceptual
            : UIDebugSeverity.architectural;

    final color = Color(severity.colorValue);

    final text = '${errorDelta.toStringAsFixed(2)}px';
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
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

    // Position label below magnifier
    final labelY = magnifierCenter.dy + magnifierSize / 2 + 10;

    // Draw background
    final backgroundRect = Rect.fromLTWH(
      magnifierCenter.dx - textPainter.width / 2 - 4,
      labelY - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(backgroundRect, const Radius.circular(4)),
      backgroundPaint,
    );

    textPainter.paint(
      canvas,
      Offset(
        magnifierCenter.dx - textPainter.width / 2,
        labelY,
      ),
    );
  }

  @override
  bool shouldRepaint(ErrorMagnifierPainter oldDelegate) {
    return oldDelegate.errorPosition != errorPosition ||
        oldDelegate.errorDelta != errorDelta ||
        oldDelegate.magnifierSize != magnifierSize ||
        oldDelegate.zoomLevel != zoomLevel;
  }
}

/// Widget wrapper for Error Magnifier.
class ErrorMagnifier extends StatelessWidget {
  /// Error position (where the error occurs)
  final Offset errorPosition;

  /// Error delta in pixels
  final double errorDelta;

  /// Magnifier size
  final double magnifierSize;

  /// Zoom level (e.g., 3.0 for 3× zoom)
  final double zoomLevel;

  const ErrorMagnifier({
    super.key,
    required this.errorPosition,
    required this.errorDelta,
    this.magnifierSize = 120.0,
    this.zoomLevel = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.errorMagnifier)) {
      return const SizedBox.shrink();
    }

    // Only show if error exceeds threshold
    if (errorDelta < ErrorMagnifierPainter.errorThreshold) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: ErrorMagnifierPainter(
        errorPosition: errorPosition,
        errorDelta: errorDelta,
        magnifierSize: magnifierSize,
        zoomLevel: zoomLevel,
      ),
      size: Size.infinite,
    );
  }
}

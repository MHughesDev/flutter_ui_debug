import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Overlay Boundary Outline: Dashed rectangle showing overlay bounds.
///
/// Displays a dashed rectangle around the overlay bounds and flashes red
/// if the animated widget exits the overlay bounds.
///
/// This helps detect when animations escape their intended boundaries.
class OverlayBoundsDebugPainter extends CustomPainter {
  /// Overlay bounds rectangle
  final Rect overlayBounds;

  /// Current widget position (center)
  final Offset? widgetPosition;

  /// Widget size
  final Size? widgetSize;

  /// Whether widget has exited bounds
  final bool hasExitedBounds;

  /// Line width for the outline
  final double lineWidth;

  /// Dash pattern spacing
  final double dashSpacing;

  OverlayBoundsDebugPainter({
    required this.overlayBounds,
    this.widgetPosition,
    this.widgetSize,
    this.hasExitedBounds = false,
    this.lineWidth = 2.0,
    this.dashSpacing = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(capabilities.UIDebugCapability.overlayBounds)) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..color = hasExitedBounds ? Colors.red : Colors.cyan;

    // Draw dashed rectangle for overlay bounds
    _drawDashedRect(canvas, overlayBounds, paint);

    // If widget has exited bounds, flash the entire overlay area
    if (hasExitedBounds) {
      final flashPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.red.withValues(alpha: 0.2);
      canvas.drawRect(overlayBounds, flashPaint);
    }

    // Draw widget bounds if position and size are provided
    if (widgetPosition != null && widgetSize != null) {
      final widgetRect = Rect.fromCenter(
        center: widgetPosition!,
        width: widgetSize!.width,
        height: widgetSize!.height,
      );

      // Check if widget is outside overlay bounds
      final isOutside = !overlayBounds.contains(widgetRect.topLeft) ||
          !overlayBounds.contains(widgetRect.bottomRight);

      if (isOutside) {
        final widgetPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = Colors.red;
        canvas.drawRect(widgetRect, widgetPaint);

        // Draw warning text
        final textPainter = TextPainter(
          text: const TextSpan(
            text: 'OUT OF BOUNDS',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
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
            widgetPosition!.dx - textPainter.width / 2,
            widgetPosition!.dy - widgetSize!.height / 2 - 20,
          ),
        );
      }
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    final path = Path();
    final dashWidth = dashSpacing;
    final dashHeight = dashSpacing;

    // Top edge
    for (double x = rect.left; x < rect.right; x += dashWidth * 2) {
      path.moveTo(x, rect.top);
      path.lineTo((x + dashWidth).clamp(rect.left, rect.right), rect.top);
    }

    // Right edge
    for (double y = rect.top; y < rect.bottom; y += dashHeight * 2) {
      path.moveTo(rect.right, y);
      path.lineTo(rect.right, (y + dashHeight).clamp(rect.top, rect.bottom));
    }

    // Bottom edge
    for (double x = rect.right; x > rect.left; x -= dashWidth * 2) {
      path.moveTo(x, rect.bottom);
      path.lineTo((x - dashWidth).clamp(rect.left, rect.right), rect.bottom);
    }

    // Left edge
    for (double y = rect.bottom; y > rect.top; y -= dashHeight * 2) {
      path.moveTo(rect.left, y);
      path.lineTo(rect.left, (y - dashHeight).clamp(rect.top, rect.bottom));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(OverlayBoundsDebugPainter oldDelegate) {
    return oldDelegate.overlayBounds != overlayBounds ||
        oldDelegate.widgetPosition != widgetPosition ||
        oldDelegate.widgetSize != widgetSize ||
        oldDelegate.hasExitedBounds != hasExitedBounds;
  }
}

/// Widget wrapper for Overlay Boundary Outline.
class OverlayBoundsDebug extends StatelessWidget {
  /// Overlay bounds rectangle
  final Rect overlayBounds;

  /// Current widget position (center)
  final Offset? widgetPosition;

  /// Widget size
  final Size? widgetSize;

  /// Whether widget has exited bounds
  final bool hasExitedBounds;

  const OverlayBoundsDebug({
    super.key,
    required this.overlayBounds,
    this.widgetPosition,
    this.widgetSize,
    this.hasExitedBounds = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!capabilities.UIDebugConfig.isEnabled(capabilities.UIDebugCapability.overlayBounds)) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: OverlayBoundsDebugPainter(
        overlayBounds: overlayBounds,
        widgetPosition: widgetPosition,
        widgetSize: widgetSize,
        hasExitedBounds: hasExitedBounds,
      ),
      size: Size.infinite,
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Local Coordinate Grid Debug Painter: Draws coordinate system visualization.
///
/// Draws:
/// - Small local axis grid attached to animated widget
/// - Global axis reference in corner
/// - Reveals mixed coordinate usage and parent transform effects
///
/// This helps diagnose coordinate space issues by showing both local and
/// global coordinate systems simultaneously.
class CoordinateGridDebugPainter extends CustomPainter {
  /// Widget position (top-left corner)
  final Offset widgetPosition;

  /// Widget size
  final Size widgetSize;

  /// Screen size for full-screen rendering
  final Size screenSize;

  /// Grid spacing in pixels
  static const double gridSpacing = 20.0;

  /// Grid line length for local grid
  static const double localGridLineLength = 40.0;

  /// Grid line length for global reference
  static const double globalGridLineLength = 60.0;

  CoordinateGridDebugPainter({
    required this.widgetPosition,
    required this.widgetSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.coordinateGrid)) {
      return;
    }

    // Draw local coordinate grid attached to widget
    _drawLocalGrid(canvas);

    // Draw global axis reference in corner
    _drawGlobalReference(canvas);
  }

  void _drawLocalGrid(Canvas canvas) {
    final widgetCenter = Offset(
      widgetPosition.dx + widgetSize.width / 2,
      widgetPosition.dy + widgetSize.height / 2,
    );

    // Draw local X axis (horizontal, red)
    final xAxisPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final xAxisStart = widgetCenter - Offset(localGridLineLength / 2, 0);
    final xAxisEnd = widgetCenter + Offset(localGridLineLength / 2, 0);
    canvas.drawLine(xAxisStart, xAxisEnd, xAxisPaint);

    // Draw X axis arrow
    _drawArrow(canvas, xAxisEnd, 0, Colors.red.withValues(alpha: 0.7));

    // Draw local Y axis (vertical, green)
    final yAxisPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final yAxisStart = widgetCenter - Offset(0, localGridLineLength / 2);
    final yAxisEnd = widgetCenter + Offset(0, localGridLineLength / 2);
    canvas.drawLine(yAxisStart, yAxisEnd, yAxisPaint);

    // Draw Y axis arrow
    _drawArrow(canvas, yAxisEnd, 3.141592653589793 / 2, Colors.green.withValues(alpha: 0.7));

    // Draw grid lines around widget
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Horizontal grid lines
    for (double y = widgetCenter.dy - localGridLineLength;
        y <= widgetCenter.dy + localGridLineLength;
        y += gridSpacing) {
      canvas.drawLine(
        Offset(widgetCenter.dx - localGridLineLength / 2, y),
        Offset(widgetCenter.dx + localGridLineLength / 2, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    for (double x = widgetCenter.dx - localGridLineLength / 2;
        x <= widgetCenter.dx + localGridLineLength / 2;
        x += gridSpacing) {
      canvas.drawLine(
        Offset(x, widgetCenter.dy - localGridLineLength / 2),
        Offset(x, widgetCenter.dy + localGridLineLength / 2),
        gridPaint,
      );
    }

    // Draw origin marker at widget center
    final originPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    canvas.drawCircle(widgetCenter, 4, originPaint);

    // Draw origin label
    final originLabel = TextPainter(
      text: TextSpan(
        text: 'LOCAL (0,0)',
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 9,
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
    originLabel.layout();
    originLabel.paint(
      canvas,
      Offset(
        widgetCenter.dx - originLabel.width / 2,
        widgetCenter.dy + localGridLineLength / 2 + 6,
      ),
    );

    // Draw axis labels
    final xLabel = TextPainter(
      text: TextSpan(
        text: 'X',
        style: TextStyle(
          color: Colors.red,
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
    xLabel.layout();
    xLabel.paint(
      canvas,
      Offset(xAxisEnd.dx + 4, xAxisEnd.dy - xLabel.height / 2),
    );

    final yLabel = TextPainter(
      text: TextSpan(
        text: 'Y',
        style: TextStyle(
          color: Colors.green,
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
    yLabel.layout();
    yLabel.paint(
      canvas,
      Offset(yAxisEnd.dx - yLabel.width / 2, yAxisEnd.dy - yLabel.height - 4),
    );
  }

  void _drawGlobalReference(Canvas canvas) {
    // Draw global reference in top-right corner
    final referenceOrigin = Offset(screenSize.width - globalGridLineLength - 20, 20);

    // Draw global X axis (horizontal, cyan)
    final xAxisPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final xAxisStart = referenceOrigin;
    final xAxisEnd = referenceOrigin + Offset(globalGridLineLength, 0);
    canvas.drawLine(xAxisStart, xAxisEnd, xAxisPaint);

    // Draw X axis arrow
    _drawArrow(canvas, xAxisEnd, 0, Colors.cyan.withValues(alpha: 0.8));

    // Draw global Y axis (vertical, cyan)
    final yAxisPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final yAxisStart = referenceOrigin;
    final yAxisEnd = referenceOrigin + Offset(0, globalGridLineLength);
    canvas.drawLine(yAxisStart, yAxisEnd, yAxisPaint);

    // Draw Y axis arrow
    _drawArrow(canvas, yAxisEnd, 3.141592653589793 / 2, Colors.cyan.withValues(alpha: 0.8));

    // Draw origin marker
    final originPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(referenceOrigin, 3, originPaint);

    // Draw global reference label
    final label = TextPainter(
      text: TextSpan(
        text: 'GLOBAL',
        style: TextStyle(
          color: Colors.cyan,
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
    label.layout();
    label.paint(
      canvas,
      Offset(
        referenceOrigin.dx - label.width / 2,
        referenceOrigin.dy + globalGridLineLength + 6,
      ),
    );
  }

  void _drawArrow(Canvas canvas, Offset position, double angle, Color color) {
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final arrowSize = 6.0;
    final arrowPath = Path();

    // Arrow points in direction of angle
    final tip = position;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    
    // Left point of arrow
    final left = tip + Offset(
      -arrowSize * 1.5 * cosA + arrowSize * sinA,
      -arrowSize * 1.5 * sinA - arrowSize * cosA,
    );
    
    // Right point of arrow
    final right = tip + Offset(
      -arrowSize * 1.5 * cosA - arrowSize * sinA,
      -arrowSize * 1.5 * sinA + arrowSize * cosA,
    );

    arrowPath.moveTo(tip.dx, tip.dy);
    arrowPath.lineTo(left.dx, left.dy);
    arrowPath.lineTo(right.dx, right.dy);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(CoordinateGridDebugPainter oldDelegate) {
    return oldDelegate.widgetPosition != widgetPosition ||
        oldDelegate.widgetSize != widgetSize ||
        oldDelegate.screenSize != screenSize;
  }
}


/// Widget wrapper for Local Coordinate Grid Debug Visualization.
class CoordinateGridDebug extends StatelessWidget {
  /// Widget position (top-left corner)
  final Offset widgetPosition;

  /// Widget size
  final Size widgetSize;

  const CoordinateGridDebug({
    super.key,
    required this.widgetPosition,
    required this.widgetSize,
  });

  @override
  Widget build(BuildContext context) {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.coordinateGrid)) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    return CustomPaint(
      painter: CoordinateGridDebugPainter(
        widgetPosition: widgetPosition,
        widgetSize: widgetSize,
        screenSize: screenSize,
      ),
      size: Size.infinite,
    );
  }
}

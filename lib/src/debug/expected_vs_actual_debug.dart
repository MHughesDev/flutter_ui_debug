import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;
import 'ui_debug_severity.dart';

/// Expected vs Actual Debug Painter: Compares expected animation path with actual path.
///
/// Draws:
/// - Dashed "expected path" (from start to target)
/// - Solid "actual path" (from position history)
/// - Ghost final widget at expected end position
/// - Error label showing ΔEnd distance
///
/// This makes alignment errors immediately visible in screen recordings.
class ExpectedVsActualDebugPainter extends CustomPainter {
  /// Expected start position
  final Offset expectedStart;

  /// Expected end position
  final Offset expectedEnd;

  /// Actual path (from position history)
  final List<Offset> actualPath;

  /// Actual final position
  final Offset? actualEnd;

  /// Widget size for drawing ghost widget
  final Size widgetSize;

  /// Screen size for full-screen rendering
  final Size screenSize;

  /// Error threshold for highlighting (in pixels)
  static const double errorThreshold = 2.0;

  ExpectedVsActualDebugPainter({
    required this.expectedStart,
    required this.expectedEnd,
    required this.actualPath,
    this.actualEnd,
    required this.widgetSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.expectedVsActual)) {
      return;
    }

    // Draw expected path (dashed line from start to end)
    _drawExpectedPath(canvas);

    // Draw actual path (solid line from position history)
    if (actualPath.length > 1) {
      _drawActualPath(canvas);
    }

    // Draw ghost widget at expected end position
    _drawGhostWidget(canvas, expectedEnd);

    // Calculate and display error if actual end position is available
    if (actualEnd != null) {
      final error = (expectedEnd - actualEnd!).distance;
      _drawErrorLabel(canvas, error, actualEnd!);
    }
  }

  void _drawExpectedPath(Canvas canvas) {
    final dashPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw dashed line manually
    final dashLength = 8.0;
    final gapLength = 4.0;
    final totalLength = (expectedEnd - expectedStart).distance;
    final direction = (expectedEnd - expectedStart) / totalLength;

    double currentLength = 0.0;
    while (currentLength < totalLength) {
      final start = expectedStart + direction * currentLength;
      final dashEndLength = (currentLength + dashLength).clamp(0.0, totalLength);
      final end = expectedStart + direction * dashEndLength;
      canvas.drawLine(start, end, dashPaint);
      currentLength += dashLength + gapLength;
    }

    // Draw start marker
    _drawMarker(canvas, expectedStart, Colors.cyan, 'EXP START');

    // Draw end marker
    _drawMarker(canvas, expectedEnd, Colors.cyan, 'EXP END');
  }

  void _drawActualPath(Canvas canvas) {
    if (actualPath.length < 2) return;

    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path()
      ..moveTo(actualPath.first.dx, actualPath.first.dy);

    for (int i = 1; i < actualPath.length; i++) {
      path.lineTo(actualPath[i].dx, actualPath[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw start marker
    if (actualPath.isNotEmpty) {
      _drawMarker(canvas, actualPath.first, Colors.blue, 'ACT START');
    }

    // Draw end marker
    if (actualPath.length > 1) {
      _drawMarker(canvas, actualPath.last, Colors.blue, 'ACT END');
    }
  }

  void _drawGhostWidget(Canvas canvas, Offset position) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw ghost widget rectangle
    final rect = Rect.fromCenter(
      center: position,
      width: widgetSize.width,
      height: widgetSize.height,
    );

    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, strokePaint);

    // Draw "GHOST" label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'GHOST',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - widgetSize.height / 2 - textPainter.height - 4,
      ),
    );
  }

  void _drawErrorLabel(Canvas canvas, double error, Offset actualEnd) {
    final severity = error < 1.0
        ? UIDebugSeverity.cosmetic
        : error < errorThreshold
            ? UIDebugSeverity.perceptual
            : UIDebugSeverity.architectural;

    final color = Color(severity.colorValue);

    // Draw error line from expected to actual
    final errorPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(expectedEnd, actualEnd, errorPaint);

    // Draw error label
    final text = 'ΔEnd: ${error.toStringAsFixed(2)}px';
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
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

    // Position label at midpoint of error line
    final labelPosition = Offset.lerp(expectedEnd, actualEnd, 0.5)!;

    // Draw background
    final backgroundRect = Rect.fromLTWH(
      labelPosition.dx - textPainter.width / 2 - 4,
      labelPosition.dy - textPainter.height / 2 - 2,
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
        labelPosition.dx - textPainter.width / 2,
        labelPosition.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawMarker(Canvas canvas, Offset position, Color color, String label) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw circle marker
    canvas.drawCircle(position, 6, paint);

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(position, 6, borderPaint);

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
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
        position.dx - textPainter.width / 2,
        position.dy + 10,
      ),
    );
  }

  @override
  bool shouldRepaint(ExpectedVsActualDebugPainter oldDelegate) {
    return oldDelegate.expectedStart != expectedStart ||
        oldDelegate.expectedEnd != expectedEnd ||
        oldDelegate.actualPath.length != actualPath.length ||
        oldDelegate.actualEnd != actualEnd ||
        oldDelegate.widgetSize != widgetSize ||
        oldDelegate.screenSize != screenSize;
  }
}

/// Widget wrapper for Expected vs Actual Debug Visualization.
class ExpectedVsActualDebug extends StatelessWidget {
  /// Expected start position
  final Offset expectedStart;

  /// Expected end position
  final Offset expectedEnd;

  /// Actual path (from position history)
  final List<Offset> actualPath;

  /// Actual final position
  final Offset? actualEnd;

  /// Widget size for drawing ghost widget
  final Size widgetSize;

  const ExpectedVsActualDebug({
    super.key,
    required this.expectedStart,
    required this.expectedEnd,
    required this.actualPath,
    this.actualEnd,
    required this.widgetSize,
  });

  @override
  Widget build(BuildContext context) {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.expectedVsActual)) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    return CustomPaint(
      painter: ExpectedVsActualDebugPainter(
        expectedStart: expectedStart,
        expectedEnd: expectedEnd,
        actualPath: actualPath,
        actualEnd: actualEnd,
        widgetSize: widgetSize,
        screenSize: screenSize,
      ),
      size: Size.infinite,
    );
  }
}

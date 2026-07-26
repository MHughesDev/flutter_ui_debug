import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;
import '../constants/ui_debug_mode.dart';

/// Constraint Cage Debug Painter: Enhanced constraint visualization with cage and clipping detection.
///
/// Shows:
/// - Live constraint box (cage) around widget
/// - Label: `maxW=360, maxH=112`
/// - `CLIPPED BY: ClipRRect@NotesPage` when clipped
///
/// This makes constraint violations and clipping issues immediately visible.
class ConstraintCageDebugPainter extends CustomPainter {
  /// Widget bounds
  final Rect widgetBounds;

  /// Box constraints
  final BoxConstraints constraints;

  /// Screen size for full-screen rendering
  final Size screenSize;

  /// Clipping source (e.g., "ClipRRect@NotesPage")
  final String? clippingSource;

  ConstraintCageDebugPainter({
    required this.widgetBounds,
    required this.constraints,
    required this.screenSize,
    this.clippingSource,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.constraintCage)) {
      return;
    }

    // Draw constraint cage (box showing max constraints)
    _drawConstraintCage(canvas);

    // Draw constraint labels
    _drawConstraintLabels(canvas);

    // Draw clipping indicator if clipped
    if (clippingSource != null) {
      _drawClippingIndicator(canvas);
    }
  }

  void _drawConstraintCage(Canvas canvas) {
    // Calculate constraint box
    final constraintBox = Rect.fromLTWH(
      widgetBounds.left,
      widgetBounds.top,
      constraints.maxWidth.isFinite ? constraints.maxWidth : widgetBounds.width,
      constraints.maxHeight.isFinite ? constraints.maxHeight : widgetBounds.height,
    );

    // Draw constraint cage (dashed rectangle)
    final cagePaint = Paint()
      ..color = UIDebugColors.constraintSatisfied.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw dashed rectangle manually
    final dashLength = 8.0;
    final gapLength = 4.0;

    // Top edge
    _drawDashedLine(
      canvas,
      Offset(constraintBox.left, constraintBox.top),
      Offset(constraintBox.right, constraintBox.top),
      dashLength,
      gapLength,
      cagePaint,
    );

    // Right edge
    _drawDashedLine(
      canvas,
      Offset(constraintBox.right, constraintBox.top),
      Offset(constraintBox.right, constraintBox.bottom),
      dashLength,
      gapLength,
      cagePaint,
    );

    // Bottom edge
    _drawDashedLine(
      canvas,
      Offset(constraintBox.right, constraintBox.bottom),
      Offset(constraintBox.left, constraintBox.bottom),
      dashLength,
      gapLength,
      cagePaint,
    );

    // Left edge
    _drawDashedLine(
      canvas,
      Offset(constraintBox.left, constraintBox.bottom),
      Offset(constraintBox.left, constraintBox.top),
      dashLength,
      gapLength,
      cagePaint,
    );

    // Draw corner markers
    final cornerPaint = Paint()
      ..color = UIDebugColors.constraintSatisfied
      ..style = PaintingStyle.fill;

    final cornerRadius = 4.0;
    canvas.drawCircle(constraintBox.topLeft, cornerRadius, cornerPaint);
    canvas.drawCircle(constraintBox.topRight, cornerRadius, cornerPaint);
    canvas.drawCircle(constraintBox.bottomLeft, cornerRadius, cornerPaint);
    canvas.drawCircle(constraintBox.bottomRight, cornerRadius, cornerPaint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    double dashLength,
    double gapLength,
    Paint paint,
  ) {
    final totalLength = (end - start).distance;
    final direction = (end - start) / totalLength;

    double currentLength = 0.0;
    while (currentLength < totalLength) {
      final dashStart = start + direction * currentLength;
      final dashEndLength = (currentLength + dashLength).clamp(0.0, totalLength);
      final dashEnd = start + direction * dashEndLength;
      canvas.drawLine(dashStart, dashEnd, paint);
      currentLength += dashLength + gapLength;
    }
  }

  void _drawConstraintLabels(Canvas canvas) {
    // Draw constraint labels
    final maxW = constraints.maxWidth.isFinite
        ? constraints.maxWidth.toStringAsFixed(0)
        : '∞';
    final maxH = constraints.maxHeight.isFinite
        ? constraints.maxHeight.toStringAsFixed(0)
        : '∞';
    final minW = constraints.minWidth.toStringAsFixed(0);
    final minH = constraints.minHeight.toStringAsFixed(0);

    final labelText = 'maxW=$maxW, maxH=$maxH\nminW=$minW, minH=$minH';

    final textPainter = TextPainter(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          color: UIDebugColors.constraintSatisfied,
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

    // Position label above widget
    final labelPosition = Offset(
      widgetBounds.left,
      widgetBounds.top - textPainter.height - 8,
    );

    // Draw background
    final backgroundRect = Rect.fromLTWH(
      labelPosition.dx - 4,
      labelPosition.dy - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(backgroundRect, const Radius.circular(4)),
      backgroundPaint,
    );

    textPainter.paint(canvas, labelPosition);
  }

  void _drawClippingIndicator(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'CLIPPED BY: $clippingSource',
        style: TextStyle(
          color: UIDebugColors.constraintViolated,
          fontSize: 11,
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

    // Position indicator below widget
    final indicatorPosition = Offset(
      widgetBounds.left,
      widgetBounds.bottom + 8,
    );

    // Draw background
    final backgroundRect = Rect.fromLTWH(
      indicatorPosition.dx - 4,
      indicatorPosition.dy - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(backgroundRect, const Radius.circular(4)),
      backgroundPaint,
    );

    // Draw warning border
    final borderPaint = Paint()
      ..color = UIDebugColors.constraintViolated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(backgroundRect, const Radius.circular(4)),
      borderPaint,
    );

    textPainter.paint(canvas, indicatorPosition);
  }

  @override
  bool shouldRepaint(ConstraintCageDebugPainter oldDelegate) {
    return oldDelegate.widgetBounds != widgetBounds ||
        oldDelegate.constraints != constraints ||
        oldDelegate.screenSize != screenSize ||
        oldDelegate.clippingSource != clippingSource;
  }
}

/// Widget wrapper for Constraint Cage Debug Visualization.
class ConstraintCageDebug extends StatelessWidget {
  /// Widget bounds
  final Rect widgetBounds;

  /// Box constraints
  final BoxConstraints constraints;

  /// Clipping source (e.g., "ClipRRect@NotesPage")
  final String? clippingSource;

  const ConstraintCageDebug({
    super.key,
    required this.widgetBounds,
    required this.constraints,
    this.clippingSource,
  });

  @override
  Widget build(BuildContext context) {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.constraintCage)) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    return CustomPaint(
      painter: ConstraintCageDebugPainter(
        widgetBounds: widgetBounds,
        constraints: constraints,
        screenSize: screenSize,
        clippingSource: clippingSource,
      ),
      size: Size.infinite,
    );
  }
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Data for a single easing curve to visualize
class CurveData {
  /// Curve to visualize
  final Curve curve;

  /// Display name
  final String name;

  /// Display color
  final Color color;

  const CurveData({
    required this.curve,
    required this.name,
    this.color = Colors.blue,
  });
}

/// Easing Curve Visualizer: Visualize and compare easing curves.
///
/// Displays easing curves as graphs showing how animation progress
/// maps to animation values over time.
///
/// This helps developers understand and compare different easing
/// functions, choose appropriate easing curves, and debug animation timing.
class EasingCurveVisualizer extends StatelessWidget {
  /// Easing curves to visualize
  final List<CurveData> curves;

  /// Current animation progress (for indicator)
  final double? currentProgress;

  /// Size of the visualizer
  final Size size;

  /// Position of the visualizer overlay
  final Offset? position;

  /// Whether to show grid
  final bool showGrid;

  /// Whether to show axes labels
  final bool showLabels;

  /// Number of samples for curve plotting
  final int samples;

  const EasingCurveVisualizer({
    super.key,
    required this.curves,
    this.currentProgress,
    this.size = const Size(300, 200),
    this.position,
    this.showGrid = true,
    this.showLabels = true,
    this.samples = 100,
  });

  @override
  Widget build(BuildContext context) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.easingCurveVisualizer)) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final pos = position ??
        Offset(
          screenSize.width - size.width - 8,
          screenSize.height - size.height - 8,
        );

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(left: pos.dx, bottom: pos.dy),
        child: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: CustomPaint(
                painter: _CurvePainter(
                  curves: curves,
                  currentProgress: currentProgress,
                  showGrid: showGrid,
                  showLabels: showLabels,
                  samples: samples,
                ),
                child: Container(),
              ),
            ),
            if (curves.length > 1) ...[
              const SizedBox(height: 8),
              _buildLegend(),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'EASING CURVES',
      style: TextStyle(
        color: Colors.cyan,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: curves.map((curve) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: curve.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              curve.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _CurvePainter extends CustomPainter {
  final List<CurveData> curves;
  final double? currentProgress;
  final bool showGrid;
  final bool showLabels;
  final int samples;

  _CurvePainter({
    required this.curves,
    this.currentProgress,
    this.showGrid = true,
    this.showLabels = true,
    this.samples = 100,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 40.0;
    final graphWidth = size.width - padding * 2;
    final graphHeight = size.height - padding * 2;
    final graphOrigin = Offset(padding, padding + graphHeight);

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, graphOrigin, graphWidth, graphHeight);
    }

    // Draw axes
    _drawAxes(canvas, graphOrigin, graphWidth, graphHeight);

    // Draw curves
    for (final curveData in curves) {
      _drawCurve(
        canvas,
        curveData,
        graphOrigin,
        graphWidth,
        graphHeight,
      );
    }

    // Draw current progress indicator
    if (currentProgress != null) {
      _drawProgressIndicator(
        canvas,
        graphOrigin,
        graphWidth,
        graphHeight,
      );
    }
  }

  void _drawGrid(Canvas canvas, Offset origin, double width, double height) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Vertical grid lines
    for (int i = 0; i <= 10; i++) {
      final x = origin.dx + (i / 10) * width;
      canvas.drawLine(
        Offset(x, origin.dy),
        Offset(x, origin.dy - height),
        gridPaint,
      );
    }

    // Horizontal grid lines
    for (int i = 0; i <= 10; i++) {
      final y = origin.dy - (i / 10) * height;
      canvas.drawLine(
        Offset(origin.dx, y),
        Offset(origin.dx + width, y),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Offset origin, double width, double height) {
    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // X-axis (time)
    canvas.drawLine(
      origin,
      Offset(origin.dx + width, origin.dy),
      axisPaint,
    );

    // Y-axis (value)
    canvas.drawLine(
      origin,
      Offset(origin.dx, origin.dy - height),
      axisPaint,
    );

    // Labels
    if (showLabels) {
      final textStyle = TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 8,
      );

      // X-axis labels (0.0, 0.5, 1.0)
      for (double value in [0.0, 0.5, 1.0]) {
        final x = origin.dx + value * width;
        final textPainter = TextPainter(
          text: TextSpan(text: value.toStringAsFixed(1), style: textStyle),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, origin.dy + 4),
        );
      }

      // Y-axis labels (0.0, 0.5, 1.0)
      for (double value in [0.0, 0.5, 1.0]) {
        final y = origin.dy - value * height;
        final textPainter = TextPainter(
          text: TextSpan(text: value.toStringAsFixed(1), style: textStyle),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(origin.dx - textPainter.width - 4, y - textPainter.height / 2),
        );
      }
    }
  }

  void _drawCurve(
    Canvas canvas,
    CurveData curveData,
    Offset origin,
    double width,
    double height,
  ) {
    final path = ui.Path();
    final paint = Paint()
      ..color = curveData.color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    bool isFirst = true;
    for (int i = 0; i <= samples; i++) {
      final t = i / samples;
      final value = curveData.curve.transform(t);

      final x = origin.dx + t * width;
      final y = origin.dy - value * height;

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawProgressIndicator(
    Canvas canvas,
    Offset origin,
    double width,
    double height,
  ) {
    if (currentProgress == null) return;

    final progress = currentProgress!.clamp(0.0, 1.0);
    final x = origin.dx + progress * width;

    final indicatorPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Vertical line
    canvas.drawLine(
      Offset(x, origin.dy),
      Offset(x, origin.dy - height),
      indicatorPaint,
    );

    // Get value at current progress (from first curve)
    if (curves.isNotEmpty) {
      final value = curves.first.curve.transform(progress);
      final y = origin.dy - value * height;

      // Draw point
      final pointPaint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);

      // Draw value label
      final textPainter = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(2),
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + 4, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_CurvePainter oldDelegate) {
    return oldDelegate.curves != curves ||
        oldDelegate.currentProgress != currentProgress ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.showLabels != showLabels;
  }
}

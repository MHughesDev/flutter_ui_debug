import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Frame-Stable Anchor Graph: Sparkline showing anchor position over frames.
///
/// Displays a small graph showing anchor position stability over time.
/// - Flat line = stable anchor (good)
/// - Noise/jitter = anchor drift (bug)
///
/// This helps identify anchor stability issues that might not be obvious
/// from single-frame snapshots.
class AnchorStabilityGraph extends StatefulWidget {
  /// History of anchor positions (one per frame)
  final List<Offset> anchorHistory;

  /// Optional label for the graph
  final String? label;

  /// Width of the graph
  final double width;

  /// Height of the graph
  final double height;

  const AnchorStabilityGraph({
    super.key,
    required this.anchorHistory,
    this.label,
    this.width = 120,
    this.height = 30,
  });

  @override
  State<AnchorStabilityGraph> createState() => _AnchorStabilityGraphState();
}

class _AnchorStabilityGraphState extends State<AnchorStabilityGraph> {
  @override
  Widget build(BuildContext context) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.anchorStabilityGraph)) {
      return const SizedBox.shrink();
    }

    if (widget.anchorHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: _AnchorGraphPainter(
          anchorHistory: widget.anchorHistory,
          label: widget.label,
        ),
        size: Size(widget.width, widget.height),
      ),
    );
  }
}

/// Painter for drawing the anchor stability graph
class _AnchorGraphPainter extends CustomPainter {
  final List<Offset> anchorHistory;
  final String? label;

  _AnchorGraphPainter({
    required this.anchorHistory,
    this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (anchorHistory.isEmpty) return;

    // Calculate bounds for normalization
    final xValues = anchorHistory.map((p) => p.dx).toList();
    final yValues = anchorHistory.map((p) => p.dy).toList();

    final minX = xValues.reduce(math.min);
    final maxX = xValues.reduce(math.max);
    final minY = yValues.reduce(math.min);
    final maxY = yValues.reduce(math.max);

    final xRange = (maxX - minX).abs();
    final yRange = (maxY - minY).abs();

    // Use larger range for normalization to show relative movement
    final range = math.max(math.max(xRange, yRange), 1.0); // At least 1.0 to avoid division by zero

    // Draw background
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(2),
      ),
      bgPaint,
    );

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final centerY = size.height / 2;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      gridPaint,
    );

    // Draw X-axis (horizontal position) line
    final xPath = Path();
    final xPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    bool isFirst = true;
    for (int i = 0; i < anchorHistory.length; i++) {
      final x = (i / (anchorHistory.length - 1)) * size.width;
      final normalizedX = (anchorHistory[i].dx - minX) / range;
      final y = size.height - (normalizedX * size.height);
      
      if (isFirst) {
        xPath.moveTo(x, y);
        isFirst = false;
      } else {
        xPath.lineTo(x, y);
      }
    }
    canvas.drawPath(xPath, xPaint);

    // Draw Y-axis (vertical position) line
    final yPath = Path();
    final yPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    isFirst = true;
    for (int i = 0; i < anchorHistory.length; i++) {
      final x = (i / (anchorHistory.length - 1)) * size.width;
      final normalizedY = (anchorHistory[i].dy - minY) / range;
      final y = size.height - (normalizedY * size.height);
      
      if (isFirst) {
        yPath.moveTo(x, y);
        isFirst = false;
      } else {
        yPath.lineTo(x, y);
      }
    }
    canvas.drawPath(yPath, yPaint);

    // Draw label if provided
    if (label != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, const Offset(2, 2));
    }

    // Draw stability indicator
    final stability = _calculateStability();
    final stabilityColor = stability < 0.1
        ? Colors.green
        : (stability < 1.0 ? Colors.yellow : Colors.red);
    
    final indicatorPaint = Paint()
      ..color = stabilityColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width - 6, 6),
      3,
      indicatorPaint,
    );
  }

  /// Calculate stability metric (lower = more stable)
  double _calculateStability() {
    if (anchorHistory.length < 2) return 0.0;

    double totalDelta = 0.0;
    for (int i = 1; i < anchorHistory.length; i++) {
      final delta = (anchorHistory[i] - anchorHistory[i - 1]).distance;
      totalDelta += delta;
    }

    return totalDelta / (anchorHistory.length - 1);
  }

  @override
  bool shouldRepaint(_AnchorGraphPainter oldDelegate) {
    return anchorHistory != oldDelegate.anchorHistory ||
        label != oldDelegate.label;
  }
}

/// Helper class for tracking anchor position history.
///
/// Tracks anchor positions frame-by-frame to build the stability graph.
class AnchorHistoryTracker {
  final List<Offset> _history = [];
  final int _maxHistoryLength;

  AnchorHistoryTracker({int maxHistoryLength = 100})
      : _maxHistoryLength = maxHistoryLength;

  /// Add a new anchor position (called each frame)
  void addPosition(Offset position) {
    _history.add(position);
    if (_history.length > _maxHistoryLength) {
      _history.removeAt(0);
    }
  }

  /// Get the current history
  List<Offset> get history => List.unmodifiable(_history);

  /// Clear the history
  void clear() {
    _history.clear();
  }

  /// Calculate stability metric (standard deviation of deltas)
  double calculateStability() {
    if (_history.length < 2) return 0.0;

    final deltas = <double>[];
    for (int i = 1; i < _history.length; i++) {
      final delta = (_history[i] - _history[i - 1]).distance;
      deltas.add(delta);
    }

    if (deltas.isEmpty) return 0.0;

    final mean = deltas.reduce((a, b) => a + b) / deltas.length;
    final variance = deltas
        .map((d) => (d - mean) * (d - mean))
        .reduce((a, b) => a + b) /
        deltas.length;
    return math.sqrt(variance);
  }
}

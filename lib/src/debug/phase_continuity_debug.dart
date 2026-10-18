import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;
import 'animation_phase_metadata.dart';

/// Phase Continuity Debug Painter: Measures anchor delta at phase boundaries.
///
/// Displays a color-coded background tint:
/// - Clear (0px delta)
/// - Yellow (<2px delta)
/// - Red (>=2px delta)
///
/// This makes anchor drift at phase transitions immediately visible.
class PhaseContinuityDebugPainter extends CustomPainter {
  /// List of phase metadata for the animation
  final List<AnimationPhaseMetadata> phases;

  /// Current animation progress (0.0 to 1.0)
  final double currentProgress;

  /// Anchor delta at each phase boundary (keyed by boundary progress)
  final Map<double, double> boundaryDeltas;

  /// Screen size for full-screen background
  final Size screenSize;

  /// Warning threshold (yellow) in pixels
  static const double warningThreshold = 2.0;

  PhaseContinuityDebugPainter({
    required this.phases,
    required this.currentProgress,
    required this.boundaryDeltas,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.phaseContinuity)) {
      return;
    }

    // Find current phase
    final currentPhase = phases.firstWhere(
      (phase) => phase.containsProgress(currentProgress),
      orElse: () => phases.last,
    );

    // Check if we're near a phase boundary
    for (final phase in phases) {
      final boundaryProgress = phase.startProgress;
      final distanceToBoundary = (currentProgress - boundaryProgress).abs();

      // Show background tint when near boundary (within 2% of boundary)
      if (distanceToBoundary < 0.02 && boundaryDeltas.containsKey(boundaryProgress)) {
        final delta = boundaryDeltas[boundaryProgress]!;
        _drawBackgroundTint(canvas, delta, screenSize);
      }
    }

    // Also show tint if we're at the start of current phase
    final distanceToPhaseStart = (currentProgress - currentPhase.startProgress).abs();
    if (distanceToPhaseStart < 0.02 &&
        boundaryDeltas.containsKey(currentPhase.startProgress)) {
      final delta = boundaryDeltas[currentPhase.startProgress]!;
      _drawBackgroundTint(canvas, delta, screenSize);
    }
  }

  void _drawBackgroundTint(Canvas canvas, double delta, Size screenSize) {
    Color tintColor;
    double opacity;

    if (delta < 0.1) {
      // Clear (no tint) for very small deltas
      return;
    } else if (delta < warningThreshold) {
      // Yellow for warning threshold
      tintColor = Colors.yellow;
      opacity = 0.3;
    } else {
      // Red for critical threshold
      tintColor = Colors.red;
      opacity = 0.4;
    }

    final paint = Paint()
      ..color = tintColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Draw full-screen tint
    canvas.drawRect(
      Rect.fromLTWH(0, 0, screenSize.width, screenSize.height),
      paint,
    );

    // Draw delta label at top-center
    final text = 'Δ${delta.toStringAsFixed(2)}px at boundary';
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

    final x = screenSize.width / 2 - textPainter.width / 2;
    final y = 100.0;

    // Draw background for text
    final backgroundRect = Rect.fromLTWH(
      x - 4,
      y - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(backgroundRect, const Radius.circular(4)),
      backgroundPaint,
    );

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(PhaseContinuityDebugPainter oldDelegate) {
    return oldDelegate.currentProgress != currentProgress ||
        oldDelegate.boundaryDeltas != boundaryDeltas ||
        oldDelegate.screenSize != screenSize ||
        oldDelegate.phases.length != phases.length;
  }
}

/// Widget wrapper for Phase Continuity Debug Visualization.
class PhaseContinuityDebug extends StatelessWidget {
  /// List of phase metadata for the animation
  final List<AnimationPhaseMetadata> phases;

  /// Current animation progress (0.0 to 1.0)
  final double currentProgress;

  /// Anchor delta at each phase boundary (keyed by boundary progress)
  final Map<double, double> boundaryDeltas;

  const PhaseContinuityDebug({
    super.key,
    required this.phases,
    required this.currentProgress,
    required this.boundaryDeltas,
  });

  @override
  Widget build(BuildContext context) {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.phaseContinuity)) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    return CustomPaint(
      painter: PhaseContinuityDebugPainter(
        phases: phases,
        currentProgress: currentProgress,
        boundaryDeltas: boundaryDeltas,
        screenSize: screenSize,
      ),
      size: Size.infinite,
    );
  }
}

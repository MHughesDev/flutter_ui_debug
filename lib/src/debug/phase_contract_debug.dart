import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;
import 'animation_phase_metadata.dart';
import 'ui_debug_severity.dart';

/// Phase Contract Debug Painter: Displays floating labels at phase boundaries.
///
/// Shows expected vs observed transforms with severity indicators.
/// This makes phase contract violations immediately visible in screen recordings.
class PhaseContractDebugPainter extends CustomPainter {
  /// List of phase metadata for the animation
  final List<AnimationPhaseMetadata> phases;

  /// Current animation progress (0.0 to 1.0)
  final double currentProgress;

  /// Current transform state
  final bool hasTranslation;
  final bool hasScale;
  final bool hasRotation;

  /// Screen size for positioning labels
  final Size screenSize;

  /// Label font size
  final double fontSize;

  PhaseContractDebugPainter({
    required this.phases,
    required this.currentProgress,
    required this.hasTranslation,
    required this.hasScale,
    required this.hasRotation,
    required this.screenSize,
    this.fontSize = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.phaseContracts)) {
      return;
    }

    // Find current phase
    final currentPhase = phases.firstWhere(
      (phase) => phase.containsProgress(currentProgress),
      orElse: () => phases.last,
    );

    // Check for violations
    final violation = currentPhase.checkViolation(
      hasTranslation: hasTranslation,
      hasScale: hasScale,
      hasRotation: hasRotation,
    );

    // Draw phase boundary labels
    for (final phase in phases) {
      // Only show label near phase boundaries (within 5% of boundary)
      final boundaryProgress = phase.startProgress;
      final distanceToBoundary = (currentProgress - boundaryProgress).abs();
      if (distanceToBoundary < 0.05) {
        _drawPhaseBoundaryLabel(
          canvas,
          phase,
          boundaryProgress,
          screenSize,
        );
      }
    }

    // Draw current phase label
    _drawCurrentPhaseLabel(
      canvas,
      currentPhase,
      violation,
      screenSize,
    );
  }

  void _drawPhaseBoundaryLabel(
    Canvas canvas,
    AnimationPhaseMetadata phase,
    double boundaryProgress,
    Size screenSize,
  ) {
    final text = '${phase.name} Boundary';
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
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

    // Position label at top-center of screen
    final x = screenSize.width / 2 - textPainter.width / 2;
    final y = 20.0;

    // Draw background
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

  void _drawCurrentPhaseLabel(
    Canvas canvas,
    AnimationPhaseMetadata phase,
    UIDebugSeverity? violation,
    Size screenSize,
  ) {
    final allowedTransforms = <String>[];
    if (phase.hasTranslation) allowedTransforms.add('T');
    if (phase.hasScale) allowedTransforms.add('S');
    if (phase.hasRotation) allowedTransforms.add('R');

    final observedTransforms = <String>[];
    if (hasTranslation) observedTransforms.add('T');
    if (hasScale) observedTransforms.add('S');
    if (hasRotation) observedTransforms.add('R');

    final text = 'Phase: ${phase.name}\n'
        'Allowed: [${allowedTransforms.join(', ')}]\n'
        'Observed: [${observedTransforms.join(', ')}]';

    final severityColor = violation != null
        ? Color(violation.colorValue)
        : Colors.green;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: violation != null ? Colors.white : Colors.green,
          fontSize: fontSize,
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

    // Position label at top-right of screen
    final x = screenSize.width - textPainter.width - 20;
    final y = 60.0;

    // Draw background with severity color
    final backgroundRect = Rect.fromLTWH(
      x - 4,
      y - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    final backgroundPaint = Paint()
      ..color = severityColor.withValues(alpha: violation != null ? 0.8 : 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(backgroundRect, const Radius.circular(4)),
      backgroundPaint,
    );

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(PhaseContractDebugPainter oldDelegate) {
    return oldDelegate.currentProgress != currentProgress ||
        oldDelegate.hasTranslation != hasTranslation ||
        oldDelegate.hasScale != hasScale ||
        oldDelegate.hasRotation != hasRotation ||
        oldDelegate.phases.length != phases.length ||
        oldDelegate.screenSize != screenSize;
  }
}

/// Widget wrapper for Phase Contract Debug Visualization.
class PhaseContractDebug extends StatelessWidget {
  /// List of phase metadata for the animation
  final List<AnimationPhaseMetadata> phases;

  /// Current animation progress (0.0 to 1.0)
  final double currentProgress;

  /// Current transform state
  final bool hasTranslation;
  final bool hasScale;
  final bool hasRotation;

  const PhaseContractDebug({
    super.key,
    required this.phases,
    required this.currentProgress,
    required this.hasTranslation,
    required this.hasScale,
    required this.hasRotation,
  });

  @override
  Widget build(BuildContext context) {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.phaseContracts)) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    return CustomPaint(
      painter: PhaseContractDebugPainter(
        phases: phases,
        currentProgress: currentProgress,
        hasTranslation: hasTranslation,
        hasScale: hasScale,
        hasRotation: hasRotation,
        screenSize: screenSize,
      ),
      size: Size.infinite,
    );
  }
}

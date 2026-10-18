/// Global UI Debug Mode Configuration
/// 
/// This file contains the single source of truth for UI debug mode across the entire application.
/// When enabled, this mode provides visual debugging aids including:
/// - Container border highlighting
/// - Position and relative position tracking
/// - Animation trail visualization
/// - Color-coded debug overlays
/// - Shape outline detection (circles, ovals) with rotation indicators
/// - Tangent lines for curved animation paths
/// - Transform matrix visualization (scale, rotation, translation)
/// - Velocity vectors showing movement direction and speed
/// - Anchor/pivot point markers for transform origins
/// - Curvature indicators showing curve sharpness and inflection points
/// - Bounding box visualization (render bounds vs layout bounds)
/// - Phase transition markers for multi-phase animations
/// - Normal vectors perpendicular to curved surfaces
/// - Acceleration indicators (accelerating vs decelerating)
/// - Grid alignment guides for widget alignment
/// - Collision boundary detection for overlapping widgets
/// - Path smoothness analysis (smooth vs rough segments)
/// - Constraint visualization (satisfied vs violated constraints)
/// 
/// To enable/disable debug mode, change the value of [kUIDebugMode] below.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Global UI Debug Mode flag
/// 
/// When set to `true`:
/// - All containers display colored borders indicating their boundaries
/// - Position tracking is enabled for animated widgets
/// - Animation trails are visualized with color-coded paths
/// - Relative position information is displayed
/// 
/// When set to `false`:
/// - All debug visualizations are disabled
/// - No performance overhead from debug tracking
/// - Production-ready UI appearance
bool kUIDebugMode = true;

/// Debug color scheme for visual debugging
/// 
/// These colors are used consistently across all debug visualizations
/// to help identify different types of UI elements and their states.
class UIDebugColors {
  UIDebugColors._();

  /// Red: Static container borders
  /// Used to highlight the boundaries of all containers in the widget tree
  static const containerBorder = Color(0xFFFF0000);

  /// Blue: Animated widget position trails
  /// Shows the movement path of animated widgets over time
  static const animationTrail = Color(0xFF0000FF);

  /// Green: Start position markers
  /// Indicates the initial position of animated elements
  static const startPosition = Color(0xFF00FF00);

  /// Cyan: End position markers
  /// Indicates the final position of animated elements
  static const endPosition = Color(0xFF00FFFF);

  /// Purple: Container expansion trails
  /// Shows how containers grow or shrink during animations
  static const containerTrail = Color(0xFF800080);

  /// Orange: Icon position trails
  /// Tracks the movement of icons within animated containers
  static const iconTrail = Color(0xFFFFA500);

  /// Pink: Indicator box trails
  /// Shows the path of selection indicators and highlight boxes
  static const indicatorTrail = Color(0xFFFFC0CB);

  /// Yellow: Intermediate position markers
  /// Marks key points along animation paths
  static const intermediatePosition = Color(0xFFFFFF00);

  // Shape & Geometry Debug Colors

  /// Teal: Shape outlines (circles, ovals, rectangles)
  /// Shows the actual outline of geometric shapes
  static const shapeOutline = Color(0xFF00CED1);

  /// Magenta: Rotation indicators
  /// Shows rotation angle and axis for transformed widgets
  static const rotationIndicator = Color(0xFFFF00FF);

  /// Lime: Tangent lines
  /// Shows direction of movement along curved paths
  static const tangentLine = Color(0xFF00FF00);

  /// Orange: Transform indicators
  /// Shows scale, rotation, and translation information
  static const transformIndicator = Color(0xFFFFA500);

  /// Yellow: Velocity vectors
  /// Shows direction and speed of movement
  static const velocityVector = Color(0xFFFFFF00);

  /// Purple: Anchor/pivot points
  /// Shows where transforms originate (scale/rotation center)
  static const anchorPoint = Color(0xFF800080);

  // Medium Priority Debug Colors

  /// Brown: Curvature indicators
  /// Shows curve sharpness and inflection points
  static const curvatureIndicator = Color(0xFF8B4513);

  /// Light Blue: Bounding box visualization
  /// Shows render bounds vs layout bounds
  static const boundingBox = Color(0xFF87CEEB);

  /// White: Phase transition markers
  /// Marks boundaries between animation phases
  static const phaseTransition = Color(0xFFFFFFFF);

  /// Aqua: Normal vectors
  /// Shows surface normals perpendicular to curved paths
  static const normalVector = Color(0xFF00FFFF);

  /// Red-Orange: Acceleration indicators
  /// Shows where animation is accelerating (green) or decelerating (red)
  static const accelerationPositive = Color(0xFF00FF00); // Green for acceleration
  static const accelerationNegative = Color(0xFFFF4500); // Red-Orange for deceleration

  // Low Priority Debug Colors

  /// Gray: Grid alignment guides
  /// Shows alignment to other widgets and screen edges
  static const alignmentGuide = Color(0xFF808080);

  /// Dark Red: Collision boundaries
  /// Shows where widgets might collide or overlap
  static const collisionBoundary = Color(0xFF8B0000);

  /// Light Green: Path smoothness (smooth areas)
  /// Indicates smooth animation segments
  static const pathSmooth = Color(0xFF90EE90);

  /// Dark Orange: Path smoothness (rough areas)
  /// Indicates stuttering or jumpy segments
  static const pathRough = Color(0xFFFF8C00);

  /// Light Blue: Constraint visualization (satisfied)
  /// Shows constraints that are being met
  static const constraintSatisfied = Color(0xFFADD8E6);

  /// Dark Red: Constraint visualization (violated)
  /// Shows constraints that are being violated
  static const constraintViolated = Color(0xFFDC143C);
}

/// Debug visualization configuration
class UIDebugVisualizationConfig {
  UIDebugVisualizationConfig._();

  /// Border width for container highlighting
  static const double containerBorderWidth = 1.0;

  /// Trail line width for animation paths
  static const double trailLineWidth = 2.0;

  /// Marker size for position indicators
  static const double positionMarkerSize = 4.0;

  /// Maximum number of trail points to track (for performance)
  static const int maxTrailPoints = 50;

  /// Minimum distance between trail points (prevents duplicate tracking)
  static const double minTrailPointDistance = 2.0;

  /// Opacity for trail lines
  static const double trailOpacity = 0.6;

  /// Opacity for position markers
  static const double markerOpacity = 0.9;

  // Enhanced Debug Visualization Config

  /// Length of tangent lines (in pixels)
  static const double tangentLineLength = 20.0;

  /// Length of velocity vectors (base length, scaled by speed)
  static const double velocityVectorBaseLength = 15.0;

  /// Size of anchor point markers
  static const double anchorPointSize = 6.0;

  /// Size of rotation indicator arc radius
  static const double rotationArcRadius = 30.0;

  /// Length of rotation indicator line
  static const double rotationLineLength = 25.0;

  /// Spacing between tangent lines along path (every N points)
  static const int tangentLineSpacing = 5;

  /// Minimum points required to show tangent lines
  static const int minPointsForTangents = 3;

  // Medium Priority Debug Config

  /// Length of normal vectors (in pixels)
  static const double normalVectorLength = 15.0;

  /// Length of acceleration indicator arrows (base length)
  static const double accelerationArrowBaseLength = 12.0;

  /// Radius of curvature circle size multiplier
  static const double curvatureCircleMultiplier = 0.5;

  /// Minimum curvature value to show indicator
  static const double minCurvatureThreshold = 0.01;

  /// Maximum curvature value for color mapping
  static const double maxCurvatureValue = 1.0;

  /// Spacing for phase transition markers (vertical lines)
  static const double phaseMarkerLineLength = 40.0;

  /// Width of bounding box lines
  static const double boundingBoxLineWidth = 1.5;

  /// Spacing between bounding box dashes
  static const double boundingBoxDashSpacing = 4.0;

  // Low Priority Debug Config

  /// Grid alignment guide line length
  static const double alignmentGuideLength = 100.0;

  /// Grid alignment guide spacing (for grid patterns)
  static const double alignmentGridSpacing = 20.0;

  /// Collision boundary opacity
  static const double collisionBoundaryOpacity = 0.3;

  /// Path smoothness analysis window size (number of points to analyze)
  static const int smoothnessWindowSize = 5;

  /// Path smoothness threshold (below this = smooth, above = rough)
  static const double smoothnessThreshold = 2.0;

  /// Constraint visualization line width
  static const double constraintLineWidth = 2.0;

  /// Minimum constraint violation to show indicator
  static const double minConstraintViolation = 1.0;
}

/// Centralized position tracker for debug mode animation trails.
/// Handles all position history tracking logic.
class UIDebugPositionTracker {
  final List<Offset> _positionHistory = [];

  /// Get the current position history (read-only)
  List<Offset> get positionHistory => List.unmodifiable(_positionHistory);

  /// Track a new position. Only adds if position changed significantly.
  /// Returns true if position was added, false otherwise.
  bool track(Offset position) {
    if (!kUIDebugMode) return false;

    if (_positionHistory.isEmpty ||
        (_positionHistory.last - position).distance >
            UIDebugVisualizationConfig.minTrailPointDistance) {
      _positionHistory.add(position);
      if (_positionHistory.length > UIDebugVisualizationConfig.maxTrailPoints) {
        _positionHistory.removeAt(0);
      }
      return true;
    }
    return false;
  }

  /// Clear all tracked positions
  void clear() {
    if (kUIDebugMode) {
      _positionHistory.clear();
    }
  }

  /// Check if there are enough points to draw a trail
  bool get canDrawTrail => kUIDebugMode && _positionHistory.length > 1;
}

/// Centralized helper functions for debug mode UI operations.
///
/// For new debug features, use the capability-based system:
/// ```dart
/// import 'package:flutter_ui_debug/flutter_ui_debug.dart';
///
/// if (UIDebugConfig.isEnabled(UIDebugCapability.flightRecorder)) {
///   // Render debug feature
/// }
/// ```
///
/// Existing methods continue to use kUIDebugMode for backward compatibility.
class UIDebugHelpers {
  UIDebugHelpers._();

  /// Get border decoration for containers when debug mode is enabled.
  /// Returns null when debug mode is disabled (no performance impact).
  static BoxDecoration? getBorderDecoration() {
    if (!kUIDebugMode) return null;
    return BoxDecoration(
      border: Border.all(
        color: UIDebugColors.containerBorder,
        width: UIDebugVisualizationConfig.containerBorderWidth,
      ),
    );
  }

  /// Get border decoration that can be merged with existing decoration.
  static Border? getBorder() {
    if (!kUIDebugMode) return null;
    return Border.all(
      color: UIDebugColors.containerBorder,
      width: UIDebugVisualizationConfig.containerBorderWidth,
    );
  }

  /// Wrap a widget with debug border container when debug mode is enabled.
  /// Returns the original widget when debug mode is disabled.
  static Widget wrapWithDebugBorder(Widget child) {
    if (!kUIDebugMode) return child;
    return Container(
      decoration: getBorderDecoration(),
      child: child,
    );
  }

  /// Create a trail painter widget for a single path.
  /// Returns empty widget when debug mode is disabled or insufficient points.
  static Widget createTrailPainter({
    required List<Offset> path,
    required Size screenSize,
    Color? trailColor,
    bool showStartMarker = true,
    bool showEndMarker = true,
    bool showIntermediateMarkers = true,
  }) {
    if (!kUIDebugMode || path.length < 2) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugTrailPainter(
            path: path,
            trailColor: trailColor ?? UIDebugColors.animationTrail,
            showStartMarker: showStartMarker,
            showEndMarker: showEndMarker,
            showIntermediateMarkers: showIntermediateMarkers,
          ),
        ),
      ),
    );
  }

  /// Create a menu trail painter widget for multiple paths (container, icons, indicator).
  /// Returns empty widget when debug mode is disabled.
  static Widget createMenuTrailPainter({
    required Size screenSize,
    required List<Offset> menuContainerPath,
    required Map<int, List<Offset>> iconPaths,
    required List<Offset> indicatorBoxPath,
  }) {
    if (!kUIDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugMenuTrailPainter(
            menuContainerPath: menuContainerPath,
            iconPaths: iconPaths,
            indicatorBoxPath: indicatorBoxPath,
          ),
        ),
      ),
    );
  }

  /// Create a shape outline painter widget for circles/ovals.
  /// Returns empty widget when debug mode is disabled.
  static Widget createShapeOutlinePainter({
    required Size screenSize,
    required Offset center,
    required Size shapeSize,
    double? rotationAngle,
    bool isCircle = false,
  }) {
    if (!kUIDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugShapeOutlinePainter(
            center: center,
            shapeSize: shapeSize,
            rotationAngle: rotationAngle,
            isCircle: isCircle,
          ),
        ),
      ),
    );
  }

  /// Create a tangent line painter for curved paths.
  /// Returns empty widget when debug mode is disabled.
  static Widget createTangentLinePainter({
    required List<Offset> path,
    required Size screenSize,
  }) {
    if (!kUIDebugMode || path.length < UIDebugVisualizationConfig.minPointsForTangents) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugTangentLinePainter(path: path),
        ),
      ),
    );
  }

  /// Create a transform visualization painter.
  /// Returns empty widget when debug mode is disabled.
  static Widget createTransformPainter({
    required Size screenSize,
    required Offset position,
    required Size size,
    Matrix4? transform,
    double? scaleX,
    double? scaleY,
    double? rotationAngle,
    Offset? pivotPoint,
  }) {
    if (!kUIDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugTransformPainter(
            position: position,
            size: size,
            transform: transform,
            scaleX: scaleX,
            scaleY: scaleY,
            rotationAngle: rotationAngle,
            pivotPoint: pivotPoint,
          ),
        ),
      ),
    );
  }

  /// Create a velocity vector painter for animation paths.
  /// Returns empty widget when debug mode is disabled.
  static Widget createVelocityVectorPainter({
    required List<Offset> path,
    required Size screenSize,
  }) {
    if (!kUIDebugMode || path.length < 2) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugVelocityVectorPainter(path: path),
        ),
      ),
    );
  }

  /// Create an anchor point marker painter.
  /// Returns empty widget when debug mode is disabled.
  static Widget createAnchorPointPainter({
    required Size screenSize,
    required Offset anchorPoint,
    String? label,
  }) {
    if (!kUIDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugAnchorPointPainter(
            anchorPoint: anchorPoint,
            label: label,
          ),
        ),
      ),
    );
  }

  /// Create a curvature indicator painter for curved paths.
  /// Returns empty widget when debug mode is disabled.
  static Widget createCurvaturePainter({
    required List<Offset> path,
    required Size screenSize,
  }) {
    if (!kUIDebugMode || path.length < 3) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugCurvaturePainter(path: path),
        ),
      ),
    );
  }

  /// Create a bounding box visualization painter.
  /// Returns empty widget when debug mode is disabled.
  static Widget createBoundingBoxPainter({
    required Size screenSize,
    required Rect renderBounds,
    Rect? layoutBounds,
  }) {
    if (!kUIDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugBoundingBoxPainter(
            renderBounds: renderBounds,
            layoutBounds: layoutBounds,
          ),
        ),
      ),
    );
  }

  /// Create a phase transition marker painter.
  /// Returns empty widget when debug mode is disabled.
  static Widget createPhaseTransitionPainter({
    required Size screenSize,
    required List<Offset> path,
    required List<double> phaseBoundaries, // e.g., [0.4, 0.6] for 40% and 60%
  }) {
    if (!kUIDebugMode || path.isEmpty || phaseBoundaries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugPhaseTransitionPainter(
            path: path,
            phaseBoundaries: phaseBoundaries,
          ),
        ),
      ),
    );
  }

  /// Create a normal vector painter for curved surfaces.
  /// Returns empty widget when debug mode is disabled.
  static Widget createNormalVectorPainter({
    required List<Offset> path,
    required Size screenSize,
  }) {
    if (!kUIDebugMode || path.length < 3) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugNormalVectorPainter(path: path),
        ),
      ),
    );
  }

  /// Create an acceleration indicator painter.
  /// Returns empty widget when debug mode is disabled.
  static Widget createAccelerationPainter({
    required List<Offset> path,
    required Size screenSize,
  }) {
    if (!kUIDebugMode || path.length < 3) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugAccelerationPainter(path: path),
        ),
      ),
    );
  }

  /// Create a grid alignment guide painter.
  /// Returns empty widget when debug mode is disabled.
  static Widget createAlignmentGuidePainter({
    required Size screenSize,
    required Offset widgetPosition,
    required Size widgetSize,
    List<Offset>? alignmentTargets,
    bool showScreenEdges = true,
  }) {
    if (!kUIDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugAlignmentGuidePainter(
            widgetPosition: widgetPosition,
            widgetSize: widgetSize,
            screenSize: screenSize,
            alignmentTargets: alignmentTargets,
            showScreenEdges: showScreenEdges,
          ),
        ),
      ),
    );
  }

  /// Create a collision boundary painter.
  /// Returns empty widget when debug mode is disabled.
  static Widget createCollisionBoundaryPainter({
    required Size screenSize,
    required List<Rect> widgetBounds,
  }) {
    if (!kUIDebugMode || widgetBounds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugCollisionBoundaryPainter(
            widgetBounds: widgetBounds,
          ),
        ),
      ),
    );
  }

  /// Create a path smoothness analysis painter.
  /// Returns empty widget when debug mode is disabled.
  static Widget createPathSmoothnessPainter({
    required List<Offset> path,
    required Size screenSize,
  }) {
    if (!kUIDebugMode || path.length < UIDebugVisualizationConfig.smoothnessWindowSize) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugPathSmoothnessPainter(path: path),
        ),
      ),
    );
  }

  /// Create a constraint visualization painter.
  /// Returns empty widget when debug mode is disabled.
  static Widget createConstraintPainter({
    required Size screenSize,
    required Rect widgetBounds,
    required BoxConstraints constraints,
  }) {
    if (!kUIDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      top: 0,
      width: screenSize.width,
      height: screenSize.height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: UIDebugConstraintPainter(
            widgetBounds: widgetBounds,
            constraints: constraints,
          ),
        ),
      ),
    );
  }
}

/// Generic trail painter for single animation paths.
/// Centralized implementation for all trail visualization.
class UIDebugTrailPainter extends CustomPainter {
  final List<Offset> path;
  final Color trailColor;
  final bool showStartMarker;
  final bool showEndMarker;
  final bool showIntermediateMarkers;

  UIDebugTrailPainter({
    required this.path,
    required this.trailColor,
    this.showStartMarker = true,
    this.showEndMarker = true,
    this.showIntermediateMarkers = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode || path.length < 2) return;

    // Draw the trail path
    final paint = Paint()
      ..color = trailColor.withValues(alpha: UIDebugVisualizationConfig.trailOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = UIDebugVisualizationConfig.trailLineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pathLine = Path();
    pathLine.moveTo(path.first.dx, path.first.dy);
    for (int i = 1; i < path.length; i++) {
      pathLine.lineTo(path[i].dx, path[i].dy);
    }
    canvas.drawPath(pathLine, paint);

    // Draw start point (green)
    if (showStartMarker) {
      final startPaint = Paint()
        ..color = UIDebugColors.startPosition.withValues(
            alpha: UIDebugVisualizationConfig.markerOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(path.first, UIDebugVisualizationConfig.positionMarkerSize,
          startPaint);
    }

    // Draw end point (cyan)
    if (showEndMarker) {
      final endPaint = Paint()
        ..color = UIDebugColors.endPosition.withValues(
            alpha: UIDebugVisualizationConfig.markerOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(path.last, UIDebugVisualizationConfig.positionMarkerSize, endPaint);
    }

    // Draw intermediate dots (yellow)
    if (showIntermediateMarkers) {
      final intermediatePaint = Paint()
        ..color = UIDebugColors.intermediatePosition.withValues(
            alpha: UIDebugVisualizationConfig.markerOpacity)
        ..style = PaintingStyle.fill;
      for (int i = 1; i < path.length - 1; i += 10) {
        canvas.drawCircle(path[i], UIDebugVisualizationConfig.positionMarkerSize / 2,
            intermediatePaint);
      }
    }
  }

  @override
  bool shouldRepaint(UIDebugTrailPainter oldDelegate) {
    return path != oldDelegate.path ||
        trailColor != oldDelegate.trailColor ||
        showStartMarker != oldDelegate.showStartMarker ||
        showEndMarker != oldDelegate.showEndMarker ||
        showIntermediateMarkers != oldDelegate.showIntermediateMarkers;
  }
}

/// Menu trail painter for complex animations with multiple paths.
/// Handles container trails, icon trails, and indicator box trails.
class UIDebugMenuTrailPainter extends CustomPainter {
  final List<Offset> menuContainerPath;
  final Map<int, List<Offset>> iconPaths;
  final List<Offset> indicatorBoxPath;

  UIDebugMenuTrailPainter({
    required this.menuContainerPath,
    required this.iconPaths,
    required this.indicatorBoxPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode) return;

    // Draw menu container trail (purple)
    if (menuContainerPath.length > 1) {
      final paint = Paint()
        ..color = UIDebugColors.containerTrail
            .withValues(alpha: UIDebugVisualizationConfig.trailOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = UIDebugVisualizationConfig.trailLineWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(menuContainerPath.first.dx, menuContainerPath.first.dy);
      for (int i = 1; i < menuContainerPath.length; i++) {
        path.lineTo(menuContainerPath[i].dx, menuContainerPath[i].dy);
      }
      canvas.drawPath(path, paint);

      // Draw start/end markers for container
      final startPaint = Paint()
        ..color = UIDebugColors.containerTrail.withValues(
            alpha: UIDebugVisualizationConfig.markerOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(menuContainerPath.first,
          UIDebugVisualizationConfig.positionMarkerSize, startPaint);

      final endPaint = Paint()
        ..color = UIDebugColors.endPosition.withValues(
            alpha: UIDebugVisualizationConfig.markerOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(menuContainerPath.last, UIDebugVisualizationConfig.positionMarkerSize,
          endPaint);
    }

    // Draw icon trails (orange for all icons)
    iconPaths.forEach((index, path) {
      if (path.length > 1) {
        final paint = Paint()
          ..color = UIDebugColors.iconTrail
              .withValues(alpha: UIDebugVisualizationConfig.trailOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = UIDebugVisualizationConfig.trailLineWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final trailPath = Path();
        trailPath.moveTo(path.first.dx, path.first.dy);
        for (int i = 1; i < path.length; i++) {
          trailPath.lineTo(path[i].dx, path[i].dy);
        }
        canvas.drawPath(trailPath, paint);

        // Draw icon position markers
        final dotPaint = Paint()
          ..color = UIDebugColors.iconTrail.withValues(
              alpha: UIDebugVisualizationConfig.markerOpacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(path.last, UIDebugVisualizationConfig.positionMarkerSize, dotPaint);
      }
    });

    // Draw indicator box trail (pink)
    if (indicatorBoxPath.length > 1) {
      final paint = Paint()
        ..color = UIDebugColors.indicatorTrail
            .withValues(alpha: UIDebugVisualizationConfig.trailOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = UIDebugVisualizationConfig.trailLineWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(indicatorBoxPath.first.dx, indicatorBoxPath.first.dy);
      for (int i = 1; i < indicatorBoxPath.length; i++) {
        path.lineTo(indicatorBoxPath[i].dx, indicatorBoxPath[i].dy);
      }
      canvas.drawPath(path, paint);

      // Draw start/end markers for indicator box
      final startPaint = Paint()
        ..color = UIDebugColors.startPosition.withValues(
            alpha: UIDebugVisualizationConfig.markerOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(indicatorBoxPath.first,
          UIDebugVisualizationConfig.positionMarkerSize, startPaint);

      final endPaint = Paint()
        ..color = UIDebugColors.endPosition.withValues(
            alpha: UIDebugVisualizationConfig.markerOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(indicatorBoxPath.last, UIDebugVisualizationConfig.positionMarkerSize,
          endPaint);
    }
  }

  @override
  bool shouldRepaint(UIDebugMenuTrailPainter oldDelegate) {
    return menuContainerPath != oldDelegate.menuContainerPath ||
        iconPaths != oldDelegate.iconPaths ||
        indicatorBoxPath != oldDelegate.indicatorBoxPath;
  }
}

/// Shape outline painter for circles and ovals.
/// Shows the actual outline and detects rotation.
class UIDebugShapeOutlinePainter extends CustomPainter {
  final Offset center;
  final Size shapeSize;
  final double? rotationAngle;
  final bool isCircle;

  UIDebugShapeOutlinePainter({
    required this.center,
    required this.shapeSize,
    this.rotationAngle,
    this.isCircle = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode) return;

    final shapePaint = Paint()
      ..color = UIDebugColors.shapeOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = UIDebugVisualizationConfig.trailLineWidth;

    // Draw shape outline
    if (isCircle) {
      final radius = shapeSize.width / 2;
      canvas.drawCircle(center, radius, shapePaint);
    } else {
      // Draw oval
      final rect = Rect.fromCenter(
        center: center,
        width: shapeSize.width,
        height: shapeSize.height,
      );
      canvas.drawOval(rect, shapePaint);
    }

    // Draw center crosshair
    final crosshairPaint = Paint()
      ..color = UIDebugColors.shapeOutline.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final crosshairSize = 8.0;
    canvas.drawLine(
      center - Offset(crosshairSize, 0),
      center + Offset(crosshairSize, 0),
      crosshairPaint,
    );
    canvas.drawLine(
      center - Offset(0, crosshairSize),
      center + Offset(0, crosshairSize),
      crosshairPaint,
    );

    // Draw rotation indicator if rotated
    if (rotationAngle != null && rotationAngle != 0) {
      final rotationPaint = Paint()
        ..color = UIDebugColors.rotationIndicator
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw rotation arc
      final arcRadius = UIDebugVisualizationConfig.rotationArcRadius;
      final arcRect = Rect.fromCircle(center: center, radius: arcRadius);
      final startAngle = 0.0;
      final sweepAngle = rotationAngle!;

      canvas.drawArc(
        arcRect,
        startAngle,
        sweepAngle,
        false,
        rotationPaint,
      );

      // Draw rotation line from center
      final lineEnd = Offset(
        center.dx + UIDebugVisualizationConfig.rotationLineLength * sweepAngle.cos,
        center.dy + UIDebugVisualizationConfig.rotationLineLength * sweepAngle.sin,
      );
      canvas.drawLine(center, lineEnd, rotationPaint);

      // Draw reference line (0° position) - dashed effect using small segments
      final referencePaint = Paint()
        ..color = UIDebugColors.rotationIndicator.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      final referenceEnd = Offset(
        center.dx + UIDebugVisualizationConfig.rotationLineLength,
        center.dy,
      );
      // Draw dashed line manually
      final dashLength = 4.0;
      final gapLength = 2.0;
      final totalLength = (referenceEnd - center).distance;
      final direction = (referenceEnd - center).normalized();
      double currentLength = 0.0;
      while (currentLength < totalLength) {
        final dashStart = center + direction * currentLength;
        final dashEnd = center + direction * (currentLength + dashLength).clamp(0.0, totalLength);
        canvas.drawLine(dashStart, dashEnd, referencePaint);
        currentLength += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(UIDebugShapeOutlinePainter oldDelegate) {
    return center != oldDelegate.center ||
        shapeSize != oldDelegate.shapeSize ||
        rotationAngle != oldDelegate.rotationAngle ||
        isCircle != oldDelegate.isCircle;
  }
}

/// Tangent line painter for curved animation paths.
/// Shows direction of movement at key points along the path.
class UIDebugTangentLinePainter extends CustomPainter {
  final List<Offset> path;

  UIDebugTangentLinePainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode || path.length < UIDebugVisualizationConfig.minPointsForTangents) {
      return;
    }

    final tangentPaint = Paint()
      ..color = UIDebugColors.tangentLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw tangent lines at regular intervals
    for (int i = 1; i < path.length - 1; i += UIDebugVisualizationConfig.tangentLineSpacing) {
      final point = path[i];
      final prevPoint = path[i - 1];
      final nextPoint = path[i + 1];

      // Calculate tangent direction (average of incoming and outgoing vectors)
      final incoming = (point - prevPoint).normalized();
      final outgoing = (nextPoint - point).normalized();
      final tangent = (incoming + outgoing).normalized();

      // Draw tangent line
      final lineStart = point - tangent * UIDebugVisualizationConfig.tangentLineLength;
      final lineEnd = point + tangent * UIDebugVisualizationConfig.tangentLineLength;

      canvas.drawLine(lineStart, lineEnd, tangentPaint);

      // Draw small circle at the point
      final pointPaint = Paint()
        ..color = UIDebugColors.tangentLine
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 2.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(UIDebugTangentLinePainter oldDelegate) {
    return path != oldDelegate.path;
  }
}

/// Transform visualization painter.
/// Shows scale, rotation, and translation information.
class UIDebugTransformPainter extends CustomPainter {
  final Offset position;
  final Size size;
  final Matrix4? transform;
  final double? scaleX;
  final double? scaleY;
  final double? rotationAngle;
  final Offset? pivotPoint;

  UIDebugTransformPainter({
    required this.position,
    required this.size,
    this.transform,
    this.scaleX,
    this.scaleY,
    this.rotationAngle,
    this.pivotPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode) return;

    final center = position + Offset(this.size.width / 2, this.size.height / 2);

    // Extract transform values if Matrix4 is provided
    double? actualScaleX = scaleX;
    double? actualScaleY = scaleY;
    double? actualRotation = rotationAngle;
    Offset? actualPivot = pivotPoint;

    if (transform != null) {
      // Extract scale from matrix
      final scale = transform!.getMaxScaleOnAxis();
      actualScaleX ??= scale;
      actualScaleY ??= scale;

      // Extract rotation from matrix (simplified - assumes 2D rotation)
      // Matrix4 rotation extraction is complex, so we use provided angle if available
    }

    // Draw scale indicators
    if (actualScaleX != null || actualScaleY != null) {
      final scalePaint = Paint()
        ..color = UIDebugColors.transformIndicator
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final baseWidth = this.size.width;
      final baseHeight = this.size.height;
      final scaledWidth = baseWidth * (actualScaleX ?? 1.0);
      final scaledHeight = baseHeight * (actualScaleY ?? 1.0);

      // Draw original size (dashed)
      final originalPaint = Paint()
        ..color = UIDebugColors.transformIndicator.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      final originalRect = Rect.fromLTWH(
        position.dx,
        position.dy,
        baseWidth,
        baseHeight,
      );
      canvas.drawRect(originalRect, originalPaint);

      // Draw scaled size (solid)
      final scaledRect = Rect.fromLTWH(
        center.dx - scaledWidth / 2,
        center.dy - scaledHeight / 2,
        scaledWidth,
        scaledHeight,
      );
      canvas.drawRect(scaledRect, scalePaint);
    }

    // Draw rotation indicator
    if (actualRotation != null && actualRotation != 0) {
      final rotationPaint = Paint()
        ..color = UIDebugColors.rotationIndicator
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final arcRadius = UIDebugVisualizationConfig.rotationArcRadius;
      final arcRect = Rect.fromCircle(center: center, radius: arcRadius);
      canvas.drawArc(
        arcRect,
        0.0,
        actualRotation,
        false,
        rotationPaint,
      );

      // Draw rotation line
      final lineEnd = Offset(
        center.dx + UIDebugVisualizationConfig.rotationLineLength * actualRotation.cos,
        center.dy + UIDebugVisualizationConfig.rotationLineLength * actualRotation.sin,
      );
      canvas.drawLine(center, lineEnd, rotationPaint);
    }

    // Draw pivot point if specified
    if (actualPivot != null) {
      final pivotPaint = Paint()
        ..color = UIDebugColors.anchorPoint
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        actualPivot,
        UIDebugVisualizationConfig.anchorPointSize,
        pivotPaint,
      );

      // Draw crosshair at pivot
      final crosshairPaint = Paint()
        ..color = UIDebugColors.anchorPoint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      final crosshairSize = UIDebugVisualizationConfig.anchorPointSize + 4.0;
      canvas.drawLine(
        actualPivot - Offset(crosshairSize, 0),
        actualPivot + Offset(crosshairSize, 0),
        crosshairPaint,
      );
      canvas.drawLine(
        actualPivot - Offset(0, crosshairSize),
        actualPivot + Offset(0, crosshairSize),
        crosshairPaint,
      );
    }
  }

  @override
  bool shouldRepaint(UIDebugTransformPainter oldDelegate) {
    return position != oldDelegate.position ||
        size != oldDelegate.size ||
        transform != oldDelegate.transform ||
        scaleX != oldDelegate.scaleX ||
        scaleY != oldDelegate.scaleY ||
        rotationAngle != oldDelegate.rotationAngle ||
        pivotPoint != oldDelegate.pivotPoint;
  }
}

/// Velocity vector painter for animation paths.
/// Shows direction and speed of movement.
class UIDebugVelocityVectorPainter extends CustomPainter {
  final List<Offset> path;

  UIDebugVelocityVectorPainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode || path.length < 2) return;

    // Draw velocity vectors at each point
    for (int i = 1; i < path.length; i++) {
      final current = path[i];
      final previous = path[i - 1];

      // Calculate velocity vector
      final velocity = current - previous;
      final speed = velocity.distance;
      final direction = velocity.normalized();

      // Skip if movement is too small
      if (speed < 0.1) continue;

      // Scale vector length by speed (with base length)
      final vectorLength = UIDebugVisualizationConfig.velocityVectorBaseLength * (1.0 + speed / 10.0);
      final vectorEnd = current + direction * vectorLength;

      // Color intensity based on speed
      final speedFactor = (speed / 50.0).clamp(0.0, 1.0);
      final vectorColor = Color.lerp(
        UIDebugColors.velocityVector.withValues(alpha: 0.3),
        UIDebugColors.velocityVector,
        speedFactor,
      )!;

      final vectorPaint = Paint()
        ..color = vectorColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      // Draw velocity vector (arrow)
      canvas.drawLine(current, vectorEnd, vectorPaint);

      // Draw arrowhead
      final arrowSize = 4.0;
      final arrowAngle = direction.direction;
      final arrowLeft = Offset(
        vectorEnd.dx - arrowSize * (arrowAngle + 2.5).cos,
        vectorEnd.dy - arrowSize * (arrowAngle + 2.5).sin,
      );
      final arrowRight = Offset(
        vectorEnd.dx - arrowSize * (arrowAngle - 2.5).cos,
        vectorEnd.dy - arrowSize * (arrowAngle - 2.5).sin,
      );

      final arrowPaint = Paint()
        ..color = vectorColor
        ..style = PaintingStyle.fill;
      final arrowPath = Path()
        ..moveTo(vectorEnd.dx, vectorEnd.dy)
        ..lineTo(arrowLeft.dx, arrowLeft.dy)
        ..lineTo(arrowRight.dx, arrowRight.dy)
        ..close();
      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(UIDebugVelocityVectorPainter oldDelegate) {
    return path != oldDelegate.path;
  }
}

/// Anchor point painter.
/// Shows where transforms originate (pivot points for scale/rotation).
class UIDebugAnchorPointPainter extends CustomPainter {
  final Offset anchorPoint;
  final String? label;

  UIDebugAnchorPointPainter({
    required this.anchorPoint,
    this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode) return;

    // Draw anchor point circle
    final anchorPaint = Paint()
      ..color = UIDebugColors.anchorPoint
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      anchorPoint,
      UIDebugVisualizationConfig.anchorPointSize,
      anchorPaint,
    );

    // Draw crosshair
    final crosshairPaint = Paint()
      ..color = UIDebugColors.anchorPoint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final crosshairSize = UIDebugVisualizationConfig.anchorPointSize + 6.0;
    canvas.drawLine(
      anchorPoint - Offset(crosshairSize, 0),
      anchorPoint + Offset(crosshairSize, 0),
      crosshairPaint,
    );
    canvas.drawLine(
      anchorPoint - Offset(0, crosshairSize),
      anchorPoint + Offset(0, crosshairSize),
      crosshairPaint,
    );

    // Draw label if provided
    if (label != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label!,
          style: TextStyle(
            color: UIDebugColors.anchorPoint,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        anchorPoint + Offset(UIDebugVisualizationConfig.anchorPointSize + 4, -textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(UIDebugAnchorPointPainter oldDelegate) {
    return anchorPoint != oldDelegate.anchorPoint || label != oldDelegate.label;
  }
}

/// Curvature indicator painter for curved animation paths.
/// Shows curve sharpness and inflection points with color-coded indicators.
class UIDebugCurvaturePainter extends CustomPainter {
  final List<Offset> path;

  UIDebugCurvaturePainter({required this.path});

  /// Calculate curvature at a point using three consecutive points.
  /// Returns curvature value (higher = sharper curve).
  double _calculateCurvature(Offset p0, Offset p1, Offset p2) {
    // Calculate vectors
    final v1 = p1 - p0;
    final v2 = p2 - p1;

    // Calculate angles
    final angle1 = v1.direction;
    final angle2 = v2.direction;

    // Calculate angle difference (curvature)
    var angleDiff = (angle2 - angle1).abs();
    if (angleDiff > math.pi) {
      angleDiff = 2 * math.pi - angleDiff;
    }

    // Normalize by distance to get curvature
    final dist1 = v1.distance;
    final dist2 = v2.distance;
    final avgDist = (dist1 + dist2) / 2;

    if (avgDist < 0.1) return 0.0;

    return angleDiff / avgDist;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode || path.length < 3) return;

    // Calculate curvature at each point
    final curvatures = <double>[];
    for (int i = 1; i < path.length - 1; i++) {
      final curvature = _calculateCurvature(path[i - 1], path[i], path[i + 1]);
      curvatures.add(curvature);
    }

    // Draw curvature indicators
    for (int i = 1; i < path.length - 1; i++) {
      final point = path[i];
      final curvature = curvatures[i - 1];

      if (curvature < UIDebugVisualizationConfig.minCurvatureThreshold) continue;

      // Normalize curvature for color mapping
      final normalizedCurvature = (curvature / UIDebugVisualizationConfig.maxCurvatureValue).clamp(0.0, 1.0);

      // Color from blue (gentle) to red (sharp)
      final color = Color.lerp(
        UIDebugColors.boundingBox, // Light blue for gentle curves
        UIDebugColors.containerBorder, // Red for sharp curves
        normalizedCurvature,
      ) ?? UIDebugColors.curvatureIndicator;

      // Draw circle showing radius of curvature
      final radius = UIDebugVisualizationConfig.curvatureCircleMultiplier / (curvature + 0.01);
      final curvaturePaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(point, radius.clamp(2.0, 20.0), curvaturePaint);

      // Draw point marker
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 2.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(UIDebugCurvaturePainter oldDelegate) {
    return path != oldDelegate.path;
  }
}

/// Bounding box visualization painter.
/// Shows render bounds vs layout bounds to identify overflow issues.
class UIDebugBoundingBoxPainter extends CustomPainter {
  final Rect renderBounds;
  final Rect? layoutBounds;

  UIDebugBoundingBoxPainter({
    required this.renderBounds,
    this.layoutBounds,
  });

  /// Draw a dashed rectangle
  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    final dashLength = UIDebugVisualizationConfig.boundingBoxDashSpacing;
    final gapLength = UIDebugVisualizationConfig.boundingBoxDashSpacing;

    // Top edge
    double x = rect.left;
    while (x < rect.right) {
      final endX = (x + dashLength).clamp(rect.left, rect.right);
      canvas.drawLine(Offset(x, rect.top), Offset(endX, rect.top), paint);
      x += dashLength + gapLength;
    }

    // Right edge
    double y = rect.top;
    while (y < rect.bottom) {
      final endY = (y + dashLength).clamp(rect.top, rect.bottom);
      canvas.drawLine(Offset(rect.right, y), Offset(rect.right, endY), paint);
      y += dashLength + gapLength;
    }

    // Bottom edge
    x = rect.left;
    while (x < rect.right) {
      final endX = (x + dashLength).clamp(rect.left, rect.right);
      canvas.drawLine(Offset(x, rect.bottom), Offset(endX, rect.bottom), paint);
      x += dashLength + gapLength;
    }

    // Left edge
    y = rect.top;
    while (y < rect.bottom) {
      final endY = (y + dashLength).clamp(rect.top, rect.bottom);
      canvas.drawLine(Offset(rect.left, y), Offset(rect.left, endY), paint);
      y += dashLength + gapLength;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode) return;

    // Draw layout bounds (if provided) - dashed blue
    if (layoutBounds != null) {
      final layoutPaint = Paint()
        ..color = UIDebugColors.boundingBox
        ..style = PaintingStyle.stroke
        ..strokeWidth = UIDebugVisualizationConfig.boundingBoxLineWidth;
      _drawDashedRect(canvas, layoutBounds!, layoutPaint);
    }

    // Draw render bounds - solid red
    final renderPaint = Paint()
      ..color = UIDebugColors.containerBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = UIDebugVisualizationConfig.boundingBoxLineWidth;
    canvas.drawRect(renderBounds, renderPaint);

    // Highlight overflow areas if render bounds exceed layout bounds
    if (layoutBounds != null) {
      final overflowPaint = Paint()
        ..color = UIDebugColors.containerBorder.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;

      // Check each edge for overflow
      if (renderBounds.left < layoutBounds!.left) {
        canvas.drawRect(
          Rect.fromLTRB(
            renderBounds.left,
            math.max(renderBounds.top, layoutBounds!.top),
            layoutBounds!.left,
            math.min(renderBounds.bottom, layoutBounds!.bottom),
          ),
          overflowPaint,
        );
      }
      if (renderBounds.right > layoutBounds!.right) {
        canvas.drawRect(
          Rect.fromLTRB(
            layoutBounds!.right,
            math.max(renderBounds.top, layoutBounds!.top),
            renderBounds.right,
            math.min(renderBounds.bottom, layoutBounds!.bottom),
          ),
          overflowPaint,
        );
      }
      if (renderBounds.top < layoutBounds!.top) {
        canvas.drawRect(
          Rect.fromLTRB(
            math.max(renderBounds.left, layoutBounds!.left),
            renderBounds.top,
            math.min(renderBounds.right, layoutBounds!.right),
            layoutBounds!.top,
          ),
          overflowPaint,
        );
      }
      if (renderBounds.bottom > layoutBounds!.bottom) {
        canvas.drawRect(
          Rect.fromLTRB(
            math.max(renderBounds.left, layoutBounds!.left),
            layoutBounds!.bottom,
            math.min(renderBounds.right, layoutBounds!.right),
            renderBounds.bottom,
          ),
          overflowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(UIDebugBoundingBoxPainter oldDelegate) {
    return renderBounds != oldDelegate.renderBounds ||
        layoutBounds != oldDelegate.layoutBounds;
  }
}

/// Phase transition marker painter.
/// Marks boundaries between animation phases with vertical lines.
class UIDebugPhaseTransitionPainter extends CustomPainter {
  final List<Offset> path;
  final List<double> phaseBoundaries; // Values 0.0 to 1.0

  UIDebugPhaseTransitionPainter({
    required this.path,
    required this.phaseBoundaries,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode || path.isEmpty || phaseBoundaries.isEmpty) return;

    final phasePaint = Paint()
      ..color = UIDebugColors.phaseTransition
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw phase boundary markers
    for (final boundary in phaseBoundaries) {
      final index = (boundary * (path.length - 1)).round().clamp(0, path.length - 1);
      if (index < path.length) {
        final point = path[index];

        // Draw vertical line
        final lineStart = point - Offset(0, UIDebugVisualizationConfig.phaseMarkerLineLength / 2);
        final lineEnd = point + Offset(0, UIDebugVisualizationConfig.phaseMarkerLineLength / 2);
        canvas.drawLine(lineStart, lineEnd, phasePaint);

        // Draw horizontal line at top
        final topLineStart = lineStart - Offset(UIDebugVisualizationConfig.phaseMarkerLineLength / 4, 0);
        final topLineEnd = lineStart + Offset(UIDebugVisualizationConfig.phaseMarkerLineLength / 4, 0);
        canvas.drawLine(topLineStart, topLineEnd, phasePaint);

        // Draw label
        final percentage = (boundary * 100).toStringAsFixed(0);
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$percentage%',
            style: TextStyle(
              color: UIDebugColors.phaseTransition,
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          topLineStart - Offset(0, textPainter.height + 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(UIDebugPhaseTransitionPainter oldDelegate) {
    return path != oldDelegate.path ||
        phaseBoundaries != oldDelegate.phaseBoundaries;
  }
}

/// Normal vector painter for curved surfaces.
/// Shows surface normals perpendicular to curved paths.
class UIDebugNormalVectorPainter extends CustomPainter {
  final List<Offset> path;

  UIDebugNormalVectorPainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode || path.length < 3) return;

    final normalPaint = Paint()
      ..color = UIDebugColors.normalVector
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Draw normal vectors at regular intervals
    for (int i = 1; i < path.length - 1; i += UIDebugVisualizationConfig.tangentLineSpacing) {
      final point = path[i];
      final prevPoint = path[i - 1];
      final nextPoint = path[i + 1];

      // Calculate tangent direction
      final incoming = (point - prevPoint).normalized();
      final outgoing = (nextPoint - point).normalized();
      final tangent = (incoming + outgoing).normalized();

      // Calculate normal (perpendicular to tangent, rotated 90°)
      final normal = Offset(-tangent.dy, tangent.dx);

      // Draw normal vector
      final normalStart = point;
      final normalEnd = point + normal * UIDebugVisualizationConfig.normalVectorLength;

      canvas.drawLine(normalStart, normalEnd, normalPaint);

      // Draw small circle at the point
      final pointPaint = Paint()
        ..color = UIDebugColors.normalVector
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 2.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(UIDebugNormalVectorPainter oldDelegate) {
    return path != oldDelegate.path;
  }
}

/// Acceleration indicator painter.
/// Shows where animation is accelerating (green) or decelerating (red-orange).
class UIDebugAccelerationPainter extends CustomPainter {
  final List<Offset> path;

  UIDebugAccelerationPainter({required this.path});

  /// Calculate acceleration at a point using velocity change.
  double _calculateAcceleration(Offset p0, Offset p1, Offset p2) {
    // Calculate velocities
    final v1 = (p1 - p0).distance;
    final v2 = (p2 - p1).distance;

    // Calculate acceleration (change in velocity)
    return v2 - v1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode || path.length < 3) return;

    // Calculate accelerations
    final accelerations = <double>[];
    for (int i = 1; i < path.length - 1; i++) {
      final acceleration = _calculateAcceleration(
        path[i - 1],
        path[i],
        path[i + 1],
      );
      accelerations.add(acceleration);
    }

    // Draw acceleration indicators
    for (int i = 1; i < path.length - 1; i++) {
      final point = path[i];
      final acceleration = accelerations[i - 1];

      // Skip if acceleration is negligible
      if (acceleration.abs() < 0.1) continue;

      // Determine color and direction
      final isAccelerating = acceleration > 0;
      final color = isAccelerating
          ? UIDebugColors.accelerationPositive
          : UIDebugColors.accelerationNegative;

      // Calculate direction of movement
      final direction = (path[i + 1] - path[i]).normalized();

      // Calculate arrow length based on acceleration magnitude
      final arrowLength = UIDebugVisualizationConfig.accelerationArrowBaseLength *
          (1.0 + acceleration.abs() / 10.0);
      final arrowEnd = point + direction * arrowLength;

      // Draw acceleration arrow
      final arrowPaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(point, arrowEnd, arrowPaint);

      // Draw arrowhead
      final arrowAngle = direction.direction;
      final arrowSize = 4.0;
      final arrowLeft = Offset(
        arrowEnd.dx - arrowSize * (arrowAngle + 2.5).cos,
        arrowEnd.dy - arrowSize * (arrowAngle + 2.5).sin,
      );
      final arrowRight = Offset(
        arrowEnd.dx - arrowSize * (arrowAngle - 2.5).cos,
        arrowEnd.dy - arrowSize * (arrowAngle - 2.5).sin,
      );

      final arrowHeadPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final arrowPath = Path()
        ..moveTo(arrowEnd.dx, arrowEnd.dy)
        ..lineTo(arrowLeft.dx, arrowLeft.dy)
        ..lineTo(arrowRight.dx, arrowRight.dy)
        ..close();
      canvas.drawPath(arrowPath, arrowHeadPaint);
    }
  }

  @override
  bool shouldRepaint(UIDebugAccelerationPainter oldDelegate) {
    return path != oldDelegate.path;
  }
}

/// Grid alignment guide painter.
/// Shows alignment to other widgets and screen edges.
class UIDebugAlignmentGuidePainter extends CustomPainter {
  final Offset widgetPosition;
  final Size widgetSize;
  final Size screenSize;
  final List<Offset>? alignmentTargets;
  final bool showScreenEdges;

  UIDebugAlignmentGuidePainter({
    required this.widgetPosition,
    required this.widgetSize,
    required this.screenSize,
    this.alignmentTargets,
    this.showScreenEdges = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode) return;

    final guidePaint = Paint()
      ..color = UIDebugColors.alignmentGuide
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final widgetCenter = widgetPosition + Offset(widgetSize.width / 2, widgetSize.height / 2);
    final widgetLeft = widgetPosition.dx;
    final widgetRight = widgetPosition.dx + widgetSize.width;
    final widgetTop = widgetPosition.dy;
    final widgetBottom = widgetPosition.dy + widgetSize.height;

    // Draw alignment guides to screen edges
    if (showScreenEdges) {
      // Left edge alignment
      if (widgetLeft < screenSize.width / 2) {
        canvas.drawLine(
          Offset(0, widgetTop),
          Offset(0, widgetBottom),
          guidePaint,
        );
        canvas.drawLine(
          Offset(0, widgetCenter.dy),
          Offset(widgetLeft, widgetCenter.dy),
          guidePaint,
        );
      }

      // Right edge alignment
      if (widgetRight > screenSize.width / 2) {
        canvas.drawLine(
          Offset(screenSize.width, widgetTop),
          Offset(screenSize.width, widgetBottom),
          guidePaint,
        );
        canvas.drawLine(
          Offset(widgetRight, widgetCenter.dy),
          Offset(screenSize.width, widgetCenter.dy),
          guidePaint,
        );
      }

      // Top edge alignment
      if (widgetTop < screenSize.height / 2) {
        canvas.drawLine(
          Offset(widgetLeft, 0),
          Offset(widgetRight, 0),
          guidePaint,
        );
        canvas.drawLine(
          Offset(widgetCenter.dx, 0),
          Offset(widgetCenter.dx, widgetTop),
          guidePaint,
        );
      }

      // Bottom edge alignment
      if (widgetBottom > screenSize.height / 2) {
        canvas.drawLine(
          Offset(widgetLeft, screenSize.height),
          Offset(widgetRight, screenSize.height),
          guidePaint,
        );
        canvas.drawLine(
          Offset(widgetCenter.dx, widgetBottom),
          Offset(widgetCenter.dx, screenSize.height),
          guidePaint,
        );
      }

      // Center alignment guides
      final centerX = screenSize.width / 2;
      final centerY = screenSize.height / 2;

      // Vertical center line
      if ((widgetLeft < centerX && widgetRight > centerX) ||
          (widgetLeft - centerX).abs() < 10 ||
          (widgetRight - centerX).abs() < 10) {
        canvas.drawLine(
          Offset(centerX, 0),
          Offset(centerX, screenSize.height),
          guidePaint..color = UIDebugColors.alignmentGuide.withValues(alpha: 0.5),
        );
      }

      // Horizontal center line
      if ((widgetTop < centerY && widgetBottom > centerY) ||
          (widgetTop - centerY).abs() < 10 ||
          (widgetBottom - centerY).abs() < 10) {
        canvas.drawLine(
          Offset(0, centerY),
          Offset(screenSize.width, centerY),
          guidePaint..color = UIDebugColors.alignmentGuide.withValues(alpha: 0.5),
        );
      }
    }

    // Draw alignment guides to other widgets
    if (alignmentTargets != null) {
      for (final target in alignmentTargets!) {
        // Horizontal alignment
        if ((target.dy - widgetCenter.dy).abs() < 5) {
          final startX = math.min(widgetCenter.dx, target.dx);
          final endX = math.max(widgetCenter.dx, target.dx);
          canvas.drawLine(
            Offset(startX, widgetCenter.dy),
            Offset(endX, widgetCenter.dy),
            guidePaint,
          );
        }

        // Vertical alignment
        if ((target.dx - widgetCenter.dx).abs() < 5) {
          final startY = math.min(widgetCenter.dy, target.dy);
          final endY = math.max(widgetCenter.dy, target.dy);
          canvas.drawLine(
            Offset(widgetCenter.dx, startY),
            Offset(widgetCenter.dx, endY),
            guidePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(UIDebugAlignmentGuidePainter oldDelegate) {
    return widgetPosition != oldDelegate.widgetPosition ||
        widgetSize != oldDelegate.widgetSize ||
        screenSize != oldDelegate.screenSize ||
        alignmentTargets != oldDelegate.alignmentTargets ||
        showScreenEdges != oldDelegate.showScreenEdges;
  }
}

/// Collision boundary painter.
/// Shows where widgets might collide or overlap.
class UIDebugCollisionBoundaryPainter extends CustomPainter {
  final List<Rect> widgetBounds;

  UIDebugCollisionBoundaryPainter({required this.widgetBounds});

  /// Check if two rectangles overlap
  bool _rectanglesOverlap(Rect a, Rect b) {
    return a.left < b.right && a.right > b.left && a.top < b.bottom && a.bottom > b.top;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode || widgetBounds.isEmpty) return;

    final collisionPaint = Paint()
      ..color = UIDebugColors.collisionBoundary
          .withValues(alpha: UIDebugVisualizationConfig.collisionBoundaryOpacity)
      ..style = PaintingStyle.fill;

    final boundaryPaint = Paint()
      ..color = UIDebugColors.collisionBoundary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Find all overlapping areas
    final overlappingAreas = <Rect>[];
    for (int i = 0; i < widgetBounds.length; i++) {
      for (int j = i + 1; j < widgetBounds.length; j++) {
        if (_rectanglesOverlap(widgetBounds[i], widgetBounds[j])) {
          // Calculate intersection
          final left = math.max(widgetBounds[i].left, widgetBounds[j].left);
          final top = math.max(widgetBounds[i].top, widgetBounds[j].top);
          final right = math.min(widgetBounds[i].right, widgetBounds[j].right);
          final bottom = math.min(widgetBounds[i].bottom, widgetBounds[j].bottom);

          if (right > left && bottom > top) {
            overlappingAreas.add(Rect.fromLTRB(left, top, right, bottom));
          }
        }
      }
    }

    // Draw overlapping areas
    for (final area in overlappingAreas) {
      canvas.drawRect(area, collisionPaint);
      canvas.drawRect(area, boundaryPaint);
    }

    // Draw collision boundaries around each widget
    for (final bounds in widgetBounds) {
      final boundaryRect = bounds.inflate(2.0);
      canvas.drawRect(boundaryRect, boundaryPaint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(UIDebugCollisionBoundaryPainter oldDelegate) {
    return widgetBounds != oldDelegate.widgetBounds;
  }
}

/// Path smoothness analysis painter.
/// Indicates smooth vs rough animation segments.
class UIDebugPathSmoothnessPainter extends CustomPainter {
  final List<Offset> path;

  UIDebugPathSmoothnessPainter({required this.path});

  /// Calculate smoothness metric for a window of points.
  /// Lower value = smoother, higher value = rougher.
  double _calculateSmoothness(List<Offset> window) {
    if (window.length < 2) return 0.0;

    double totalDeviation = 0.0;
    for (int i = 1; i < window.length - 1; i++) {
      final prev = window[i - 1];
      final curr = window[i];
      final next = window[i + 1];

      // Calculate expected position (linear interpolation)
      final expected = Offset.lerp(prev, next, 0.5)!;
      final actual = curr;

      // Deviation from expected smooth path
      final deviation = (actual - expected).distance;
      totalDeviation += deviation;
    }

    return totalDeviation / (window.length - 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode || path.length < UIDebugVisualizationConfig.smoothnessWindowSize) return;

    final smoothPaint = Paint()
      ..color = UIDebugColors.pathSmooth
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final roughPaint = Paint()
      ..color = UIDebugColors.pathRough
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Analyze path in windows
    for (int i = 0; i <= path.length - UIDebugVisualizationConfig.smoothnessWindowSize; i++) {
      final window = path.sublist(i, i + UIDebugVisualizationConfig.smoothnessWindowSize);
      final smoothness = _calculateSmoothness(window);

      // Draw segment with appropriate color
      final paint = smoothness < UIDebugVisualizationConfig.smoothnessThreshold
          ? smoothPaint
          : roughPaint;

      // Draw line segment
      if (i + 1 < path.length) {
        canvas.drawLine(path[i], path[i + 1], paint);
      }

      // Draw marker at rough points
      if (smoothness >= UIDebugVisualizationConfig.smoothnessThreshold) {
        final markerPaint = Paint()
          ..color = UIDebugColors.pathRough
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          path[i + UIDebugVisualizationConfig.smoothnessWindowSize ~/ 2],
          3.0,
          markerPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(UIDebugPathSmoothnessPainter oldDelegate) {
    return path != oldDelegate.path;
  }
}

/// Constraint visualization painter.
/// Shows which constraints are satisfied vs violated.
class UIDebugConstraintPainter extends CustomPainter {
  final Rect widgetBounds;
  final BoxConstraints constraints;

  UIDebugConstraintPainter({
    required this.widgetBounds,
    required this.constraints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!kUIDebugMode) return;

    final satisfiedPaint = Paint()
      ..color = UIDebugColors.constraintSatisfied
      ..style = PaintingStyle.stroke
      ..strokeWidth = UIDebugVisualizationConfig.constraintLineWidth;

    final violatedPaint = Paint()
      ..color = UIDebugColors.constraintViolated
      ..style = PaintingStyle.stroke
      ..strokeWidth = UIDebugVisualizationConfig.constraintLineWidth;

    final actualWidth = widgetBounds.width;
    final actualHeight = widgetBounds.height;

    // Check width constraints
    final widthSatisfied = actualWidth >= constraints.minWidth &&
        actualWidth <= constraints.maxWidth;
    final widthViolation = actualWidth < constraints.minWidth
        ? constraints.minWidth - actualWidth
        : (actualWidth > constraints.maxWidth ? actualWidth - constraints.maxWidth : 0.0);

    // Check height constraints
    final heightSatisfied = actualHeight >= constraints.minHeight &&
        actualHeight <= constraints.maxHeight;
    final heightViolation = actualHeight < constraints.minHeight
        ? constraints.minHeight - actualHeight
        : (actualHeight > constraints.maxHeight ? actualHeight - constraints.maxHeight : 0.0);

    // Draw width constraint indicators
    if (widthViolation > UIDebugVisualizationConfig.minConstraintViolation) {
      // Draw violated constraint line
      final violationX = widthSatisfied
          ? widgetBounds.right
          : (actualWidth < constraints.minWidth
              ? widgetBounds.left + constraints.minWidth
              : widgetBounds.right);
      canvas.drawLine(
        Offset(violationX, widgetBounds.top - 10),
        Offset(violationX, widgetBounds.bottom + 10),
        violatedPaint,
      );

      // Draw constraint range
      final minX = widgetBounds.left + constraints.minWidth;
      final maxX = widgetBounds.left + constraints.maxWidth;
      canvas.drawLine(
        Offset(minX, widgetBounds.top - 15),
        Offset(maxX, widgetBounds.top - 15),
        violatedPaint,
      );
    } else if (widthSatisfied) {
      // Draw satisfied constraint indicators
      final minX = widgetBounds.left + constraints.minWidth;
      final maxX = widgetBounds.left + constraints.maxWidth;
      canvas.drawLine(
        Offset(minX, widgetBounds.top - 10),
        Offset(minX, widgetBounds.top - 5),
        satisfiedPaint,
      );
      canvas.drawLine(
        Offset(maxX, widgetBounds.top - 10),
        Offset(maxX, widgetBounds.top - 5),
        satisfiedPaint,
      );
    }

    // Draw height constraint indicators
    if (heightViolation > UIDebugVisualizationConfig.minConstraintViolation) {
      // Draw violated constraint line
      final violationY = heightSatisfied
          ? widgetBounds.bottom
          : (actualHeight < constraints.minHeight
              ? widgetBounds.top + constraints.minHeight
              : widgetBounds.bottom);
      canvas.drawLine(
        Offset(widgetBounds.left - 10, violationY),
        Offset(widgetBounds.right + 10, violationY),
        violatedPaint,
      );

      // Draw constraint range
      final minY = widgetBounds.top + constraints.minHeight;
      final maxY = widgetBounds.top + constraints.maxHeight;
      canvas.drawLine(
        Offset(widgetBounds.left - 15, minY),
        Offset(widgetBounds.left - 15, maxY),
        violatedPaint,
      );
    } else if (heightSatisfied) {
      // Draw satisfied constraint indicators
      final minY = widgetBounds.top + constraints.minHeight;
      final maxY = widgetBounds.top + constraints.maxHeight;
      canvas.drawLine(
        Offset(widgetBounds.left - 10, minY),
        Offset(widgetBounds.left - 5, minY),
        satisfiedPaint,
      );
      canvas.drawLine(
        Offset(widgetBounds.left - 10, maxY),
        Offset(widgetBounds.left - 5, maxY),
        satisfiedPaint,
      );
    }

    // Draw constraint violation text
    if (widthViolation > UIDebugVisualizationConfig.minConstraintViolation ||
        heightViolation > UIDebugVisualizationConfig.minConstraintViolation) {
      final violations = <String>[];
      if (widthViolation > UIDebugVisualizationConfig.minConstraintViolation) {
        violations.add('W: ${widthViolation.toStringAsFixed(1)}px');
      }
      if (heightViolation > UIDebugVisualizationConfig.minConstraintViolation) {
        violations.add('H: ${heightViolation.toStringAsFixed(1)}px');
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: violations.join(', '),
          style: TextStyle(
            color: UIDebugColors.constraintViolated,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        widgetBounds.topLeft - Offset(0, textPainter.height + 5),
      );
    }
  }

  @override
  bool shouldRepaint(UIDebugConstraintPainter oldDelegate) {
    return widgetBounds != oldDelegate.widgetBounds ||
        constraints != oldDelegate.constraints;
  }
}

/// Extension methods for Offset calculations used in debug visualizations.
extension UIDebugOffsetExtensions on Offset {
  /// Returns a normalized version of this offset (unit vector).
  Offset normalized() {
    final length = distance;
    if (length == 0.0) return Offset.zero;
    return Offset(dx / length, dy / length);
  }

  /// Returns the direction angle in radians.
  double get direction => math.atan2(dy, dx);
}

/// Extension methods for double (angle) calculations.
extension UIDebugDoubleExtensions on double {
  /// Cosine of this angle (in radians).
  double get cos => math.cos(this);

  /// Sine of this angle (in radians).
  double get sin => math.sin(this);
}
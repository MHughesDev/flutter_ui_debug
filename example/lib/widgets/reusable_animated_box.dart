import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

/// Simple phase implementation for demo purposes
class SimplePhase implements AnimationPhaseMetadata {
  @override
  final String name;
  
  @override
  final double startProgress;
  
  @override
  final double endProgress;
  
  @override
  final bool hasTranslation;
  
  @override
  final bool hasScale;
  
  @override
  final bool hasRotation;
  
  const SimplePhase({
    required this.name,
    required this.startProgress,
    required this.endProgress,
    this.hasTranslation = false,
    this.hasScale = false,
    this.hasRotation = false,
  });
  
  @override
  bool containsProgress(double progress) {
    if (progress < startProgress) return false;
    if (progress < endProgress) return true;
    return progress == endProgress;
  }
  
  @override
  UIDebugSeverity? checkViolation({
    required bool hasTranslation,
    required bool hasScale,
    required bool hasRotation,
  }) {
    final violations = <String>[];
    if (hasTranslation && !this.hasTranslation) {
      violations.add('translation');
    }
    if (hasScale && !this.hasScale) {
      violations.add('scale');
    }
    if (hasRotation && !this.hasRotation) {
      violations.add('rotation');
    }
    
    if (violations.isEmpty) {
      return null;
    }
    
    return UIDebugSeverity.architectural;
  }
}

/// Reusable animated box widget for testing debug features
class ReusableAnimatedBox extends StatefulWidget {
  final String animId;
  final List<AnimationPhaseMetadata> phases;
  final Duration duration;
  final Offset beginOffset;
  final Offset endOffset;
  final double beginScale;
  final double endScale;
  final double beginRotation;
  final double endRotation;
  final Color color;
  final Curve curve;
  
  const ReusableAnimatedBox({
    super.key,
    required this.animId,
    required this.phases,
    this.duration = const Duration(seconds: 2),
    this.beginOffset = Offset.zero,
    this.endOffset = const Offset(200, 200),
    this.beginScale = 1.0,
    this.endScale = 1.5,
    this.beginRotation = 0.0,
    this.endRotation = 2 * math.pi,
    this.color = Colors.blue,
    this.curve = Curves.easeInOut,
  });

  @override
  State<ReusableAnimatedBox> createState() => _ReusableAnimatedBoxState();
}

class _ReusableAnimatedBoxState extends State<ReusableAnimatedBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  int _rebuildCount = 0;
  final int _layoutChangeCount = 0;
  int _violationCount = 0;
  
  // Anchor tracking for anchor lock and stability graph
  Offset _anchorPosition = Offset.zero;
  double _anchorDelta = 0.0;
  final List<Offset> _anchorHistory = [];
  
  // Phase boundary tracking for phase continuity
  final Map<double, double> _boundaryDeltas = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    
    _offsetAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: widget.beginRotation,
      end: widget.endRotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  String _getCurrentPhase() {
    final progress = _controller.value;
    final phase = widget.phases.firstWhere(
      (p) => p.containsProgress(progress),
      orElse: () => widget.phases.last,
    );
    return phase.name;
  }

  bool _hasTranslation() {
    return _offsetAnimation.value != widget.beginOffset;
  }

  bool _hasScale() {
    return (_scaleAnimation.value - widget.beginScale).abs() > 0.01;
  }

  bool _hasRotation() {
    return (_rotationAnimation.value - widget.beginRotation).abs() > 0.01;
  }

  @override
  Widget build(BuildContext context) {
    _rebuildCount++;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final hasTranslation = _hasTranslation();
        final hasScale = _hasScale();
        final hasRotation = _hasRotation();
        
        // Update anchor position and delta
        final currentPosition = _offsetAnimation.value * 100;
        _anchorDelta = (currentPosition - _anchorPosition).distance;
        _anchorPosition = currentPosition;
        
        // Always track anchor history for stability graph (so it's ready when enabled)
        _anchorHistory.add(_anchorPosition);
        if (_anchorHistory.length > 50) {
          _anchorHistory.removeAt(0);
        }
        
        // Always track phase boundary deltas for phase continuity
        for (final phase in widget.phases) {
          if ((_controller.value - phase.endProgress).abs() < 0.01) {
            _boundaryDeltas[phase.endProgress] = _anchorDelta;
          }
        }
        
        // Check for violations
        final currentPhase = widget.phases.firstWhere(
          (p) => p.containsProgress(_controller.value),
          orElse: () => widget.phases.last,
        );
        final violation = currentPhase.checkViolation(
          hasTranslation: hasTranslation,
          hasScale: hasScale,
          hasRotation: hasRotation,
        );
        if (violation != null) {
          _violationCount++;
        }
        
        // Calculate transform values for transform stack inspector
        final translation = hasTranslation ? _offsetAnimation.value * 100 : null;
        final scale = hasScale ? Offset(_scaleAnimation.value, _scaleAnimation.value) : null;
        final rotation = hasRotation ? _rotationAnimation.value : null;
        
        return Stack(
          children: [
            // The actual animated widget
            Center(
              child: Transform.translate(
                offset: _offsetAnimation.value * 100,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Test',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Debug overlays
            if (UIDebugConfig.isEnabled(UIDebugCapability.flightRecorder))
              Positioned(
                top: 16,
                left: 16,
                child: FlightRecorderHUD(
                  animId: widget.animId,
                  coordSystem: 'local',
                  anchorPosition: _anchorPosition,
                  currentPhase: _getCurrentPhase(),
                  anchorDelta: _anchorDelta,
                  overlayStatus: _controller.isAnimating ? 'active' : 'paused',
                  rebuildCount: _rebuildCount,
                  layoutChangeCount: _layoutChangeCount,
                  violationCount: _violationCount,
                ),
              ),
            
            if (UIDebugConfig.isEnabled(UIDebugCapability.phaseContracts))
              Positioned.fill(
                child: CustomPaint(
                  painter: PhaseContractDebugPainter(
                    phases: widget.phases,
                    currentProgress: _controller.value,
                    hasTranslation: hasTranslation,
                    hasScale: hasScale,
                    hasRotation: hasRotation,
                    screenSize: MediaQuery.of(context).size,
                  ),
                ),
              ),
            
            if (UIDebugConfig.isEnabled(UIDebugCapability.animationTimelineScrubber))
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimationTimelineScrubber(
                  progress: _controller.value,
                  onProgressChanged: (progress) {
                    _controller.value = progress;
                  },
                  phases: widget.phases,
                  isPlaying: _controller.isAnimating,
                  onPlayPause: (playing) {
                    if (playing) {
                      _controller.repeat();
                    } else {
                      _controller.stop();
                    }
                  },
                  duration: widget.duration,
                ),
              ),
            
            // Anchor Lock Debug
            if (UIDebugConfig.isEnabled(UIDebugCapability.anchorLock))
              Positioned(
                left: _anchorPosition.dx + 60,
                top: _anchorPosition.dy - 20,
                child: AnchorLockDebug(
                  anchorPosition: _anchorPosition,
                  anchorDelta: _anchorDelta,
                ),
              ),
            
            // Phase Continuity Debug
            if (UIDebugConfig.isEnabled(UIDebugCapability.phaseContinuity))
              Positioned.fill(
                child: PhaseContinuityDebug(
                  phases: widget.phases,
                  currentProgress: _controller.value,
                  boundaryDeltas: _boundaryDeltas,
                ),
              ),
            
            // Transform Stack Inspector
            if (UIDebugConfig.isEnabled(UIDebugCapability.transformStackInspector))
              TransformStackInspector(
                translation: translation,
                scale: scale,
                rotation: rotation,
                coordinateSpace: 'local',
                showAlternateOrder: true,
              ),
            
            // Anchor Stability Graph
            if (UIDebugConfig.isEnabled(UIDebugCapability.anchorStabilityGraph) && _anchorHistory.isNotEmpty)
              Positioned(
                top: 80,
                left: 16,
                child: AnchorStabilityGraph(
                  anchorHistory: _anchorHistory,
                  label: 'Anchor Stability',
                ),
              ),
            
            // Expected vs Actual Debug
            if (UIDebugConfig.isEnabled(UIDebugCapability.expectedVsActual))
              Positioned.fill(
                child: ExpectedVsActualDebug(
                  expectedStart: widget.beginOffset * 100,
                  expectedEnd: widget.endOffset * 100,
                  actualPath: _anchorHistory.isNotEmpty 
                      ? _anchorHistory 
                      : [widget.beginOffset * 100, _anchorPosition],
                  actualEnd: _anchorPosition,
                  widgetSize: const Size(100, 100),
                ),
              ),
            
            // Error Magnifier (show if there's any error)
            if (UIDebugConfig.isEnabled(UIDebugCapability.errorMagnifier) && _anchorDelta > 2.0)
              ErrorMagnifier(
                errorPosition: _anchorPosition,
                errorDelta: _anchorDelta,
                magnifierSize: 120.0,
                zoomLevel: 3.0,
              ),
            
            // Overlay Bounds Debug
            if (UIDebugConfig.isEnabled(UIDebugCapability.overlayBounds))
              Positioned.fill(
                child: OverlayBoundsDebug(
                  overlayBounds: Rect.fromLTWH(
                    MediaQuery.of(context).size.width * 0.1,
                    MediaQuery.of(context).size.height * 0.1,
                    MediaQuery.of(context).size.width * 0.8,
                    MediaQuery.of(context).size.height * 0.8,
                  ),
                  widgetPosition: _anchorPosition,
                  widgetSize: const Size(100, 100),
                  hasExitedBounds: !Rect.fromLTWH(
                    MediaQuery.of(context).size.width * 0.1,
                    MediaQuery.of(context).size.height * 0.1,
                    MediaQuery.of(context).size.width * 0.8,
                    MediaQuery.of(context).size.height * 0.8,
                  ).contains(_anchorPosition),
                ),
              ),
            
            // Constraint Cage Debug
            if (UIDebugConfig.isEnabled(UIDebugCapability.constraintCage))
              Positioned.fill(
                child: ConstraintCageDebug(
                  widgetBounds: Rect.fromCenter(
                    center: _anchorPosition,
                    width: 100,
                    height: 100,
                  ),
                  constraints: const BoxConstraints(
                    maxWidth: 200,
                    maxHeight: 200,
                  ),
                ),
              ),
            
            // Coordinate Grid Debug
            if (UIDebugConfig.isEnabled(UIDebugCapability.coordinateGrid))
              Positioned.fill(
                child: CoordinateGridDebug(
                  widgetPosition: _anchorPosition,
                  widgetSize: const Size(100, 100),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

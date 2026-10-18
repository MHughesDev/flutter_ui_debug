import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';
import '../../widgets/reusable_animated_box.dart';

/// Comprehensive showcase demo that automatically enables and displays
/// all relevant debug capabilities for animation debugging.
class ComprehensiveShowcaseDemo extends StatefulWidget {
  const ComprehensiveShowcaseDemo({super.key});

  @override
  State<ComprehensiveShowcaseDemo> createState() => _ComprehensiveShowcaseDemoState();
}

class _ComprehensiveShowcaseDemoState extends State<ComprehensiveShowcaseDemo> {
  @override
  void initState() {
    super.initState();
    // Automatically enable all relevant capabilities for showcasing
    _enableAllRelevantCapabilities();
  }

  void _enableAllRelevantCapabilities() {
    // Enable all animation-related capabilities
    UIDebugConfig.enableAll([
      // Core animation debugging
      UIDebugCapability.flightRecorder,
      UIDebugCapability.anchorLock,
      UIDebugCapability.phaseContracts,
      UIDebugCapability.phaseContinuity,
      UIDebugCapability.animationTimelineScrubber,
      
      // Transform and coordinate debugging
      UIDebugCapability.transformStackInspector,
      UIDebugCapability.coordinateGrid,
      
      // Path and alignment debugging
      UIDebugCapability.expectedVsActual,
      UIDebugCapability.errorMagnifier,
      
      // Stability and tracking
      UIDebugCapability.anchorStabilityGraph,
      UIDebugCapability.ownershipTimeline,
      
      // Layout and constraint debugging
      UIDebugCapability.constraintCage,
      UIDebugCapability.rebuildDetector,
      UIDebugCapability.overlayBounds,
      
      // Performance monitoring
      UIDebugCapability.frameRateMonitor,
      
      // Visualization tools
      UIDebugCapability.easingCurveVisualizer,
      
      // Export and reporting
      UIDebugCapability.snapshotExport,
      UIDebugCapability.reportCard,
      
      // Interactive debugging
      UIDebugCapability.hitTestOverlay,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main animated showcase with multiple phases
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Comprehensive Debug Showcase',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              const ReusableAnimatedBox(
                animId: 'comprehensive-showcase',
                phases: [
                  SimplePhase(
                    name: 'Phase 1: Slide',
                    startProgress: 0.0,
                    endProgress: 0.33,
                    hasTranslation: true,
                  ),
                  SimplePhase(
                    name: 'Phase 2: Scale',
                    startProgress: 0.33,
                    endProgress: 0.66,
                    hasScale: true,
                  ),
                  SimplePhase(
                    name: 'Phase 3: Rotate',
                    startProgress: 0.66,
                    endProgress: 1.0,
                    hasRotation: true,
                  ),
                ],
                duration: Duration(seconds: 4),
                beginOffset: Offset(-1, -1),
                endOffset: Offset(1, 1),
                beginScale: 0.8,
                endScale: 1.5,
                beginRotation: 0.0,
                endRotation: 2 * 3.14159,
                color: Colors.blue,
                curve: Curves.easeInOut,
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'This demo showcases all debug capabilities simultaneously.\n'
                  'Use the debug control panel to toggle individual features.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

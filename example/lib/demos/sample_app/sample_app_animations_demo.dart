import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';
import 'navigation/app_destination.dart';
import 'widgets/custom_scaffold.dart';

class SampleAppAnimationsDemo extends StatefulWidget {
  const SampleAppAnimationsDemo({super.key});

  @override
  State<SampleAppAnimationsDemo> createState() =>
      _SampleAppAnimationsDemoState();
}

class _SampleAppAnimationsDemoState extends State<SampleAppAnimationsDemo> {
  AppDestination _selectedDestination = AppDestination.home;

  static const _destinations = [
    AppDestination.home,
    AppDestination.notes,
    AppDestination.tasks,
    AppDestination.mindMap,
    AppDestination.calendar,
    AppDestination.settings,
    AppDestination.chat,
  ];

  @override
  void initState() {
    super.initState();
    // Automatically enable all debug capabilities for showcasing
    _enableAllDebugCapabilities();
  }

  void _enableAllDebugCapabilities() {
    // Enable all relevant debug capabilities
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

  void _handleDestinationSelected(AppDestination destination) {
    setState(() {
      _selectedDestination = destination;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main navigation scaffold
        CustomScaffold(
          destination: _selectedDestination,
          destinations: _destinations,
          onDestinationSelected: _handleDestinationSelected,
          title: 'Ego App Animations',
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedDestination.selectedIcon,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedDestination.label,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Tap the navigation button in the app bar to see the animated menu.\n\n'
                        'All debug capabilities are enabled to showcase the navigation animations.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Rebuild Detector wrapper
              if (UIDebugConfig.isEnabled(UIDebugCapability.rebuildDetector))
                RebuildDetector(
                  child: const SizedBox.shrink(),
                ),
            ],
          ),
        ),
        
        // Debug overlays that work with the navigation menu
        // Flight Recorder HUD
        if (UIDebugConfig.isEnabled(UIDebugCapability.flightRecorder))
          Positioned(
            top: 16,
            left: 16,
            child: FlightRecorderHUD(
              animId: 'navigation-menu',
              coordSystem: 'global',
              anchorPosition: const Offset(0, 0),
              currentPhase: 'Navigation',
              anchorDelta: 0.0,
              overlayStatus: 'active',
              rebuildCount: 0,
              layoutChangeCount: 0,
              violationCount: 0,
            ),
          ),
        
        // Hit Test Overlay
        if (UIDebugConfig.isEnabled(UIDebugCapability.hitTestOverlay))
          Positioned.fill(
            child: HitTestOverlay(
              showTappableRegions: true,
              showGestureReceivers: true,
              showGestureArena: true,
              child: const SizedBox.shrink(),
            ),
          ),
        
        // Overlay Bounds Debug (shows bounds for navigation menu area)
        if (UIDebugConfig.isEnabled(UIDebugCapability.overlayBounds))
          Positioned.fill(
            child: OverlayBoundsDebug(
              overlayBounds: Rect.fromLTWH(
                0,
                0,
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              ),
              widgetPosition: Offset(
                MediaQuery.of(context).size.width * 0.1,
                100,
              ),
              widgetSize: const Size(48, 48),
              hasExitedBounds: false,
            ),
          ),
        
        // Constraint Cage Debug
        if (UIDebugConfig.isEnabled(UIDebugCapability.constraintCage))
          Positioned.fill(
            child: ConstraintCageDebug(
              widgetBounds: Rect.fromLTWH(
                MediaQuery.of(context).size.width * 0.1,
                100,
                48,
                48,
              ),
              constraints: const BoxConstraints(
                maxWidth: 200,
                maxHeight: 200,
              ),
            ),
          ),
        
        // Coordinate Grid Debug (for navigation button area)
        if (UIDebugConfig.isEnabled(UIDebugCapability.coordinateGrid))
          Positioned.fill(
            child: CoordinateGridDebug(
              widgetPosition: Offset(
                MediaQuery.of(context).size.width * 0.1,
                100,
              ),
              widgetSize: const Size(48, 48),
            ),
          ),
      ],
    );
  }
}

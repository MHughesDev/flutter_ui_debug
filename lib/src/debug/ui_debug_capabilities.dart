import '../constants/ui_debug_mode.dart';

/// Debug capabilities that can be enabled independently.
///
/// Each capability represents a specific debug feature that can be
/// enabled or disabled without affecting other features.
enum UIDebugCapability {
  /// Flight Recorder HUD: Real-time telemetry overlay in top-left corner.
  ///
  /// Shows: AnimID, Coord system, Anchor position, Current phase,
  /// Anchor delta, Overlay status, Rebuild count, Layout change count,
  /// Violation count.
  flightRecorder,

  /// Anchor Lock Visualization: Lock glyph showing anchor stability.
  ///
  /// Green lock = stable (delta < 0.1px)
  /// Red lock = drift detected (delta >= 0.1px)
  anchorLock,

  /// Overlay Boundary Outline: Dashed rectangle showing overlay bounds.
  ///
  /// Flashes red if animated widget exits overlay bounds.
  overlayBounds,

  /// Phase Contract Metadata: Floating labels at phase boundaries.
  ///
  /// Shows expected vs observed transforms with severity indicators.
  phaseContracts,

  /// Phase Continuity Heatmap: Background tint measuring anchor delta.
  ///
  /// Clear (0px), yellow (<2px), red (>=2px) at phase boundaries.
  phaseContinuity,

  /// Expected vs Actual Debug: Ghost targets and path comparison.
  ///
  /// Shows dashed expected path, solid actual path, ghost final widget,
  /// error label showing ΔEnd distance.
  expectedVsActual,

  /// Error Magnifier: 3× zoom inset with crosshairs.
  ///
  /// Auto-appears when alignment error exceeds threshold (e.g., 2px).
  errorMagnifier,

  /// Rebuild Detector: Tracks rebuilds and layout changes.
  ///
  /// White flash (rebuild), red flash (layout change),
  /// purple flash (RenderObject replaced).
  rebuildDetector,

  /// Constraint Cage: Live constraint box with clipping detection.
  ///
  /// Shows constraint box, labels (maxW, maxH), clipping source.
  constraintCage,

  /// Debug Snapshot Export: JSON serialization of animation state.
  ///
  /// Exports: animId, anchor, phases, violations, severity.
  /// Triggered on long-press or animation end.
  snapshotExport,

  /// Animation Report Card: End-of-animation diagnostic summary.
  ///
  /// Shows status indicators (✅/❌/⚠️) for each check,
  /// verdict (DO NOT SHIP / SHIP / REVIEW NEEDED).
  reportCard,

  /// Transform Stack Inspector: Overlay panel showing transform stack.
  ///
  /// Shows: T (translate), S (scale), R (rotate), ALIGN (alignment),
  /// SPACE (coordinate space), optional alternate-order preview.
  transformStackInspector,

  /// Local Coordinate Grid: Local axis grid attached to animated widget.
  ///
  /// Shows small local axis grid attached to widget and global axis
  /// reference in corner. Reveals mixed coordinate usage.
  coordinateGrid,

  /// Animation Ownership Timeline: Timeline bar showing controller ownership.
  ///
  /// Displays overlapping controller ownership periods to catch competing
  /// controllers and premature disposal.
  ownershipTimeline,

  /// Frame-Stable Anchor Graph: Sparkline showing anchor position over frames.
  ///
  /// Flat line = stable (good), noise = drift (bug). Displayed as small
  /// graph in Flight Recorder HUD.
  anchorStabilityGraph,

  /// Hit-Test Overlay: Shows tappable regions and gesture receivers.
  ///
  /// Highlights tappable regions, actual gesture receiver, and gesture
  /// arena resolution.
  hitTestOverlay,

  /// Stress & Distortion Modes: Safe-area and layout mutation testing.
  ///
  /// Simulates exaggerated insets, notches, keyboard height, orientation
  /// changes, and layout mutations to verify overlay stability.
  stressModes,

  /// Frame Rate Monitor: Real-time FPS overlay with jank detection.
  ///
  /// Shows current FPS, average FPS, and highlights frame drops.
  frameRateMonitor,

  /// Animation Timeline Scrubber: Interactive timeline for debugging animations.
  ///
  /// Allows manual control of animation progress, scrubbing, and frame-by-frame
  /// stepping. Displays phase boundaries and current progress.
  animationTimelineScrubber,

  /// Easing Curve Visualizer: Visualize and compare easing curves.
  ///
  /// Displays easing curves as graphs showing how animation progress
  /// maps to animation values over time.
  easingCurveVisualizer,

  /// Debug Preset Manager: Save/load debug capability configurations.
  ///
  /// Allows developers to save and load debug capability presets for
  /// quick switching between different debug modes.
  debugPresetManager,
}

/// Configuration for debug capabilities.
///
/// Manages which debug capabilities are enabled and provides
/// utility methods for checking capability state.
class UIDebugConfig {
  UIDebugConfig._();

  /// Set of enabled debug capabilities.
  ///
  /// Only capabilities in this set will be rendered.
  /// Empty set means no capabilities are enabled (but kUIDebugMode
  /// may still be enabled for legacy features).
  static Set<UIDebugCapability> enabled = {};

  /// Check if a specific capability is enabled.
  ///
  /// Returns true if:
  /// 1. kUIDebugMode is true, AND
  /// 2. The capability is in the enabled set
  static bool isEnabled(UIDebugCapability capability) {
    if (!kUIDebugMode) return false;
    return enabled.contains(capability);
  }

  /// Check if any of the given capabilities are enabled.
  ///
  /// Returns true if at least one capability is enabled.
  static bool isAnyEnabled(Iterable<UIDebugCapability> capabilities) {
    if (!kUIDebugMode) return false;
    return capabilities.any((cap) => enabled.contains(cap));
  }

  /// Check if all of the given capabilities are enabled.
  ///
  /// Returns true only if all capabilities are enabled.
  static bool areAllEnabled(Iterable<UIDebugCapability> capabilities) {
    if (!kUIDebugMode) return false;
    return capabilities.every((cap) => enabled.contains(cap));
  }

  /// Enable a specific capability.
  static void enable(UIDebugCapability capability) {
    enabled.add(capability);
  }

  /// Disable a specific capability.
  static void disable(UIDebugCapability capability) {
    enabled.remove(capability);
  }

  /// Enable multiple capabilities at once.
  static void enableAll(Iterable<UIDebugCapability> capabilities) {
    enabled.addAll(capabilities);
  }

  /// Disable multiple capabilities at once.
  static void disableAll(Iterable<UIDebugCapability> capabilities) {
    enabled.removeAll(capabilities);
  }

  /// Enable all available capabilities.
  static void enableAllCapabilities() {
    enabled = UIDebugCapability.values.toSet();
  }

  /// Disable all capabilities.
  static void disableAllCapabilities() {
    enabled.clear();
  }

  /// Get a human-readable name for a capability.
  static String getCapabilityName(UIDebugCapability capability) {
    switch (capability) {
      case UIDebugCapability.flightRecorder:
        return 'Flight Recorder HUD';
      case UIDebugCapability.anchorLock:
        return 'Anchor Lock Visualization';
      case UIDebugCapability.overlayBounds:
        return 'Overlay Boundary Outline';
      case UIDebugCapability.phaseContracts:
        return 'Phase Contract Metadata';
      case UIDebugCapability.phaseContinuity:
        return 'Phase Continuity Heatmap';
      case UIDebugCapability.expectedVsActual:
        return 'Expected vs Actual Debug';
      case UIDebugCapability.errorMagnifier:
        return 'Error Magnifier';
      case UIDebugCapability.rebuildDetector:
        return 'Rebuild Detector';
      case UIDebugCapability.constraintCage:
        return 'Constraint Cage';
      case UIDebugCapability.snapshotExport:
        return 'Debug Snapshot Export';
      case UIDebugCapability.reportCard:
        return 'Animation Report Card';
      case UIDebugCapability.transformStackInspector:
        return 'Transform Stack Inspector';
      case UIDebugCapability.coordinateGrid:
        return 'Local Coordinate Grid';
      case UIDebugCapability.ownershipTimeline:
        return 'Animation Ownership Timeline';
      case UIDebugCapability.anchorStabilityGraph:
        return 'Frame-Stable Anchor Graph';
      case UIDebugCapability.hitTestOverlay:
        return 'Hit-Test Overlay';
      case UIDebugCapability.stressModes:
        return 'Stress & Distortion Modes';
      case UIDebugCapability.frameRateMonitor:
        return 'Frame Rate Monitor';
      case UIDebugCapability.animationTimelineScrubber:
        return 'Animation Timeline Scrubber';
      case UIDebugCapability.easingCurveVisualizer:
        return 'Easing Curve Visualizer';
      case UIDebugCapability.debugPresetManager:
        return 'Debug Preset Manager';
    }
  }
}

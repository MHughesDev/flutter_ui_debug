# flutter_ui_debug

Advanced animation debugging toolkit for Flutter with visual diagnostics, trail visualization, constraint analysis, and phase contract debugging.

## Features

- **Animation Trail Visualization**: See the exact path your animated widgets take
- **Constraint Analysis**: Visualize constraint violations and layout issues
- **Phase Contract Debugging**: Track animation phases and detect contract violations
- **Transform Matrix Visualization**: Understand scale, rotation, and translation transforms
- **Anchor Stability Tracking**: Detect anchor drift and pivot point issues
- **Rebuild Detection**: Identify unnecessary rebuilds and layout changes
- **Flight Recorder HUD**: Real-time telemetry overlay for animation diagnostics
- **Error Magnifier**: 3× zoom inset for precise alignment error detection
- **Expected vs Actual Debug**: Compare expected animation paths with actual paths
- **Frame Rate Monitor**: Real-time FPS overlay with jank detection
- **Animation Timeline Scrubber**: Interactive timeline for debugging animations
- **Easing Curve Visualizer**: Visualize and compare easing curves
- **Debug Preset Manager**: Save/load debug capability configurations
- **And much more!**

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_ui_debug: ^1.1.0
```

Or install via command line:

```bash
flutter pub add flutter_ui_debug
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

void main() {
  // Enable debug mode
  kUIDebugMode = true;
  
  // Enable specific capabilities
  UIDebugConfig.enable(UIDebugCapability.flightRecorder);
  UIDebugConfig.enable(UIDebugCapability.anchorLock);
  UIDebugConfig.enable(UIDebugCapability.phaseContracts);
  
  runApp(MyApp());
}
```

### Using Phase Contract Debugging

```dart
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

// Implement AnimationPhaseMetadata for your animation phases
class MyAnimationPhase implements AnimationPhaseMetadata {
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
  
  MyAnimationPhase({
    required this.name,
    required this.startProgress,
    required this.endProgress,
    required this.hasTranslation,
    required this.hasScale,
    required this.hasRotation,
  });
}

// Use in your widget
PhaseContractDebug(
  phases: [
    MyAnimationPhase(
      name: 'Slide In',
      startProgress: 0.0,
      endProgress: 0.5,
      hasTranslation: true,
      hasScale: false,
      hasRotation: false,
    ),
    MyAnimationPhase(
      name: 'Fade Out',
      startProgress: 0.5,
      endProgress: 1.0,
      hasTranslation: false,
      hasScale: false,
      hasRotation: false,
    ),
  ],
  currentProgress: animation.value,
  hasTranslation: hasTranslation,
  hasScale: hasScale,
  hasRotation: hasRotation,
)
```

### Using Flight Recorder HUD

```dart
FlightRecorderHUD(
  animId: 'my-animation',
  coordSystem: 'local',
  anchorPosition: Offset(100, 200),
  currentPhase: 'Slide In',
  anchorDelta: 0.5,
  overlayStatus: 'active',
  rebuildCount: 3,
  layoutChangeCount: 1,
  violationCount: 0,
)
```

### Using Frame Rate Monitor

```dart
// Enable the capability
UIDebugConfig.enable(UIDebugCapability.frameRateMonitor);

// Add the widget to your app
FrameRateMonitor(
  showAverage: true,
  showJankIndicator: true,
)
```

### Using Animation Timeline Scrubber

```dart
// Enable the capability
UIDebugConfig.enable(UIDebugCapability.animationTimelineScrubber);

// Add the widget to your app
AnimationTimelineScrubber(
  progress: animation.value,
  onProgressChanged: (progress) {
    animationController.value = progress;
  },
  phases: myPhases,
  isPlaying: animationController.isAnimating,
  onPlayPause: (playing) {
    if (playing) {
      animationController.forward();
    } else {
      animationController.stop();
    }
  },
  duration: animationController.duration,
)
```

### Using Easing Curve Visualizer

```dart
// Enable the capability
UIDebugConfig.enable(UIDebugCapability.easingCurveVisualizer);

// Add the widget to your app
EasingCurveVisualizer(
  curves: [
    CurveData(
      curve: Curves.easeInOut,
      name: 'Ease In Out',
      color: Colors.blue,
    ),
    CurveData(
      curve: Curves.easeOut,
      name: 'Ease Out',
      color: Colors.green,
    ),
  ],
  currentProgress: animation.value,
)
```

### Using Debug Preset Manager

```dart
// Enable the capability
UIDebugConfig.enable(UIDebugCapability.debugPresetManager);

// Save current configuration as a preset
DebugPresetManager.savePreset('My Debug Setup');

// Load a preset
DebugPresetManager.loadPreset('Performance Debug');

// Or use the UI widget
DebugPresetSelector(
  onPresetLoaded: (presetName) {
    print('Loaded preset: $presetName');
  },
)
```

## API Overview

### Core Classes

- **`kUIDebugMode`**: Global flag to enable/disable debug mode
- **`UIDebugConfig`**: Manages which debug capabilities are enabled
- **`UIDebugCapability`**: Enum of available debug features
- **`UIDebugSeverity`**: Severity classification for debug issues

### Debug Widgets

- **`PhaseContractDebug`**: Displays phase contract violations
- **`PhaseContinuityDebug`**: Measures anchor delta at phase boundaries
- **`FlightRecorderHUD`**: Real-time telemetry overlay
- **`AnchorLockDebug`**: Lock glyph showing anchor stability
- **`AnimationReportCard`**: End-of-animation diagnostic summary
- **`ErrorMagnifier`**: 3× zoom inset for alignment errors
- **`ExpectedVsActualDebug`**: Compares expected vs actual animation paths
- **`RebuildDetector`**: Tracks rebuilds and layout changes
- **`ConstraintCageDebug`**: Live constraint box visualization
- **`TransformStackInspector`**: Overlay panel showing transform stack
- **`CoordinateGridDebug`**: Local coordinate grid visualization
- **`AnimationOwnershipTimeline`**: Timeline bar showing controller ownership
- **`AnchorStabilityGraph`**: Sparkline showing anchor position over frames
- **`HitTestOverlay`**: Shows tappable regions and gesture receivers
- **`OverlayBoundsDebug`**: Dashed rectangle showing overlay bounds
- **`StressModes`**: Safe-area and layout mutation testing
- **`FrameRateMonitor`**: Real-time FPS overlay with jank detection
- **`AnimationTimelineScrubber`**: Interactive timeline for debugging animations
- **`EasingCurveVisualizer`**: Visualize and compare easing curves
- **`DebugPresetManager`**: Save/load debug capability configurations
- **`DebugPresetSelector`**: UI widget for managing debug presets

### Abstract Interfaces

- **`AnimationPhaseMetadata`**: Interface for animation phase metadata
  - `name`: Phase name or identifier
  - `startProgress`: Start progress (0.0 to 1.0)
  - `endProgress`: End progress (0.0 to 1.0)
  - `hasTranslation`: Whether translation is allowed
  - `hasScale`: Whether scale is allowed
  - `hasRotation`: Whether rotation is allowed
  - `containsProgress(double progress)`: Check if progress is in phase range
  - `checkViolation(...)`: Check for contract violations

## Capabilities

Enable specific debug features:

```dart
// Enable a single capability
UIDebugConfig.enable(UIDebugCapability.flightRecorder);

// Enable multiple capabilities
UIDebugConfig.enableAll([
  UIDebugCapability.flightRecorder,
  UIDebugCapability.anchorLock,
  UIDebugCapability.phaseContracts,
]);

// Enable all capabilities
UIDebugConfig.enableAllCapabilities();

// Disable a capability
UIDebugConfig.disable(UIDebugCapability.flightRecorder);

// Check if enabled
if (UIDebugConfig.isEnabled(UIDebugCapability.flightRecorder)) {
  // Render debug feature
}
```

## Severity Levels

Debug issues are classified by severity:

- **`cosmetic`**: Visual imperfections that don't affect functionality
- **`perceptual`**: Problems that affect user experience but don't break functionality
- **`architectural`**: Critical problems that indicate fundamental failures

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- [GitHub Repository](https://github.com/MHughesDev/flutter_ui_debug)
- [Issue Tracker](https://github.com/MHughesDev/flutter_ui_debug/issues)
- [Pub.dev Package](https://pub.dev/packages/flutter_ui_debug)

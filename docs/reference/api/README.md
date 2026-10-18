# API Reference

Complete API documentation for `flutter_ui_debug`.

## Core APIs

### Constants
- `kUIDebugMode` - Global debug mode flag

### Configuration
- `UIDebugConfig` - Capability management
- `UIDebugCapability` - Available capabilities enum
- `UIDebugSeverity` - Severity classification enum

### Interfaces
- `AnimationPhaseMetadata` - Phase contract interface

## Debug Widgets

### Telemetry
- `FlightRecorderHUD` - Real-time telemetry overlay

### Visualization
- `PhaseContractDebug` - Phase contract visualization
- `PhaseContinuityDebug` - Phase continuity heatmap
- `AnchorLockDebug` - Anchor stability indicator
- `ExpectedVsActualDebug` - Path comparison
- `ErrorMagnifier` - Precision alignment tool
- `TransformStackInspector` - Transform visualization
- `CoordinateGridDebug` - Coordinate system visualization

### Analysis
- `RebuildDetector` - Rebuild tracking
- `ConstraintCageDebug` - Constraint visualization
- `OverlayBoundsDebug` - Overlay boundary tracking
- `HitTestOverlay` - Gesture debugging

### Reporting
- `AnimationReportCard` - Diagnostic summary
- `DebugSnapshotExport` - State export

## Utilities

### Helpers
- `UIDebugHelpers` - Utility functions
- `UIDebugPositionTracker` - Position tracking
- `UIDebugColors` - Color constants
- `UIDebugVisualizationConfig` - Visualization settings

## Generating API Docs

To generate API documentation:

```bash
dart doc
```

Documentation will be generated in the `doc/api/` directory.

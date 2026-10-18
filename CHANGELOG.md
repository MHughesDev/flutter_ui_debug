# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-02-10

### Added
- **Frame Rate Monitor**: Real-time FPS overlay with jank detection
  - Displays current FPS and average FPS
  - Color-coded status indicators (green/yellow/red)
  - Automatic jank detection with visual alerts
  - Configurable jank threshold
- **Animation Timeline Scrubber**: Interactive timeline for debugging animations
  - Manual scrubbing through animation progress
  - Phase boundary markers
  - Play/pause controls
  - Frame-by-frame stepping
  - Time display support
- **Easing Curve Visualizer**: Visualize and compare easing curves
  - Graph visualization of easing curves
  - Support for multiple curves simultaneously
  - Current progress indicator
  - Grid and axis labels
  - Custom curve support
- **Debug Preset Manager**: Save/load debug capability configurations
  - Save current debug configuration as presets
  - Load presets to quickly switch debug modes
  - UI widget for preset management
  - Default presets: Performance Debug, Animation Debug, Layout Debug, Full Debug
  - In-memory preset storage

### Changed
- Updated capability system to include 4 new debug capabilities
- Enhanced documentation with new feature examples

## [1.0.0] - 2026-02-10

### Added
- Initial release of flutter_ui_debug package
- Animation trail visualization with color-coded paths
- Constraint analysis and visualization
- Phase contract debugging with violation detection
- Transform matrix visualization (scale, rotation, translation)
- Anchor stability tracking and drift detection
- Rebuild detection with visual indicators
- Flight Recorder HUD for real-time telemetry
- Error Magnifier with 3× zoom for precise alignment detection
- Expected vs Actual debug for path comparison
- Animation Report Card for end-of-animation diagnostics
- Constraint Cage visualization
- Transform Stack Inspector overlay
- Local Coordinate Grid visualization
- Animation Ownership Timeline
- Anchor Stability Graph (sparkline)
- Hit-Test Overlay for gesture debugging
- Overlay Bounds Debug visualization
- Stress & Distortion Modes for testing
- Debug Snapshot Export for LLM-assisted debugging
- Phase Continuity Debug for anchor delta measurement
- Abstract `AnimationPhaseMetadata` interface for phase contract implementation
- Capability-based debug feature system
- Severity classification system (cosmetic, perceptual, architectural)

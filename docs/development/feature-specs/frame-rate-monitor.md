# Feature Specification: Frame Rate Monitor

**Status:** Completed  
**Created:** 2026-02-10  
**Last Updated:** 2026-02-10  
**Author:** Development Team

## Overview

A real-time FPS (Frames Per Second) overlay with jank detection that helps developers identify performance issues during animation debugging. The monitor displays current FPS, average FPS, and highlights frame drops (jank) that could affect animation smoothness.

## Motivation

Performance issues during animations can cause stuttering, jank, and poor user experience. Without real-time FPS monitoring, developers may not notice subtle performance problems. This feature provides immediate visual feedback about frame rate performance, making it easier to identify and fix performance bottlenecks.

### User Stories

- As a developer, I want to see real-time FPS during animations so that I can identify performance issues immediately
- As a developer, I want to see jank detection so that I know when frames are dropped
- As a developer, I want to see average FPS over time so that I can understand overall performance trends

## Use Cases

### Example 1: Animation Performance Debugging
A developer is debugging a complex animation and notices it feels choppy. They enable the Frame Rate Monitor to see if the FPS is dropping below 60, indicating performance issues.

### Example 2: Jank Detection
During animation playback, the monitor highlights when frames are dropped (jank), helping identify specific moments where performance degrades.

## Design

The Frame Rate Monitor displays as an overlay widget (typically in the top-right corner) showing:
- Current FPS (real-time)
- Average FPS (over a rolling window)
- Jank indicator (when frames drop below threshold)
- Color-coded status (green = good, yellow = warning, red = poor)

### User Interface

- Compact overlay similar to Flight Recorder HUD
- Monospace font for readability
- Color-coded FPS values:
  - Green: 55-60 FPS (excellent)
  - Yellow: 45-54 FPS (acceptable)
  - Red: <45 FPS (poor)
- Jank indicator flashes when frame drops detected

### Behavior

- Updates every frame using `SchedulerBinding` frame callbacks
- Calculates FPS from frame timestamps
- Detects jank when frame time exceeds 16.67ms (60 FPS threshold)
- Maintains rolling average over last 60 frames (1 second at 60 FPS)

## API Design

### New Classes/Interfaces

```dart
/// Frame Rate Monitor: Real-time FPS overlay with jank detection.
///
/// Displays current FPS, average FPS, and highlights frame drops.
/// Typically positioned in top-right corner of screen.
class FrameRateMonitor extends StatefulWidget {
  /// Position of the monitor overlay
  final Offset? position;
  
  /// Whether to show average FPS
  final bool showAverage;
  
  /// Whether to show jank indicator
  final bool showJankIndicator;
  
  /// FPS threshold for jank detection (default: 16.67ms = 60 FPS)
  final Duration jankThreshold;
  
  const FrameRateMonitor({
    super.key,
    this.position,
    this.showAverage = true,
    this.showJankIndicator = true,
    this.jankThreshold = const Duration(milliseconds: 16),
  });
}
```

### New Capabilities

```dart
enum UIDebugCapability {
  // ... existing capabilities ...
  /// Frame Rate Monitor: Real-time FPS overlay with jank detection.
  ///
  /// Shows current FPS, average FPS, and highlights frame drops.
  frameRateMonitor,
}
```

### Configuration Options

- Position: Customizable overlay position (default: top-right)
- Show Average: Toggle average FPS display (default: true)
- Show Jank Indicator: Toggle jank detection (default: true)
- Jank Threshold: Customizable threshold for jank detection (default: 16ms)

## Implementation Plan

### Phase 1: Core FPS Tracking
- [ ] Create `FrameRateMonitor` widget
- [ ] Implement frame callback using `SchedulerBinding`
- [ ] Calculate FPS from frame timestamps
- [ ] Display current FPS in overlay

### Phase 2: Advanced Features
- [ ] Implement rolling average calculation
- [ ] Add jank detection logic
- [ ] Add color-coded status indicators
- [ ] Add jank indicator flashing

### Phase 3: Integration
- [ ] Add capability to enum
- [ ] Export in main library file
- [ ] Update documentation

## Testing Strategy

### Unit Tests
- Test FPS calculation accuracy
- Test jank detection logic
- Test rolling average calculation

### Integration Tests
- Test overlay positioning
- Test frame callback registration/unregistration
- Test capability enable/disable

### Manual Testing
- Enable monitor during animations
- Verify FPS accuracy matches device performance
- Verify jank detection triggers correctly

## Performance Considerations

- Minimal overhead: Only tracks frame timestamps
- Efficient: Uses `SchedulerBinding` callbacks (already optimized)
- Memory: Stores only last 60 frame timestamps for rolling average

## Accessibility

- High contrast text for readability
- Color coding supplemented with text labels
- Can be positioned to avoid content overlap

## Open Questions

- [ ] Should we support custom FPS targets (e.g., 30 FPS for some animations)?
- [ ] Should we log FPS history for later analysis?

## Alternatives Considered

1. **External FPS tools**: Less integrated, requires separate tool
2. **Flutter DevTools**: More complex, not always available
3. **Simple counter**: Less informative, no jank detection

## References

- Flutter `SchedulerBinding` documentation
- Frame timing best practices

# Feature Specification: Animation Timeline Scrubber

**Status:** Completed  
**Created:** 2026-02-10  
**Last Updated:** 2026-02-10  
**Author:** Development Team

## Overview

An interactive timeline scrubber that allows developers to manually control animation progress, scrub through animations frame-by-frame, and debug animation behavior at specific points in time. This is essential for precise animation debugging and understanding animation state at any given moment.

## Motivation

Debugging animations can be difficult when they play too fast to observe details. The timeline scrubber allows developers to pause, rewind, and step through animations frame-by-frame, making it possible to identify issues at specific animation progress points. This is similar to video editing tools but for animations.

### User Stories

- As a developer, I want to scrub through animations so that I can examine specific frames in detail
- As a developer, I want to pause animations so that I can inspect state at a specific moment
- As a developer, I want to see animation progress visually so that I understand where I am in the animation

## Use Cases

### Example 1: Frame-by-Frame Inspection
A developer notices an animation glitch at around 50% progress. They use the timeline scrubber to jump to exactly 50% and inspect the widget state at that moment.

### Example 2: Animation State Debugging
A developer wants to verify that animation phases are correctly defined. They scrub through the timeline and observe phase boundaries to ensure they align with expected behavior.

## Design

The timeline scrubber displays as a horizontal slider/scrubber widget that:
- Shows current animation progress (0.0 to 1.0)
- Allows dragging to scrub through animation
- Displays phase boundaries as markers
- Shows current time/progress value
- Provides play/pause controls
- Supports frame-by-frame stepping

### User Interface

- Horizontal slider bar (similar to video player timeline)
- Draggable thumb/indicator
- Phase boundary markers (vertical lines)
- Current progress label
- Play/pause button
- Step forward/backward buttons
- Optional: Speed control (0.5x, 1x, 2x)

### Behavior

- When scrubbing: Animation jumps to selected progress point
- When playing: Animation progresses normally
- When paused: Animation stays at current progress
- Frame stepping: Move forward/backward by one frame
- Phase markers: Highlight current phase and boundaries

## API Design

### New Classes/Interfaces

```dart
/// Animation Timeline Scrubber: Interactive timeline for debugging animations.
///
/// Allows manual control of animation progress, scrubbing, and frame-by-frame
/// stepping. Displays phase boundaries and current progress.
class AnimationTimelineScrubber extends StatefulWidget {
  /// Current animation progress (0.0 to 1.0)
  final double progress;
  
  /// Callback when progress changes (from scrubbing)
  final ValueChanged<double>? onProgressChanged;
  
  /// Animation phases (for boundary markers)
  final List<AnimationPhaseMetadata>? phases;
  
  /// Whether animation is currently playing
  final bool isPlaying;
  
  /// Callback when play/pause is toggled
  final ValueChanged<bool>? onPlayPause;
  
  /// Callback for step forward
  final VoidCallback? onStepForward;
  
  /// Callback for step backward
  final VoidCallback? onStepBackward;
  
  /// Animation duration (for time display)
  final Duration? duration;
  
  /// Position of the scrubber overlay
  final Offset? position;
  
  const AnimationTimelineScrubber({
    super.key,
    required this.progress,
    this.onProgressChanged,
    this.phases,
    this.isPlaying = false,
    this.onPlayPause,
    this.onStepForward,
    this.onStepBackward,
    this.duration,
    this.position,
  });
}
```

### New Capabilities

```dart
enum UIDebugCapability {
  // ... existing capabilities ...
  /// Animation Timeline Scrubber: Interactive timeline for debugging animations.
  ///
  /// Allows manual control of animation progress, scrubbing, and frame-by-frame
  /// stepping. Displays phase boundaries and current progress.
  animationTimelineScrubber,
}
```

### Configuration Options

- Position: Customizable overlay position (default: bottom-center)
- Show Phase Markers: Toggle phase boundary display (default: true)
- Show Controls: Toggle play/pause/step controls (default: true)
- Show Time Display: Toggle time/progress display (default: true)

## Implementation Plan

### Phase 1: Basic Scrubber
- [ ] Create `AnimationTimelineScrubber` widget
- [ ] Implement horizontal slider with draggable thumb
- [ ] Add progress callback
- [ ] Display current progress value

### Phase 2: Phase Markers
- [ ] Add phase boundary markers
- [ ] Highlight current phase
- [ ] Display phase labels

### Phase 3: Controls
- [ ] Add play/pause button
- [ ] Add step forward/backward buttons
- [ ] Add time display (if duration provided)

### Phase 4: Integration
- [ ] Add capability to enum
- [ ] Export in main library file
- [ ] Update documentation

## Testing Strategy

### Unit Tests
- Test progress value updates
- Test callback invocations
- Test phase marker positioning

### Integration Tests
- Test scrubbing interaction
- Test play/pause functionality
- Test step forward/backward

### Manual Testing
- Use scrubber with real animations
- Verify phase markers align correctly
- Verify smooth scrubbing experience

## Performance Considerations

- Lightweight: Simple slider widget
- Efficient: Only updates on user interaction
- No frame-by-frame overhead when not scrubbing

## Accessibility

- Large touch targets for controls
- Clear visual feedback for interactions
- Keyboard navigation support (optional)

## Open Questions

- [ ] Should we support multiple animation timelines simultaneously?
- [ ] Should we support animation speed control (slow motion)?
- [ ] Should we support bookmarking specific progress points?

## Alternatives Considered

1. **External video tools**: Less integrated, requires screen recording
2. **Flutter DevTools**: More complex, not always available
3. **Simple progress bar**: Less interactive, no scrubbing

## References

- Flutter `Slider` widget documentation
- Animation controller best practices

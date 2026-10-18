# Development Roadmap

This document outlines the planned development for `flutter_ui_debug`.

## Current Version: 1.1.0

**Status:** ✅ Released (v1.1.0 includes Frame Rate Monitor, Animation Timeline Scrubber, Easing Curve Visualizer, and Debug Preset Manager)

## Upcoming Features

### High Priority

These features are planned for near-term development:

- [x] **Frame Rate Monitor** - Real-time FPS overlay with jank detection ✅
- [x] **Animation Timeline Scrubber** - Interactive timeline for debugging animations ✅
- [x] **Easing Curve Visualizer** - Visualize and compare easing curves ✅
- [x] **Debug Preset Manager** - Save/load debug capability configurations ✅

### Medium Priority

These features are planned for future releases:

- [ ] **Layout Boundary Explorer** - Interactive layout debugging tool
- [ ] **Gesture Arena Visualizer** - Visualize gesture recognition
- [ ] **Animation Recording/Playback** - Record and replay animations
- [ ] **Widget Tree Inspector** - Interactive widget tree explorer
- [ ] **Performance Budget Dashboard** - Set and monitor performance budgets

### Low Priority / Future Considerations

These are ideas for future exploration:

- [ ] **Time Travel Debugger** - Record and replay widget state
- [ ] **3D Transform Visualizer** - 3D visualization of transforms
- [ ] **CI/CD Integration** - Automated testing and benchmarking
- [ ] **LLM Debug Assistant** - Enhanced AI-powered debugging

## Version Planning

### v1.1.0 (Released) ✅
- [x] Frame Rate Monitor ✅
- [x] Animation Timeline Scrubber ✅
- [x] Easing Curve Visualizer ✅
- [x] Debug Preset Manager ✅

### v1.2.0 (Planned)
- Layout Boundary Explorer
- Gesture Arena Visualizer
- Animation Recording/Playback
- Widget Tree Inspector
- Performance Budget Dashboard

### v2.0.0 (Future)
- Major API improvements
- Performance optimizations
- Breaking changes (if needed)
- Time Travel Debugger
- 3D Transform Visualizer
- CI/CD Integration
- LLM Debug Assistant

## Testing and Validation

As features are developed, they will be tested and validated in real Flutter applications to ensure:

- **Functionality**: All features work correctly and as designed
- **Performance**: Features have minimal performance impact
- **Usability**: Features are intuitive and easy to use
- **Integration**: Features work well together
- **Compatibility**: Features work across different Flutter versions and platforms

### Testing Strategy

- **Unit Tests**: Test individual components and functionality
- **Integration Tests**: Test features working together
- **Manual Testing**: Test in real Flutter applications
- **Performance Testing**: Verify minimal performance impact
- **Cross-platform Testing**: Test on iOS, Android, Web, Desktop

## Contributing

Want to work on a feature? Check the [Feature Specifications](feature-specs/) directory for design documents, or create a new one if the feature isn't documented yet.

## Feedback

Have ideas for new features? Open an issue on GitHub with the `enhancement` label!

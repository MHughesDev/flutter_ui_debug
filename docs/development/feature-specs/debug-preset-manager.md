# Feature Specification: Debug Preset Manager

**Status:** Completed  
**Created:** 2026-02-10  
**Last Updated:** 2026-02-10  
**Author:** Development Team

## Overview

A system for saving and loading debug capability configurations as presets. This allows developers to quickly switch between different debug setups (e.g., "Performance Debug", "Animation Debug", "Layout Debug") without manually enabling/disabling individual capabilities each time.

## Motivation

Debugging different aspects of animations requires different combinations of debug capabilities. Manually enabling/disabling capabilities each time is tedious and error-prone. Presets allow developers to:
- Save common debug configurations
- Quickly switch between debug modes
- Share debug configurations with team members
- Create specialized debug setups for specific scenarios

### User Stories

- As a developer, I want to save my debug configuration so that I can reuse it later
- As a developer, I want to load preset configurations so that I can quickly switch debug modes
- As a developer, I want to share presets with my team so that we use consistent debug setups

## Use Cases

### Example 1: Quick Debug Mode Switching
A developer is debugging performance issues and has enabled frame rate monitor, rebuild detector, and constraint cage. They save this as "Performance Debug" preset. Later, they switch to animation debugging and load "Animation Debug" preset which enables different capabilities.

### Example 2: Team Consistency
A team creates standard debug presets ("Basic Debug", "Full Debug", "Performance Debug") that all team members use, ensuring consistent debugging approaches.

## Design

The preset manager provides:
- Save current capability configuration as preset
- Load preset (apply saved configuration)
- Delete preset
- List available presets
- Preset storage (in-memory or persistent)

### User Interface

The preset manager can be used programmatically or via a simple UI widget:
- Dropdown/selector for presets
- Save button (saves current configuration)
- Load button (applies selected preset)
- Delete button (removes preset)
- Preset name input

### Behavior

- Saving: Captures current `UIDebugConfig.enabled` set
- Loading: Applies saved capability set to `UIDebugConfig`
- Storage: In-memory by default, can be extended to persistent storage
- Validation: Ensures preset contains valid capabilities

## API Design

### New Classes/Interfaces

```dart
/// Debug Preset Manager: Save/load debug capability configurations.
///
/// Allows developers to save and load debug capability presets for
/// quick switching between different debug modes.
class DebugPresetManager {
  DebugPresetManager._();
  
  /// Storage for presets (in-memory by default)
  static final Map<String, Set<UIDebugCapability>> _presets = {};
  
  /// Save current configuration as a preset
  static void savePreset(String name) {
    _presets[name] = Set.from(UIDebugConfig.enabled);
  }
  
  /// Load a preset (apply saved configuration)
  static void loadPreset(String name) {
    final preset = _presets[name];
    if (preset != null) {
      UIDebugConfig.enabled = Set.from(preset);
    }
  }
  
  /// Delete a preset
  static void deletePreset(String name) {
    _presets.remove(name);
  }
  
  /// Get list of preset names
  static List<String> getPresetNames() {
    return _presets.keys.toList();
  }
  
  /// Check if preset exists
  static bool hasPreset(String name) {
    return _presets.containsKey(name);
  }
  
  /// Get preset capabilities (without loading)
  static Set<UIDebugCapability>? getPresetCapabilities(String name) {
    return _presets[name]?.toSet();
  }
}

/// Debug Preset Selector Widget: UI for managing presets.
///
/// Provides a simple interface for saving, loading, and deleting presets.
class DebugPresetSelector extends StatefulWidget {
  /// Callback when preset is loaded
  final ValueChanged<String>? onPresetLoaded;
  
  /// Position of the selector overlay
  final Offset? position;
  
  const DebugPresetSelector({
    super.key,
    this.onPresetLoaded,
    this.position,
  });
}
```

### New Capabilities

```dart
enum UIDebugCapability {
  // ... existing capabilities ...
  /// Debug Preset Manager: Save/load debug capability configurations.
  ///
  /// Allows developers to save and load debug capability presets for
  /// quick switching between different debug modes.
  debugPresetManager,
}
```

### Configuration Options

- Storage: In-memory (default) or persistent (future)
- Default Presets: Pre-defined presets (optional)
- Auto-save: Automatically save current configuration (optional)

## Implementation Plan

### Phase 1: Core Manager
- [ ] Create `DebugPresetManager` class
- [ ] Implement save/load/delete operations
- [ ] Implement preset storage (in-memory)
- [ ] Add preset validation

### Phase 2: UI Widget
- [ ] Create `DebugPresetSelector` widget
- [ ] Add preset dropdown/selector
- [ ] Add save/load/delete buttons
- [ ] Add preset name input

### Phase 3: Default Presets
- [ ] Add common preset configurations
- [ ] Add preset descriptions
- [ ] Add preset categories (optional)

### Phase 4: Integration
- [ ] Add capability to enum
- [ ] Export in main library file
- [ ] Update documentation

## Testing Strategy

### Unit Tests
- Test preset save/load operations
- Test preset deletion
- Test preset validation
- Test preset listing

### Integration Tests
- Test preset manager with `UIDebugConfig`
- Test preset selector widget
- Test capability enable/disable via presets

### Manual Testing
- Save and load presets
- Switch between different presets
- Verify capabilities are correctly applied

## Performance Considerations

- Minimal overhead: Simple map operations
- Efficient: In-memory storage (fast access)
- Memory: Only stores capability sets (minimal)

## Accessibility

- Clear preset names
- Easy-to-use UI controls
- Keyboard navigation support

## Open Questions

- [ ] Should we support persistent storage (shared preferences)?
- [ ] Should we support preset import/export (JSON)?
- [ ] Should we support preset categories or tags?
- [ ] Should we provide default presets out of the box?

## Alternatives Considered

1. **Manual configuration**: Too tedious, error-prone
2. **Code-based presets**: Less flexible, requires code changes
3. **External config files**: More complex, requires file management

## References

- Flutter `SharedPreferences` (for future persistent storage)
- Configuration management best practices

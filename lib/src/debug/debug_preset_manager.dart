import 'ui_debug_capabilities.dart' as capabilities;
import 'package:flutter/material.dart';

/// Debug Preset Manager: Save/load debug capability configurations.
///
/// Allows developers to save and load debug capability presets for
/// quick switching between different debug modes.
///
/// This makes it easy to switch between different debug setups (e.g.,
/// "Performance Debug", "Animation Debug", "Layout Debug") without
/// manually enabling/disabling individual capabilities each time.
class DebugPresetManager {
  DebugPresetManager._();

  /// Storage for presets (in-memory by default)
  static final Map<String, Set<capabilities.UIDebugCapability>> _presets = {};

  /// Save current configuration as a preset
  static void savePreset(String name) {
    _presets[name] = Set.from(capabilities.UIDebugConfig.enabled);
  }

  /// Load a preset (apply saved configuration)
  static void loadPreset(String name) {
    final preset = _presets[name];
    if (preset != null) {
      capabilities.UIDebugConfig.enabled = Set.from(preset);
    }
  }

  /// Delete a preset
  static void deletePreset(String name) {
    _presets.remove(name);
  }

  /// Get list of preset names
  static List<String> getPresetNames() {
    return _presets.keys.toList()..sort();
  }

  /// Check if preset exists
  static bool hasPreset(String name) {
    return _presets.containsKey(name);
  }

  /// Get preset capabilities (without loading)
  static Set<capabilities.UIDebugCapability>? getPresetCapabilities(
      String name) {
    return _presets[name]?.toSet();
  }

  /// Clear all presets
  static void clearAllPresets() {
    _presets.clear();
  }

  /// Initialize with default presets
  static void initializeDefaultPresets() {
    // Performance Debug preset
    savePreset('Performance Debug');
    capabilities.UIDebugConfig.enableAll([
      capabilities.UIDebugCapability.frameRateMonitor,
      capabilities.UIDebugCapability.rebuildDetector,
      capabilities.UIDebugCapability.constraintCage,
    ]);
    savePreset('Performance Debug');

    // Animation Debug preset
    capabilities.UIDebugConfig.enableAll([
      capabilities.UIDebugCapability.flightRecorder,
      capabilities.UIDebugCapability.anchorLock,
      capabilities.UIDebugCapability.phaseContracts,
      capabilities.UIDebugCapability.phaseContinuity,
      capabilities.UIDebugCapability.animationTimelineScrubber,
      capabilities.UIDebugCapability.easingCurveVisualizer,
    ]);
    savePreset('Animation Debug');

    // Layout Debug preset
    capabilities.UIDebugConfig.enableAll([
      capabilities.UIDebugCapability.constraintCage,
      capabilities.UIDebugCapability.overlayBounds,
      capabilities.UIDebugCapability.coordinateGrid,
    ]);
    savePreset('Layout Debug');

    // Full Debug preset
    capabilities.UIDebugConfig.enableAllCapabilities();
    savePreset('Full Debug');

    // Clear to reset state
    capabilities.UIDebugConfig.disableAllCapabilities();
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

  @override
  State<DebugPresetSelector> createState() => _DebugPresetSelectorState();
}

class _DebugPresetSelectorState extends State<DebugPresetSelector> {
  String? _selectedPreset;
  final TextEditingController _presetNameController = TextEditingController();
  final List<String> _presets = [];

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  @override
  void dispose() {
    _presetNameController.dispose();
    super.dispose();
  }

  void _loadPresets() {
    setState(() {
      _presets.clear();
      _presets.addAll(DebugPresetManager.getPresetNames());
    });
  }

  void _savePreset() {
    final name = _presetNameController.text.trim();
    if (name.isEmpty) return;

    DebugPresetManager.savePreset(name);
    _presetNameController.clear();
    _loadPresets();
  }

  void _loadPreset(String name) {
    DebugPresetManager.loadPreset(name);
    setState(() {
      _selectedPreset = name;
    });
    widget.onPresetLoaded?.call(name);
  }

  void _deletePreset(String name) {
    DebugPresetManager.deletePreset(name);
    if (_selectedPreset == name) {
      _selectedPreset = null;
    }
    _loadPresets();
  }

  @override
  Widget build(BuildContext context) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.debugPresetManager)) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final position = widget.position ??
        Offset(
          screenSize.width - 250,
          8,
        );

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(
          top: position.dy,
          right: screenSize.width - position.dx - 240,
        ),
        child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildPresetList(),
            const SizedBox(height: 8),
            _buildSaveSection(),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'DEBUG PRESETS',
      style: TextStyle(
        color: Colors.cyan,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildPresetList() {
    if (_presets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No presets saved',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _presets.map((preset) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _loadPreset(preset),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedPreset == preset
                          ? Colors.cyan.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      preset,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: _selectedPreset == preset
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                onPressed: () => _deletePreset(preset),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Delete preset',
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _presetNameController,
            style: const TextStyle(color: Colors.white, fontSize: 10),
            decoration: InputDecoration(
              hintText: 'Preset name',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.cyan),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.save, color: Colors.cyan, size: 18),
          onPressed: _savePreset,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'Save current configuration',
        ),
      ],
    );
  }
}

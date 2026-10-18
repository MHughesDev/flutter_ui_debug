import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

class DebugControlPanel extends StatefulWidget {
  const DebugControlPanel({super.key});

  @override
  State<DebugControlPanel> createState() => _DebugControlPanelState();
}

class FloatingDebugControlPanel extends StatefulWidget {
  final VoidCallback? onClose;
  
  const FloatingDebugControlPanel({super.key, this.onClose});

  @override
  State<FloatingDebugControlPanel> createState() => _FloatingDebugControlPanelState();
}

class _DebugControlPanelState extends State<DebugControlPanel> {
  String _getCapabilityName(UIDebugCapability capability) {
    switch (capability) {
      case UIDebugCapability.flightRecorder:
        return 'Flight Recorder HUD';
      case UIDebugCapability.anchorLock:
        return 'Anchor Lock';
      case UIDebugCapability.overlayBounds:
        return 'Overlay Bounds';
      case UIDebugCapability.phaseContracts:
        return 'Phase Contracts';
      case UIDebugCapability.phaseContinuity:
        return 'Phase Continuity';
      case UIDebugCapability.expectedVsActual:
        return 'Expected vs Actual';
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
        return 'Coordinate Grid';
      case UIDebugCapability.ownershipTimeline:
        return 'Animation Ownership Timeline';
      case UIDebugCapability.anchorStabilityGraph:
        return 'Anchor Stability Graph';
      case UIDebugCapability.hitTestOverlay:
        return 'Hit Test Overlay';
      case UIDebugCapability.stressModes:
        return 'Stress Modes';
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

  void _applyPreset(String presetName) {
    UIDebugConfig.disableAllCapabilities();
    
    switch (presetName) {
      case 'All On':
        UIDebugConfig.enableAllCapabilities();
        break;
      case 'Animation':
        UIDebugConfig.enableAll([
          UIDebugCapability.frameRateMonitor,
          UIDebugCapability.animationTimelineScrubber,
          UIDebugCapability.easingCurveVisualizer,
          UIDebugCapability.phaseContracts,
          UIDebugCapability.phaseContinuity,
          UIDebugCapability.flightRecorder,
        ]);
        break;
      case 'Layout':
        UIDebugConfig.enableAll([
          UIDebugCapability.constraintCage,
          UIDebugCapability.rebuildDetector,
          UIDebugCapability.overlayBounds,
          UIDebugCapability.coordinateGrid,
        ]);
        break;
      case 'Performance':
        UIDebugConfig.enableAll([
          UIDebugCapability.frameRateMonitor,
          UIDebugCapability.rebuildDetector,
        ]);
        break;
      case 'All Off':
        // Already disabled above
        break;
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Debug Capabilities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: UIDebugCapability.values.map((capability) {
                  return CheckboxListTile(
                    title: Text(_getCapabilityName(capability)),
                    value: UIDebugConfig.isEnabled(capability),
                    onChanged: (enabled) {
                      if (enabled == true) {
                        UIDebugConfig.enable(capability);
                      } else {
                        UIDebugConfig.disable(capability);
                      }
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Quick Presets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _applyPreset('All On'),
                  child: const Text('All On'),
                ),
                ElevatedButton(
                  onPressed: () => _applyPreset('All Off'),
                  child: const Text('All Off'),
                ),
                ElevatedButton(
                  onPressed: () => _applyPreset('Animation'),
                  child: const Text('Animation'),
                ),
                ElevatedButton(
                  onPressed: () => _applyPreset('Layout'),
                  child: const Text('Layout'),
                ),
                ElevatedButton(
                  onPressed: () => _applyPreset('Performance'),
                  child: const Text('Performance'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingDebugControlPanelState extends State<FloatingDebugControlPanel> {
  String _getCapabilityName(UIDebugCapability capability) {
    switch (capability) {
      case UIDebugCapability.flightRecorder:
        return 'Flight Recorder HUD';
      case UIDebugCapability.anchorLock:
        return 'Anchor Lock';
      case UIDebugCapability.overlayBounds:
        return 'Overlay Bounds';
      case UIDebugCapability.phaseContracts:
        return 'Phase Contracts';
      case UIDebugCapability.phaseContinuity:
        return 'Phase Continuity';
      case UIDebugCapability.expectedVsActual:
        return 'Expected vs Actual';
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
        return 'Coordinate Grid';
      case UIDebugCapability.ownershipTimeline:
        return 'Animation Ownership Timeline';
      case UIDebugCapability.anchorStabilityGraph:
        return 'Anchor Stability Graph';
      case UIDebugCapability.hitTestOverlay:
        return 'Hit Test Overlay';
      case UIDebugCapability.stressModes:
        return 'Stress Modes';
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

  void _applyPreset(String presetName) {
    UIDebugConfig.disableAllCapabilities();
    
    switch (presetName) {
      case 'All On':
        UIDebugConfig.enableAllCapabilities();
        break;
      case 'Animation':
        UIDebugConfig.enableAll([
          UIDebugCapability.frameRateMonitor,
          UIDebugCapability.animationTimelineScrubber,
          UIDebugCapability.easingCurveVisualizer,
          UIDebugCapability.phaseContracts,
          UIDebugCapability.phaseContinuity,
          UIDebugCapability.flightRecorder,
        ]);
        break;
      case 'Layout':
        UIDebugConfig.enableAll([
          UIDebugCapability.constraintCage,
          UIDebugCapability.rebuildDetector,
          UIDebugCapability.overlayBounds,
          UIDebugCapability.coordinateGrid,
        ]);
        break;
      case 'Performance':
        UIDebugConfig.enableAll([
          UIDebugCapability.frameRateMonitor,
          UIDebugCapability.rebuildDetector,
        ]);
        break;
      case 'All Off':
        // Already disabled above
        break;
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final panelWidth = 320.0;
    final panelHeight = screenSize.height * 0.75;
    
    return Positioned(
      top: 80,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: panelWidth,
          height: panelHeight,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Header with drag handle
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tune, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Debug Capabilities',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: widget.onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Scrollable capabilities list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: UIDebugCapability.values.map((capability) {
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        _getCapabilityName(capability),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                      value: UIDebugConfig.isEnabled(capability),
                      onChanged: (enabled) {
                        if (enabled == true) {
                          UIDebugConfig.enable(capability);
                        } else {
                          UIDebugConfig.disable(capability);
                        }
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              
              // Quick presets section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Quick Presets',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _PresetButton(
                          label: 'All On',
                          onPressed: () => _applyPreset('All On'),
                        ),
                        _PresetButton(
                          label: 'All Off',
                          onPressed: () => _applyPreset('All Off'),
                        ),
                        _PresetButton(
                          label: 'Animation',
                          onPressed: () => _applyPreset('Animation'),
                        ),
                        _PresetButton(
                          label: 'Layout',
                          onPressed: () => _applyPreset('Layout'),
                        ),
                        _PresetButton(
                          label: 'Performance',
                          onPressed: () => _applyPreset('Performance'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PresetButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}

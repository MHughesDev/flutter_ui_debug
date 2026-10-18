import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Stress & Distortion Modes: Safe-area and layout mutation testing.
///
/// Simulates:
/// - Exaggerated safe-area insets (notches, status bars)
/// - Keyboard height changes
/// - Orientation changes
/// - Text scale changes
/// - Navigation resize
///
/// This helps verify that anchored overlays remain stable under stress conditions.
class StressModeConfig {
  /// Safe-area distortion settings
  final SafeAreaDistortion? safeAreaDistortion;

  /// Dynamic layout mutation settings
  final LayoutMutationConfig? layoutMutation;

  /// Whether stress modes are active
  final bool isActive;

  const StressModeConfig({
    this.safeAreaDistortion,
    this.layoutMutation,
    this.isActive = false,
  });

  /// Create a config with safe-area distortion
  factory StressModeConfig.safeAreaDistortion({
    double topInset = 100,
    double bottomInset = 100,
    double leftInset = 50,
    double rightInset = 50,
  }) {
    return StressModeConfig(
      isActive: true,
      safeAreaDistortion: SafeAreaDistortion(
        topInset: topInset,
        bottomInset: bottomInset,
        leftInset: leftInset,
        rightInset: rightInset,
      ),
    );
  }

  /// Create a config with layout mutations
  factory StressModeConfig.layoutMutations({
    Duration mutationInterval = const Duration(seconds: 2),
    bool simulateOrientationChange = true,
    bool simulateTextScaleChange = true,
    bool simulateNavResize = true,
  }) {
    return StressModeConfig(
      isActive: true,
      layoutMutation: LayoutMutationConfig(
        mutationInterval: mutationInterval,
        simulateOrientationChange: simulateOrientationChange,
        simulateTextScaleChange: simulateTextScaleChange,
        simulateNavResize: simulateNavResize,
      ),
    );
  }
}

/// Safe-area distortion configuration
class SafeAreaDistortion {
  final double topInset;
  final double bottomInset;
  final double leftInset;
  final double rightInset;

  const SafeAreaDistortion({
    this.topInset = 0,
    this.bottomInset = 0,
    this.leftInset = 0,
    this.rightInset = 0,
  });
}

/// Layout mutation configuration
class LayoutMutationConfig {
  final Duration mutationInterval;
  final bool simulateOrientationChange;
  final bool simulateTextScaleChange;
  final bool simulateNavResize;

  const LayoutMutationConfig({
    this.mutationInterval = const Duration(seconds: 2),
    this.simulateOrientationChange = true,
    this.simulateTextScaleChange = true,
    this.simulateNavResize = true,
  });
}

/// Widget that applies stress mode distortions to MediaQuery
class StressModeWrapper extends StatelessWidget {
  final Widget child;
  final StressModeConfig? config;

  const StressModeWrapper({
    super.key,
    required this.child,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    // Only apply if capability is enabled and config is active
    if (!capabilities.UIDebugConfig.isEnabled(
            capabilities.UIDebugCapability.stressModes) ||
        config == null ||
        !config!.isActive) {
      return child;
    }

    MediaQueryData mediaQuery = MediaQuery.of(context);

    // Apply safe-area distortion
    if (config!.safeAreaDistortion != null) {
      final distortion = config!.safeAreaDistortion!;
      mediaQuery = mediaQuery.copyWith(
        padding: EdgeInsets.only(
          top: mediaQuery.padding.top + distortion.topInset,
          bottom: mediaQuery.padding.bottom + distortion.bottomInset,
          left: mediaQuery.padding.left + distortion.leftInset,
          right: mediaQuery.padding.right + distortion.rightInset,
        ),
        viewPadding: EdgeInsets.only(
          top: mediaQuery.viewPadding.top + distortion.topInset,
          bottom: mediaQuery.viewPadding.bottom + distortion.bottomInset,
          left: mediaQuery.viewPadding.left + distortion.leftInset,
          right: mediaQuery.viewPadding.right + distortion.rightInset,
        ),
      );
    }

    // Apply text scale distortion
    if (config!.layoutMutation?.simulateTextScaleChange == true) {
      final currentScaler = mediaQuery.textScaler;
      mediaQuery = mediaQuery.copyWith(
        textScaler: TextScaler.linear(currentScaler.scale(1.0) * 1.5), // 50% larger
      );
    }

    return MediaQuery(
      data: mediaQuery,
      child: child,
    );
  }
}

/// Widget that triggers periodic layout mutations
class LayoutMutationTrigger extends StatefulWidget {
  final Widget child;
  final LayoutMutationConfig? config;

  const LayoutMutationTrigger({
    super.key,
    required this.child,
    this.config,
  });

  @override
  State<LayoutMutationTrigger> createState() => _LayoutMutationTriggerState();
}

class _LayoutMutationTriggerState extends State<LayoutMutationTrigger> {
  Orientation? _currentOrientation;
  double _textScaleFactor = 1.0;
  bool _isMutating = false;

  @override
  void initState() {
    super.initState();
    if (widget.config != null &&
        capabilities.UIDebugConfig.isEnabled(
            capabilities.UIDebugCapability.stressModes)) {
      _startMutations();
    }
  }

  void _startMutations() {
    if (widget.config == null) return;

    Future.delayed(widget.config!.mutationInterval, () {
      if (!mounted) return;
      setState(() {
        _isMutating = true;
      });

      // Trigger mutation
      if (widget.config!.simulateOrientationChange) {
        _mutateOrientation();
      }
      if (widget.config!.simulateTextScaleChange) {
        _mutateTextScale();
      }

      // Reset after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isMutating = false;
          });
        }
      });

      // Schedule next mutation
      _startMutations();
    });
  }

  void _mutateOrientation() {
    final current = MediaQuery.of(context).orientation;
    setState(() {
      _currentOrientation = current == Orientation.portrait
          ? Orientation.landscape
          : Orientation.portrait;
    });
  }

  void _mutateTextScale() {
    setState(() {
      _textScaleFactor = _textScaleFactor == 1.0 ? 1.5 : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!capabilities.UIDebugConfig.isEnabled(
            capabilities.UIDebugCapability.stressModes) ||
        widget.config == null) {
      return widget.child;
    }

    MediaQueryData mediaQuery = MediaQuery.of(context);

    // Apply orientation mutation
    if (_currentOrientation != null &&
        widget.config!.simulateOrientationChange) {
      final size = mediaQuery.size;
      mediaQuery = mediaQuery.copyWith(
        size: Size(size.height, size.width),
      );
    }

    // Apply text scale mutation
    if (widget.config!.simulateTextScaleChange) {
      mediaQuery = mediaQuery.copyWith(
        textScaler: TextScaler.linear(_textScaleFactor),
      );
    }

    return MediaQuery(
      data: mediaQuery,
      child: Stack(
        children: [
          widget.child,
          if (_isMutating)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.red.withValues(alpha: 0.1),
                  child: const Center(
                    child: Text(
                      'LAYOUT MUTATION',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Global stress mode configuration
class StressModeManager {
  static StressModeConfig? _currentConfig;

  /// Get current stress mode config
  static StressModeConfig? get currentConfig => _currentConfig;

  /// Set stress mode config
  static void setConfig(StressModeConfig? config) {
    _currentConfig = config;
  }

  /// Enable safe-area distortion
  static void enableSafeAreaDistortion({
    double topInset = 100,
    double bottomInset = 100,
    double leftInset = 50,
    double rightInset = 50,
  }) {
    _currentConfig = StressModeConfig.safeAreaDistortion(
      topInset: topInset,
      bottomInset: bottomInset,
      leftInset: leftInset,
      rightInset: rightInset,
    );
  }

  /// Enable layout mutations
  static void enableLayoutMutations({
    Duration mutationInterval = const Duration(seconds: 2),
    bool simulateOrientationChange = true,
    bool simulateTextScaleChange = true,
    bool simulateNavResize = true,
  }) {
    _currentConfig = StressModeConfig.layoutMutations(
      mutationInterval: mutationInterval,
      simulateOrientationChange: simulateOrientationChange,
      simulateTextScaleChange: simulateTextScaleChange,
      simulateNavResize: simulateNavResize,
    );
  }

  /// Disable stress modes
  static void disable() {
    _currentConfig = null;
  }
}

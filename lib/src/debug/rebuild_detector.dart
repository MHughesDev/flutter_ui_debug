import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Rebuild Detector: Tracks rebuilds, layout changes, and RenderObject replacements.
///
/// Displays:
/// - White flash → rebuild detected
/// - Red flash → layout metric change
/// - Purple flash → RenderObject replaced
///
/// Also provides counters that can be integrated into Flight Recorder HUD.
///
/// Usage: Wrap the widget you want to track with RebuildDetector.
class RebuildDetector extends StatefulWidget {
  /// The widget to track for rebuilds
  final Widget child;

  /// Callback to notify when rebuild count changes
  final ValueChanged<int>? onRebuildCountChanged;

  /// Callback to notify when layout change count changes
  final ValueChanged<int>? onLayoutChangeCountChanged;

  /// Callback to notify when RenderObject replacement count changes
  final ValueChanged<int>? onRenderObjectReplacedCountChanged;

  const RebuildDetector({
    super.key,
    required this.child,
    this.onRebuildCountChanged,
    this.onLayoutChangeCountChanged,
    this.onRenderObjectReplacedCountChanged,
  });

  @override
  State<RebuildDetector> createState() => _RebuildDetectorState();
}

class _RebuildDetectorState extends State<RebuildDetector>
    with SingleTickerProviderStateMixin {
  /// Track a rebuild event
  void trackRebuild() {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.rebuildDetector)) {
      return;
    }

    _rebuildCount++;
    widget.onRebuildCountChanged?.call(_rebuildCount);
    _triggerFlash(RebuildEventType.rebuild);
  }
  int _rebuildCount = 0;
  int _layoutChangeCount = 0;
  int _renderObjectReplacedCount = 0;

  // Flash animation
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;
  RebuildEventType? _currentFlashType;

  // Previous layout values for comparison
  Size? _previousSize;
  Offset? _previousPosition;

  // RenderObject identity tracking
  RenderObject? _previousRenderObject;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flashController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Note: We don't track rebuilds here because this widget itself rebuilds
    // Rebuilds should be tracked in the parent widget's build method
  }

  void _trackLayoutChange(Size newSize, Offset? newPosition) {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.rebuildDetector)) {
      return;
    }

    final hasLayoutChange = _previousSize != null &&
        (_previousSize != newSize ||
            (_previousPosition != null &&
                newPosition != null &&
                _previousPosition != newPosition));

    if (hasLayoutChange) {
      _layoutChangeCount++;
      widget.onLayoutChangeCountChanged?.call(_layoutChangeCount);
      _triggerFlash(RebuildEventType.layoutChange);
    }

    _previousSize = newSize;
    _previousPosition = newPosition;
  }

  void _trackRenderObjectReplacement(RenderObject? renderObject) {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.rebuildDetector)) {
      return;
    }

    if (_previousRenderObject != null &&
        renderObject != null &&
        _previousRenderObject != renderObject) {
      _renderObjectReplacedCount++;
      widget.onRenderObjectReplacedCountChanged?.call(_renderObjectReplacedCount);
      _triggerFlash(RebuildEventType.renderObjectReplaced);
    }

    _previousRenderObject = renderObject;
  }

  void _triggerFlash(RebuildEventType type) {
    _currentFlashType = type;
    _flashController.forward(from: 0.0).then((_) {
      _flashController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.rebuildDetector)) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Track layout changes
        final renderObject = context.findRenderObject();
        final renderBox = renderObject as RenderBox?;
        final size = renderBox?.size ?? screenSize;
        final position = renderBox?.localToGlobal(Offset.zero);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _trackLayoutChange(size, position);
            _trackRenderObjectReplacement(renderObject);
          }
        });

        return AnimatedBuilder(
          animation: _flashAnimation,
          builder: (context, child) {
            Color? flashColor;
            if (_currentFlashType != null && _flashAnimation.value > 0) {
              switch (_currentFlashType!) {
                case RebuildEventType.rebuild:
                  flashColor = Colors.white.withValues(
                      alpha: _flashAnimation.value * 0.3);
                case RebuildEventType.layoutChange:
                  flashColor = Colors.red.withValues(
                      alpha: _flashAnimation.value * 0.3);
                case RebuildEventType.renderObjectReplaced:
                  flashColor = Colors.purple.withValues(
                      alpha: _flashAnimation.value * 0.3);
              }
            }

            return Stack(
              children: [
                if (flashColor != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: flashColor,
                      ),
                    ),
                  ),
                widget.child,
              ],
            );
          },
        );
      },
    );
  }

  /// Get current rebuild count
  int get rebuildCount => _rebuildCount;

  /// Get current layout change count
  int get layoutChangeCount => _layoutChangeCount;

  /// Get current RenderObject replacement count
  int get renderObjectReplacedCount => _renderObjectReplacedCount;

  /// Reset all counters
  void reset() {
    setState(() {
      _rebuildCount = 0;
      _layoutChangeCount = 0;
      _renderObjectReplacedCount = 0;
    });
    widget.onRebuildCountChanged?.call(0);
    widget.onLayoutChangeCountChanged?.call(0);
    widget.onRenderObjectReplacedCountChanged?.call(0);
  }
}

/// Types of rebuild events that can be detected
enum RebuildEventType {
  /// Widget rebuild detected
  rebuild,

  /// Layout metric change detected
  layoutChange,

  /// RenderObject replaced
  renderObjectReplaced,
}

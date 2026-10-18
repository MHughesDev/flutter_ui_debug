import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Hit-Test Overlay: Shows tappable regions and gesture receivers.
///
/// Displays:
/// - Tappable regions (areas that respond to taps)
/// - Actual gesture receiver highlight (which widget receives the gesture)
/// - Gesture arena resolution (which gesture wins in conflicts)
///
/// This helps debug gesture conflicts and hit-test issues.
class HitTestOverlay extends StatefulWidget {
  /// Widget to wrap with hit-test debugging
  final Widget child;

  /// Whether to show tappable regions
  final bool showTappableRegions;

  /// Whether to show gesture receiver highlights
  final bool showGestureReceivers;

  /// Whether to show gesture arena resolution
  final bool showGestureArena;

  const HitTestOverlay({
    super.key,
    required this.child,
    this.showTappableRegions = true,
    this.showGestureReceivers = true,
    this.showGestureArena = true,
  });

  @override
  State<HitTestOverlay> createState() => _HitTestOverlayState();
}

class _HitTestOverlayState extends State<HitTestOverlay> {
  final Map<GlobalKey, HitTestInfo> _hitTestInfo = {};
  final List<GestureEvent> _gestureEvents = [];
  static const int _maxEvents = 50;

  @override
  Widget build(BuildContext context) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.hitTestOverlay)) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: CustomPaint(
              painter: _HitTestPainter(
                hitTestInfo: _hitTestInfo,
                gestureEvents: _gestureEvents,
                showTappableRegions: widget.showTappableRegions,
                showGestureReceivers: widget.showGestureReceivers,
                showGestureArena: widget.showGestureArena,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Register a widget as tappable
  void registerTappable(GlobalKey key, Rect bounds, String? label) {
    setState(() {
      _hitTestInfo[key] = HitTestInfo(
        bounds: bounds,
        label: label,
        isTappable: true,
      );
    });
  }

  /// Register a gesture receiver
  void registerGestureReceiver(GlobalKey key, Rect bounds, String gestureType) {
    setState(() {
      _hitTestInfo[key] = HitTestInfo(
        bounds: bounds,
        label: gestureType,
        isGestureReceiver: true,
      );
    });
  }

  /// Record a gesture event
  void recordGestureEvent(GestureEvent event) {
    setState(() {
      _gestureEvents.add(event);
      if (_gestureEvents.length > _maxEvents) {
        _gestureEvents.removeAt(0);
      }
    });
  }
}

/// Information about a hit-test target
class HitTestInfo {
  final Rect bounds;
  final String? label;
  final bool isTappable;
  final bool isGestureReceiver;

  HitTestInfo({
    required this.bounds,
    this.label,
    this.isTappable = false,
    this.isGestureReceiver = false,
  });
}

/// Gesture event information
class GestureEvent {
  final Offset position;
  final String type;
  final String? receiver;
  final DateTime timestamp;

  GestureEvent({
    required this.position,
    required this.type,
    this.receiver,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Painter for drawing hit-test overlay
class _HitTestPainter extends CustomPainter {
  final Map<GlobalKey, HitTestInfo> hitTestInfo;
  final List<GestureEvent> gestureEvents;
  final bool showTappableRegions;
  final bool showGestureReceivers;
  final bool showGestureArena;

  _HitTestPainter({
    required this.hitTestInfo,
    required this.gestureEvents,
    required this.showTappableRegions,
    required this.showGestureReceivers,
    required this.showGestureArena,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw tappable regions
    if (showTappableRegions) {
      for (final info in hitTestInfo.values) {
        if (info.isTappable) {
          _drawTappableRegion(canvas, info);
        }
      }
    }

    // Draw gesture receivers
    if (showGestureReceivers) {
      for (final info in hitTestInfo.values) {
        if (info.isGestureReceiver) {
          _drawGestureReceiver(canvas, info);
        }
      }
    }

    // Draw recent gesture events
    if (showGestureArena) {
      _drawGestureEvents(canvas, size);
    }
  }

  void _drawTappableRegion(Canvas canvas, HitTestInfo info) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(info.bounds, paint);

    final borderPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(info.bounds, borderPaint);

    if (info.label != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: info.label!,
          style: TextStyle(
            color: Colors.blue,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          info.bounds.left + 4,
          info.bounds.top + 4,
        ),
      );
    }
  }

  void _drawGestureReceiver(Canvas canvas, HitTestInfo info) {
    final paint = Paint()
      ..color = Colors.green.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(info.bounds, paint);

    final borderPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(info.bounds, borderPaint);

    if (info.label != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'RECEIVER: ${info.label!}',
          style: const TextStyle(
            color: Colors.green,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          info.bounds.left + 4,
          info.bounds.top + 4,
        ),
      );
    }
  }

  void _drawGestureEvents(Canvas canvas, Size size) {
    // Draw recent gesture events as small indicators
    final now = DateTime.now();
    for (final event in gestureEvents) {
      final age = now.difference(event.timestamp);
      if (age.inSeconds > 2) continue; // Only show events from last 2 seconds

      final alpha = 1.0 - (age.inMilliseconds / 2000.0);
      final paint = Paint()
        ..color = Colors.orange.withValues(alpha: alpha * 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(event.position, 8, paint);

      final borderPaint = Paint()
        ..color = Colors.orange.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(event.position, 8, borderPaint);

      if (event.receiver != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: event.receiver!,
            style: TextStyle(
              color: Colors.orange,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            event.position.dx + 12,
            event.position.dy - 6,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HitTestPainter oldDelegate) {
    return hitTestInfo != oldDelegate.hitTestInfo ||
        gestureEvents != oldDelegate.gestureEvents ||
        showTappableRegions != oldDelegate.showTappableRegions ||
        showGestureReceivers != oldDelegate.showGestureReceivers ||
        showGestureArena != oldDelegate.showGestureArena;
  }
}

/// Helper widget that wraps a child and provides hit-test debugging
class HitTestDebugWrapper extends StatelessWidget {
  final Widget child;
  final GlobalKey hitTestKey;

  const HitTestDebugWrapper({
    super.key,
    required this.child,
    required this.hitTestKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        // Record tap event for debugging
        if (capabilities.UIDebugConfig.isEnabled(
            capabilities.UIDebugCapability.hitTestOverlay)) {
          // This would be handled by the overlay system
        }
      },
      child: child,
    );
  }
}

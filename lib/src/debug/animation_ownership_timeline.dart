import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Animation Ownership Timeline: Tracks and displays animation controller lifecycle.
///
/// Shows a timeline bar displaying overlapping controller ownership periods.
/// This helps catch:
/// - Competing controllers (multiple controllers active simultaneously)
/// - Premature disposal (controller disposed while animation is active)
/// - Lifecycle issues (controllers not properly cleaned up)
///
/// The timeline displays ownership periods as colored bars, with overlapping
/// periods highlighted to indicate potential issues.
class AnimationOwnershipTimeline extends StatefulWidget {
  /// List of animation controller ownership periods to display
  final List<ControllerOwnershipPeriod> ownershipPeriods;

  /// Optional label for this timeline
  final String? label;

  const AnimationOwnershipTimeline({
    super.key,
    required this.ownershipPeriods,
    this.label,
  });

  @override
  State<AnimationOwnershipTimeline> createState() =>
      _AnimationOwnershipTimelineState();
}

class _AnimationOwnershipTimelineState
    extends State<AnimationOwnershipTimeline> {
  @override
  Widget build(BuildContext context) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.ownershipTimeline)) {
      return const SizedBox.shrink();
    }

    if (widget.ownershipPeriods.isEmpty) {
      return const SizedBox.shrink();
    }

    final width = MediaQuery.sizeOf(context).width;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: SizedBox(
          width: width > 16 ? width - 16 : width,
          child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            _buildTimeline(),
            const SizedBox(height: 4),
            _buildLegend(),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    // Calculate timeline bounds
    final startTime = widget.ownershipPeriods
        .map((p) => p.startTime)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final endTime = widget.ownershipPeriods
        .map((p) => p.endTime ?? DateTime.now())
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final duration = endTime.difference(startTime);

    if (duration.inMilliseconds == 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: CustomPaint(
        painter: _TimelinePainter(
          ownershipPeriods: widget.ownershipPeriods,
          startTime: startTime,
          duration: duration,
        ),
        size: const Size(double.infinity, 40),
      ),
    );
  }

  Widget _buildLegend() {
    // Group periods by controller ID for legend
    final controllerIds = widget.ownershipPeriods
        .map((p) => p.controllerId)
        .toSet()
        .toList();

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: controllerIds.map((id) {
        final period = widget.ownershipPeriods.firstWhere(
          (p) => p.controllerId == id,
        );
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: period.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              id,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/// Painter for drawing the timeline with ownership periods
class _TimelinePainter extends CustomPainter {
  final List<ControllerOwnershipPeriod> ownershipPeriods;
  final DateTime startTime;
  final Duration duration;

  _TimelinePainter({
    required this.ownershipPeriods,
    required this.startTime,
    required this.duration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // Draw timeline background
    paint.color = Colors.white.withValues(alpha: 0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(2),
      ),
      paint,
    );

    // Draw ownership periods
    for (final period in ownershipPeriods) {
      final startOffset = _getTimeOffset(period.startTime, size.width);
      final endOffset = period.endTime != null
          ? _getTimeOffset(period.endTime!, size.width)
          : size.width;

      paint.color = period.color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            startOffset,
            4,
            endOffset - startOffset,
            size.height - 8,
          ),
          const Radius.circular(2),
        ),
        paint,
      );

      // Draw label if there's space
      if (endOffset - startOffset > 40) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: period.controllerId,
            style: const TextStyle(
              color: Colors.white,
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
            startOffset + 4,
            (size.height - textPainter.height) / 2,
          ),
        );
      }
    }

    // Check for overlaps and highlight them
    _drawOverlaps(canvas, size);
  }

  void _drawOverlaps(Canvas canvas, Size size) {
    // Find overlapping periods
    for (int i = 0; i < ownershipPeriods.length; i++) {
      for (int j = i + 1; j < ownershipPeriods.length; j++) {
        final period1 = ownershipPeriods[i];
        final period2 = ownershipPeriods[j];

        if (_periodsOverlap(period1, period2)) {
          // Draw warning indicator
          final overlapStart = _getTimeOffset(
            period1.startTime.isAfter(period2.startTime)
                ? period1.startTime
                : period2.startTime,
            size.width,
          );
          final overlapEnd = _getTimeOffset(
            (period1.endTime ?? DateTime.now())
                .isBefore(period2.endTime ?? DateTime.now())
                ? (period1.endTime ?? DateTime.now())
                : (period2.endTime ?? DateTime.now()),
            size.width,
          );

          final paint = Paint()
            ..color = Colors.red.withValues(alpha: 0.3)
            ..style = PaintingStyle.fill;
          canvas.drawRect(
            Rect.fromLTWH(
              overlapStart,
              0,
              overlapEnd - overlapStart,
              size.height,
            ),
            paint,
          );
        }
      }
    }
  }

  bool _periodsOverlap(
    ControllerOwnershipPeriod period1,
    ControllerOwnershipPeriod period2,
  ) {
    final start1 = period1.startTime;
    final end1 = period1.endTime ?? DateTime.now();
    final start2 = period2.startTime;
    final end2 = period2.endTime ?? DateTime.now();

    return start1.isBefore(end2) && start2.isBefore(end1);
  }

  double _getTimeOffset(DateTime time, double width) {
    final elapsed = time.difference(startTime);
    final progress = elapsed.inMilliseconds / duration.inMilliseconds;
    return (progress * width).clamp(0.0, width);
  }

  @override
  bool shouldRepaint(_TimelinePainter oldDelegate) {
    return ownershipPeriods != oldDelegate.ownershipPeriods ||
        startTime != oldDelegate.startTime ||
        duration != oldDelegate.duration;
  }
}

/// Represents a period of time when an animation controller was active.
///
/// Tracks when a controller was created, when it started animating,
/// and when it was disposed or completed.
class ControllerOwnershipPeriod {
  /// Unique identifier for this controller (e.g., "NavButton_001")
  final String controllerId;

  /// When the controller was created/started
  final DateTime startTime;

  /// When the controller was disposed/completed (null if still active)
  final DateTime? endTime;

  /// Color to use for this period in the timeline
  final Color color;

  /// Optional description of what this controller was doing
  final String? description;

  ControllerOwnershipPeriod({
    required this.controllerId,
    required this.startTime,
    this.endTime,
    Color? color,
    this.description,
  }) : color = color ?? _getDefaultColor(controllerId);

  /// Get a default color based on controller ID hash
  static Color _getDefaultColor(String id) {
    final hash = id.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  /// Check if this period is currently active
  bool get isActive => endTime == null;

  /// Get the duration of this period
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}

/// Helper class for tracking animation controller ownership.
///
/// Use this to track controller lifecycle and detect issues like:
/// - Multiple controllers active simultaneously
/// - Controllers not properly disposed
/// - Premature disposal
class AnimationOwnershipTracker {
  final List<ControllerOwnershipPeriod> _periods = [];
  final Map<String, ControllerOwnershipPeriod> _activePeriods = {};

  /// Start tracking a controller
  void startTracking(String controllerId, {String? description}) {
    final period = ControllerOwnershipPeriod(
      controllerId: controllerId,
      startTime: DateTime.now(),
      description: description,
    );
    _periods.add(period);
    _activePeriods[controllerId] = period;
  }

  /// Stop tracking a controller (mark as completed/disposed)
  void stopTracking(String controllerId) {
    final period = _activePeriods.remove(controllerId);
    if (period != null) {
      final index = _periods.indexOf(period);
      if (index != -1) {
        _periods[index] = ControllerOwnershipPeriod(
          controllerId: period.controllerId,
          startTime: period.startTime,
          endTime: DateTime.now(),
          color: period.color,
          description: period.description,
        );
      }
    }
  }

  /// Get all tracked periods
  List<ControllerOwnershipPeriod> get periods => List.unmodifiable(_periods);

  /// Get currently active periods
  List<ControllerOwnershipPeriod> get activePeriods {
    return _activePeriods.values.toList();
  }

  /// Check if there are overlapping periods (competing controllers)
  bool hasOverlaps() {
    for (int i = 0; i < _periods.length; i++) {
      for (int j = i + 1; j < _periods.length; j++) {
        final period1 = _periods[i];
        final period2 = _periods[j];

        if (period1.endTime == null || period2.endTime == null) {
          // At least one is still active, check if they overlap
          final start1 = period1.startTime;
          final end1 = period1.endTime ?? DateTime.now();
          final start2 = period2.startTime;
          final end2 = period2.endTime ?? DateTime.now();

          if (start1.isBefore(end2) && start2.isBefore(end1)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Clear all tracked periods
  void clear() {
    _periods.clear();
    _activePeriods.clear();
  }
}

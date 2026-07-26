import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Frame Rate Monitor: Real-time FPS overlay with jank detection.
///
/// Displays current FPS, average FPS, and highlights frame drops (jank).
/// Typically positioned in top-right corner of screen.
///
/// This helps identify performance issues during animation debugging by
/// providing immediate visual feedback about frame rate performance.
class FrameRateMonitor extends StatefulWidget {
  /// Position of the monitor overlay (default: top-right)
  final Offset? position;

  /// Whether to show average FPS
  final bool showAverage;

  /// Whether to show jank indicator
  final bool showJankIndicator;

  /// FPS threshold for jank detection (default: 16ms = 60 FPS)
  final Duration jankThreshold;

  const FrameRateMonitor({
    super.key,
    this.position,
    this.showAverage = true,
    this.showJankIndicator = true,
    this.jankThreshold = const Duration(milliseconds: 16),
  });

  @override
  State<FrameRateMonitor> createState() => _FrameRateMonitorState();
}

class _FrameRateMonitorState extends State<FrameRateMonitor> {
  double _currentFPS = 60.0;
  double _averageFPS = 60.0;
  bool _jankDetected = false;
  final List<Duration> _frameTimes = [];
  static const int _maxFrameTimes = 60; // 1 second at 60 FPS
  DateTime? _lastFrameTime;
  Timer? _jankTimer;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _stopMonitoring();
    super.dispose();
  }

  void _startMonitoring() {
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _stopMonitoring() {
    _jankTimer?.cancel();
    _jankTimer = null;
  }

  void _onFrame(Duration timestamp) {
    if (!mounted) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      final fps = 1000.0 / frameDuration.inMilliseconds;

      setState(() {
        _currentFPS = fps.clamp(0.0, 120.0); // Cap at 120 FPS

        // Add to frame times list
        _frameTimes.add(frameDuration);
        if (_frameTimes.length > _maxFrameTimes) {
          _frameTimes.removeAt(0);
        }

        // Calculate average FPS
        if (_frameTimes.isNotEmpty) {
          final totalMs = _frameTimes.fold<int>(
            0,
            (sum, duration) => sum + duration.inMilliseconds,
          );
          final avgFrameTime = totalMs / _frameTimes.length;
          _averageFPS = 1000.0 / avgFrameTime;
        }

        // Detect jank
        if (widget.showJankIndicator) {
          if (frameDuration > widget.jankThreshold) {
            _jankDetected = true;
            _jankTimer?.cancel();
            _jankTimer = Timer(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _jankDetected = false;
                });
              }
            });
          }
        }
      });
    }

    _lastFrameTime = now;
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  @override
  Widget build(BuildContext context) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.frameRateMonitor)) {
      return const SizedBox.shrink();
    }

    final position = widget.position ??
        Offset(
          MediaQuery.of(context).size.width - 220,
          8,
        );

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: position.dx, top: position.dy),
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
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'monospace',
            height: 1.2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 4),
              _buildDivider(),
              _buildRow('FPS', _currentFPS.toStringAsFixed(1), _getFPSColor(_currentFPS)),
              if (widget.showAverage)
                _buildRow('Avg', _averageFPS.toStringAsFixed(1), _getFPSColor(_averageFPS)),
              if (widget.showJankIndicator && _jankDetected) ...[
                const SizedBox(height: 4),
                _buildJankIndicator(),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'FPS MONITOR',
      style: TextStyle(
        color: Colors.cyan,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: 200,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJankIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: const Text(
        'JANK DETECTED',
        style: TextStyle(
          color: Colors.red,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getFPSColor(double fps) {
    if (fps >= 55) {
      return Colors.green; // Excellent
    } else if (fps >= 45) {
      return Colors.yellow; // Acceptable
    } else {
      return Colors.red; // Poor
    }
  }
}

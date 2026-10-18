import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;
import 'animation_phase_metadata.dart';

/// Animation Timeline Scrubber: Interactive timeline for debugging animations.
///
/// Allows manual control of animation progress, scrubbing, and frame-by-frame
/// stepping. Displays phase boundaries and current progress.
///
/// This is essential for precise animation debugging and understanding
/// animation state at any given moment.
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

  /// Whether to show phase markers
  final bool showPhaseMarkers;

  /// Whether to show controls
  final bool showControls;

  /// Whether to show time display
  final bool showTimeDisplay;

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
    this.showPhaseMarkers = true,
    this.showControls = true,
    this.showTimeDisplay = true,
  });

  @override
  State<AnimationTimelineScrubber> createState() =>
      _AnimationTimelineScrubberState();
}

class _AnimationTimelineScrubberState
    extends State<AnimationTimelineScrubber> {
  @override
  Widget build(BuildContext context) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.animationTimelineScrubber)) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final position = widget.position ??
        Offset(
          (screenSize.width - 400) / 2, // Center horizontally
          screenSize.height - 120, // Near bottom (top coordinate)
        );

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: position.dx, top: position.dy),
        child: Container(
        width: 400,
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
            _buildTimeline(),
            if (widget.showControls) ...[
              const SizedBox(height: 8),
              _buildControls(),
            ],
            if (widget.showTimeDisplay && widget.duration != null) ...[
              const SizedBox(height: 4),
              _buildTimeDisplay(),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'ANIMATION TIMELINE',
      style: TextStyle(
        color: Colors.cyan,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTimeline() {
    return Stack(
      children: [
        // Timeline track
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: CustomPaint(
            painter: _TimelinePainter(
              progress: widget.progress,
              phases: widget.showPhaseMarkers ? widget.phases : null,
            ),
            child: GestureDetector(
              onTapDown: (details) => _handleTap(details.localPosition),
              onPanUpdate: (details) => _handlePan(details.localPosition),
              child: Container(),
            ),
          ),
        ),
        // Progress indicator
        Positioned(
          left: widget.progress * 400 - 8,
          top: 0,
          child: Container(
            width: 16,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Step backward
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 20),
          onPressed: widget.onStepBackward,
          tooltip: 'Step backward',
        ),
        const SizedBox(width: 8),
        // Play/Pause
        IconButton(
          icon: Icon(
            widget.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => widget.onPlayPause?.call(!widget.isPlaying),
          tooltip: widget.isPlaying ? 'Pause' : 'Play',
        ),
        const SizedBox(width: 8),
        // Step forward
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 20),
          onPressed: widget.onStepForward,
          tooltip: 'Step forward',
        ),
      ],
    );
  }

  Widget _buildTimeDisplay() {
    final currentTime = widget.duration! * widget.progress;
    final totalTime = widget.duration!;
    return Center(
      child: Text(
        '${_formatDuration(currentTime)} / ${_formatDuration(totalTime)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    final milliseconds = duration.inMilliseconds % 1000;
    return '${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')}s';
  }

  void _handleTap(Offset localPosition) {
    final progress = (localPosition.dx / 400).clamp(0.0, 1.0);
    widget.onProgressChanged?.call(progress);
  }

  void _handlePan(Offset localPosition) {
    final progress = (localPosition.dx / 400).clamp(0.0, 1.0);
    widget.onProgressChanged?.call(progress);
  }
}

class _TimelinePainter extends CustomPainter {
  final double progress;
  final List<AnimationPhaseMetadata>? phases;

  _TimelinePainter({
    required this.progress,
    this.phases,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw phase boundaries
    if (phases != null) {
      final phasePaint = Paint()
        ..color = Colors.cyan.withValues(alpha: 0.5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      for (final phase in phases!) {
        final startX = phase.startProgress * size.width;
        final endX = phase.endProgress * size.width;

        // Draw phase boundary lines
        canvas.drawLine(
          Offset(startX, 0),
          Offset(startX, size.height),
          phasePaint,
        );
        canvas.drawLine(
          Offset(endX, 0),
          Offset(endX, size.height),
          phasePaint,
        );

        // Draw phase label
        if (startX < size.width - 50) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: phase.name,
              style: TextStyle(
                color: Colors.cyan.withValues(alpha: 0.7),
                fontSize: 8,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(startX + 2, size.height - textPainter.height - 2),
          );
        }
      }
    }

    // Draw progress indicator line
    final progressPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final progressX = progress * size.width;
    canvas.drawLine(
      Offset(progressX, 0),
      Offset(progressX, size.height),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_TimelinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phases != phases;
  }
}

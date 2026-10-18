import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Flight Recorder HUD: Real-time telemetry overlay for animation diagnostics.
///
/// Displays animation metadata in a compact overlay in the top-left corner:
/// - Animation ID
/// - Coordinate system
/// - Anchor position
/// - Current phase
/// - Anchor delta (stability measurement)
/// - Overlay status
/// - Rebuild count
/// - Layout change count
/// - Violation count
///
/// This makes animation bugs self-evident in screen recordings by providing
/// continuous telemetry throughout the animation lifecycle.
class FlightRecorderHUD extends StatefulWidget {
  /// Animation identifier (e.g., "NAV_EMANATE_03")
  final String? animId;

  /// Coordinate system being used (e.g., "Global", "Local")
  final String? coordSystem;

  /// Frozen anchor position
  final Offset? anchorPosition;

  /// Current animation phase (e.g., "Phase 1", "Phase 2", "Phase 3")
  final String? currentPhase;

  /// Anchor delta (distance from original anchor, measures drift)
  final double? anchorDelta;

  /// Overlay status (e.g., "Active", "Complete")
  final String? overlayStatus;

  /// Rebuild count during animation
  final int rebuildCount;

  /// Layout change count during animation
  final int layoutChangeCount;

  /// Violation count (number of detected issues)
  final int violationCount;

  /// Optional snapshot hash for export
  final String? snapshotHash;

  const FlightRecorderHUD({
    super.key,
    this.animId,
    this.coordSystem,
    this.anchorPosition,
    this.currentPhase,
    this.anchorDelta,
    this.overlayStatus,
    this.rebuildCount = 0,
    this.layoutChangeCount = 0,
    this.violationCount = 0,
    this.snapshotHash,
  });

  @override
  State<FlightRecorderHUD> createState() => _FlightRecorderHUDState();
}

class _FlightRecorderHUDState extends State<FlightRecorderHUD> {
  @override
  Widget build(BuildContext context) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(capabilities.UIDebugCapability.flightRecorder)) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8),
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
                if (widget.animId != null) _buildRow('AnimID', widget.animId!),
                if (widget.coordSystem != null)
                  _buildRow('Coord', widget.coordSystem!),
                if (widget.anchorPosition != null)
                  _buildRow(
                    'Anchor',
                    '(${widget.anchorPosition!.dx.toStringAsFixed(1)}, '
                    '${widget.anchorPosition!.dy.toStringAsFixed(1)})',
                  ),
                if (widget.currentPhase != null)
                  _buildRow('Phase', widget.currentPhase!),
                if (widget.anchorDelta != null)
                  _buildRow(
                    'ΔAnchor',
                    '${widget.anchorDelta!.toStringAsFixed(2)}px',
                    _getDeltaColor(widget.anchorDelta!),
                  ),
                if (widget.overlayStatus != null)
                  _buildRow('Status', widget.overlayStatus!),
                _buildRow('Rebuilds', widget.rebuildCount.toString()),
                _buildRow('Layout Δ', widget.layoutChangeCount.toString()),
                _buildRow(
                  'Violations',
                  widget.violationCount.toString(),
                  widget.violationCount > 0 ? Colors.red : Colors.white,
                ),
                if (widget.snapshotHash != null) ...[
                  const SizedBox(height: 4),
                  _buildDivider(),
                  _buildRow('Hash', widget.snapshotHash!.substring(0, 8)),
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
      'FLIGHT RECORDER',
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

  Widget _buildRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 70,
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
              color: valueColor ?? Colors.white,
              fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDeltaColor(double delta) {
    if (delta < 0.1) {
      return Colors.green; // Stable
    } else if (delta < 2.0) {
      return Colors.yellow; // Minor drift
    } else {
      return Colors.red; // Significant drift
    }
  }
}

/// Metadata class for passing animation information to Flight Recorder HUD.
///
/// This class aggregates animation state that can be passed to the HUD
/// for real-time telemetry display.
class FlightRecorderMetadata {
  final String? animId;
  final String? coordSystem;
  final Offset? anchorPosition;
  final String? currentPhase;
  final double? anchorDelta;
  final String? overlayStatus;
  final int rebuildCount;
  final int layoutChangeCount;
  final int violationCount;
  final String? snapshotHash;

  const FlightRecorderMetadata({
    this.animId,
    this.coordSystem,
    this.anchorPosition,
    this.currentPhase,
    this.anchorDelta,
    this.overlayStatus,
    this.rebuildCount = 0,
    this.layoutChangeCount = 0,
    this.violationCount = 0,
    this.snapshotHash,
  });

  FlightRecorderMetadata copyWith({
    String? animId,
    String? coordSystem,
    Offset? anchorPosition,
    String? currentPhase,
    double? anchorDelta,
    String? overlayStatus,
    int? rebuildCount,
    int? layoutChangeCount,
    int? violationCount,
    String? snapshotHash,
  }) {
    return FlightRecorderMetadata(
      animId: animId ?? this.animId,
      coordSystem: coordSystem ?? this.coordSystem,
      anchorPosition: anchorPosition ?? this.anchorPosition,
      currentPhase: currentPhase ?? this.currentPhase,
      anchorDelta: anchorDelta ?? this.anchorDelta,
      overlayStatus: overlayStatus ?? this.overlayStatus,
      rebuildCount: rebuildCount ?? this.rebuildCount,
      layoutChangeCount: layoutChangeCount ?? this.layoutChangeCount,
      violationCount: violationCount ?? this.violationCount,
      snapshotHash: snapshotHash ?? this.snapshotHash,
    );
  }
}

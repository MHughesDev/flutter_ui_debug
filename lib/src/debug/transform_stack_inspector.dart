import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;

/// Transform Stack Inspector: Overlay panel showing transform stack information.
///
/// Displays:
/// - T: translate(x, y)
/// - S: scale(x, y)
/// - R: rotate(angle)
/// - ALIGN: alignment
/// - SPACE: coordinate space (global/local)
/// - Optional: Alternate-order preview (dotted magenta)
///
/// This reveals the transform stack applied to animated widgets and helps
/// diagnose transform order issues.
class TransformStackInspector extends StatelessWidget {
  /// Translation offset
  final Offset? translation;

  /// Scale values (x, y)
  final Offset? scale;

  /// Rotation angle in radians
  final double? rotation;

  /// Alignment for transforms
  final Alignment? alignment;

  /// Coordinate space (e.g., "Global", "Local")
  final String? coordinateSpace;

  /// Optional alternate transform order preview
  final bool showAlternateOrder;

  const TransformStackInspector({
    super.key,
    this.translation,
    this.scale,
    this.rotation,
    this.alignment,
    this.coordinateSpace,
    this.showAlternateOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only render if capability is enabled
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.transformStackInspector)) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.cyan.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontFamily: 'monospace',
            height: 1.4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildDivider(),
              if (translation != null) _buildTransformRow('T', _formatTranslation(translation!)),
              if (scale != null) _buildTransformRow('S', _formatScale(scale!)),
              if (rotation != null) _buildTransformRow('R', _formatRotation(rotation!)),
              if (alignment != null) _buildTransformRow('ALIGN', _formatAlignment(alignment!)),
              if (coordinateSpace != null) _buildTransformRow('SPACE', coordinateSpace!),
              if (showAlternateOrder) ...[
                const SizedBox(height: 8),
                _buildDivider(),
                _buildAlternateOrderHint(),
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
      'TRANSFORM STACK',
      style: TextStyle(
        color: Colors.cyan,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: 220,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildTransformRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.cyan.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternateOrderHint() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFFF00FF).withValues(alpha: 0.6),
            border: Border.all(
              color: const Color(0xFFFF00FF),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Alternate order',
          style: TextStyle(
            color: Color(0xFFFF00FF),
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _formatTranslation(Offset translation) {
    return '(${translation.dx.toStringAsFixed(2)}, ${translation.dy.toStringAsFixed(2)})';
  }

  String _formatScale(Offset scale) {
    if ((scale.dx - scale.dy).abs() < 0.01) {
      // Uniform scale
      return scale.dx.toStringAsFixed(3);
    } else {
      // Non-uniform scale
      return '(${scale.dx.toStringAsFixed(3)}, ${scale.dy.toStringAsFixed(3)})';
    }
  }

  String _formatRotation(double rotation) {
    final degrees = (rotation * 180 / 3.141592653589793).toStringAsFixed(1);
    return '$degrees° (${rotation.toStringAsFixed(4)} rad)';
  }

  String _formatAlignment(Alignment alignment) {
    return '(${alignment.x.toStringAsFixed(2)}, ${alignment.y.toStringAsFixed(2)})';
  }
}

/// Metadata class for passing transform information to Transform Stack Inspector.
///
/// This class aggregates transform state that can be passed to the inspector
/// for real-time display.
class TransformStackMetadata {
  final Offset? translation;
  final Offset? scale;
  final double? rotation;
  final Alignment? alignment;
  final String? coordinateSpace;
  final bool showAlternateOrder;

  const TransformStackMetadata({
    this.translation,
    this.scale,
    this.rotation,
    this.alignment,
    this.coordinateSpace,
    this.showAlternateOrder = false,
  });

  TransformStackMetadata copyWith({
    Offset? translation,
    Offset? scale,
    double? rotation,
    Alignment? alignment,
    String? coordinateSpace,
    bool? showAlternateOrder,
  }) {
    return TransformStackMetadata(
      translation: translation ?? this.translation,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      alignment: alignment ?? this.alignment,
      coordinateSpace: coordinateSpace ?? this.coordinateSpace,
      showAlternateOrder: showAlternateOrder ?? this.showAlternateOrder,
    );
  }
}

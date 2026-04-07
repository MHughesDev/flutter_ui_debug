import 'package:flutter/material.dart';

/// Snapshot of a single tagged widget in the current frame.
@immutable
class UiObjectSnapshot {
  const UiObjectSnapshot({
    required this.tag,
    required this.widgetType,
    required this.globalRect,
    required this.visibilityFraction,
    required this.capturedAt,
    this.note,
  });

  final String tag;
  final String widgetType;
  final Rect globalRect;
  final double visibilityFraction;
  final DateTime capturedAt;
  final String? note;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'tag': tag,
      'widgetType': widgetType,
      'globalRect': <String, double>{
        'left': globalRect.left,
        'top': globalRect.top,
        'right': globalRect.right,
        'bottom': globalRect.bottom,
        'width': globalRect.width,
        'height': globalRect.height,
      },
      'visibilityFraction': visibilityFraction,
      'capturedAt': capturedAt.toIso8601String(),
      'note': note,
    };
  }
}

/// Snapshot describing a tracked animation state.
@immutable
class AnimationSnapshot {
  const AnimationSnapshot({
    required this.id,
    required this.label,
    required this.value,
    required this.status,
    required this.isAnimating,
    required this.capturedAt,
  });

  final String id;
  final String label;
  final double value;
  final AnimationStatus status;
  final bool isAnimating;
  final DateTime capturedAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'label': label,
      'value': value,
      'status': status.name,
      'isAnimating': isAnimating,
      'capturedAt': capturedAt.toIso8601String(),
    };
  }
}

/// Aggregate view of debugger state.
@immutable
class UiDebugSnapshot {
  const UiDebugSnapshot({
    required this.capturedAt,
    required this.objects,
    required this.animations,
  });

  final DateTime capturedAt;
  final List<UiObjectSnapshot> objects;
  final List<AnimationSnapshot> animations;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'capturedAt': capturedAt.toIso8601String(),
      'objects': objects.map((o) => o.toJson()).toList(growable: false),
      'animations': animations.map((a) => a.toJson()).toList(growable: false),
    };
  }
}

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ui_debug_models.dart';

typedef UiDebugSnapshotWriter = Future<void> Function(UiDebugSnapshot snapshot);

/// Central state manager for tracked objects/animations and command actions.
class UiDebugController extends ChangeNotifier {
  UiDebugController({UiDebugSnapshotWriter? writer})
    : _writer = writer ?? _defaultSnapshotWriter;

  final UiDebugSnapshotWriter _writer;
  final Map<String, _TrackedUiObject> _objects = <String, _TrackedUiObject>{};
  final Map<String, _TrackedAnimation> _animations =
      <String, _TrackedAnimation>{};
  final List<String> _logs = <String>[];
  bool _notifyQueued = false;
  bool _isDisposed = false;

  bool _overlayVisible = false;
  bool _highlightObjects = true;
  bool _pauseAnimations = false;
  UiDebugSnapshot _lastSnapshot = UiDebugSnapshot(
    capturedAt: DateTime.now(),
    objects: const <UiObjectSnapshot>[],
    animations: const <AnimationSnapshot>[],
  );

  bool get overlayVisible => _overlayVisible;
  bool get highlightObjects => _highlightObjects;
  bool get pauseAnimations => _pauseAnimations;

  UnmodifiableListView<String> get logs => UnmodifiableListView<String>(_logs);
  UiDebugSnapshot get lastSnapshot => _lastSnapshot;

  void setOverlayVisible(bool value) {
    if (_overlayVisible == value) {
      return;
    }
    _overlayVisible = value;
    _recordLog('overlay.${value ? 'open' : 'closed'}');
    _scheduleNotifyListeners();
  }

  void toggleOverlay() {
    setOverlayVisible(!_overlayVisible);
  }

  void setHighlightObjects(bool value) {
    if (_highlightObjects == value) {
      return;
    }
    _highlightObjects = value;
    _recordLog('highlight.${value ? 'on' : 'off'}');
    _scheduleNotifyListeners();
  }

  void setPauseAnimations(bool value) {
    if (_pauseAnimations == value) {
      return;
    }
    _pauseAnimations = value;
    _recordLog('animations.${value ? 'paused' : 'running'}');
    for (final _TrackedAnimation tracked in _animations.values) {
      if (value) {
        tracked.pause();
      } else {
        tracked.resumeIfNeeded();
      }
    }
    _scheduleNotifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    _scheduleNotifyListeners();
  }

  void registerObject({
    required String tag,
    required BuildContext context,
    String? note,
  }) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) {
      return;
    }
    final Offset topLeft = renderObject.localToGlobal(Offset.zero);
    final Rect rect = topLeft & renderObject.size;
    final bool visible = rect.width > 0 && rect.height > 0;
    final _TrackedUiObject next = _TrackedUiObject(
      tag: tag,
      widgetType: context.widget.runtimeType.toString(),
      rect: rect,
      visibilityFraction: visible ? 1.0 : 0.0,
      note: note,
    );
    final _TrackedUiObject? previous = _objects[tag];
    if (previous != null && previous.isEquivalent(next)) {
      return;
    }
    _objects[tag] = next;
    _scheduleNotifyListeners();
  }

  void unregisterObject(String tag) {
    _objects.remove(tag);
    _scheduleNotifyListeners();
  }

  void registerAnimation({
    required String id,
    required AnimationController controller,
    String? label,
  }) {
    if (_animations.containsKey(id)) {
      return;
    }
    final _TrackedAnimation tracked = _TrackedAnimation(
      id: id,
      label: label ?? id,
      controller: controller,
      onAnimationTick: _scheduleNotifyListeners,
    );
    _animations[id] = tracked;
    if (_pauseAnimations) {
      controller.stop(canceled: false);
    }
    _scheduleNotifyListeners();
  }

  void unregisterAnimation(String id) {
    _animations.remove(id)?.dispose();
    _scheduleNotifyListeners();
  }

  Future<UiDebugSnapshot> captureSnapshot() async {
    final DateTime now = DateTime.now();
    final List<UiObjectSnapshot> objectSnapshots = _objects.values
        .map(
          (_TrackedUiObject object) => UiObjectSnapshot(
            tag: object.tag,
            widgetType: object.widgetType,
            globalRect: object.rect,
            visibilityFraction: object.visibilityFraction,
            capturedAt: now,
            note: object.note,
          ),
        )
        .toList(growable: false);

    final List<AnimationSnapshot> animationSnapshots = _animations.values
        .map(
          (_TrackedAnimation tracked) => AnimationSnapshot(
            id: tracked.id,
            label: tracked.label,
            value: tracked.controller.value,
            status: tracked.controller.status,
            isAnimating: tracked.controller.isAnimating,
            capturedAt: now,
          ),
        )
        .toList(growable: false);

    _lastSnapshot = UiDebugSnapshot(
      capturedAt: now,
      objects: objectSnapshots,
      animations: animationSnapshots,
    );
    _recordLog(
      'snapshot.objects=${objectSnapshots.length}.animations=${animationSnapshots.length}',
    );
    _scheduleNotifyListeners();
    await _writer(_lastSnapshot);
    return _lastSnapshot;
  }

  List<UiObjectSnapshot> listObjectSnapshots() {
    final DateTime now = DateTime.now();
    return _objects.values
        .map(
          (_TrackedUiObject object) => UiObjectSnapshot(
            tag: object.tag,
            widgetType: object.widgetType,
            globalRect: object.rect,
            visibilityFraction: object.visibilityFraction,
            capturedAt: now,
            note: object.note,
          ),
        )
        .toList(growable: false);
  }

  List<AnimationSnapshot> listAnimationSnapshots() {
    final DateTime now = DateTime.now();
    return _animations.values
        .map(
          (_TrackedAnimation tracked) => AnimationSnapshot(
            id: tracked.id,
            label: tracked.label,
            value: tracked.controller.value,
            status: tracked.controller.status,
            isAnimating: tracked.controller.isAnimating,
            capturedAt: now,
          ),
        )
        .toList(growable: false);
  }

  static Future<void> _defaultSnapshotWriter(UiDebugSnapshot snapshot) async {
    final String jsonPayload = const JsonEncoder.withIndent(
      '  ',
    ).convert(snapshot.toJson());
    debugPrint('UI_DEBUG_CAPTURE\n$jsonPayload');
    if (kIsWeb) {
      return;
    }
    try {
      final Directory tempDirectory = Directory.systemTemp;
      final File output = File(
        '${tempDirectory.path}/flutter_ui_debug_capture.json',
      );
      await output.writeAsString(jsonPayload, flush: true);
    } catch (_) {
      // Best effort output only, no-op if filesystem is restricted.
    }
  }

  void _recordLog(String message) {
    final String line = '${DateTime.now().toIso8601String()} | $message';
    _logs.insert(0, line);
    if (_logs.length > 30) {
      _logs.removeRange(30, _logs.length);
    }
  }

  void _scheduleNotifyListeners() {
    if (_notifyQueued || _isDisposed) {
      return;
    }
    _notifyQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyQueued = false;
      if (_isDisposed) {
        return;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final _TrackedAnimation tracked in _animations.values) {
      tracked.dispose();
    }
    _animations.clear();
    super.dispose();
  }
}

class _TrackedUiObject {
  _TrackedUiObject({
    required this.tag,
    required this.widgetType,
    required this.rect,
    required this.visibilityFraction,
    this.note,
  });

  final String tag;
  final String widgetType;
  final Rect rect;
  final double visibilityFraction;
  final String? note;

  bool isEquivalent(_TrackedUiObject other) {
    return tag == other.tag &&
        widgetType == other.widgetType &&
        rect == other.rect &&
        visibilityFraction == other.visibilityFraction &&
        note == other.note;
  }
}

class _TrackedAnimation {
  _TrackedAnimation({
    required this.id,
    required this.label,
    required this.controller,
    required this.onAnimationTick,
  }) {
    controller.addListener(onAnimationTick);
  }

  final String id;
  final String label;
  final AnimationController controller;
  final VoidCallback onAnimationTick;

  bool _wasAnimatingBeforePause = false;

  void pause() {
    _wasAnimatingBeforePause = controller.isAnimating;
    if (_wasAnimatingBeforePause) {
      controller.stop(canceled: false);
    }
  }

  void resumeIfNeeded() {
    if (_wasAnimatingBeforePause && !controller.isAnimating) {
      if (controller.status == AnimationStatus.reverse ||
          controller.value >= 1.0) {
        controller.reverse();
      } else {
        controller.forward();
      }
    }
    _wasAnimatingBeforePause = false;
  }

  void dispose() {
    controller.removeListener(onAnimationTick);
  }
}

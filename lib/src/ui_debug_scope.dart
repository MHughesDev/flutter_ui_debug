import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui_debug_controller.dart';
import 'ui_debug_models.dart';

/// Top-level wrapper that enables the in-app command menu and HUD overlay.
class UiDebugScope extends StatefulWidget {
  const UiDebugScope({
    required this.child,
    super.key,
    this.controller,
    this.menuShortcut = const <LogicalKeyboardKey>[
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.keyD,
    ],
  });

  final Widget child;
  final UiDebugController? controller;
  final List<LogicalKeyboardKey> menuShortcut;

  static UiDebugController of(BuildContext context) {
    final _UiDebugInherited? inherited = context
        .dependOnInheritedWidgetOfExactType<_UiDebugInherited>();
    assert(inherited != null, 'UiDebugScope.of() called without UiDebugScope');
    return inherited!.controller;
  }

  @override
  State<UiDebugScope> createState() => _UiDebugScopeState();
}

class _UiDebugScopeState extends State<UiDebugScope> {
  late final UiDebugController _controller =
      widget.controller ?? UiDebugController();
  late final bool _ownsController = widget.controller == null;
  final FocusNode _focusNode = FocusNode(debugLabel: 'UiDebugScope');
  final Set<LogicalKeyboardKey> _pressedKeys = <LogicalKeyboardKey>{};

  @override
  void dispose() {
    _focusNode.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  bool _matchesShortcut() {
    for (final LogicalKeyboardKey key in widget.menuShortcut) {
      if (!_pressedKeys.contains(key)) {
        return false;
      }
    }
    return true;
  }

  KeyEventResult _handleKeyEvent(FocusNode _, KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
      if (_matchesShortcut()) {
        _controller.toggleOverlay();
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return _UiDebugInherited(
      controller: _controller,
      child: Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                child ?? const SizedBox.shrink(),
                if (_controller.highlightObjects)
                  IgnorePointer(
                    child: _UiObjectHighlightOverlay(controller: _controller),
                  ),
                if (_controller.overlayVisible)
                  _UiCommandOverlay(controller: _controller)
                else
                  Positioned(
                    left: 14,
                    bottom: 18,
                    child: FloatingActionButton.small(
                      heroTag: 'ui-debug-open',
                      backgroundColor: Colors.black87,
                      onPressed: _controller.toggleOverlay,
                      child: const Icon(Icons.bug_report, color: Colors.white),
                    ),
                  ),
              ],
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

class _UiObjectHighlightOverlay extends StatelessWidget {
  const _UiObjectHighlightOverlay({required this.controller});

  final UiDebugController controller;

  @override
  Widget build(BuildContext context) {
    final List<UiObjectSnapshot> objects = controller.listObjectSnapshots();
    if (objects.isEmpty) {
      return const SizedBox.shrink();
    }
    return Stack(
      alignment: Alignment.topLeft,
      children: objects
          .map(
            (UiObjectSnapshot object) => Positioned(
              left: object.globalRect.left,
              top: object.globalRect.top,
              width: object.globalRect.width,
              height: object.globalRect.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orangeAccent, width: 1.5),
                  color: Colors.orangeAccent.withValues(alpha: 0.08),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _UiCommandOverlay extends StatelessWidget {
  const _UiCommandOverlay({required this.controller});

  final UiDebugController controller;

  @override
  Widget build(BuildContext context) {
    final List<UiObjectSnapshot> objectSnapshots = controller
        .listObjectSnapshots();
    final List<AnimationSnapshot> animationSnapshots = controller
        .listAnimationSnapshots();

    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 360, maxHeight: 460),
          decoration: BoxDecoration(
            color: const Color(0xFF15171A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'UI Debug Command Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.toggleOverlay,
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _QuickActionChip(
                      label: controller.highlightObjects
                          ? 'Hide object overlay'
                          : 'Show object overlay',
                      onTap: () => controller.setHighlightObjects(
                        !controller.highlightObjects,
                      ),
                    ),
                    _QuickActionChip(
                      label: controller.pauseAnimations
                          ? 'Resume animations'
                          : 'Pause animations',
                      onTap: () => controller.setPauseAnimations(
                        !controller.pauseAnimations,
                      ),
                    ),
                    _QuickActionChip(
                      label: 'Capture snapshot',
                      onTap: () async {
                        await controller.captureSnapshot();
                      },
                    ),
                    _QuickActionChip(
                      label: 'Clear logs',
                      onTap: controller.clearLogs,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.32),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView(
                        children: <Widget>[
                          _InfoLine(
                            label: 'Tracked objects',
                            value: '${objectSnapshots.length}',
                          ),
                          _InfoLine(
                            label: 'Tracked animations',
                            value: '${animationSnapshots.length}',
                          ),
                          const SizedBox(height: 8),
                          if (objectSnapshots.isNotEmpty) ...<Widget>[
                            const Text(
                              'Objects',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...objectSnapshots.map(
                              (UiObjectSnapshot object) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '${object.tag} '
                                  '[${object.globalRect.left.toStringAsFixed(1)}, '
                                  '${object.globalRect.top.toStringAsFixed(1)}] '
                                  '${object.globalRect.width.toStringAsFixed(1)}'
                                  'x${object.globalRect.height.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (animationSnapshots.isNotEmpty) ...<Widget>[
                            const Text(
                              'Animations',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...animationSnapshots.map(
                              (AnimationSnapshot animation) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '${animation.label} '
                                  'v=${animation.value.toStringAsFixed(2)} '
                                  '${animation.status.name}',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          const Text(
                            'Recent command log',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...controller.logs.map(
                            (String line) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                line,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Shortcut: Ctrl + Shift + D or bug button',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: Colors.white12,
      side: const BorderSide(color: Colors.white12),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      onPressed: onTap,
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UiDebugInherited extends InheritedWidget {
  const _UiDebugInherited({required this.controller, required super.child});

  final UiDebugController controller;

  @override
  bool updateShouldNotify(_UiDebugInherited oldWidget) {
    return !identical(controller, oldWidget.controller);
  }
}

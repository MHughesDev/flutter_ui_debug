import 'package:flutter/material.dart';

import 'ui_debug_controller.dart';
import 'ui_debug_scope.dart';

/// Wrap any widget to register its screen bounds with the debugger.
class UiDebugProbe extends StatefulWidget {
  const UiDebugProbe({
    required this.tag,
    required this.child,
    super.key,
    this.note,
  });

  final String tag;
  final Widget child;
  final String? note;

  @override
  State<UiDebugProbe> createState() => _UiDebugProbeState();
}

class _UiDebugProbeState extends State<UiDebugProbe> {
  UiDebugController? _controller;
  bool _registerQueued = false;

  void _scheduleRegister() {
    if (_registerQueued) {
      return;
    }
    _registerQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerQueued = false;
      if (!mounted) {
        return;
      }
      _controller ??= UiDebugScope.of(context);
      _controller!.registerObject(
        tag: widget.tag,
        context: context,
        note: widget.note,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _scheduleRegister();
  }

  @override
  void didUpdateWidget(covariant UiDebugProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleRegister();
  }

  @override
  void dispose() {
    _controller?.unregisterObject(widget.tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleRegister();
    return widget.child;
  }
}

/// Tracks an [AnimationController] and exposes it to the debugger command menu.
class UiAnimationProbe extends StatefulWidget {
  const UiAnimationProbe({
    required this.id,
    required this.controller,
    required this.child,
    super.key,
    this.label,
  });

  final String id;
  final String? label;
  final AnimationController controller;
  final Widget child;

  @override
  State<UiAnimationProbe> createState() => _UiAnimationProbeState();
}

class _UiAnimationProbeState extends State<UiAnimationProbe> {
  UiDebugController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= UiDebugScope.of(context);
    _controller!.registerAnimation(
      id: widget.id,
      controller: widget.controller,
      label: widget.label,
    );
  }

  @override
  void didUpdateWidget(covariant UiAnimationProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.id != widget.id) {
      _controller ??= UiDebugScope.of(context);
      _controller!.unregisterAnimation(oldWidget.id);
      _controller!.registerAnimation(
        id: widget.id,
        controller: widget.controller,
        label: widget.label,
      );
    }
  }

  @override
  void dispose() {
    _controller?.unregisterAnimation(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

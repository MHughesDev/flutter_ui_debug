import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

void main() {
  runApp(const DebugTesterApp());
}

class DebugTesterApp extends StatelessWidget {
  const DebugTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter UI Debug Tester',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      builder: (BuildContext context, Widget? child) {
        return UiDebugScope(child: child ?? const SizedBox.shrink());
      },
      home: const DebugTesterHomePage(),
    );
  }
}

class DebugTesterHomePage extends StatefulWidget {
  const DebugTesterHomePage({super.key});

  @override
  State<DebugTesterHomePage> createState() => _DebugTesterHomePageState();
}

class _DebugTesterHomePageState extends State<DebugTesterHomePage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideOffset;
  bool _showSecondaryPanel = true;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _slideOffset =
        Tween<Offset>(
          begin: const Offset(-0.2, 0),
          end: const Offset(0.2, 0),
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        final UiDebugController debugController = UiDebugScope.of(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('UI Debug Tester'),
            actions: <Widget>[
              IconButton(
                key: const Key('captureSnapshotButton'),
                tooltip: 'Capture snapshot',
                icon: const Icon(Icons.camera_outlined),
                onPressed: () async {
                  final ScaffoldMessengerState scaffoldMessenger =
                      ScaffoldMessenger.of(context);
                  await debugController.captureSnapshot();
                  if (!mounted) {
                    return;
                  }
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Snapshot captured')),
                  );
                },
              ),
            ],
          ),
          body: UiAnimationProbe(
            id: 'pulse-controller',
            label: 'Pulse card animation',
            controller: _pulseController,
            child: UiAnimationProbe(
              id: 'slide-controller',
              label: 'Sliding chip animation',
              controller: _slideController,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  UiDebugProbe(
                    tag: 'hero-card',
                    note: 'Primary animated card',
                    child: ScaleTransition(
                      scale: _pulseScale,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.animation_outlined, size: 30),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tap actions below, then open the debug command '
                                  'menu with the floating bug button.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  UiDebugProbe(
                    tag: 'slide-chip',
                    note: 'Moving element for placement checks',
                    child: SlideTransition(
                      position: _slideOffset,
                      child: const Chip(
                        avatar: Icon(Icons.circle, size: 14),
                        label: Text('Sliding chip'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  UiDebugProbe(
                    tag: 'tap-counter',
                    note: 'Tap interaction state',
                    child: Text(
                      'Tap Count: $_tapCount',
                      key: const Key('tapCounterLabel'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      ElevatedButton.icon(
                        key: const Key('incrementTapButton'),
                        onPressed: () {
                          setState(() {
                            _tapCount += 1;
                          });
                        },
                        icon: const Icon(Icons.touch_app_outlined),
                        label: const Text('Increment tap'),
                      ),
                      FilledButton.tonalIcon(
                        key: const Key('togglePanelButton'),
                        onPressed: () {
                          setState(() {
                            _showSecondaryPanel = !_showSecondaryPanel;
                          });
                        },
                        icon: Icon(
                          _showSecondaryPanel
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        label: Text(
                          _showSecondaryPanel ? 'Hide panel' : 'Show panel',
                        ),
                      ),
                      OutlinedButton.icon(
                        key: const Key('toggleDebugMenuButton'),
                        onPressed: debugController.toggleOverlay,
                        icon: const Icon(Icons.bug_report_outlined),
                        label: const Text('Open command menu'),
                      ),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _showSecondaryPanel
                        ? UiDebugProbe(
                            tag: 'secondary-panel',
                            note:
                                'Optional panel to validate mount/unmount '
                                'updates',
                            child: Container(
                              key: const ValueKey<String>(
                                'secondary-panel-visible',
                              ),
                              margin: const EdgeInsets.only(top: 18),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Secondary panel visible. Toggle me to verify '
                                'object enumeration updates in the debugger.',
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

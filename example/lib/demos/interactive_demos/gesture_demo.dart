import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

class GestureDemo extends StatefulWidget {
  const GestureDemo({super.key});

  @override
  State<GestureDemo> createState() => _GestureDemoState();
}

class _GestureDemoState extends State<GestureDemo> {
  String _lastGesture = 'None';
  Offset _tapPosition = Offset.zero;
  Offset _panPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Gesture Demo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Text(
            'Last Gesture: $_lastGesture',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 32),
          // Hit test overlay demo
          if (UIDebugConfig.isEnabled(UIDebugCapability.hitTestOverlay))
            Container(
              width: 300,
              height: 200,
              color: Colors.blue.withValues(alpha: 0.2),
              child: Stack(
                children: [
                  // Tap area
                  Positioned(
                    left: _tapPosition.dx,
                    top: _tapPosition.dy,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _lastGesture = 'Tap';
                          _tapPosition = Offset(
                            _tapPosition.dx == 0 ? 50 : 0,
                            _tapPosition.dy == 0 ? 50 : 0,
                          );
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.red.withValues(alpha: 0.5),
                        child: const Center(
                          child: Text('Tap Me'),
                        ),
                      ),
                    ),
                  ),
                  // Pan area
                  Positioned(
                    left: _panPosition.dx,
                    top: _panPosition.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _lastGesture = 'Pan';
                          _panPosition = details.localPosition;
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.green.withValues(alpha: 0.5),
                        child: const Center(
                          child: Text('Pan Me'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _lastGesture = 'Button Press';
                _tapPosition = Offset.zero;
                _panPosition = Offset.zero;
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

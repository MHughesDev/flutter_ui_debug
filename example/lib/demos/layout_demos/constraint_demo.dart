import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

class ConstraintDemo extends StatelessWidget {
  const ConstraintDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Constraint Demo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          // Constraint cage demo
          if (UIDebugConfig.isEnabled(UIDebugCapability.constraintCage))
            Container(
              width: 200,
              height: 200,
              color: Colors.blue.withValues(alpha: 0.2),
              child: const Center(
                child: Text('Constraint Cage'),
              ),
            ),
          const SizedBox(height: 16),
          // Rebuild detector demo
          if (UIDebugConfig.isEnabled(UIDebugCapability.rebuildDetector))
            const RebuildDetector(
              child: _RebuildableWidget(),
            ),
          const SizedBox(height: 16),
          // Overlay bounds demo
          if (UIDebugConfig.isEnabled(UIDebugCapability.overlayBounds))
            Container(
              width: 150,
              height: 150,
              color: Colors.green.withValues(alpha: 0.3),
              child: const Center(
                child: Text('Overlay Bounds'),
              ),
            ),
        ],
      ),
    );
  }
}

class _RebuildableWidget extends StatefulWidget {
  const _RebuildableWidget();

  @override
  State<_RebuildableWidget> createState() => _RebuildableWidgetState();
}

class _RebuildableWidgetState extends State<_RebuildableWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _counter++;
        });
      },
      child: Text('Rebuild Count: $_counter'),
    );
  }
}

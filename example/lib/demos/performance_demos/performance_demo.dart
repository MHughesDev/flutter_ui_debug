import 'package:flutter/material.dart';
import '../../widgets/reusable_animated_box.dart';

class PerformanceDemo extends StatelessWidget {
  const PerformanceDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Performance Demo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          // Multiple animated boxes to test performance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const ReusableAnimatedBox(
                animId: 'perf-1',
                phases: [
                  SimplePhase(
                    name: 'Anim 1',
                    startProgress: 0.0,
                    endProgress: 1.0,
                    hasTranslation: true,
                  ),
                ],
                duration: Duration(seconds: 2),
                color: Colors.red,
              ),
              const ReusableAnimatedBox(
                animId: 'perf-2',
                phases: [
                  SimplePhase(
                    name: 'Anim 2',
                    startProgress: 0.0,
                    endProgress: 1.0,
                    hasScale: true,
                  ),
                ],
                duration: Duration(seconds: 2),
                color: Colors.orange,
              ),
              const ReusableAnimatedBox(
                animId: 'perf-3',
                phases: [
                  SimplePhase(
                    name: 'Anim 3',
                    startProgress: 0.0,
                    endProgress: 1.0,
                    hasRotation: true,
                  ),
                ],
                duration: Duration(seconds: 2),
                color: Colors.yellow,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const SizedBox(height: 16),
          const Text(
            'Enable "Easing Curve Visualizer" in Debug Controls\nto see curve visualization',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

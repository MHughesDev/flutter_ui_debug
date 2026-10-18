import 'package:flutter/material.dart';
import '../../widgets/reusable_animated_box.dart';

class MultiPhaseDemo extends StatelessWidget {
  const MultiPhaseDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ReusableAnimatedBox(
        animId: 'multi-phase-demo',
        phases: [
          SimplePhase(
            name: 'Phase 1: Slide',
            startProgress: 0.0,
            endProgress: 0.33,
            hasTranslation: true,
          ),
          SimplePhase(
            name: 'Phase 2: Scale',
            startProgress: 0.33,
            endProgress: 0.66,
            hasScale: true,
          ),
          SimplePhase(
            name: 'Phase 3: Rotate',
            startProgress: 0.66,
            endProgress: 1.0,
            hasRotation: true,
          ),
        ],
        duration: Duration(seconds: 4),
        beginOffset: Offset.zero,
        endOffset: Offset(1, 0),
        beginScale: 1.0,
        endScale: 1.5,
        beginRotation: 0.0,
        endRotation: 2 * 3.14159,
        color: Colors.green,
      ),
    );
  }
}

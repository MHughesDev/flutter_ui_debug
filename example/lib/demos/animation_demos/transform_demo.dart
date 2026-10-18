import 'package:flutter/material.dart';
import '../../widgets/reusable_animated_box.dart';

class TransformDemo extends StatelessWidget {
  const TransformDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ReusableAnimatedBox(
        animId: 'transform-demo',
        phases: [
          SimplePhase(
            name: 'Complex Transform',
            startProgress: 0.0,
            endProgress: 1.0,
            hasTranslation: true,
            hasScale: true,
            hasRotation: true,
          ),
        ],
        duration: Duration(seconds: 3),
        beginOffset: Offset(-1, -1),
        endOffset: Offset(1, 1),
        beginScale: 0.5,
        endScale: 2.0,
        beginRotation: 0.0,
        endRotation: 4 * 3.14159,
        color: Colors.purple,
        curve: Curves.elasticOut,
      ),
    );
  }
}

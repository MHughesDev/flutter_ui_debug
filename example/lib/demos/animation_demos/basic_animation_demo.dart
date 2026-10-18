import 'package:flutter/material.dart';
import '../../widgets/reusable_animated_box.dart';

class BasicAnimationDemo extends StatelessWidget {
  const BasicAnimationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ReusableAnimatedBox(
        animId: 'basic-demo',
        phases: [
          SimplePhase(
            name: 'Slide',
            startProgress: 0.0,
            endProgress: 1.0,
            hasTranslation: true,
          ),
        ],
        duration: Duration(seconds: 3),
        beginOffset: Offset.zero,
        endOffset: Offset(1, 1),
        color: Colors.blue,
      ),
    );
  }
}

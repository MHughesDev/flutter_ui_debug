import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

class EasingCurveDemo extends StatefulWidget {
  const EasingCurveDemo({super.key});

  @override
  State<EasingCurveDemo> createState() => _EasingCurveDemoState();
}

class _EasingCurveDemoState extends State<EasingCurveDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  final List<CurveData> _curves = [
    CurveData(
      curve: Curves.easeInOut,
      name: 'Ease In Out',
      color: Colors.blue,
    ),
    CurveData(
      curve: Curves.easeOut,
      name: 'Ease Out',
      color: Colors.green,
    ),
    CurveData(
      curve: Curves.bounceOut,
      name: 'Bounce Out',
      color: Colors.orange,
    ),
    CurveData(
      curve: Curves.elasticOut,
      name: 'Elastic Out',
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation.value * 200, 0),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Animated',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Easing Curve Visualizer
        if (UIDebugConfig.isEnabled(UIDebugCapability.easingCurveVisualizer))
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: EasingCurveVisualizer(
              curves: _curves,
              currentProgress: _controller.value,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';
import 'dart:math' as math;

class CoordinateGridDemo extends StatefulWidget {
  const CoordinateGridDemo({super.key});

  @override
  State<CoordinateGridDemo> createState() => _CoordinateGridDemoState();
}

class _CoordinateGridDemoState extends State<CoordinateGridDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _translationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _translationAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(150, 150),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
                offset: _translationAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Local\nGrid',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Coordinate Grid Debug
        if (UIDebugConfig.isEnabled(UIDebugCapability.coordinateGrid))
          Positioned.fill(
            child: CoordinateGridDebug(
              widgetPosition: _translationAnimation.value,
              widgetSize: const Size(100, 100),
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

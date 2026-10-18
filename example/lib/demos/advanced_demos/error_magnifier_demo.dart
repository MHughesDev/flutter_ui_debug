import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

class ErrorMagnifierDemo extends StatefulWidget {
  const ErrorMagnifierDemo({super.key});

  @override
  State<ErrorMagnifierDemo> createState() => _ErrorMagnifierDemoState();
}

class _ErrorMagnifierDemoState extends State<ErrorMagnifierDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Target position
  final Offset _targetPosition = const Offset(200, 200);
  // Actual position (with error)
  Offset _actualPosition = const Offset(202, 198); // 2.8px error

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: 0,
      end: 1,
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
              // Animate the actual position slightly
              _actualPosition = Offset(
                202 + _animation.value * 2,
                198 - _animation.value * 2,
              );
              
              return Stack(
                children: [
                  // Target position (expected)
                  Positioned(
                    left: _targetPosition.dx - 40,
                    top: _targetPosition.dy - 40,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.3),
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Target',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                  
                  // Actual position
                  Positioned(
                    left: _actualPosition.dx - 40,
                    top: _actualPosition.dy - 40,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Actual',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        
        // Error Magnifier
        if (UIDebugConfig.isEnabled(UIDebugCapability.errorMagnifier))
          ErrorMagnifier(
            errorPosition: _targetPosition,
            errorDelta: (_targetPosition - _actualPosition).distance,
            magnifierSize: 120.0,
            zoomLevel: 3.0,
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

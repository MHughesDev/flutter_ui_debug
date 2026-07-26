import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

class ExpectedVsActualDemo extends StatefulWidget {
  const ExpectedVsActualDemo({super.key});

  @override
  State<ExpectedVsActualDemo> createState() => _ExpectedVsActualDemoState();
}

class _ExpectedVsActualDemoState extends State<ExpectedVsActualDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  
  // Expected end position
  final Offset _expectedEnd = const Offset(200, 200);
  // Actual end position (slightly different to show the error)
  final Offset _actualEnd = const Offset(205, 198);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: _actualEnd,
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
                offset: _animation.value,
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
              );
            },
          ),
        ),
        
        // Expected vs Actual Debug overlay
        if (UIDebugConfig.isEnabled(UIDebugCapability.expectedVsActual))
          Positioned.fill(
            child: ExpectedVsActualDebug(
              expectedStart: Offset.zero,
              expectedEnd: _expectedEnd,
              actualPath: [
                Offset.zero,
                _animation.value,
              ],
              actualEnd: _animation.value,
              widgetSize: const Size(80, 80),
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

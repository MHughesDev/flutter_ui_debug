import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

class OwnershipTimelineDemo extends StatefulWidget {
  const OwnershipTimelineDemo({super.key});

  @override
  State<OwnershipTimelineDemo> createState() => _OwnershipTimelineDemoState();
}

class _OwnershipTimelineDemoState extends State<OwnershipTimelineDemo>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  
  bool _controller1Active = true;
  bool _controller2Active = false;

  @override
  void initState() {
    super.initState();
    
    // First controller
    _controller1 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation1 = Tween<double>(begin: 0, end: 1).animate(_controller1);
    
    // Second controller (will overlap)
    _controller2 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation2 = Tween<double>(begin: 0, end: 1).animate(_controller2);
    
    // Start first animation
    _controller1.forward().then((_) {
      if (!mounted) return;
      setState(() {
        _controller1Active = false;
        _controller2Active = true;
      });
      _controller2.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_controller1, _controller2]),
            builder: (context, child) {
              final value = _controller1Active
                  ? _animation1.value
                  : _animation2.value;
              
              return Transform.scale(
                scale: 1.0 + value * 0.5,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _controller1Active ? Colors.blue : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _controller1Active ? 'Controller 1' : 'Controller 2',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Ownership Timeline
        if (UIDebugConfig.isEnabled(UIDebugCapability.ownershipTimeline))
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: AnimationOwnershipTimeline(
              ownershipPeriods: [
                ControllerOwnershipPeriod(
                  controllerId: 'controller1',
                  startTime: DateTime.now().subtract(const Duration(seconds: 2)),
                  endTime: _controller1Active ? null : DateTime.now(),
                  color: Colors.blue,
                  description: 'First animation controller',
                ),
                if (_controller2Active)
                  ControllerOwnershipPeriod(
                    controllerId: 'controller2',
                    startTime: DateTime.now(),
                    endTime: null,
                    color: Colors.green,
                    description: 'Second animation controller',
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }
}

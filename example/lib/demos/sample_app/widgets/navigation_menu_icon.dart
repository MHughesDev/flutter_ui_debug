import 'package:flutter/material.dart';

class NavigationMenuIcon extends StatelessWidget {
  const NavigationMenuIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // Check theme brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Dot color: white in dark mode, black in light mode
    final dotColor = isDark ? Colors.white : Colors.black;

    return SizedBox(
      width: 24,
      height: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(dotColor, 7.0),
              const SizedBox(width: 4),
              _buildDot(dotColor, 7.0),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(dotColor, 7.0),
              const SizedBox(width: 4),
              _buildDot(dotColor, 7.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

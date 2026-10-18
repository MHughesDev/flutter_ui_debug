import 'package:flutter/material.dart';

/// Color tokens for light and dark themes.
class AppColors {
  AppColors._();

  /// Light theme colors
  static const LightColors light = LightColors();
  
  /// Dark theme colors
  static const DarkColors dark = DarkColors();
}

/// Light theme color palette
class LightColors {
  const LightColors();

  // Background colors
  Color get background => const Color(0xFFF5F7FA);
  Color get surface => const Color(0xFFFFFFFF);
  Color get surfaceVariant => const Color(0xFFEAEEF5);

  // Primary colors (Electric blue gradient)
  Color get primary => const Color(0xFF4C7DFF);
  Color get primaryContainer => const Color(0xFF6AE0FF);

  // Text colors
  Color get onPrimary => const Color(0xFFFFFFFF);
  Color get onSurface => const Color(0xFF111217);
  Color get onBackground => const Color(0xFF111217);
}

/// Dark theme color palette
class DarkColors {
  const DarkColors();

  // Background colors
  Color get background => const Color(0xFF111217);
  Color get surface => const Color(0xFF1A1D24);
  Color get surfaceVariant => const Color(0xFF252932);

  // Primary colors (Electric blue gradient)
  Color get primary => const Color(0xFF4C7DFF);
  Color get primaryContainer => const Color(0xFF6AE0FF);

  // Text colors
  Color get onPrimary => const Color(0xFFFFFFFF);
  Color get onSurface => const Color(0xFFFFFFFF);
  Color get onBackground => const Color(0xFFFFFFFF);
}

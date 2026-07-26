import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gradient definitions for the application.
class AppGradients {
  AppGradients._();

  /// Primary gradient (Electric blue: #4C7DFF → #6AE0FF)
  static LinearGradient primary(BuildContext context) {
    return LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [
        AppColors.light.primary,
        AppColors.light.primaryContainer,
      ],
    );
  }
}

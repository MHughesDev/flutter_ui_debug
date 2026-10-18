/// Severity classification for debug issues.
///
/// Issues detected by debug features are classified by severity to help
/// prioritize fixes and guide diagnostic decisions.
enum UIDebugSeverity {
  /// Cosmetic issues: Visual imperfections that don't affect functionality.
  ///
  /// Examples:
  /// - Slight misalignment (< 1px)
  /// - Minor visual glitches
  /// - Non-critical visual artifacts
  cosmetic,

  /// Perceptual issues: Problems that affect user experience but don't break functionality.
  ///
  /// Examples:
  /// - Noticeable misalignment (1-5px)
  /// - Animation stuttering
  /// - Perceptible drift
  /// - Frame drops
  perceptual,

  /// Architectural issues: Critical problems that indicate fundamental failures.
  ///
  /// Examples:
  /// - Anchor drift > 5px
  /// - Widget exits overlay bounds
  /// - Constraint violations
  /// - Phase contract violations
  /// - Coordinate system mismatches
  architectural,
}

/// Extension methods for UIDebugSeverity.
extension UIDebugSeverityExtensions on UIDebugSeverity {
  /// Get a human-readable name for the severity.
  String get displayName {
    switch (this) {
      case UIDebugSeverity.cosmetic:
        return 'Cosmetic';
      case UIDebugSeverity.perceptual:
        return 'Perceptual';
      case UIDebugSeverity.architectural:
        return 'Architectural';
    }
  }

  /// Get a color representation for the severity.
  ///
  /// Returns a color that can be used in debug visualizations.
  /// - Cosmetic: Yellow (warning)
  /// - Perceptual: Orange (caution)
  /// - Architectural: Red (critical)
  int get colorValue {
    switch (this) {
      case UIDebugSeverity.cosmetic:
        return 0xFFFFFF00; // Yellow
      case UIDebugSeverity.perceptual:
        return 0xFFFFA500; // Orange
      case UIDebugSeverity.architectural:
        return 0xFFFF0000; // Red
    }
  }

  /// Check if this severity is more severe than another.
  bool isMoreSevereThan(UIDebugSeverity other) {
    const severityOrder = [
      UIDebugSeverity.cosmetic,
      UIDebugSeverity.perceptual,
      UIDebugSeverity.architectural,
    ];
    return severityOrder.indexOf(this) > severityOrder.indexOf(other);
  }
}

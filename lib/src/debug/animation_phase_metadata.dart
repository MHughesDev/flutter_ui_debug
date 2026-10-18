import 'ui_debug_severity.dart';

/// Abstract interface for animation phase metadata.
/// 
/// Users of this library should implement this interface
/// to provide phase contract information for their animations.
/// 
/// This interface represents a single phase within an animation,
/// including its progress range, allowed transforms, and contract
/// validation logic.
abstract class AnimationPhaseMetadata {
  /// Phase name or identifier
  String get name;
  
  /// Start progress (0.0 to 1.0)
  double get startProgress;
  
  /// End progress (0.0 to 1.0)
  double get endProgress;
  
  /// Whether this phase allows translation transforms
  bool get hasTranslation;
  
  /// Whether this phase allows scale transforms
  bool get hasScale;
  
  /// Whether this phase allows rotation transforms
  bool get hasRotation;
  
  /// Check if the given progress value falls within this phase's range.
  /// 
  /// Returns true if [progress] is >= [startProgress] and < [endProgress],
  /// or if this is the last phase and [progress] >= [startProgress].
  bool containsProgress(double progress) {
    if (progress < startProgress) return false;
    if (progress < endProgress) return true;
    // For the last phase, include the end boundary
    return progress == endProgress;
  }
  
  /// Check for contract violations based on observed transforms.
  /// 
  /// Returns a [UIDebugSeverity] if a violation is detected, or null
  /// if the observed transforms comply with the phase contract.
  /// 
  /// Parameters:
  /// - [hasTranslation]: Whether translation is currently being applied
  /// - [hasScale]: Whether scale is currently being applied
  /// - [hasRotation]: Whether rotation is currently being applied
  UIDebugSeverity? checkViolation({
    required bool hasTranslation,
    required bool hasScale,
    required bool hasRotation,
  }) {
    // Check for violations: if a transform is observed but not allowed
    final violations = <String>[];
    if (hasTranslation && !this.hasTranslation) {
      violations.add('translation');
    }
    if (hasScale && !this.hasScale) {
      violations.add('scale');
    }
    if (hasRotation && !this.hasRotation) {
      violations.add('rotation');
    }
    
    if (violations.isEmpty) {
      return null;
    }
    
    // Any contract violation is an architectural issue
    return UIDebugSeverity.architectural;
  }
}

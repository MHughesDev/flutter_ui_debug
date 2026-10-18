# Pre-Deployment Verification Prompt

## Objective
Perform a comprehensive end-to-end verification of the `flutter_ui_debug` package to ensure it's ready for publication to pub.dev. Verify all systems work cohesively, all imports resolve correctly, and there are no errors.

## Verification Tasks

### 1. Import Resolution Check
- [ ] Verify the package can be imported in a test file: `import 'package:flutter_ui_debug/flutter_ui_debug.dart';`
- [ ] Check that all exported symbols are accessible:
  - [ ] `kUIDebugMode` (from ui_debug_mode.dart)
  - [ ] `UIDebugConfig` (from ui_debug_capabilities.dart)
  - [ ] `UIDebugCapability` enum
  - [ ] `UIDebugSeverity` enum
  - [ ] `AnimationPhaseMetadata` abstract class
  - [ ] All debug widget classes (PhaseContractDebug, FlightRecorderHUD, etc.)
- [ ] Verify no ambiguous exports exist
- [ ] Check that relative imports within the package resolve correctly

### 2. Abstract Interface Verification
- [ ] Create a test implementation of `AnimationPhaseMetadata`:
  ```dart
  class TestPhase implements AnimationPhaseMetadata {
    @override final String name;
    @override final double startProgress;
    @override final double endProgress;
    @override final bool hasTranslation;
    @override final bool hasScale;
    @override final bool hasRotation;
    
    TestPhase({required this.name, ...});
  }
  ```
- [ ] Verify `containsProgress()` method works correctly
- [ ] Verify `checkViolation()` method works correctly
- [ ] Test that `PhaseContractDebug` accepts a list of `AnimationPhaseMetadata` implementations
- [ ] Test that `PhaseContinuityDebug` accepts a list of `AnimationPhaseMetadata` implementations

### 3. Compilation and Analysis
- [ ] Run `flutter pub get` - should complete without errors
- [ ] Run `flutter analyze` - should show "No issues found!"
- [ ] Check for any linter warnings that should be addressed
- [ ] Verify no deprecated APIs are being used
- [ ] Check for any unused imports

### 4. Integration Testing
- [ ] Create a minimal test app that:
  - Imports the package
  - Enables debug mode: `kUIDebugMode = true;`
  - Enables a capability: `UIDebugConfig.enable(UIDebugCapability.flightRecorder);`
  - Uses at least one debug widget (e.g., `FlightRecorderHUD`)
  - Uses `PhaseContractDebug` with a custom `AnimationPhaseMetadata` implementation
- [ ] Verify the app compiles without errors
- [ ] Check that all required parameters are properly typed

### 5. Package Structure Verification
- [ ] Verify `pubspec.yaml` has correct:
  - Package name: `flutter_ui_debug`
  - Version: `1.0.0`
  - Description
  - Homepage and repository URLs
  - SDK constraints
  - Dependencies (only Flutter SDK)
- [ ] Verify all files are in correct locations:
  - `lib/flutter_ui_debug.dart` exists and exports all public APIs
  - `lib/src/constants/ui_debug_mode.dart` exists
  - `lib/src/debug/` contains all 21 debug files (including animation_phase_metadata.dart)
- [ ] Check that no files reference private app packages or stray internal import paths

### 6. API Consistency Check
- [ ] Verify `UIDebugConfig` class methods work:
  - `enable()`, `disable()`, `enableAll()`, `disableAll()`
  - `isEnabled()`, `isAnyEnabled()`, `areAllEnabled()`
  - `enableAllCapabilities()`, `disableAllCapabilities()`
- [ ] Verify `UIDebugSeverity` enum values are accessible
- [ ] Verify `UIDebugCapability` enum values are accessible
- [ ] Check that all debug widgets have consistent constructor patterns

### 7. Documentation Verification
- [ ] Verify `README.md` has:
  - Correct installation instructions (`flutter pub add flutter_ui_debug`)
  - Working code examples
  - Complete API overview
  - All links are correct
- [ ] Verify `CHANGELOG.md` has version 1.0.0 entry
- [ ] Verify `LICENSE` file exists and is valid

### 8. Naming Conflict Resolution
- [ ] Verify `UIDebugConfig` in `ui_debug_capabilities.dart` is the capability manager
- [ ] Verify `UIDebugVisualizationConfig` in `ui_debug_mode.dart` is the visualization constants
- [ ] Check that no other naming conflicts exist

### 9. Code Quality Checks
- [ ] Verify all public classes have proper documentation comments
- [ ] Check that all required parameters are marked as `required`
- [ ] Verify no hardcoded paths or app-specific configurations remain
- [ ] Check for any TODO comments that should be addressed

### 10. Final Dry-Run
- [ ] Run `flutter pub publish --dry-run` - should show "Package has 0 warnings"
- [ ] Verify the package structure matches pub.dev requirements
- [ ] Check that all files are included in the package

## Test Implementation Template

**Note**: API smoke tests live in `test/package_api_test.dart` and run with `flutter test`. For a quick compile check you can also use:

### Option 1: Flutter Analyze (Recommended)
Run `flutter analyze` to check for compilation errors without running the code.

### Option 2: Create a Test App
Create a minimal Flutter app in a separate directory to test the package:

```bash
flutter create test_app
cd test_app
# Add flutter_ui_debug as a dependency (path dependency for local testing)
```

Then use the test implementation in `test_package_import.dart` as a reference.

### Option 3: Use Flutter Test Framework
Convert the test to a proper Flutter test file in a `test/` directory.

The tests in `test/package_api_test.dart` demonstrate expected usage patterns:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

// Test implementation of AnimationPhaseMetadata
class TestPhase implements AnimationPhaseMetadata {
  @override
  final String name;
  @override
  final double startProgress;
  @override
  final double endProgress;
  @override
  final bool hasTranslation;
  @override
  final bool hasScale;
  @override
  final bool hasRotation;

  TestPhase({
    required this.name,
    required this.startProgress,
    required this.endProgress,
    required this.hasTranslation,
    required this.hasScale,
    required this.hasRotation,
  });
}

void main() {
  // Test 1: Enable debug mode
  kUIDebugMode = true;
  
  // Test 2: Enable capabilities
  UIDebugConfig.enable(UIDebugCapability.flightRecorder);
  UIDebugConfig.enable(UIDebugCapability.anchorLock);
  
  // Test 3: Check capability status
  assert(UIDebugConfig.isEnabled(UIDebugCapability.flightRecorder));
  
  // Test 4: Create phase metadata
  final phases = [
    TestPhase(
      name: 'Test Phase',
      startProgress: 0.0,
      endProgress: 1.0,
      hasTranslation: true,
      hasScale: false,
      hasRotation: false,
    ),
  ];
  
  // Test 5: Test phase methods
  final phase = phases.first;
  assert(phase.containsProgress(0.5) == true);
  assert(phase.containsProgress(1.5) == false);
  
  final violation = phase.checkViolation(
    hasTranslation: true,
    hasScale: false,
    hasRotation: false,
  );
  assert(violation == null); // No violation expected
  
  // Test 6: Test severity enum
  final severity = UIDebugSeverity.architectural;
  assert(severity.colorValue == 0xFFFF0000);
  
  print('All tests passed!');
}
```

## Expected Results

After running all verification tasks:
- ✅ All imports resolve correctly
- ✅ No compilation errors
- ✅ No analysis warnings
- ✅ Abstract interface works with user implementations
- ✅ All public APIs are accessible
- ✅ Package structure is correct
- ✅ Documentation is complete
- ✅ Dry-run publish passes with 0 warnings

## Critical Issues to Fix Before Deployment

If any of these are found, they MUST be fixed:
- ❌ Compilation errors
- ❌ Import resolution failures
- ❌ Ambiguous exports
- ❌ Missing required files
- ❌ Broken abstract interface
- ❌ Incorrect package metadata
- ❌ References to private or internal-only packages in library code

## Success Criteria

The package is ready for deployment when:
1. All verification tasks pass
2. Test implementation compiles and runs
3. `flutter analyze` shows no issues
4. `flutter pub publish --dry-run` shows 0 warnings
5. All public APIs are accessible and functional
6. Documentation is complete and accurate

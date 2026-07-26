# Code Style Guide

This document outlines the coding standards for `flutter_ui_debug`.

## General Principles

- **Readability First** - Code should be easy to read and understand
- **Consistency** - Follow existing patterns in the codebase
- **Documentation** - Public APIs must be documented
- **Simplicity** - Prefer simple solutions over clever ones

## Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide.

### Formatting

- Use `dart format` to format code
- Line length: 80 characters
- Use 2 spaces for indentation

### Naming Conventions

- **Classes**: PascalCase (`FlightRecorderHUD`)
- **Variables**: camelCase (`anchorPosition`)
- **Constants**: camelCase with `k` prefix (`kUIDebugMode`)
- **Private members**: `_` prefix (`_positionHistory`)
- **Enums**: PascalCase (`UIDebugCapability`)

### Documentation

All public APIs must have documentation comments:

```dart
/// Brief description.
///
/// Longer description if needed.
/// 
/// Example:
/// ```dart
/// UIDebugConfig.enable(UIDebugCapability.flightRecorder);
/// ```
class MyClass {
  /// Field description.
  final String field;
}
```

### Code Organization

1. Imports (dart, package, relative)
2. Library declaration
3. Exports
4. Classes and functions

### Widget Organization

```dart
class MyWidget extends StatelessWidget {
  // 1. Constants
  static const double padding = 8.0;
  
  // 2. Fields
  final String title;
  
  // 3. Constructor
  const MyWidget({super.key, required this.title});
  
  // 4. Build method
  @override
  Widget build(BuildContext context) {
    // ...
  }
  
  // 5. Helper methods
  Widget _buildHeader() {
    // ...
  }
}
```

## Specific Guidelines

### Debug Widgets

- Always check if capability is enabled before rendering
- Return `SizedBox.shrink()` when disabled
- Use `CustomPainter` for complex visualizations
- Keep widget tree shallow when possible

### Error Handling

- Use assertions for programming errors
- Return null for optional failures
- Document exceptions in doc comments

### Performance

- Avoid unnecessary rebuilds
- Use `const` constructors when possible
- Cache expensive computations
- Check `kUIDebugMode` early to avoid work

## Tools

- `dart format` - Format code
- `flutter analyze` - Check for issues
- `dart doc` - Generate documentation

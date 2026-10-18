# Getting Started with flutter_ui_debug

This guide will help you get started with `flutter_ui_debug` in your Flutter project.

## Installation

Add `flutter_ui_debug` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_ui_debug: ^1.1.0
```

Then run:
```bash
flutter pub get
```

## Quick Start

### 1. Enable Debug Mode

```dart
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

void main() {
  // Enable debug mode globally
  kUIDebugMode = true;
  
  runApp(MyApp());
}
```

### 2. Enable Specific Capabilities

```dart
// Enable individual capabilities
UIDebugConfig.enable(UIDebugCapability.flightRecorder);
UIDebugConfig.enable(UIDebugCapability.anchorLock);

// Or enable all capabilities
UIDebugConfig.enableAllCapabilities();
```

### 3. Use Debug Widgets

```dart
Stack(
  children: [
    YourAnimatedWidget(),
    FlightRecorderHUD(
      animId: 'my-animation',
      rebuildCount: 0,
    ),
  ],
)
```

## Next Steps

- Explore [Feature Guides](../features/) for detailed usage
- Check out [Examples](../../examples/) for code samples
- Read the [API Reference](../../reference/api/) for complete documentation

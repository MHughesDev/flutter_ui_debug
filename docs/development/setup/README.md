# Development Setup

This guide will help you set up your development environment for contributing to `flutter_ui_debug`.

## Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.6.1)
- Git
- A code editor (VS Code, Android Studio, etc.)

## Setup Steps

### 1. Clone the Repository

```bash
git clone https://github.com/MHughesDev/flutter_ui_debug.git
cd flutter_ui_debug
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Setup

```bash
flutter analyze
flutter test
```

### 4. Run Example (if available)

```bash
flutter run
```

## Development Tools

### Recommended VS Code Extensions

- Dart
- Flutter
- Flutter Widget Snippets

### Recommended Android Studio Plugins

- Dart
- Flutter

## Testing

Run tests with:
```bash
flutter test
```

Run analysis with:
```bash
flutter analyze
```

## Building

Build the package:
```bash
flutter pub publish --dry-run
```

## IDE Configuration

### VS Code

Recommended settings in `.vscode/settings.json`:
```json
{
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "dart.enableSdkFormatter": true
}
```

## Next Steps

- Read the [Contributing Guide](../contributing/)
- Review the [Code Style Guide](../code-style/)
- Check the [Roadmap](../roadmap.md) for things to work on

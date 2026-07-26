# Architecture Documentation

This directory contains technical documentation about the architecture and design of `flutter_ui_debug`.

## Contents

- **[Design Decisions](design-decisions/)** - Important architectural decisions and their rationale
- **[API Design](api-design/)** - API design principles and patterns
- **[Internals](internals/)** - Internal implementation details

## Design Principles

The library follows these key principles:

1. **Capability-Based System** - Features are independently enableable
2. **Zero Performance Impact When Disabled** - Debug code has no overhead when off
3. **Visual-First Debugging** - Problems should be immediately visible
4. **Extensibility** - Easy to add new debug capabilities
5. **Developer Experience** - Simple API, powerful features

## Architecture Overview

```
flutter_ui_debug
├── Core System
│   ├── Debug Mode Flag (kUIDebugMode)
│   ├── Capability Manager (UIDebugConfig)
│   └── Severity System (UIDebugSeverity)
├── Debug Widgets
│   ├── Visualization Widgets
│   ├── Analysis Widgets
│   └── Telemetry Widgets
└── Utilities
    ├── Painters
    ├── Helpers
    └── Extensions
```

## Adding Architecture Documentation

When making significant architectural changes:
1. Document the decision in [Design Decisions](design-decisions/)
2. Update API design docs if the public API changes
3. Document internal changes in [Internals](internals/)

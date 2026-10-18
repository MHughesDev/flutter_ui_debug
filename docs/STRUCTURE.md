# Documentation Structure Overview

This document provides a visual overview of the documentation structure.

```
docs/
├── README.md                          # Main documentation index
├── STRUCTURE.md                       # This file - structure overview
│
├── guides/                            # User-facing guides
│   ├── README.md
│   ├── getting-started/              # Installation and basics
│   │   └── README.md
│   └── features/                      # Feature-specific guides
│       └── README.md
│
├── examples/                          # Code examples
│   ├── README.md
│   ├── basic/                         # Simple examples
│   └── advanced/                      # Complex examples
│
├── reference/                         # API and troubleshooting
│   ├── README.md
│   ├── api/                           # API documentation
│   │   └── README.md
│   └── troubleshooting/               # Common issues
│       └── README.md
│
├── development/                       # Contributor docs
│   ├── README.md
│   ├── contributing/                  # How to contribute
│   │   └── README.md
│   ├── setup/                         # Dev environment setup
│   │   └── README.md
│   ├── code-style/                    # Coding standards
│   │   └── README.md
│   ├── feature-specs/                 # Feature design docs
│   │   ├── README.md
│   │   └── TEMPLATE.md                # Feature spec template
│   ├── roadmap.md                     # Development roadmap
│   └── release-process.md             # Release procedures
│
└── architecture/                      # Technical architecture
    ├── README.md
    ├── design-decisions/              # Architectural decisions
    │   └── README.md
    ├── api-design/                    # API design principles
    └── internals/                     # Implementation details
```

## Directory Purposes

### guides/
**Audience:** End users  
**Purpose:** How to use the library  
**Content:** Installation, feature guides, tutorials

### examples/
**Audience:** End users, developers  
**Purpose:** Code samples and patterns  
**Content:** Working code examples, use cases

### reference/
**Audience:** End users, developers  
**Purpose:** Complete API reference and problem solving  
**Content:** API docs, troubleshooting guides

### development/
**Audience:** Contributors, maintainers  
**Purpose:** How to contribute and develop  
**Content:** Setup guides, code style, feature specs, roadmap

### architecture/
**Audience:** Maintainers, advanced contributors  
**Purpose:** Technical deep-dives  
**Content:** Design decisions, API design, internals

## File Naming Conventions

- **README.md** - Index/overview for each directory
- **Feature guides** - `feature-name.md` (e.g., `flight-recorder-hud.md`)
- **Feature specs** - `feature-name.md` (e.g., `frame-rate-monitor.md`)
- **Design decisions** - `decision-title.md` (e.g., `capability-system.md`)

## Adding New Documentation

1. **User guides** → `guides/features/feature-name.md`
2. **Examples** → `examples/basic/` or `examples/advanced/`
3. **Feature specs** → `development/feature-specs/feature-name.md`
4. **Design decisions** → `architecture/design-decisions/decision-title.md`
5. **API docs** → `reference/api/class-name.md`

## Maintenance

- Keep README files updated as structure changes
- Link new docs from appropriate README files
- Update this structure document when adding major sections

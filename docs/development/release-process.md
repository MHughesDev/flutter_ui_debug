# Release Process

This document outlines the process for releasing new versions of `flutter_ui_debug`.

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR** - Breaking changes
- **MINOR** - New features (backward compatible)
- **PATCH** - Bug fixes (backward compatible)

## Pre-Release Checklist

Before releasing:

- [ ] All tests pass (`flutter test`)
- [ ] Analysis passes (`flutter analyze`)
- [ ] Documentation is up to date
- [ ] CHANGELOG.md is updated
- [ ] Version number updated in `pubspec.yaml`
- [ ] Dry-run publish passes (`flutter pub publish --dry-run`)
- [ ] All features are documented
- [ ] Breaking changes are documented

## Release Steps

### 1. Update Version

Update version in `pubspec.yaml`:
```yaml
version: 1.1.0
```

### 2. Update CHANGELOG

Add new version entry to `CHANGELOG.md`:
```markdown
## [1.1.0] - 2026-02-XX

### Added
- New feature X
- New feature Y

### Changed
- Improved Z

### Fixed
- Bug fix A
```

### 3. Create Release Branch

```bash
git checkout -b release/1.1.0
git add .
git commit -m "Prepare release 1.1.0"
```

### 4. Tag Release

```bash
git tag -a v1.1.0 -m "Release 1.1.0"
git push origin release/1.1.0
git push origin v1.1.0
```

### 5. Publish to pub.dev

```bash
flutter pub publish
```

### 6. Create GitHub Release

1. Go to GitHub Releases
2. Create new release from tag
3. Copy CHANGELOG entry
4. Publish release

### 7. Merge to Main

```bash
git checkout main
git merge release/1.1.0
git push origin main
```

## Post-Release

- [ ] Verify package appears on pub.dev
- [ ] Check that installation works
- [ ] Monitor for issues
- [ ] Update roadmap if needed

## Emergency Releases

For critical bug fixes:
1. Create hotfix branch from main
2. Fix the issue
3. Increment patch version
4. Follow release steps
5. Merge back to main

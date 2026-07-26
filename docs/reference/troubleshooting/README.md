# Troubleshooting Guide

Common issues and their solutions when using `flutter_ui_debug`.

## Common Issues

### Debug Widgets Not Appearing

**Problem:** Debug widgets are not visible even though debug mode is enabled.

**Solutions:**
1. Verify `kUIDebugMode = true` is set before `runApp()`
2. Check that the specific capability is enabled: `UIDebugConfig.enable(UIDebugCapability.xxx)`
3. Ensure debug widgets are in a `Stack` or `Overlay` above your content
4. Check that widgets are not being clipped or hidden by parent widgets

### Performance Issues

**Problem:** Debug mode is causing performance problems.

**Solutions:**
1. Only enable the capabilities you need
2. Disable debug mode in production builds
3. Use `UIDebugConfig.disableAllCapabilities()` to turn off all features
4. Check if too many debug widgets are being rendered simultaneously

### Import Errors

**Problem:** Cannot import the package or symbols are not found.

**Solutions:**
1. Run `flutter pub get` to ensure dependencies are installed
2. Verify the package is in `pubspec.yaml`
3. Check that you're importing: `import 'package:flutter_ui_debug/flutter_ui_debug.dart';`
4. Ensure Flutter SDK version meets requirements (>=3.0.0)

### Phase Contract Not Working

**Problem:** Phase contract debugging isn't detecting violations.

**Solutions:**
1. Verify `AnimationPhaseMetadata` is properly implemented
2. Check that `containsProgress()` correctly identifies the current phase
3. Ensure `checkViolation()` is checking the right transform flags
4. Verify phases are passed in order with correct progress ranges

## Getting Help

If you can't find a solution here:
1. Check the [GitHub Issues](https://github.com/MHughesDev/flutter_ui_debug/issues)
2. Search existing issues for similar problems
3. Open a new issue with:
   - Description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Flutter version and package version

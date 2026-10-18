# flutter_ui_debug

A Flutter-first UI debugging toolkit focused on **object placement** and
**animation behavior**, with minimal setup for any Flutter app.

## What this repository now includes

- `flutter_ui_debug` package (root) with:
  - `UiDebugScope`: host wrapper that injects an in-app debug command menu
  - `UiDebugProbe`: tracks widget bounds and visibility in global coordinates
  - `UiAnimationProbe`: tracks `AnimationController` state/value/status
  - `UiDebugController`: command actions, snapshot capture, command logs
- `example/debug_tester`: Android-capable test app that exercises:
  - animated card scaling
  - animated chip movement
  - interaction state changes
  - dynamic mount/unmount behavior
- Integration test for end-to-end command/menu and interaction flow.

## Environment setup for Android emulator (Linux)

This repo uses local SDK tooling in `.tooling/` so it can run in isolated CI or
cloud agents without a global Android Studio install.

### 1) Install Flutter SDK locally

```bash
mkdir -p .tooling
curl -L "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.41.6-stable.tar.xz" -o ".tooling/flutter_linux_3.41.6-stable.tar.xz"
tar -xf ".tooling/flutter_linux_3.41.6-stable.tar.xz" -C ".tooling"
rm ".tooling/flutter_linux_3.41.6-stable.tar.xz"
```

### 2) Install Android command-line tools and SDK packages

```bash
mkdir -p ".tooling/android-sdk/cmdline-tools"
curl -L "https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip" -o ".tooling/android-sdk/cmdline-tools/cmdline-tools.zip"
unzip -q ".tooling/android-sdk/cmdline-tools/cmdline-tools.zip" -d ".tooling/android-sdk/cmdline-tools"
mv ".tooling/android-sdk/cmdline-tools/cmdline-tools" ".tooling/android-sdk/cmdline-tools/latest"
rm ".tooling/android-sdk/cmdline-tools/cmdline-tools.zip"

export ANDROID_SDK_ROOT="$PWD/.tooling/android-sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$PWD/.tooling/flutter/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"

yes | sdkmanager --licenses
sdkmanager --sdk_root="$ANDROID_SDK_ROOT" \
  "platform-tools" \
  "platforms;android-36" \
  "build-tools;36.0.0" \
  "emulator" \
  "system-images;android-36;google_apis;x86_64"
```

### 3) Configure Flutter and create/start emulator

```bash
export ANDROID_SDK_ROOT="$PWD/.tooling/android-sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$PWD/.tooling/flutter/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"

flutter config --android-sdk "$ANDROID_SDK_ROOT"

avdmanager create avd -n ui-debug-api36 -k "system-images;android-36;google_apis;x86_64" -d pixel_6
emulator -avd ui-debug-api36 -no-window -gpu swiftshader_indirect -no-audio -no-boot-anim &
adb wait-for-device
```

> If you are using Android Studio locally, point it to the same SDK path or
> install equivalent SDK components through the SDK Manager UI.

## Run the tester app

```bash
export ANDROID_SDK_ROOT="$PWD/.tooling/android-sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$PWD/.tooling/flutter/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

cd example/debug_tester
flutter pub get
flutter run -d emulator-5554
```

Use the lower-left bug icon (or `Ctrl+Shift+D` on keyboard-capable targets) to
open the command menu.

## Integration test

```bash
export ANDROID_SDK_ROOT="$PWD/.tooling/android-sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$PWD/.tooling/flutter/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

cd example/debug_tester
flutter test integration_test/ui_debug_flow_test.dart -d emulator-5554
```

## Minimal host-app integration

```dart
return UiDebugScope(
  child: MaterialApp(home: AppHome()),
);
```

Then probe objects/animations where needed:

```dart
UiDebugProbe(tag: 'checkout-button', child: ElevatedButton(...))
UiAnimationProbe(id: 'hero-fade', controller: fadeController, child: ...)
```

## Current capability summary

- Enumerates tagged UI objects with global bounds
- Tracks animation value/status/isAnimating
- Provides built-in in-app command menu for capture and control
- Supports pausing/resuming tracked animations
- Emits JSON snapshots for downstream analysis pipelines

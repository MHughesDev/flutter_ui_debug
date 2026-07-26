import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';
import '../../widgets/reusable_animated_box.dart';

class StressModesDemo extends StatefulWidget {
  const StressModesDemo({super.key});

  @override
  State<StressModesDemo> createState() => _StressModesDemoState();
}

class _StressModesDemoState extends State<StressModesDemo> {
  bool _stressModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ReusableAnimatedBox(
            animId: 'stress-demo',
            phases: [
              SimplePhase(
                name: 'Moving',
                startProgress: 0.0,
                endProgress: 1.0,
                hasTranslation: true,
              ),
            ],
            duration: Duration(seconds: 3),
            beginOffset: Offset.zero,
            endOffset: Offset(0.5, 0.5),
            color: Colors.red,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _stressModeEnabled = !_stressModeEnabled;
                if (_stressModeEnabled) {
                  StressModeManager.enableSafeAreaDistortion(
                    topInset: 100,
                    bottomInset: 100,
                    leftInset: 50,
                    rightInset: 50,
                  );
                } else {
                  StressModeManager.disable();
                }
              });
            },
            child: Text(_stressModeEnabled ? 'Disable Stress Mode' : 'Enable Stress Mode'),
          ),
        ],
      ),
    );

    // Wrap with stress mode widgets if enabled
    if (_stressModeEnabled && UIDebugConfig.isEnabled(UIDebugCapability.stressModes)) {
      content = StressModeWrapper(
        config: StressModeConfig.safeAreaDistortion(
          topInset: 100,
          bottomInset: 100,
          leftInset: 50,
          rightInset: 50,
        ),
        child: LayoutMutationTrigger(
          config: const LayoutMutationConfig(
            mutationInterval: Duration(seconds: 3),
            simulateOrientationChange: true,
            simulateTextScaleChange: true,
            simulateNavResize: true,
          ),
          child: content,
        ),
      );
    }

    return content;
  }
}

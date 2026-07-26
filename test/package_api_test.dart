import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';

class _TestPhase implements AnimationPhaseMetadata {
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

  const _TestPhase({
    required this.name,
    required this.startProgress,
    required this.endProgress,
    required this.hasTranslation,
    required this.hasScale,
    required this.hasRotation,
  });

  @override
  bool containsProgress(double progress) {
    if (progress < startProgress) return false;
    if (progress < endProgress) return true;
    return progress == endProgress;
  }

  @override
  UIDebugSeverity? checkViolation({
    required bool hasTranslation,
    required bool hasScale,
    required bool hasRotation,
  }) {
    final violations = <String>[];
    if (hasTranslation && !this.hasTranslation) {
      violations.add('translation');
    }
    if (hasScale && !this.hasScale) {
      violations.add('scale');
    }
    if (hasRotation && !this.hasRotation) {
      violations.add('rotation');
    }
    if (violations.isEmpty) return null;
    return UIDebugSeverity.architectural;
  }
}

void main() {
  late List<AnimationPhaseMetadata> phases;

  setUp(() {
    phases = [
      const _TestPhase(
        name: 'Test Phase',
        startProgress: 0.0,
        endProgress: 1.0,
        hasTranslation: true,
        hasScale: false,
        hasRotation: false,
      ),
    ];
    kUIDebugMode = true;
    UIDebugConfig.enableAllCapabilities();
  });

  tearDown(() {
    UIDebugConfig.disableAllCapabilities();
    kUIDebugMode = false;
  });

  test('kUIDebugMode and UIDebugConfig', () {
    expect(kUIDebugMode, isTrue);
    expect(
      UIDebugConfig.isEnabled(UIDebugCapability.flightRecorder),
      isTrue,
    );

    UIDebugConfig.disable(UIDebugCapability.flightRecorder);
    expect(
      UIDebugConfig.isEnabled(UIDebugCapability.flightRecorder),
      isFalse,
    );

    UIDebugConfig.enableAll([
      UIDebugCapability.flightRecorder,
      UIDebugCapability.phaseContracts,
    ]);
    expect(UIDebugConfig.isEnabled(UIDebugCapability.flightRecorder), isTrue);
    expect(
      UIDebugConfig.isEnabled(UIDebugCapability.phaseContracts),
      isTrue,
    );
    expect(
      UIDebugConfig.isAnyEnabled([
        UIDebugCapability.flightRecorder,
        UIDebugCapability.anchorLock,
      ]),
      isTrue,
    );
    expect(
      UIDebugConfig.areAllEnabled([
        UIDebugCapability.flightRecorder,
        UIDebugCapability.phaseContracts,
      ]),
      isTrue,
    );
  });

  test('AnimationPhaseMetadata implementation', () {
    final phase = phases.first;
    expect(phase.containsProgress(0.5), isTrue);
    expect(phase.containsProgress(1.5), isFalse);
    expect(phase.containsProgress(1.0), isTrue);

    expect(
      phase.checkViolation(
        hasTranslation: true,
        hasScale: false,
        hasRotation: false,
      ),
      isNull,
    );

    expect(
      phase.checkViolation(
        hasTranslation: true,
        hasScale: true,
        hasRotation: false,
      ),
      UIDebugSeverity.architectural,
    );
  });

  test('UIDebugSeverity', () {
    const severity = UIDebugSeverity.architectural;
    expect(severity.colorValue, 0xFFFF0000);
    expect(severity.displayName, 'Architectural');
  });

  test('exported widgets construct without error', () {
    expect(UIDebugCapability.values, isNotEmpty);

    expect(
      () => PhaseContractDebug(
        phases: phases,
        currentProgress: 0.5,
        hasTranslation: true,
        hasScale: false,
        hasRotation: false,
      ),
      returnsNormally,
    );

    expect(
      () => PhaseContinuityDebug(
        phases: phases,
        currentProgress: 0.5,
        boundaryDeltas: const {},
      ),
      returnsNormally,
    );

    expect(
      () => const FlightRecorderHUD(
        animId: 'test',
        rebuildCount: 0,
        layoutChangeCount: 0,
        violationCount: 0,
      ),
      returnsNormally,
    );
  });
}

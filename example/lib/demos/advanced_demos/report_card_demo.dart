import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';
import '../../widgets/reusable_animated_box.dart';

class ReportCardDemo extends StatefulWidget {
  const ReportCardDemo({super.key});

  @override
  State<ReportCardDemo> createState() => _ReportCardDemoState();
}

class _ReportCardDemoState extends State<ReportCardDemo> {
  bool _showReportCard = false;
  DebugSnapshot? _snapshot;

  void _onAnimationComplete() {
    if (!UIDebugConfig.isEnabled(UIDebugCapability.reportCard)) {
      return;
    }

    // Create a snapshot with various issues to demonstrate the report card
    _snapshot = DebugSnapshotExport.createSnapshot(
      animId: 'report-card-demo',
      startAnchor: const Offset(0, 0),
      endAnchor: const Offset(200, 200),
      currentAnchor: const Offset(201, 199), // Slight drift
      anchorDelta: 1.5, // Drift detected
      coordinateSystem: 'local',
      currentPhase: 'Complete',
      phaseBoundaries: [0.0, 0.5, 1.0],
      phaseContracts: [
        PhaseContractData(
          name: 'Phase 1',
          startProgress: 0.0,
          endProgress: 0.5,
          allowsTranslation: true,
          allowsScale: false,
          allowsRotation: false,
        ),
        PhaseContractData(
          name: 'Phase 2',
          startProgress: 0.5,
          endProgress: 1.0,
          allowsTranslation: true,
          allowsScale: true,
          allowsRotation: false,
        ),
      ],
      violations: [
        ViolationData(
          type: 'anchor_drift',
          severity: UIDebugSeverity.perceptual,
          description: 'Anchor drifted by 1.5px',
          value: 1.5,
          threshold: 0.1,
        ),
        ViolationData(
          type: 'end_position_error',
          severity: UIDebugSeverity.cosmetic,
          description: 'End position error: 2.2px',
          value: 2.2,
          threshold: 2.0,
        ),
      ],
      rebuildCount: 15,
      layoutChangeCount: 1,
      renderObjectReplacedCount: 0,
      positionHistory: [
        const Offset(0, 0),
        const Offset(50, 50),
        const Offset(100, 100),
        const Offset(150, 150),
        const Offset(201, 199), // Slight error
      ],
      endPositionError: 2.2,
    );

    setState(() {
      _showReportCard = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated box
        Center(
          child: ReusableAnimatedBox(
            animId: 'report-card-demo',
            phases: const [
              SimplePhase(
                name: 'Moving',
                startProgress: 0.0,
                endProgress: 1.0,
                hasTranslation: true,
              ),
            ],
            duration: const Duration(seconds: 3),
            beginOffset: Offset.zero,
            endOffset: const Offset(1, 1),
            color: Colors.orange,
          ),
        ),
        
        // Trigger button
        Positioned(
          bottom: 16,
          right: 16,
          child: ElevatedButton(
            onPressed: () {
              _onAnimationComplete();
            },
            child: const Text('Show Report Card'),
          ),
        ),
        
        // Report Card
        if (_showReportCard && _snapshot != null)
          AnimationReportCard(
            snapshot: _snapshot!,
            onDismiss: () {
              setState(() {
                _showReportCard = false;
              });
            },
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';
import '../../widgets/reusable_animated_box.dart';

class SnapshotExportDemo extends StatefulWidget {
  const SnapshotExportDemo({super.key});

  @override
  State<SnapshotExportDemo> createState() => _SnapshotExportDemoState();
}

class _SnapshotExportDemoState extends State<SnapshotExportDemo> {
  String? _snapshotJson;
  String? _snapshotHash;

  void _exportSnapshot() {
    if (!UIDebugConfig.isEnabled(UIDebugCapability.snapshotExport)) {
      return;
    }

    final snapshot = DebugSnapshotExport.createSnapshot(
      animId: 'snapshot-demo',
      startAnchor: const Offset(0, 0),
      endAnchor: const Offset(200, 200),
      currentAnchor: const Offset(100, 100),
      anchorDelta: 0.5,
      coordinateSystem: 'local',
      currentPhase: 'Moving',
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
          description: 'Anchor drifted by 0.5px',
          value: 0.5,
          threshold: 0.1,
        ),
      ],
      rebuildCount: 10,
      layoutChangeCount: 2,
      renderObjectReplacedCount: 0,
      positionHistory: [
        const Offset(0, 0),
        const Offset(50, 50),
        const Offset(100, 100),
        const Offset(150, 150),
        const Offset(200, 200),
      ],
      endPositionError: 2.5,
    );

    setState(() {
      _snapshotJson = snapshot.toJsonString();
      _snapshotHash = snapshot.generateHash();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated box
        const Center(
          child: ReusableAnimatedBox(
            animId: 'snapshot-demo',
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
            endOffset: Offset(1, 1),
            color: Colors.purple,
          ),
        ),
        
        // Snapshot export button
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: _exportSnapshot,
                icon: const Icon(Icons.download),
                label: const Text('Export Snapshot'),
              ),
              if (_snapshotHash != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Hash: $_snapshotHash',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Show snapshot JSON in a dialog
        if (_snapshotJson != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Debug Snapshot'),
                    content: SingleChildScrollView(
                      child: SelectableText(
                        _snapshotJson!,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _snapshotJson = null;
                            _snapshotHash = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tap to view snapshot JSON',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

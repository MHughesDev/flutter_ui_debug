import 'dart:convert';
import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;
import 'ui_debug_severity.dart';

/// Debug Snapshot: Captures animation state for LLM-assisted debugging.
///
/// Exports:
/// - Animation ID
/// - Anchor positions
/// - Phase information
/// - Violations and severity
/// - Telemetry data
///
/// This makes animation diagnostics exportable for analysis by LLMs.
class DebugSnapshot {
  /// Animation identifier
  final String? animId;

  /// Start anchor position
  final Offset? startAnchor;

  /// End anchor position
  final Offset? endAnchor;

  /// Current anchor position
  final Offset? currentAnchor;

  /// Anchor delta (drift)
  final double? anchorDelta;

  /// Coordinate system used
  final String? coordinateSystem;

  /// Current phase
  final String? currentPhase;

  /// Phase boundaries
  final List<double> phaseBoundaries;

  /// Phase contracts (allowed transforms per phase)
  final List<PhaseContractData> phaseContracts;

  /// Violations detected
  final List<ViolationData> violations;

  /// Rebuild count
  final int rebuildCount;

  /// Layout change count
  final int layoutChangeCount;

  /// RenderObject replacement count
  final int renderObjectReplacedCount;

  /// Position history
  final List<PositionData> positionHistory;

  /// Expected vs actual end position error
  final double? endPositionError;

  /// Timestamp when snapshot was created
  final DateTime timestamp;

  /// Snapshot version
  static const String version = '1.0';

  DebugSnapshot({
    this.animId,
    this.startAnchor,
    this.endAnchor,
    this.currentAnchor,
    this.anchorDelta,
    this.coordinateSystem,
    this.currentPhase,
    this.phaseBoundaries = const [],
    this.phaseContracts = const [],
    this.violations = const [],
    this.rebuildCount = 0,
    this.layoutChangeCount = 0,
    this.renderObjectReplacedCount = 0,
    this.positionHistory = const [],
    this.endPositionError,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Convert snapshot to JSON map
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'timestamp': timestamp.toIso8601String(),
      'animId': animId,
      'anchors': {
        'start': startAnchor != null
            ? {'x': startAnchor!.dx, 'y': startAnchor!.dy}
            : null,
        'end': endAnchor != null
            ? {'x': endAnchor!.dx, 'y': endAnchor!.dy}
            : null,
        'current': currentAnchor != null
            ? {'x': currentAnchor!.dx, 'y': currentAnchor!.dy}
            : null,
        'delta': anchorDelta,
      },
      'coordinateSystem': coordinateSystem,
      'phase': {
        'current': currentPhase,
        'boundaries': phaseBoundaries,
        'contracts': phaseContracts.map((c) => c.toJson()).toList(),
      },
      'violations': violations.map((v) => v.toJson()).toList(),
      'telemetry': {
        'rebuildCount': rebuildCount,
        'layoutChangeCount': layoutChangeCount,
        'renderObjectReplacedCount': renderObjectReplacedCount,
      },
      'positionHistory': positionHistory.map((p) => p.toJson()).toList(),
      'endPositionError': endPositionError,
    };
  }

  /// Convert snapshot to pretty-printed JSON string
  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  /// Create snapshot from JSON map
  factory DebugSnapshot.fromJson(Map<String, dynamic> json) {
    final anchors = json['anchors'] as Map<String, dynamic>?;
    final startAnchorData = anchors?['start'] as Map<String, dynamic>?;
    final endAnchorData = anchors?['end'] as Map<String, dynamic>?;
    final currentAnchorData = anchors?['current'] as Map<String, dynamic>?;

    final phase = json['phase'] as Map<String, dynamic>?;
    final phaseContractsData = phase?['contracts'] as List<dynamic>? ?? [];

    final violationsData = json['violations'] as List<dynamic>? ?? [];
    final positionHistoryData = json['positionHistory'] as List<dynamic>? ?? [];

    return DebugSnapshot(
      animId: json['animId'] as String?,
      startAnchor: startAnchorData != null
          ? Offset(startAnchorData['x'] as double, startAnchorData['y'] as double)
          : null,
      endAnchor: endAnchorData != null
          ? Offset(endAnchorData['x'] as double, endAnchorData['y'] as double)
          : null,
      currentAnchor: currentAnchorData != null
          ? Offset(currentAnchorData['x'] as double, currentAnchorData['y'] as double)
          : null,
      anchorDelta: anchors?['delta'] as double?,
      coordinateSystem: json['coordinateSystem'] as String?,
      currentPhase: phase?['current'] as String?,
      phaseBoundaries: (phase?['boundaries'] as List<dynamic>?)
              ?.map((e) => e as double)
              .toList() ??
          [],
      phaseContracts: phaseContractsData
          .map((e) => PhaseContractData.fromJson(e as Map<String, dynamic>))
          .toList(),
      violations: violationsData
          .map((e) => ViolationData.fromJson(e as Map<String, dynamic>))
          .toList(),
      rebuildCount: json['telemetry']?['rebuildCount'] as int? ?? 0,
      layoutChangeCount: json['telemetry']?['layoutChangeCount'] as int? ?? 0,
      renderObjectReplacedCount:
          json['telemetry']?['renderObjectReplacedCount'] as int? ?? 0,
      positionHistory: positionHistoryData
          .map((e) => PositionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      endPositionError: json['endPositionError'] as double?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  /// Generate a hash for the snapshot (for QR code or quick reference)
  String generateHash() {
    final json = toJson();
    // Remove timestamp for consistent hashing
    json.remove('timestamp');
    final jsonString = const JsonEncoder().convert(json);
    return jsonString.hashCode.toRadixString(16).substring(0, 8).toUpperCase();
  }
}

/// Phase contract data for snapshot
class PhaseContractData {
  final String name;
  final double startProgress;
  final double endProgress;
  final bool allowsTranslation;
  final bool allowsScale;
  final bool allowsRotation;

  PhaseContractData({
    required this.name,
    required this.startProgress,
    required this.endProgress,
    required this.allowsTranslation,
    required this.allowsScale,
    required this.allowsRotation,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startProgress': startProgress,
      'endProgress': endProgress,
      'allowsTranslation': allowsTranslation,
      'allowsScale': allowsScale,
      'allowsRotation': allowsRotation,
    };
  }

  factory PhaseContractData.fromJson(Map<String, dynamic> json) {
    return PhaseContractData(
      name: json['name'] as String,
      startProgress: json['startProgress'] as double,
      endProgress: json['endProgress'] as double,
      allowsTranslation: json['allowsTranslation'] as bool,
      allowsScale: json['allowsScale'] as bool,
      allowsRotation: json['allowsRotation'] as bool,
    );
  }
}

/// Violation data for snapshot
class ViolationData {
  final String type;
  final UIDebugSeverity severity;
  final String description;
  final double? value;
  final double? threshold;

  ViolationData({
    required this.type,
    required this.severity,
    required this.description,
    this.value,
    this.threshold,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity.name,
      'description': description,
      if (value != null) 'value': value,
      if (threshold != null) 'threshold': threshold,
    };
  }

  factory ViolationData.fromJson(Map<String, dynamic> json) {
    return ViolationData(
      type: json['type'] as String,
      severity: UIDebugSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => UIDebugSeverity.cosmetic,
      ),
      description: json['description'] as String,
      value: json['value'] as double?,
      threshold: json['threshold'] as double?,
    );
  }
}

/// Position data for snapshot
class PositionData {
  final double x;
  final double y;
  final DateTime? timestamp;

  PositionData({
    required this.x,
    required this.y,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  factory PositionData.fromJson(Map<String, dynamic> json) {
    return PositionData(
      x: json['x'] as double,
      y: json['y'] as double,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }
}

/// Debug Snapshot Export: Handles export of debug snapshots.
///
/// Provides methods to:
/// - Create snapshots from animation state
/// - Export snapshots as JSON
/// - Generate snapshot hashes
class DebugSnapshotExport {
  /// Create a snapshot from animation metadata
  static DebugSnapshot createSnapshot({
    String? animId,
    Offset? startAnchor,
    Offset? endAnchor,
    Offset? currentAnchor,
    double? anchorDelta,
    String? coordinateSystem,
    String? currentPhase,
    List<double> phaseBoundaries = const [],
    List<PhaseContractData> phaseContracts = const [],
    List<ViolationData> violations = const [],
    int rebuildCount = 0,
    int layoutChangeCount = 0,
    int renderObjectReplacedCount = 0,
    List<Offset> positionHistory = const [],
    double? endPositionError,
  }) {
    return DebugSnapshot(
      animId: animId,
      startAnchor: startAnchor,
      endAnchor: endAnchor,
      currentAnchor: currentAnchor,
      anchorDelta: anchorDelta,
      coordinateSystem: coordinateSystem,
      currentPhase: currentPhase,
      phaseBoundaries: phaseBoundaries,
      phaseContracts: phaseContracts,
      violations: violations,
      rebuildCount: rebuildCount,
      layoutChangeCount: layoutChangeCount,
      renderObjectReplacedCount: renderObjectReplacedCount,
      positionHistory: positionHistory
          .map((p) => PositionData(x: p.dx, y: p.dy))
          .toList(),
      endPositionError: endPositionError,
    );
  }

  /// Export snapshot to clipboard (if supported)
  static Future<void> exportToClipboard(DebugSnapshot snapshot) async {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.snapshotExport)) {
      return;
    }

    // Note: Clipboard functionality would require platform-specific implementation
    // For now, this is a placeholder
    // final jsonString = snapshot.toJsonString();
  }

  /// Export snapshot to file (if supported)
  static Future<String?> exportToFile(DebugSnapshot snapshot) async {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.snapshotExport)) {
      return null;
    }

    final jsonString = snapshot.toJsonString();
    // Note: File export would require path_provider or similar
    // For now, this is a placeholder that returns the JSON string
    return jsonString;
  }
}

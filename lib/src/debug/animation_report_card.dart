import 'package:flutter/material.dart';
import 'ui_debug_capabilities.dart' as capabilities;
import 'ui_debug_severity.dart';
import 'debug_snapshot_export.dart';

/// Animation Report Card: End-of-animation diagnostic summary.
///
/// Displays:
/// - ✅/❌/⚠️ status for each check (Anchor Stable, Pivot Drift, End Alignment, Dropped Frames)
/// - VERDICT: DO NOT SHIP / SHIP / REVIEW NEEDED
/// - Display at animation completion
///
/// This provides a clear pass/fail verdict for animation quality.
class AnimationReportCard extends StatelessWidget {
  /// Debug snapshot containing all diagnostic data
  final DebugSnapshot snapshot;

  /// Callback when card is dismissed
  final VoidCallback? onDismiss;

  const AnimationReportCard({
    super.key,
    required this.snapshot,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!capabilities.UIDebugConfig.isEnabled(
        capabilities.UIDebugCapability.reportCard)) {
      return const SizedBox.shrink();
    }

    // Calculate check results
    final checks = _calculateChecks();

    // Determine verdict
    final verdict = _calculateVerdict(checks);

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: GestureDetector(
          onTap: onDismiss,
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getVerdictColor(verdict),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(verdict),
                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 16),
                    ...checks.map((check) => _buildCheckRow(check)),
                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 16),
                    _buildVerdict(verdict),
                    const SizedBox(height: 16),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ReportVerdict verdict) {
    return Row(
      children: [
        Icon(
          Icons.assessment,
          color: _getVerdictColor(verdict),
          size: 28,
        ),
        const SizedBox(width: 12),
        const Text(
          'ANIMATION REPORT CARD',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildCheckRow(CheckResult check) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _getStatusIcon(check.status),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              check.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          if (check.details != null)
            Text(
              check.details!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerdict(ReportVerdict verdict) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getVerdictColor(verdict).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getVerdictColor(verdict),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getVerdictIcon(verdict),
            color: _getVerdictColor(verdict),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VERDICT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getVerdictText(verdict),
                  style: TextStyle(
                    color: _getVerdictColor(verdict),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'AnimID: ${snapshot.animId ?? "N/A"}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          'Hash: ${snapshot.generateHash()}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _getStatusIcon(CheckStatus status) {
    switch (status) {
      case CheckStatus.pass:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case CheckStatus.fail:
        return const Icon(Icons.cancel, color: Colors.red, size: 20);
      case CheckStatus.warning:
        return const Icon(Icons.warning, color: Colors.orange, size: 20);
    }
  }

  Color _getVerdictColor(ReportVerdict verdict) {
    switch (verdict) {
      case ReportVerdict.ship:
        return Colors.green;
      case ReportVerdict.reviewNeeded:
        return Colors.orange;
      case ReportVerdict.doNotShip:
        return Colors.red;
    }
  }

  IconData _getVerdictIcon(ReportVerdict verdict) {
    switch (verdict) {
      case ReportVerdict.ship:
        return Icons.check_circle;
      case ReportVerdict.reviewNeeded:
        return Icons.warning;
      case ReportVerdict.doNotShip:
        return Icons.cancel;
    }
  }

  String _getVerdictText(ReportVerdict verdict) {
    switch (verdict) {
      case ReportVerdict.ship:
        return 'SHIP';
      case ReportVerdict.reviewNeeded:
        return 'REVIEW NEEDED';
      case ReportVerdict.doNotShip:
        return 'DO NOT SHIP';
    }
  }

  List<CheckResult> _calculateChecks() {
    final checks = <CheckResult>[];

    // Check 1: Anchor Stable
    final anchorStable = snapshot.anchorDelta != null && snapshot.anchorDelta! < 0.1;
    checks.add(CheckResult(
      label: 'Anchor Stable',
      status: anchorStable ? CheckStatus.pass : CheckStatus.fail,
      details: snapshot.anchorDelta != null
          ? '${snapshot.anchorDelta!.toStringAsFixed(2)}px'
          : null,
    ));

    // Check 2: End Alignment
    final endAlignmentGood = snapshot.endPositionError != null &&
        snapshot.endPositionError! < 2.0;
    final endAlignmentWarning = snapshot.endPositionError != null &&
        snapshot.endPositionError! >= 2.0 &&
        snapshot.endPositionError! < 5.0;
    checks.add(CheckResult(
      label: 'End Alignment',
      status: endAlignmentGood
          ? CheckStatus.pass
          : (endAlignmentWarning ? CheckStatus.warning : CheckStatus.fail),
      details: snapshot.endPositionError != null
          ? '${snapshot.endPositionError!.toStringAsFixed(2)}px'
          : null,
    ));

    // Check 3: Rebuilds
    final rebuildsOk = snapshot.rebuildCount < 10;
    checks.add(CheckResult(
      label: 'Rebuilds',
      status: rebuildsOk ? CheckStatus.pass : CheckStatus.warning,
      details: '${snapshot.rebuildCount}',
    ));

    // Check 4: Layout Changes
    final layoutChangesOk = snapshot.layoutChangeCount < 5;
    checks.add(CheckResult(
      label: 'Layout Changes',
      status: layoutChangesOk ? CheckStatus.pass : CheckStatus.warning,
      details: '${snapshot.layoutChangeCount}',
    ));

    // Check 5: Violations
    final hasViolations = snapshot.violations.isNotEmpty;
    final architecturalViolations = snapshot.violations
        .where((v) => v.severity == UIDebugSeverity.architectural)
        .length;
    checks.add(CheckResult(
      label: 'Violations',
      status: architecturalViolations > 0
          ? CheckStatus.fail
          : (hasViolations ? CheckStatus.warning : CheckStatus.pass),
      details: hasViolations ? '${snapshot.violations.length}' : '0',
    ));

    return checks;
  }

  ReportVerdict _calculateVerdict(List<CheckResult> checks) {
    final hasFail = checks.any((c) => c.status == CheckStatus.fail);
    final hasWarning = checks.any((c) => c.status == CheckStatus.warning);

    if (hasFail) {
      return ReportVerdict.doNotShip;
    } else if (hasWarning) {
      return ReportVerdict.reviewNeeded;
    } else {
      return ReportVerdict.ship;
    }
  }
}

/// Check result for report card
class CheckResult {
  final String label;
  final CheckStatus status;
  final String? details;

  CheckResult({
    required this.label,
    required this.status,
    this.details,
  });
}

/// Check status
enum CheckStatus {
  pass,
  warning,
  fail,
}

/// Report verdict
enum ReportVerdict {
  ship,
  reviewNeeded,
  doNotShip,
}

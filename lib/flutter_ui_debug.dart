/// Advanced animation debugging toolkit for Flutter.
/// 
/// Provides visual diagnostics including:
/// - Animation trail visualization
/// - Constraint analysis
/// - Phase contract debugging
/// - Transform matrix visualization
/// - Anchor stability tracking
/// - Rebuild detection
/// - And much more!
library;

// Core constants
export 'src/constants/ui_debug_mode.dart';

// Debug capabilities and severity
export 'src/debug/ui_debug_capabilities.dart';
export 'src/debug/ui_debug_severity.dart';
export 'src/debug/animation_phase_metadata.dart';

// Debug painters and tools
export 'src/debug/anchor_lock_debug.dart';
export 'src/debug/anchor_stability_graph.dart';
export 'src/debug/animation_ownership_timeline.dart';
export 'src/debug/animation_report_card.dart';
export 'src/debug/constraint_cage_debug.dart';
export 'src/debug/coordinate_grid_debug.dart';
export 'src/debug/debug_snapshot_export.dart';
export 'src/debug/error_magnifier.dart';
export 'src/debug/expected_vs_actual_debug.dart';
export 'src/debug/flight_recorder_hud.dart';
export 'src/debug/hit_test_overlay.dart';
export 'src/debug/overlay_bounds_debug.dart';
export 'src/debug/phase_continuity_debug.dart';
export 'src/debug/phase_contract_debug.dart';
export 'src/debug/rebuild_detector.dart';
export 'src/debug/stress_modes.dart';
export 'src/debug/transform_stack_inspector.dart';
export 'src/debug/frame_rate_monitor.dart';
export 'src/debug/animation_timeline_scrubber.dart';
export 'src/debug/easing_curve_visualizer.dart';
export 'src/debug/debug_preset_manager.dart';
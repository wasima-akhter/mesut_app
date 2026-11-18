import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Lightweight frame-timing and timeline instrumentation for Debug/Profile mode.
/// Completely disabled in Release builds (`kReleaseMode`).
abstract final class PerformanceMonitor {
  static bool _isActive = false;

  static const int _frameBudgetUs = 16600; // ~60 FPS budget (16.6 ms)

  static void start() {
    if (kReleaseMode || _isActive) return;
    _isActive = true;
    SchedulerBinding.instance.addTimingsCallback(_onReportTimings);
  }

  static void stop() {
    if (!_isActive) return;
    _isActive = false;
    SchedulerBinding.instance.removeTimingsCallback(_onReportTimings);
  }

  static int _lastReportMs = 0;

  static void _onReportTimings(List<FrameTiming> timings) {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final timing in timings) {
      final buildUs = timing.buildDuration.inMicroseconds;
      final rasterUs = timing.rasterDuration.inMicroseconds;
      final totalWorkUs = buildUs + rasterUs;

      // Real jank: UI build or GPU rasterization exceeded frame budget (16.6ms)
      // or combined active compute time exceeded 2x frame budget (33.2ms).
      // (totalSpan includes idle/vsync scheduling wait, so checking active work
      // prevents false positives during page transitions and idle frames).
      final isJank = buildUs > _frameBudgetUs ||
          rasterUs > _frameBudgetUs ||
          totalWorkUs > _frameBudgetUs * 2;

      if (isJank && (now - _lastReportMs > 1500)) {
        _lastReportMs = now;
        final buildMs = (buildUs / 1000.0).toStringAsFixed(1);
        final rasterMs = (rasterUs / 1000.0).toStringAsFixed(1);
        final totalMs = (timing.totalSpan.inMicroseconds / 1000.0).toStringAsFixed(1);
        debugPrint(
          '[PERF] Slow frame detected: total=${totalMs}ms (build=${buildMs}ms, raster=${rasterMs}ms)',
        );
        break;
      }
    }
  }

  static Future<T> traceAsync<T>(
    String label,
    Future<T> Function() action,
  ) async {
    if (kReleaseMode) return action();
    return developer.Timeline.timeSync(label, action);
  }

  static T traceSync<T>(String label, T Function() action) {
    if (kReleaseMode) return action();
    return developer.Timeline.timeSync(label, action);
  }
}

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

  static void _onReportTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final totalUs = timing.totalSpan.inMicroseconds;
      if (totalUs > _frameBudgetUs * 2) {
        final buildMs = (timing.buildDuration.inMicroseconds / 1000.0)
            .toStringAsFixed(1);
        final rasterMs = (timing.rasterDuration.inMicroseconds / 1000.0)
            .toStringAsFixed(1);
        final totalMs = (totalUs / 1000.0).toStringAsFixed(1);
        debugPrint(
          '[PERF] Slow frame detected: total=${totalMs}ms (build=${buildMs}ms, raster=${rasterMs}ms)',
        );
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

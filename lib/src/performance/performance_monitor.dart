import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:utiler/src/performance/performance_memory_stub.dart'
    if (dart.library.io) 'package:utiler/src/performance/performance_memory_io.dart';
import 'package:utiler/src/ui/overlay_coordinator.dart';

/// A live performance monitoring overlay styled to match [LoggerConsole].
///
/// Tracks and displays nine real-time metrics, all app-only and requiring
/// no custom native code:
///
/// | Metric | Source |
/// |---|---|
/// | FPS, jank, total frames | [SchedulerBinding] frame timings |
/// | Build time, raster time, vsync overhead | [FrameTiming] |
/// | GPU raster cache (KB) | [FrameTiming.layerCacheBytes] |
/// | Memory (current & peak RSS) | `dart:io` [ProcessInfo] · N/A on web |
///
/// **Vsync overhead** measures how long the main thread was blocked *before*
/// Flutter could start building a frame — a more accurate indicator of main-
/// thread congestion than a timer-delay approximation.
///
/// **GPU cache** shows how many KB the Flutter compositor's raster cache
/// is holding in GPU memory. A steady climb may indicate excessive
/// [RepaintBoundary] snapshots.
///
/// The overlay coordinates with [LoggerConsole] via [OverlayCoordinator]:
/// when either panel is open the other's FAB hides automatically.
///
/// When [hasLoggerConsole] is `true` the FAB shifts to `left: 80` to sit
/// beside the [LoggerConsole] button at `left: 20`.
///
/// Enable via [UtilerScope.showPerformanceMonitor]:
///
/// ```dart
/// UtilerScope(showPerformanceMonitor: true, child: const MyApp())
/// ```
class PerformanceMonitor extends StatefulWidget {
  /// Creates a [PerformanceMonitor] that wraps [child] with a live-metrics overlay.
  const PerformanceMonitor({
    required this.child,
    this.hasLoggerConsole = false,
    super.key,
  });

  /// The application widget tree displayed beneath the overlay.
  final Widget child;

  /// Set to `true` when [LoggerConsole] is also active so the FAB shifts
  /// right to sit beside the logger's button instead of overlapping it.
  final bool hasLoggerConsole;

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  bool _isVisible = false;

  // Frame metrics — populated by SchedulerBinding.addTimingsCallback
  double _fps = 0;
  double _buildMs = 0;
  double _rasterMs = 0;
  double _vsyncMs = 0;
  double _layerCacheKb = 0;
  int _jankFrames = 0;
  int _totalFrames = 0;

  // Memory — polled every 500 ms via dart:io (0 on web)
  double _memMb = 0;
  double _peakMemMb = 0;

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    OverlayCoordinator.loggerOpen.addListener(_rebuild);
    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _onPollTick(),
    );
  }

  void _onTimings(List<FrameTiming> timings) {
    if (timings.isEmpty) return;
    for (final t in timings) {
      _fps = (1000000.0 / t.totalSpan.inMicroseconds).clamp(0.0, 120.0);
      _buildMs = t.buildDuration.inMicroseconds / 1000.0;
      _rasterMs = t.rasterDuration.inMicroseconds / 1000.0;
      _vsyncMs = t.vsyncOverhead.inMicroseconds / 1000.0;
      _layerCacheKb = t.layerCacheBytes / 1024.0;
      _totalFrames++;
      if (t.totalSpan > const Duration(milliseconds: 17)) _jankFrames++;
    }
  }

  void _onPollTick() {
    _memMb = getMemoryBytes() / (1024 * 1024);
    _peakMemMb = getPeakMemoryBytes() / (1024 * 1024);
    if (mounted) setState(() {});
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _open() {
    setState(() => _isVisible = true);
    OverlayCoordinator.performanceOpen.value = true;
  }

  void _close() {
    setState(() => _isVisible = false);
    OverlayCoordinator.performanceOpen.value = false;
  }

  void _reset() {
    setState(() {
      _jankFrames = 0;
      _totalFrames = 0;
    });
  }

  @override
  void dispose() {
    OverlayCoordinator.performanceOpen.value = false;
    OverlayCoordinator.loggerOpen.removeListener(_rebuild);
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _pollTimer?.cancel();
    super.dispose();
  }

  // ─── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fabLeft = widget.hasLoggerConsole ? 80.0 : 20.0;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [widget.child, _buildPanel(size), _buildFab(fabLeft)],
      ),
    );
  }

  Widget _buildPanel(Size size) {
    return AnimatedPositioned(
      bottom: _isVisible ? 0 : -size.height * 0.5,
      duration: const Duration(milliseconds: 400),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: size.width,
            height: size.height * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white.withValues(alpha: 0.07),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFab(double leftOffset) {
    return AnimatedPositioned(
      bottom: _isVisible || OverlayCoordinator.loggerOpen.value ? -100 : 20,
      left: leftOffset,
      duration: const Duration(milliseconds: 500),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white.withValues(alpha: 0.07),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _open,
              icon: const Icon(Icons.speed, color: Colors.grey, size: 26),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: _close,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black87,
          ),
        ),
        const Expanded(child: SizedBox()),
        const Text(
          'PERFORMANCE',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const Expanded(child: SizedBox()),
        IconButton(
          onPressed: _reset,
          icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(15),
      ),
      child: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(10),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.05,
        children: [
          _tile(
            icon: Icons.speed,
            label: 'FPS',
            value: _fps.toStringAsFixed(1),
            unit: 'frames/s',
            color: _fpsColor(_fps),
          ),
          _tile(
            icon: Icons.memory,
            label: 'MEMORY',
            value: _memMb > 0 ? _memMb.toStringAsFixed(0) : 'N/A',
            unit: _memMb > 0 ? 'MB' : '',
            color: Colors.blueAccent,
          ),
          _tile(
            icon: Icons.data_usage,
            label: 'PEAK MEM',
            value: _peakMemMb > 0 ? _peakMemMb.toStringAsFixed(0) : 'N/A',
            unit: _peakMemMb > 0 ? 'MB' : '',
            color: Colors.orangeAccent,
          ),
          _tile(
            icon: Icons.movie,
            label: 'FRAMES',
            value: '$_totalFrames',
            unit: 'rendered',
            color: Colors.tealAccent,
          ),
          _tile(
            icon: Icons.cached,
            label: 'GPU CACHE',
            value: _layerCacheKb.toStringAsFixed(0),
            unit: 'KB cached',
            color: Colors.indigoAccent,
          ),
          _tile(
            icon: Icons.timer,
            label: 'VSYNC',
            value: _vsyncMs.toStringAsFixed(1),
            unit: 'ms overhead',
            color: _vsyncColor(_vsyncMs),
          ),
          _tile(
            icon: Icons.build,
            label: 'BUILD',
            value: _buildMs.toStringAsFixed(1),
            unit: 'ms/frame',
            color: Colors.cyanAccent,
          ),
          _tile(
            icon: Icons.layers,
            label: 'RASTER',
            value: _rasterMs.toStringAsFixed(1),
            unit: 'ms/frame',
            color: Colors.purpleAccent,
          ),
          _tile(
            icon: Icons.warning,
            label: 'JANK',
            value: '$_jankFrames',
            unit: 'slow frames',
            color: _jankFrames == 0 ? Colors.greenAccent : Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 8,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: const TextStyle(color: Colors.white38, fontSize: 8),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  // ─── color helpers ───────────────────────────────────────────────────────────

  Color _fpsColor(double fps) {
    if (fps >= 55) return Colors.greenAccent;
    if (fps >= 30) return Colors.amber;
    return Colors.redAccent;
  }

  // vsyncOverhead > 8 ms means the main thread was blocked for nearly an
  // entire 60 Hz frame budget before Flutter could start building.
  Color _vsyncColor(double ms) {
    if (ms < 2.0) return Colors.greenAccent;
    if (ms < 8.0) return Colors.amber;
    return Colors.redAccent;
  }
}

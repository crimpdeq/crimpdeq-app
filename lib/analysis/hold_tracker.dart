import 'dart:collection';

import '../models/progressor_models.dart';

/// Times a hold on the Crimpdeq, which stands in for a hung weight. The hold
/// counts only while the pull is above [thresholdKg], so it starts with the
/// pull at any force and ends when the force stays at or below the threshold
/// for a second, once released. With [waitForRelease], a load already there
/// must drop first.
class HoldTracker {
  HoldTracker({required this.thresholdKg, this.waitForRelease = false});

  static const defaultThresholdKg = 2.0;
  static const failureUs = 1000000;

  final double thresholdKg;

  /// A load that stays on, such as an offset or a resting grip, would start
  /// the hold before the pull: it starts after the force drops to the
  /// threshold.
  bool waitForRelease;

  int? _lastUs;
  int _heldUs = 0;
  double _heldKgUs = 0;
  int _belowUs = 0;

  bool started = false;
  bool failed = false;

  double get heldSeconds => _heldUs / Duration.microsecondsPerSecond;

  /// Mean force over the time held, null before the hang starts.
  double? get meanKg => _heldUs == 0 ? null : _heldKgUs / _heldUs;

  void add(WeightMeasurement sample) {
    // A tare or restart moves the timeline back: skip the gap.
    final lastUs = _lastUs;
    final dtUs = lastUs == null || sample.timestampUs < lastUs
        ? 0
        : sample.timestampUs - lastUs;
    _lastUs = sample.timestampUs;
    if (failed) return;
    final pulling = sample.weightKg > thresholdKg;
    if (waitForRelease) {
      waitForRelease = pulling;
      return;
    }
    if (!started) {
      started = pulling;
      return;
    }
    if (pulling) {
      _heldUs += dtUs;
      _heldKgUs += sample.weightKg * dtUs;
      _belowUs = 0;
    } else {
      _belowUs += dtUs;
      failed = _belowUs >= failureUs;
    }
  }
}

/// Whether a load stays on through the end of a rest: on for [leftOnUs] is
/// left on, such as a resting grip, not the next pull, which then waits for
/// it to drop.
class RestLoad {
  RestLoad({required this.thresholdKg});

  static const leftOnUs = 3000000;

  final double thresholdKg;

  // Device time since the force stayed above the threshold, and of the
  // latest sample.
  int? _loadedSinceUs;
  int? _lastUs;

  bool get leftOn {
    final loadedSinceUs = _loadedSinceUs;
    return loadedSinceUs != null && _lastUs! - loadedSinceUs >= leftOnUs;
  }

  void add(WeightMeasurement sample) {
    final lastUs = _lastUs;
    // A tare or restart moves the timeline back: the load starts over.
    if (lastUs != null && sample.timestampUs < lastUs) _loadedSinceUs = null;
    _lastUs = sample.timestampUs;
    _loadedSinceUs = sample.weightKg > thresholdKg
        ? _loadedSinceUs ?? sample.timestampUs
        : null;
  }
}

/// Highest mean force over any 5 s of a pull: the force the climber could
/// hold for 5 s, which OpenGrips takes as the benchmark.
class FiveSecondMax {
  static const windowUs = 5000000;

  final _window = ListQueue<WeightMeasurement>();
  double _windowKg = 0;
  int? _firstUs;

  double? bestKg;
  int elapsedUs = 0;

  void add(WeightMeasurement sample) {
    // A tare or restart moves the timeline back: start a new window.
    if (_window.isNotEmpty && sample.timestampUs < _window.last.timestampUs) {
      _window.clear();
      _windowKg = 0;
      _firstUs = sample.timestampUs - elapsedUs;
    }
    final firstUs = _firstUs ??= sample.timestampUs;
    elapsedUs = sample.timestampUs - firstUs;

    _window.addLast(sample);
    _windowKg += sample.weightKg;
    // Keep the newest sample that is at least the window older as the start.
    while (_window.length > 1 &&
        sample.timestampUs - _window.elementAt(1).timestampUs >= windowUs) {
      _windowKg -= _window.removeFirst().weightKg;
    }
    if (sample.timestampUs - _window.first.timestampUs < windowUs) return;
    final meanKg = _windowKg / _window.length;
    if (meanKg > (bestKg ?? double.negativeInfinity)) bestKg = meanKg;
  }
}

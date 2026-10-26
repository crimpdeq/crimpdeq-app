import 'dart:collection';

import '../models/progressor_models.dart';

/// Times a hang on the Crimpdeq, which stands in for a hung weight. A weight
/// is either lifted or not, while a pull varies, so the hang starts when the
/// force first reaches 90% of the target and ends when it stays below that
/// for a second. Dips shorter than that count as hanging.
class HoldTracker {
  HoldTracker(double targetKg) : thresholdKg = targetKg * thresholdRatio;

  static const thresholdRatio = 0.9;
  static const failureUs = 1000000;

  final double thresholdKg;

  int? _lastUs;
  int _heldUs = 0;
  double _heldKgUs = 0;
  // Time and force impulse since the force last reached the threshold.
  int _belowUs = 0;
  double _belowKgUs = 0;

  bool started = false;
  bool failed = false;

  double get heldSeconds => _heldUs / Duration.microsecondsPerSecond;

  /// Mean force over the hang, null before it starts.
  double? get meanKg => _heldUs == 0 ? null : _heldKgUs / _heldUs;

  void add(WeightMeasurement sample) {
    // A tare or restart moves the timeline back: skip the gap.
    final lastUs = _lastUs;
    final dtUs = lastUs == null || sample.timestampUs < lastUs
        ? 0
        : sample.timestampUs - lastUs;
    _lastUs = sample.timestampUs;
    if (failed) return;
    if (!started) {
      started = sample.weightKg >= thresholdKg;
      return;
    }

    _belowUs += dtUs;
    _belowKgUs += sample.weightKg * dtUs;
    if (sample.weightKg >= thresholdKg) {
      _heldUs += _belowUs;
      _heldKgUs += _belowKgUs;
      _belowUs = 0;
      _belowKgUs = 0;
    } else if (_belowUs >= failureUs) {
      failed = true;
    }
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

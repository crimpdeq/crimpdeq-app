import 'dart:collection';
import 'dart:math';

import '../models/progressor_models.dart';

/// Extremes and peak rate of force development (RFD) over a measurement window.
class ForceStats {
  /// RFD is the force change across at least this span. Shorter spans amplify
  /// the ADC noise at high sample rates.
  static const rfdSpanUs = 50000;

  double? _minKg;
  double? _peakKg;
  double? _peakRfdKgPerS;

  double? get minKg => _minKg;
  double? get peakKg => _peakKg;

  /// Steepest force increase, in kg/s.
  double? get peakRfdKgPerS => _peakRfdKgPerS;

  final _recent = ListQueue<WeightMeasurement>();

  void add(WeightMeasurement sample) {
    final kg = sample.weightKg;
    _minKg = min(_minKg ?? kg, kg);
    _peakKg = max(_peakKg ?? kg, kg);

    _recent.addLast(sample);
    // Keep the newest sample that is at least the span older as the base.
    while (_recent.length > 1 &&
        sample.timestampUs - _recent.elementAt(1).timestampUs >= rfdSpanUs) {
      _recent.removeFirst();
    }
    final base = _recent.first;
    final spanUs = sample.timestampUs - base.timestampUs;
    if (spanUs < rfdSpanUs) return;
    final rfd =
        (kg - base.weightKg) / (spanUs / Duration.microsecondsPerSecond);
    _peakRfdKgPerS = max(_peakRfdKgPerS ?? rfd, rfd);
  }
}

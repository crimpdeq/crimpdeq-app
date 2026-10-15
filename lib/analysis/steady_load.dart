import 'dart:math';

import '../models/progressor_models.dart';

/// Detects a load that holds steady: every 100 ms slice of the last second has
/// samples and their medians stay within 20 g or 0.3% of the load, whichever is
/// larger. The median removes the ADC noise and ignores BLE transmissions, which
/// offset the conversions they overlap, while they hit fewer than half of the
/// slice, so the check catches swinging and creep. A hung weight never stops swinging completely: its rope tension
/// varies by about 1.5·θ², so 0.3% allows a swing of about 2.6°.
class SteadyLoadDetector {
  static const _windowUs = 1000000;
  static const _sliceUs = 100000;
  static const _minToleranceKg = 0.02;
  static const _relativeTolerance = 0.003;

  final _samples = <WeightMeasurement>[];
  bool receivedSamples = false;

  /// Mean of the slice medians once the load is steady.
  double? steadyLoadKg;

  /// Adds [samples] and returns whether the load is steady.
  bool add(List<WeightMeasurement> samples) {
    for (final sample in samples) {
      // A restarted measurement moves the timeline back: start a new window.
      if (_samples.isNotEmpty &&
          sample.timestampUs < _samples.last.timestampUs) {
        _samples.clear();
      }
      _samples.add(sample);
      receivedSamples = true;
    }
    if (_samples.isEmpty) return false;

    final latestUs = _samples.last.timestampUs;
    final windowStartUs = latestUs - _windowUs;
    // Wait until the samples span the whole window.
    if (_samples.first.timestampUs > windowStartUs) return false;
    _samples.removeWhere((sample) => sample.timestampUs <= windowStartUs);

    final slices = <int, List<double>>{};
    for (final sample in _samples) {
      final slice = (latestUs - sample.timestampUs) ~/ _sliceUs;
      slices.putIfAbsent(slice, () => []).add(sample.weightKg);
    }
    // A gap in the samples hides the load during it.
    if (slices.length < _windowUs ~/ _sliceUs) return false;
    final medians = slices.values.map(_median).toList();
    final loadKg = medians.reduce((a, b) => a + b) / medians.length;
    final toleranceKg = max(_minToleranceKg, _relativeTolerance * loadKg.abs());
    if (medians.reduce(max) - medians.reduce(min) > toleranceKg) return false;
    steadyLoadKg = loadKg;
    return true;
  }

  static double _median(List<double> weights) {
    weights.sort();
    final middle = weights.length ~/ 2;
    return weights.length.isOdd
        ? weights[middle]
        : (weights[middle - 1] + weights[middle]) / 2;
  }
}

import 'package:fl_chart/fl_chart.dart';

import '../models/progressor_models.dart';

/// The force of the latest [windowSeconds], which the live force graph shows:
/// a mean point every 0.1 s, over the seconds since the first sample.
class ForceTrace {
  static const windowSeconds = 15;
  static const _intervalUs = 100000;

  int? _startUs;
  int? _lastUs;
  // Time of the last point since the first sample.
  int? _pointAtUs;
  double _kg = 0;
  int _samples = 0;

  /// Replaced, not changed, when points are added, so a state holding it
  /// changes only then.
  List<FlSpot> points = const [];

  void addAll(List<WeightMeasurement> samples) {
    final added = <FlSpot>[];
    for (final sample in samples) {
      final lastUs = _lastUs;
      // A tare or restart moves the timeline back: continue the trace.
      if (lastUs != null && sample.timestampUs < lastUs) {
        _startUs = _startUs! + sample.timestampUs - lastUs;
      }
      final startUs = _startUs ??= sample.timestampUs;
      _lastUs = sample.timestampUs;
      _kg += sample.weightKg;
      _samples++;
      final sinceStartUs = sample.timestampUs - startUs;
      final pointAtUs = _pointAtUs;
      if (pointAtUs == null || sinceStartUs - pointAtUs >= _intervalUs) {
        added.add(
          FlSpot(sinceStartUs / Duration.microsecondsPerSecond, _kg / _samples),
        );
        _pointAtUs = sinceStartUs;
        _kg = 0;
        _samples = 0;
      }
    }
    if (added.isEmpty) return;
    final all = [...points, ...added];
    // From the last point before the window, so the line reaches its edge.
    final fromX = all.last.x - windowSeconds;
    final inWindow = all.indexWhere((point) => point.x > fromX);
    points = all.sublist(inWindow > 0 ? inWindow - 1 : 0);
  }
}

import '../models/session_models.dart';

enum RepDetectorState { idle, hanging, resting }

class RepDetectorConfig {
  final double hangThresholdKg;
  final int debounceMs;
  final int minHangDurationMs;

  const RepDetectorConfig({
    this.hangThresholdKg = 2.0,
    this.debounceMs = 200,
    this.minHangDurationMs = 1000,
  });
}

class RepDetectorResult {
  final Rep? completedRep;
  final RepDetectorState state;

  const RepDetectorResult({this.completedRep, required this.state});
}

class RepDetector {
  RepDetectorConfig _config;
  RepDetectorState _state = RepDetectorState.idle;

  int? _thresholdCrossedAtMs;
  int? _hangStartMs;
  double _peakForce = 0.0;
  double _forceSum = 0.0;
  int _sampleCount = 0;
  final List<WeightSample> _hangSamples = [];

  RepDetector({RepDetectorConfig config = const RepDetectorConfig()})
      : _config = config;

  RepDetectorState get state => _state;

  void updateConfig(RepDetectorConfig config) {
    _config = config;
  }

  void reset() {
    _state = RepDetectorState.idle;
    _thresholdCrossedAtMs = null;
    _hangStartMs = null;
    _peakForce = 0.0;
    _forceSum = 0.0;
    _sampleCount = 0;
    _hangSamples.clear();
  }

  RepDetectorResult process(double weightKg, int timestampMs) {
    final aboveThreshold = weightKg > _config.hangThresholdKg;

    switch (_state) {
      case RepDetectorState.idle:
      case RepDetectorState.resting:
        if (aboveThreshold) {
          if (_thresholdCrossedAtMs == null) {
            _thresholdCrossedAtMs = timestampMs;
          } else if (timestampMs - _thresholdCrossedAtMs! >=
              _config.debounceMs) {
            _state = RepDetectorState.hanging;
            _hangStartMs = _thresholdCrossedAtMs;
            _peakForce = weightKg;
            _forceSum = weightKg;
            _sampleCount = 1;
            _hangSamples.clear();
            _hangSamples.add(
              WeightSample(weight: weightKg, timestampMs: timestampMs),
            );
            _thresholdCrossedAtMs = null;
          }
        } else {
          _thresholdCrossedAtMs = null;
        }
        return RepDetectorResult(state: _state);

      case RepDetectorState.hanging:
        if (aboveThreshold) {
          _thresholdCrossedAtMs = null;
          if (weightKg > _peakForce) _peakForce = weightKg;
          _forceSum += weightKg;
          _sampleCount++;
          _hangSamples.add(
            WeightSample(weight: weightKg, timestampMs: timestampMs),
          );
          return RepDetectorResult(state: _state);
        } else {
          if (_thresholdCrossedAtMs == null) {
            _thresholdCrossedAtMs = timestampMs;
          } else if (timestampMs - _thresholdCrossedAtMs! >=
              _config.debounceMs) {
            final hangDuration = timestampMs - (_hangStartMs ?? timestampMs);
            _thresholdCrossedAtMs = null;

            if (hangDuration >= _config.minHangDurationMs) {
              final rep = Rep(
                peakForceKg: _peakForce,
                avgForceKg: _sampleCount > 0 ? _forceSum / _sampleCount : 0.0,
                durationMs: hangDuration,
                startTimestampMs: _hangStartMs ?? timestampMs,
                weightSamples: List.unmodifiable(_hangSamples),
              );
              _state = RepDetectorState.resting;
              _resetHangState();
              return RepDetectorResult(completedRep: rep, state: _state);
            } else {
              // Short hang, discard
              _state = RepDetectorState.resting;
              _resetHangState();
              return RepDetectorResult(state: _state);
            }
          }
          // Still within debounce — keep accumulating
          _forceSum += weightKg;
          _sampleCount++;
          _hangSamples.add(
            WeightSample(weight: weightKg, timestampMs: timestampMs),
          );
          return RepDetectorResult(state: _state);
        }
    }
  }

  void _resetHangState() {
    _hangStartMs = null;
    _peakForce = 0.0;
    _forceSum = 0.0;
    _sampleCount = 0;
    _hangSamples.clear();
  }
}

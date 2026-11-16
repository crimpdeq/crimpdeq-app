import '../models/training_models.dart';

/// Warm-ups as fractions of the benchmarks, alternating the hands, so each
/// hand rests while the other holds. Every hold stays far from failure: the
/// forces climb while the holds shorten. Adapted from the GripGains adaptive
/// warm-up (Hand of God grippers); the values are starting points, not
/// validated ones.
typedef _Level = ({double ratio, int seconds});

/// Rest between the holds, enough to change hands.
const warmupRestSeconds = 15;

/// Rest to change tools.
const toolChangeRestSeconds = 30;

/// Before gripper training: a ramp on the tool to train.
const _trainingRamp = <_Level>[
  (ratio: 0.3, seconds: 20),
  (ratio: 0.5, seconds: 12),
  (ratio: 0.7, seconds: 6),
];

/// Before a heavy session, such as Power or a benchmark.
const _heavyLevel = (ratio: 0.85, seconds: 3);

/// Before climbing: Spark warms the larger muscle first, then Photon the
/// fingertips for small holds.
const _climbingLevels = <String, List<_Level>>{
  'Spark': [(ratio: 0.4, seconds: 20), (ratio: 0.6, seconds: 10)],
  'Photon': [
    (ratio: 0.4, seconds: 20),
    (ratio: 0.6, seconds: 10),
    (ratio: 0.75, seconds: 5),
  ],
};

/// A readiness check pulls Photon, the tool of small holds, as hard as
/// possible after a rest from the warm-up, for a full 5 s window.
const readinessTool = 'Photon';
const readinessRestSeconds = 180;
const readinessPullSeconds = 6;

/// Tools and hands of [tools] without a benchmark, which a warm-up needs.
List<(String, Hand)> missingBenchmarks(
  List<Benchmark> benchmarks,
  List<String> tools,
) => [
  for (final tool in tools)
    for (final hand in Hand.values)
      if (bestBenchmark(benchmarks, tool, hand) == null) (tool, hand),
];

double _benchmarkKg(List<Benchmark> benchmarks, String tool, Hand hand) {
  final benchmark = bestBenchmark(benchmarks, tool, hand);
  if (benchmark == null) {
    throw StateError('No benchmark for $tool with the ${hand.label} hand.');
  }
  return benchmark.forceKg;
}

double _round2(double value) => (value * 100).round() / 100;

/// Each level with the left hand, then the right one.
List<WarmupStep> _ramp(
  List<Benchmark> benchmarks,
  String tool,
  List<_Level> levels, {
  required int firstRestSeconds,
}) => [
  for (final (index, level) in levels.indexed)
    for (final hand in Hand.values)
      (
        tool: tool,
        hand: hand,
        benchmarkKg: _benchmarkKg(benchmarks, tool, hand),
        forceKg: _round2(_benchmarkKg(benchmarks, tool, hand) * level.ratio),
        seconds: level.seconds,
        restSeconds: index == 0 && hand == Hand.left
            ? firstRestSeconds
            : warmupRestSeconds,
      ),
];

/// Before training with [tool]. [heavy] adds a short hold at 85%, for the
/// heaviest workouts and benchmarks.
List<WarmupStep> trainingWarmup(
  List<Benchmark> benchmarks,
  String tool, {
  required bool heavy,
}) => _ramp(benchmarks, tool, [
  ..._trainingRamp,
  if (heavy) _heavyLevel,
], firstRestSeconds: 0);

/// Before climbing, with both tools.
List<WarmupStep> climbingWarmup(List<Benchmark> benchmarks) => [
  for (final (index, MapEntry(key: tool, value: levels))
      in _climbingLevels.entries.indexed)
    ..._ramp(
      benchmarks,
      tool,
      levels,
      firstRestSeconds: index == 0 ? 0 : toolChangeRestSeconds,
    ),
];

/// A maximal pull with each hand, the first after a rest from the warm-up.
List<WarmupStep> readinessCheck(List<Benchmark> benchmarks) => [
  for (final hand in Hand.values)
    (
      tool: readinessTool,
      hand: hand,
      benchmarkKg: _benchmarkKg(benchmarks, readinessTool, hand),
      forceKg: null,
      seconds: readinessPullSeconds,
      restSeconds: hand == Hand.left ? readinessRestSeconds : warmupRestSeconds,
    ),
];

/// Total time of [steps], rests included.
int warmupSeconds(List<WarmupStep> steps) =>
    steps.fold(0, (total, step) => total + step.restSeconds + step.seconds);

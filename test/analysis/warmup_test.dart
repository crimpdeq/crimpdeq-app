import 'package:crimpdeq/analysis/warmup.dart';
import 'package:crimpdeq/models/training_models.dart';
import 'package:flutter_test/flutter_test.dart';

Benchmark _benchmark(String tool, Hand hand, double forceKg) => Benchmark(
  date: DateTime(2026, 10, 26),
  tool: tool,
  hand: hand,
  forceKg: forceKg,
);

void main() {
  final benchmarks = [
    _benchmark('Photon', Hand.left, 20),
    _benchmark('Photon', Hand.right, 30),
    _benchmark('Spark', Hand.left, 40),
    _benchmark('Spark', Hand.right, 50),
    // A weaker, later benchmark: the best one sets the forces.
    _benchmark('Photon', Hand.right, 25),
  ];

  String describe(WarmupStep step) =>
      '${step.tool} ${step.hand.name} ${step.forceKg} kg '
      '${step.seconds} s after ${step.restSeconds} s';

  test('ramps the tool to train, alternating the hands', () {
    expect(trainingWarmup(benchmarks, 'Photon', heavy: false).map(describe), [
      'Photon left 6.0 kg 20 s after 0 s',
      'Photon right 9.0 kg 20 s after 15 s',
      'Photon left 10.0 kg 12 s after 15 s',
      'Photon right 15.0 kg 12 s after 15 s',
      'Photon left 14.0 kg 6 s after 15 s',
      'Photon right 21.0 kg 6 s after 15 s',
    ]);
    // A heavy session ends with 3 s at 85%.
    final heavy = trainingWarmup(benchmarks, 'Spark', heavy: true);
    expect(heavy.skip(6).map(describe), [
      'Spark left 34.0 kg 3 s after 15 s',
      'Spark right 42.5 kg 3 s after 15 s',
    ]);
    expect(warmupSeconds(heavy), 7 * 15 + 2 * (20 + 12 + 6 + 3));
  });

  test('warms Spark, then Photon, before climbing', () {
    expect(climbingWarmup(benchmarks).map(describe), [
      'Spark left 16.0 kg 20 s after 0 s',
      'Spark right 20.0 kg 20 s after 15 s',
      'Spark left 24.0 kg 10 s after 15 s',
      'Spark right 30.0 kg 10 s after 15 s',
      'Photon left 8.0 kg 20 s after 30 s',
      'Photon right 12.0 kg 20 s after 15 s',
      'Photon left 12.0 kg 10 s after 15 s',
      'Photon right 18.0 kg 10 s after 15 s',
      'Photon left 15.0 kg 5 s after 15 s',
      'Photon right 22.5 kg 5 s after 15 s',
    ]);
  });

  test('checks readiness with a maximal Photon pull per hand', () {
    expect(readinessCheck(benchmarks).map(describe), [
      'Photon left null kg 6 s after 180 s',
      'Photon right null kg 6 s after 15 s',
    ]);
    expect(readinessCheck(benchmarks).last.benchmarkKg, 30);
  });

  test('lists the benchmarks a warm-up lacks', () {
    final photon = benchmarks.where((benchmark) => benchmark.tool == 'Photon');
    expect(missingBenchmarks(photon.toList(), ['Photon']), isEmpty);
    expect(missingBenchmarks(photon.toList(), ['Photon', 'Spark']), [
      ('Spark', Hand.left),
      ('Spark', Hand.right),
    ]);
    expect(
      () => climbingWarmup(photon.toList()),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'No benchmark for Spark with the Left hand.',
        ),
      ),
    );
  });

  test('stores a readiness check', () {
    final check = ReadinessCheck(
      date: DateTime(2026, 10, 27, 18),
      tool: 'Photon',
      pulls: const [(hand: Hand.right, forceKg: 28.4, benchmarkKg: 30)],
    );
    final reloaded = ReadinessCheck.fromJson(check.toJson());
    expect(reloaded.toJson(), check.toJson());
    expect(reloaded.pulls.single, check.pulls.single);
  });
}

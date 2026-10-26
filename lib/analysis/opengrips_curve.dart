import 'dart:math';

/// The OpenGrips (opengrips.xyz) workout model. A workout trains one section
/// of the force-time curve: low forces held for long hangs (endurance) to high
/// forces held for short ones (power). The forces are fractions of the
/// "balanced" force, two thirds of the benchmark: the highest force held for
/// 5 s.
enum CurveSection {
  endurance(
    'Endurance',
    forceRatio: 0.3409091,
    topRatio: 0.3901515,
    firstRepSeconds: 193,
    repRatios: [1, 0.285, 0.223, 0.202],
  ),
  strengthEndurance(
    'Strength/Endurance',
    forceRatio: 0.4393939,
    topRatio: 0.51893935,
    firstRepSeconds: 146,
    repRatios: [1, 0.342, 0.295, 0.24],
  ),
  strength(
    'Strength',
    forceRatio: 0.5984848,
    topRatio: 0.7310606,
    firstRepSeconds: 101,
    repRatios: [1, 0.356, 0.287, 0.257, 0.228],
  ),
  powerStrength(
    'Power/Strength',
    forceRatio: 0.8636364,
    topRatio: 0.9318182,
    firstRepSeconds: 56,
    repRatios: [1, 0.357, 0.232, 0.214, 0.196],
  ),
  power(
    'Power',
    forceRatio: 1,
    topRatio: double.infinity,
    firstRepSeconds: 40,
    repRatios: [1, 0.375, 0.25, 0.225, 0.2, 0.2],
  );

  const CurveSection(
    this.label, {
    required this.forceRatio,
    required this.topRatio,
    required this.firstRepSeconds,
    required this.repRatios,
  });

  final String label;

  /// Target force over the balanced force.
  final double forceRatio;

  /// Highest force over the balanced force that belongs to the section.
  final double topRatio;
  final int firstRepSeconds;

  /// Each rep's target over the first hang, for the default rest. The last
  /// ratio repeats for further reps.
  final List<double> repRatios;

  int get reps => repRatios.length;

  /// Target force for a benchmark, rounded to 10 g.
  double targetForceKg(double benchmarkKg) =>
      (benchmarkKg * balancedRatio * forceRatio * 100).round() / 100;

  /// Section that a workout at [forceKg] trained.
  static CurveSection of(double forceKg, double benchmarkKg) {
    final ratio = forceKg / (benchmarkKg * balancedRatio);
    return values.firstWhere((section) => ratio <= section.topRatio);
  }
}

const balancedRatio = 2 / 3;
const defaultRestSeconds = 20;

/// Target of each rep. Once the first hang is over, the later targets scale
/// with it if it missed its target by more than 3 s.
List<int> repTargetSeconds(
  CurveSection section, {
  required int reps,
  required int firstHangSeconds,
  double? firstHangActualSeconds,
}) {
  final actual = firstHangActualSeconds;
  final base =
      actual != null && actual > 0 && (actual - firstHangSeconds).abs() > 3
      ? actual
      : firstHangSeconds;
  final ratios = section.repRatios;
  return [
    firstHangSeconds,
    for (var rep = 2; rep <= reps; rep++)
      max(1, (base * ratios[min(rep, ratios.length) - 1]).round()),
  ];
}

/// First hang the ideal force curve predicts at [forceKg]: 5 s at the
/// benchmark, decaying exponentially with the force.
int idealFirstHangSeconds(double forceKg, double benchmarkKg) {
  final enduranceKg =
      benchmarkKg * balancedRatio * CurveSection.endurance.forceRatio;
  final decay =
      -log(max(max(1, enduranceKg - 10) / max(benchmarkKg, 1e-6), 1e-6)) / 188;
  if (decay == 0) return 0;
  return max(1, (5 - log(forceKg / max(benchmarkKg, 1e-6)) / decay).round());
}

/// A past workout on the curve: its mean force and its first hang.
typedef CurvePoint = ({double forceKg, double firstHangSeconds});

/// Section to train next. Until every section has a workout, the one with
/// the fewest; then the one whose first hangs fall furthest below the ideal
/// curve.
CurveSection suggestSection(List<CurvePoint> history, double benchmarkKg) {
  final gaps = {for (final section in CurveSection.values) section: <double>[]};
  for (final point in history) {
    gaps[CurveSection.of(point.forceKg, benchmarkKg)]!.add(
      point.firstHangSeconds -
          idealFirstHangSeconds(point.forceKg, benchmarkKg),
    );
  }
  double mean(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;
  final covered = gaps.values.every((sectionGaps) => sectionGaps.isNotEmpty);
  return CurveSection.values.reduce((best, section) {
    final better = covered
        ? mean(gaps[section]!) < mean(gaps[best]!)
        : gaps[section]!.length < gaps[best]!.length;
    return better ? section : best;
  });
}

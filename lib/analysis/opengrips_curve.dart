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
    bottomRatio: 0,
    topRatio: 0.3901515,
    firstRepSeconds: 193,
    repRatios: [1, 0.285, 0.223, 0.202],
    energySystems: (power: 0.74, powerEndurance: 0.37, endurance: 0.2),
  ),
  strengthEndurance(
    'Strength/Endurance',
    forceRatio: 0.4393939,
    bottomRatio: 0.3901515,
    topRatio: 0.51893935,
    firstRepSeconds: 146,
    repRatios: [1, 0.342, 0.295, 0.24],
    energySystems: (power: 0.62, powerEndurance: 0.31, endurance: 0.17),
  ),
  strength(
    'Strength',
    forceRatio: 0.5984848,
    bottomRatio: 0.51893935,
    topRatio: 0.7310606,
    firstRepSeconds: 101,
    repRatios: [1, 0.356, 0.287, 0.257, 0.228],
    energySystems: (power: 0.52, powerEndurance: 0.27, endurance: 0.15),
  ),
  powerStrength(
    'Power/Strength',
    forceRatio: 0.8636364,
    bottomRatio: 0.7310606,
    topRatio: 0.9318182,
    firstRepSeconds: 56,
    repRatios: [1, 0.357, 0.232, 0.214, 0.196],
    energySystems: (power: 0.41, powerEndurance: 0.22, endurance: 0.12),
  ),
  power(
    'Power',
    forceRatio: 1,
    bottomRatio: 0.9318182,
    topRatio: double.infinity,
    firstRepSeconds: 40,
    repRatios: [1, 0.375, 0.25, 0.225, 0.2, 0.2],
    energySystems: (power: 0.3, powerEndurance: 0.17, endurance: 0.05),
  );

  const CurveSection(
    this.label, {
    required this.forceRatio,
    required this.bottomRatio,
    required this.topRatio,
    required this.firstRepSeconds,
    required this.repRatios,
    required this.energySystems,
  });

  final String label;

  /// Target force over the balanced force.
  final double forceRatio;

  /// Range of forces over the balanced force that belong to the section.
  final double bottomRatio;
  final double topRatio;
  final int firstRepSeconds;

  /// Each rep's target over the first hang, for the default rest. The last
  /// ratio repeats for further reps.
  final List<double> repRatios;

  /// Starting point of the advanced configuration.
  final EnergySystems energySystems;

  int get reps => repRatios.length;

  /// Target force for a benchmark, rounded to 10 g.
  double targetForceKg(double benchmarkKg) =>
      _round2(benchmarkKg * balancedRatio * forceRatio);

  /// Section that a workout at [forceKg] trained.
  static CurveSection of(double forceKg, double benchmarkKg) {
    final ratio = forceKg / (benchmarkKg * balancedRatio);
    return values.firstWhere((section) => ratio <= section.topRatio);
  }
}

const balancedRatio = 2 / 3;
const defaultRestSeconds = 20;

double _round2(double value) => (value * 100).round() / 100;

double _normalize(double value, double low, double high) =>
    (value.clamp(low, high) - low) / (high - low);

/// The advanced configuration: how the targets after the first hang fall. The
/// second rep lasts [power] of the first; the later reps approach an
/// asymptote set by [powerEndurance] and [endurance].
typedef EnergySystems = ({
  double power,
  double powerEndurance,
  double endurance,
});

typedef Range = ({double min, double max});

const enduranceRange = (min: 0.05, max: 0.2);

/// Each energy system bounds the next one.
Range powerEnduranceRange(double endurance) =>
    (min: _round2(0.2 * endurance + 0.16).clamp(0.17, 0.2), max: 0.37);

Range powerRange(double powerEndurance) => (
  min: _round2(0.22 + 0.18 / 0.17 * (powerEndurance - 0.2)).clamp(0.22, 0.4),
  max: _round2(0.6 * powerEndurance + 0.628).clamp(0.73, 0.85),
);

/// Rounds the systems to the slider steps and clamps each into the range the
/// previous one allows.
EnergySystems clampEnergySystems(EnergySystems systems) {
  double clamp(double value, Range range) =>
      _round2(value).clamp(range.min, range.max);
  final endurance = clamp(systems.endurance, enduranceRange);
  final powerEndurance = clamp(
    systems.powerEndurance,
    powerEnduranceRange(endurance),
  );
  return (
    power: clamp(systems.power, powerRange(powerEndurance)),
    powerEndurance: powerEndurance,
    endurance: endurance,
  );
}

/// Target of each rep. Once the first hang is over, the later targets scale
/// with it if it missed its target by more than 3 s. Without [energySystems]
/// the targets follow the section's rep ratios.
List<int> repTargetSeconds(
  CurveSection section, {
  required int reps,
  required int firstHangSeconds,
  double? firstHangActualSeconds,
  EnergySystems? energySystems,
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
      energySystems == null
          ? max(1, (base * ratios[min(rep, ratios.length) - 1]).round())
          : _energySystemsTarget(energySystems, rep, base),
  ];
}

/// The second rep is [EnergySystems.power] of the first hang plus a second,
/// and the later reps fall geometrically towards the asymptote.
int _energySystemsTarget(EnergySystems systems, int rep, num firstHang) {
  final secondRep = (firstHang * systems.power).round() + 1;
  if (rep == 2) return secondRep;
  final asymptote =
      0.18 +
      0.54 *
          _normalize(
            systems.endurance,
            enduranceRange.min,
            enduranceRange.max,
          ) *
          _normalize(systems.powerEndurance, 0.17, 0.37);
  final decay = (0.5 + (systems.power - 0.45) * 0.1087 / 0.25).clamp(0.4, 0.75);
  final ratio =
      asymptote +
      (secondRep / firstHang - asymptote) * pow(decay, rep - 2).toDouble();
  return (firstHang * ratio).round();
}

/// Lowest force on the ideal force curve, held for the endurance first hang.
double curveFloorKg(double benchmarkKg) => max(
  1,
  benchmarkKg * balancedRatio * CurveSection.endurance.forceRatio - 10,
);

/// Decay rate of the ideal force curve: from the benchmark at 5 s to the
/// floor at 193 s.
double _curveDecay(double benchmarkKg) =>
    -log(max(curveFloorKg(benchmarkKg) / max(benchmarkKg, 1e-6), 1e-6)) / 188;

/// Force the ideal curve holds for [seconds].
double idealForceKg(double seconds, double benchmarkKg) =>
    benchmarkKg * exp(-_curveDecay(benchmarkKg) * (seconds - 5));

/// Hang the ideal force curve predicts at [forceKg], unrounded.
double _idealSeconds(double forceKg, double benchmarkKg) {
  final decay = _curveDecay(benchmarkKg);
  if (decay == 0) return 0;
  return max(1, 5 - log(forceKg / max(benchmarkKg, 1e-6)) / decay);
}

/// First hang the ideal force curve predicts at [forceKg].
int idealFirstHangSeconds(double forceKg, double benchmarkKg) =>
    _idealSeconds(forceKg, benchmarkKg).round();

/// The 5 s max of a hold of [forceKg] for [heldSeconds]: the benchmark whose
/// ideal curve passes through the hold, rounded to 10 g. Holds of 5 s or less
/// are the benchmark itself.
double deriveBenchmarkKg(double forceKg, double heldSeconds) {
  if (forceKg <= 0 || heldSeconds <= 5) return forceKg;
  var low = forceKg;
  var high = max(100 * forceKg, 1000.0);
  for (var i = 0; i < 100; i++) {
    final middle = (low + high) / 2;
    if (_idealSeconds(forceKg, middle) > heldSeconds) {
      high = middle;
    } else {
      low = middle;
    }
  }
  return _round2((low + high) / 2);
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

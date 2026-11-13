import 'dart:math';

import '../protocol/progressor_protocol.dart';

/// Calibration curve the firmware reports, evaluated with the firmware rules,
/// so a preview matches the device. The firmware fits and applies the curve;
/// the app only draws it.
///
/// Nonlinear curves use `x = (raw - referenceRaw) / scale`, which grows with
/// the load for either wiring polarity. Past the calibrated range `[xMin,
/// xMax]` the curve continues straight with the slope at the end of the range.
class CalibrationCurve {
  const CalibrationCurve({
    required this.model,
    required this.coefficients,
    required this.referenceRaw,
    required this.scale,
    required this.xMin,
    required this.xMax,
  });

  final CalibrationModel model;

  /// Linear `[factor, offsetKg]`, quadratic `[a, b, c]`, piecewise
  /// `[c, m1, m2, breakpoint]`.
  final List<double> coefficients;
  final double referenceRaw;
  final double scale;
  final double xMin;
  final double xMax;

  /// Absolute load in kg at an untared raw value.
  double kg(double raw) => switch (model) {
    CalibrationModel.linear =>
      coefficients[1] + (raw - referenceRaw) * coefficients[0] / 1000,
    _ => kgAt((raw - referenceRaw) / scale),
  };

  double kgAt(double x) {
    switch (model) {
      case CalibrationModel.linear:
        return coefficients[1] + coefficients[0] * scale * x / 1000;
      case CalibrationModel.quadratic:
        final [a, b, c, _] = coefficients;
        final end = x.clamp(xMin, xMax);
        return (a * end + b) * end + c + (2 * a * end + b) * (x - end);
      case CalibrationModel.piecewise:
        final [c, m1, m2, breakpoint] = coefficients;
        return c + m1 * x + (m2 - m1) * max(0, x - breakpoint);
    }
  }

  /// Raw values at the ends of the calibrated range, lowest load first.
  (double, double) get rawRange =>
      (referenceRaw + xMin * scale, referenceRaw + xMax * scale);

  /// Breakpoint of a piecewise curve as a raw value.
  double? get breakpointRaw => model == CalibrationModel.piecewise
      ? referenceRaw + coefficients[3] * scale
      : null;
}

/// Calibration point with the load the device curve gives it.
typedef FittedPoint = ({double raw, double weightKg, double? fittedKg});

/// Calibration as the firmware reports it with GetCalibrationDetails.
class CalibrationDetails {
  const CalibrationDetails({
    required this.info,
    required this.coefficients,
    required this.coordinates,
    required this.fit,
    required this.tare,
    required this.points,
  });

  final CalibrationInfo info;
  final List<double> coefficients;
  final CalibrationCoordinates coordinates;
  final CalibrationFitSummary fit;
  final CalibrationTare tare;
  final List<FittedPoint> points;

  CalibrationModel get model => info.model;

  /// These details with the load at the tare unknown, for a command that
  /// changes it, until the device reports it again.
  CalibrationDetails withUnknownTareLoad() => CalibrationDetails(
    info: info,
    coefficients: coefficients,
    coordinates: coordinates,
    fit: fit,
    tare: CalibrationTare(null, tare.zeroShift),
    points: points,
  );

  /// Factor of a linear calibration, null for a nonlinear one.
  double? get linearFactor =>
      model == CalibrationModel.linear ? coefficients[0] : null;

  /// Curve of a calibration fit from points; null for the default or a factor
  /// of earlier firmware, which have no reference or range.
  CalibrationCurve? get curve {
    final CalibrationCoordinates(:referenceRaw, :scale, :xMin, :xMax) =
        coordinates;
    if (!info.hasFit ||
        referenceRaw == null ||
        scale == null ||
        xMin == null ||
        xMax == null) {
      return null;
    }
    return CalibrationCurve(
      model: model,
      coefficients: coefficients,
      referenceRaw: referenceRaw,
      scale: scale,
      xMin: xMin,
      xMax: xMax,
    );
  }

  /// Loads at the ends of the calibrated range, null when unknown.
  ({double min, double max})? get loadRangeKg {
    final (min, max) = (fit.loadMinKg, fit.loadMaxKg);
    return min == null || max == null ? null : (min: min, max: max);
  }

  /// Average sensitivity over the calibrated range, in g per raw count, to
  /// compare readings in counts.
  double? get gramsPerCount {
    if (linearFactor case final factor?) return factor;
    final range = loadRangeKg;
    final curve = this.curve;
    if (range == null || curve == null || curve.xMax <= curve.xMin) return null;
    return (range.max - range.min) *
        1000 /
        (curve.scale.abs() * (curve.xMax - curve.xMin));
  }

  /// Whether a tared reading lies outside the calibrated range, so the device
  /// extrapolated it; null when the range or the load at the tare is unknown.
  /// The reading plus the load at the tare is the absolute load. Readings
  /// within half a percent of the range of its ends count as inside, so
  /// unloaded noise is not flagged.
  bool? isOutsideRange(double readingKg) {
    final range = loadRangeKg;
    final tareLoadKg = tare.tareLoadKg;
    if (range == null || tareLoadKg == null) return null;
    final tolerance = max(0.1, 0.005 * (range.max - range.min));
    final absolute = readingKg + tareLoadKg;
    return absolute < range.min - tolerance || absolute > range.max + tolerance;
  }
}

/// Collects the calibration detail notifications into [CalibrationDetails].
class CalibrationDetailsReader {
  CalibrationInfo? _info;
  CalibrationCurveDetail? _curve;
  CalibrationCoordinates? _coordinates;
  CalibrationFitSummary? _fit;
  CalibrationTare? _tare;
  final _points = <int, FittedPoint>{};

  /// Returns the details once [detail] completes them. An info starts over,
  /// and an end with missing parts, such as a dropped notification, returns
  /// null.
  CalibrationDetails? add(CalibrationDetail detail) {
    switch (detail) {
      case CalibrationInfo():
        _info = detail;
        _curve = null;
        _coordinates = null;
        _fit = null;
        _tare = null;
        _points.clear();
      case CalibrationCurveDetail():
        _curve = detail;
      case CalibrationCoordinates():
        _coordinates = detail;
      case CalibrationFitSummary():
        _fit = detail;
      case CalibrationTare():
        _tare = detail;
      case CalibrationFittedPoint(:final index, :final raw, :final weightKg):
        _points[index] = (
          raw: raw,
          weightKg: weightKg,
          fittedKg: detail.fittedKg,
        );
      case CalibrationDetailsEnd(:final pointCount):
        final (info, curve, coordinates, fit, tare) = (
          _info,
          _curve,
          _coordinates,
          _fit,
          _tare,
        );
        _info = null;
        final points = [for (var i = 0; i < pointCount; i++) _points[i]];
        if (info == null ||
            curve == null ||
            coordinates == null ||
            fit == null ||
            tare == null ||
            info.pointCount != pointCount ||
            points.contains(null)) {
          return null;
        }
        return CalibrationDetails(
          info: info,
          coefficients: curve.coefficients,
          coordinates: coordinates,
          fit: fit,
          tare: tare,
          points: points.nonNulls.toList(),
        );
    }
    return null;
  }
}

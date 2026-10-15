import 'dart:math';

import '../models/progressor_models.dart';

/// Error of one calibration point against the line the device applies.
typedef CalibrationResidual = ({
  CalibrationPoint point,
  double fittedKg,
  double errorKg,
});

/// How well the device factor fits the calibration points.
///
/// The firmware keeps only the slope (`factor` grams per raw count) and relies
/// on a no-load tare for the offset, so the line has the device slope and
/// passes through the average zero-weight point, like the firmware fit. Without
/// a zero-weight point, both use the mean point. Points hold untared raw counts.
class CalibrationCheck {
  CalibrationCheck._(this.residuals, this.maxErrorKg, this.rmsErrorKg);

  /// Null until at least two points define a line.
  static CalibrationCheck? of(List<CalibrationPoint> points, double factor) {
    if (points.length < 2) return null;
    final slope = factor / 1000;
    final zeroPoints = points.where((point) => point.weightKg == 0).toList();
    final anchor = zeroPoints.isEmpty ? points : zeroPoints;
    final anchorRaw = _mean(anchor.map((point) => point.raw));
    final anchorKg = _mean(anchor.map((point) => point.weightKg));
    final residuals = [
      for (final point in points)
        _residual(point, anchorKg + slope * (point.raw - anchorRaw)),
    ];
    final errors = residuals.map((residual) => residual.errorKg);
    return CalibrationCheck._(
      residuals,
      errors.map((error) => error.abs()).reduce(max),
      sqrt(_mean(errors.map((error) => error * error))),
    );
  }

  final List<CalibrationResidual> residuals;
  final double maxErrorKg;
  final double rmsErrorKg;

  /// Largest error relative to the heaviest calibration weight.
  double get maxErrorPercentOfSpan {
    final spanKg = residuals.map((r) => r.point.weightKg).reduce(max);
    return spanKg == 0 ? 0 : maxErrorKg / spanKg * 100;
  }

  static CalibrationResidual _residual(CalibrationPoint point, double fitted) =>
      (point: point, fittedKg: fitted, errorKg: fitted - point.weightKg);

  static double _mean(Iterable<double> values) =>
      values.reduce((a, b) => a + b) / values.length;
}

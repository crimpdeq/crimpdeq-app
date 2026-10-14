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
/// The firmware keeps only the least-squares slope (`factor` grams per raw
/// count) and relies on tare for the offset, so the fitted line has the device
/// slope and passes through the mean point. Points hold untared raw counts.
class CalibrationCheck {
  CalibrationCheck._(this.residuals, this.maxErrorKg, this.rmsErrorKg);

  /// Null until at least two points define a line.
  static CalibrationCheck? of(List<CalibrationPoint> points, double factor) {
    if (points.length < 2) return null;
    final slope = factor / 1000;
    final meanRaw = _mean(points.map((point) => point.raw));
    final meanKg = _mean(points.map((point) => point.weightKg));
    final residuals = [
      for (final point in points)
        _residual(point, meanKg + slope * (point.raw - meanRaw)),
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

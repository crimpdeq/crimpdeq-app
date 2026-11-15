import 'dart:typed_data';

import 'package:crimpdeq/protocol/progressor_protocol.dart';

/// Notifications of the calibration details, laid out like the firmware's
/// `crimpdeq_calibration::wire` payloads.
List<List<int>> calibrationDetailFrames({
  CalibrationModel model = CalibrationModel.linear,
  List<double> coefficients = const [0.1, 0, 0, 0],
  bool hasFit = true,
  double referenceRaw = 0,
  double scale = 100000,
  double xMin = 0,
  double xMax = 1,
  double rmsKg = 0.05,
  double maxAbsKg = 0.08,
  double loadMinKg = 0,
  double loadMaxKg = 10,
  double tareLoadKg = 0,
  double zeroShift = 0,
  CalibrationError? pending,
  CalibrationCommandResult? lastCommand,
  List<({double raw, double weightKg, double fittedKg})> points = const [],
}) {
  List<int> frame(List<int> payload) => [
    calibrationDetailCode,
    payload.length,
    ...payload,
  ];
  List<int> floats(List<double> values) => [
    for (final value in values)
      ...(ByteData(
        4,
      )..setFloat32(0, value, Endian.little)).buffer.asUint8List(),
  ];
  double known(double value) => hasFit ? value : double.nan;

  return [
    frame([
      0,
      1,
      0x7,
      model.code,
      points.length,
      hasFit ? 1 : 0,
      pending?.code ?? 0,
      lastCommand?.opCode ?? 0,
      lastCommand?.disposition.index ?? 0,
      lastCommand?.error?.code ?? 0,
    ]),
    frame([1, model.code, ...floats(coefficients)]),
    frame([
      2,
      ...floats([known(referenceRaw), known(scale), known(xMin), known(xMax)]),
    ]),
    frame([
      3,
      ...floats([
        points.isEmpty ? double.nan : known(rmsKg),
        points.isEmpty ? double.nan : known(maxAbsKg),
        known(loadMinKg),
        known(loadMaxKg),
      ]),
    ]),
    frame([
      4,
      ...floats([known(tareLoadKg), zeroShift]),
    ]),
    for (final (index, point) in points.indexed)
      frame([
        5,
        index,
        ...floats([point.raw, point.weightKg, known(point.fittedKg)]),
      ]),
    frame([6, points.length]),
  ];
}

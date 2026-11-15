import 'dart:typed_data';

/// Tindeq Progressor BLE protocol, as implemented by the Crimpdeq firmware.
const progressorServiceUuid = '7e4e1701-1ea6-40c9-9dcc-13d34ffead57';
const progressorNotifyCharUuid = '7e4e1702-1ea6-40c9-9dcc-13d34ffead57';
const progressorWriteCharUuid = '7e4e1703-1ea6-40c9-9dcc-13d34ffead57';

/// Calibration points the firmware stores before it ignores new ones.
const maxCalibrationPoints = 20;

/// Commands written to the control point as `[opcode, payload...]`.
enum ControlOpCode {
  tareScale(0x64),
  startMeasurement(0x65),
  stopMeasurement(0x66),
  addCalibrationPoint(0x69),
  getAppVersion(0x6B),
  sampleBattery(0x6F),
  getCalibration(0x72),
  defaultCalibration(0x74),
  setSampleRate(0x75),
  getSampleRate(0x76),
  getBatteryStatus(0x77),
  removeCalibrationPoint(0x78),
  getCalibrationDetails(0x79),
  setCalibrationModel(0x7A),
  setZero(0x7B);

  const ControlOpCode(this.value);

  final int value;
}

/// One weight sample: the timestamp counts microseconds since the measurement
/// started and wraps at 2^32.
typedef RawWeightSample = ({double weightKg, int timestampUs});

/// Notification decoded from a `[responseCode, payloadLength, payload...]` frame.
sealed class ProgressorMessage {}

/// Response to [ControlOpCode.getAppVersion] or [ControlOpCode.sampleBattery].
/// The response code is shared, so the payload is matched to its request.
final class CommandResponse extends ProgressorMessage {
  CommandResponse(this.payload);
  final Uint8List payload;
}

final class WeightSamples extends ProgressorMessage {
  WeightSamples(this.samples);
  final List<RawWeightSample> samples;
}

/// Sent before the battery runs out; the device then turns itself off.
final class LowPowerWarning extends ProgressorMessage {}

/// Factor applied as `kg = (raw - tare) * factor / 1000`. The firmware sends it
/// before the stored calibration points. NaN for a nonlinear calibration, which
/// no single factor describes.
final class CalibrationFactor extends ProgressorMessage {
  CalibrationFactor(this.factor);
  final double factor;
}

final class CalibrationPointMessage extends ProgressorMessage {
  CalibrationPointMessage(this.raw, this.weightKg);
  final double raw;
  final double weightKg;
}

final class SampleRate extends ProgressorMessage {
  SampleRate(this.samplesPerSecond);
  final int samplesPerSecond;
}

/// Answer to [ControlOpCode.removeCalibrationPoint], sent after the new
/// calibration when the device removed the point. Firmware without the
/// command never sends it.
final class CalibrationPointRemoved extends ProgressorMessage {
  CalibrationPointRemoved(this.removed);
  final bool removed;
}

/// Calibration model of the firmware. The value is its BLE code.
enum CalibrationModel {
  linear(0, 'Linear'),
  quadratic(1, 'Quadratic'),
  piecewise(2, 'Piecewise linear');

  const CalibrationModel(this.code, this.label);

  final int code;
  final String label;

  static CalibrationModel? fromCode(int code) =>
      values.where((model) => model.code == code).firstOrNull;
}

/// Why the firmware could not apply a calibration command. The value is its
/// BLE code.
enum CalibrationError {
  notEnoughPoints(1, 'The model needs more points.'),
  notEnoughLoadLevels(
    2,
    'The model needs more different loads. Loads within 2% of the load '
    'range count as one.',
  ),
  noMidRangeLevel(
    3,
    'The quadratic model needs a load in the middle half of the range.',
  ),
  insufficientSegmentSupport(
    4,
    'Each segment needs at least 3 different loads on its side of the break.',
  ),
  noBreakpoint(
    5,
    'The two segments have almost the same slope, so the points show no '
    'break. Use the linear model.',
  ),
  implausibleSensitivity(
    6,
    'The fit is implausible for the load cell. Check that each weight was '
    'hung and entered correctly.',
  ),
  excessiveNonlinearity(
    7,
    'The curve bends more than a load cell does. Check the points for a '
    'wrong one.',
  ),
  notMonotonic(
    8,
    'The curve would read less as the load grows. Check the points for a '
    'wrong one.',
  ),
  nonFinite(9, 'A point or coefficient is not a number.'),
  degenerate(10, 'The points do not determine the curve.'),
  unsupportedModel(11, 'The firmware does not support this model.'),
  pointLimitReached(12, 'The device holds no more points.'),
  invalidIndex(13, 'The device has no such point.'),
  samplingFailed(14, 'The device failed to read the load cell.'),
  zeroOutOfRange(
    15,
    'The load cell is not unloaded: the reading is over 1 kg from the '
    'calibrated zero. Remove the load, or tare instead.',
  );

  const CalibrationError(this.code, this.message);

  final int code;
  final String message;

  static CalibrationError? fromCode(int code) =>
      values.where((error) => error.code == code).firstOrNull;
}

/// What a calibration command did.
enum CalibrationDisposition {
  /// The calibration fit from the stored points is in use.
  applied,

  /// The points were stored, but the device keeps the previous calibration
  /// until they can be fit.
  pending,

  /// Nothing changed.
  rejected,
}

/// Last calibration command the device ran, with its outcome.
typedef CalibrationCommandResult = ({
  int opCode,
  CalibrationDisposition disposition,
  CalibrationError? error,
});

/// One notification of the calibration details that firmware with calibration
/// models sends: info first, then the curve, coordinates, fit, tare, each
/// point and the end. Unknown values are NaN, decoded as null.
sealed class CalibrationDetail extends ProgressorMessage {}

final class CalibrationInfo extends CalibrationDetail {
  CalibrationInfo({
    required this.version,
    required this.supportedModels,
    required this.model,
    required this.pointCount,
    required this.hasFit,
    required this.pending,
    required this.lastCommand,
  });

  final int version;
  final Set<CalibrationModel> supportedModels;
  final CalibrationModel model;
  final int pointCount;

  /// Whether the calibration was fit from points, so its range is known.
  final bool hasFit;

  /// Why the stored points are not applied, or null when they are.
  final CalibrationError? pending;
  final CalibrationCommandResult? lastCommand;
}

/// Coefficients in the firmware order: linear `[factor, offsetKg]`, quadratic
/// `[a, b, c]`, piecewise `[c, m1, m2, breakpoint]`.
final class CalibrationCurveDetail extends CalibrationDetail {
  CalibrationCurveDetail(this.model, this.coefficients);
  final CalibrationModel model;
  final List<double> coefficients;
}

final class CalibrationCoordinates extends CalibrationDetail {
  CalibrationCoordinates(this.referenceRaw, this.scale, this.xMin, this.xMax);
  final double? referenceRaw;
  final double? scale;
  final double? xMin;
  final double? xMax;
}

final class CalibrationFitSummary extends CalibrationDetail {
  CalibrationFitSummary(
    this.rmsKg,
    this.maxAbsKg,
    this.loadMinKg,
    this.loadMaxKg,
  );
  final double? rmsKg;
  final double? maxAbsKg;
  final double? loadMinKg;
  final double? loadMaxKg;
}

final class CalibrationTare extends CalibrationDetail {
  CalibrationTare(this.tareLoadKg, this.zeroShift);
  final double? tareLoadKg;
  final double zeroShift;
}

final class CalibrationFittedPoint extends CalibrationDetail {
  CalibrationFittedPoint(this.index, this.raw, this.weightKg, this.fittedKg);
  final int index;
  final double raw;
  final double weightKg;
  final double? fittedKg;
}

final class CalibrationDetailsEnd extends CalibrationDetail {
  CalibrationDetailsEnd(this.pointCount);
  final int pointCount;
}

/// Fuel gauge reading; firmware without GetBatteryStatus never sends it.
final class BatteryStatus extends ProgressorMessage {
  BatteryStatus(this.percent, this.charging);
  final int percent;
  final bool charging;
}

const _weightSampleSize = 8;

/// `[responseCode, payloadLength, payload...]` notification frame.
typedef Frame = ({int code, Uint8List payload});

/// Parses a notification that carries one frame, as native platforms deliver
/// them. Returns null when the length byte does not match the notification.
Frame? parseFrame(List<int> notification) {
  if (notification.length < 2 || notification.length != 2 + notification[1]) {
    return null;
  }
  return (
    code: notification[0],
    payload: Uint8List.fromList(notification.sublist(2)),
  );
}

/// Reassembles frames from notification chunks, as Web Bluetooth may split or
/// batch them.
class FrameReader {
  final _buffer = <int>[];

  /// Returns the frames completed by [chunk]. A known code with a length it
  /// cannot have is a corrupted header, so it drops the buffer instead of
  /// swallowing the next frames.
  List<Frame> add(List<int> chunk) {
    _buffer.addAll(chunk);
    final frames = <Frame>[];
    while (_buffer.length >= 2) {
      if (!_isValidPayloadLength(_buffer[0], _buffer[1])) {
        _buffer.clear();
        break;
      }
      final frameLength = 2 + _buffer[1];
      if (_buffer.length < frameLength) break;
      frames.add((
        code: _buffer[0],
        payload: Uint8List.fromList(_buffer.sublist(2, frameLength)),
      ));
      _buffer.removeRange(0, frameLength);
    }
    return frames;
  }
}

/// Whether a frame with response [code] can carry [length] payload bytes.
/// Unknown codes can carry any, as newer firmware may add them.
bool _isValidPayloadLength(int code, int length) => switch (code) {
  1 => length % _weightSampleSize == 0,
  4 => length == 0,
  5 => length == 4,
  6 => length == 8,
  7 || 8 => length == 2,
  9 => length == 1,
  calibrationDetailCode => length >= 1 && length <= 18,
  _ => true,
};

/// Response code of every calibration detail.
const calibrationDetailCode = 10;

/// Throws [FormatException] for unknown codes and malformed payloads. Drops
/// non-finite weights, which are not readings and would poison the stats.
ProgressorMessage decodeMessage(Frame frame) {
  final (:code, :payload) = frame;
  if (!_isValidPayloadLength(code, payload.length)) {
    throw FormatException(
      'Response code $code cannot carry ${payload.length} payload bytes',
    );
  }
  final data = ByteData.sublistView(payload);
  return switch (code) {
    0 => CommandResponse(payload),
    1 => WeightSamples([
      for (var i = 0; i < payload.length; i += _weightSampleSize)
        if (data.getFloat32(i, Endian.little) case final weightKg
            when weightKg.isFinite)
          (
            weightKg: weightKg,
            timestampUs: data.getUint32(i + 4, Endian.little),
          ),
    ]),
    4 => LowPowerWarning(),
    5 => CalibrationFactor(data.getFloat32(0, Endian.little)),
    6 => CalibrationPointMessage(
      data.getFloat32(0, Endian.little),
      data.getFloat32(4, Endian.little),
    ),
    7 => SampleRate(data.getUint16(0, Endian.little)),
    8 => BatteryStatus(payload[0], payload[1] != 0),
    9 => CalibrationPointRemoved(payload[0] != 0),
    calibrationDetailCode => _decodeCalibrationDetail(payload),
    _ => throw FormatException('Unknown response code $code'),
  };
}

CalibrationDetail _decodeCalibrationDetail(Uint8List payload) {
  final data = ByteData.sublistView(payload);
  final kind = payload[0];
  const lengths = {0: 10, 1: 18, 2: 17, 3: 17, 4: 9, 5: 14, 6: 2};
  if (lengths[kind] case final length? when length != payload.length) {
    throw FormatException(
      'Calibration detail $kind cannot carry ${payload.length} bytes',
    );
  }
  double? float(int offset) {
    final value = data.getFloat32(offset, Endian.little);
    return value.isFinite ? value : null;
  }

  CalibrationModel model(int code) =>
      CalibrationModel.fromCode(code) ??
      (throw FormatException('Unknown calibration model $code'));
  CalibrationError? error(int code) => code == 0
      ? null
      : CalibrationError.fromCode(code) ??
            (throw FormatException('Unknown calibration error $code'));

  return switch (kind) {
    0 => CalibrationInfo(
      version: payload[1],
      supportedModels: {
        for (final model in CalibrationModel.values)
          if (payload[2] & (1 << model.code) != 0) model,
      },
      model: model(payload[3]),
      pointCount: payload[4],
      hasFit: payload[5] & 1 != 0,
      pending: error(payload[6]),
      lastCommand: payload[7] == 0
          ? null
          : (
              opCode: payload[7],
              disposition:
                  CalibrationDisposition.values.elementAtOrNull(payload[8]) ??
                  (throw FormatException('Unknown disposition ${payload[8]}')),
              error: error(payload[9]),
            ),
    ),
    1 => CalibrationCurveDetail(model(payload[1]), [
      for (var offset = 2; offset < 18; offset += 4)
        data.getFloat32(offset, Endian.little),
    ]),
    2 => CalibrationCoordinates(float(1), float(5), float(9), float(13)),
    3 => CalibrationFitSummary(float(1), float(5), float(9), float(13)),
    4 => CalibrationTare(float(1), float(5) ?? 0),
    5 => CalibrationFittedPoint(
      payload[1],
      data.getFloat32(2, Endian.little),
      data.getFloat32(6, Endian.little),
      float(10),
    ),
    6 => CalibrationDetailsEnd(payload[1]),
    _ => throw FormatException('Unknown calibration detail $kind'),
  };
}

/// Battery voltage in millivolts from a [ControlOpCode.sampleBattery] response.
int decodeBatteryMillivolts(Uint8List payload) {
  if (payload.length != 4) {
    throw FormatException(
      'Battery response expects 4 payload bytes, got ${payload.length}',
    );
  }
  return ByteData.sublistView(payload).getUint32(0, Endian.little);
}

List<int> encodeFloat32(double value) =>
    (ByteData(4)..setFloat32(0, value, Endian.little)).buffer.asUint8List();

List<int> encodeUint16(int value) =>
    (ByteData(2)..setUint16(0, value, Endian.little)).buffer.asUint8List();

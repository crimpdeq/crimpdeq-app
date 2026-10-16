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
  deleteCalibrationPoint(0x78);

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
/// before the stored calibration points.
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
  _ => true,
};

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
    _ => throw FormatException('Unknown response code $code'),
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

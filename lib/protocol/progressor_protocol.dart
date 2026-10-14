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
  getBatteryStatus(0x77);

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

/// Reassembles frames from notification chunks. Native platforms deliver one
/// frame per notification; Web Bluetooth may split or batch them.
class FrameReader {
  final _buffer = <int>[];

  /// Returns the frames completed by [chunk].
  List<Frame> add(List<int> chunk) {
    _buffer.addAll(chunk);
    final frames = <Frame>[];
    while (_buffer.length >= 2) {
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

/// Throws [FormatException] for unknown codes and malformed payloads.
ProgressorMessage decodeMessage(Frame frame) {
  final (:code, :payload) = frame;
  final data = ByteData.sublistView(payload);
  switch (code) {
    case 0:
      return CommandResponse(payload);
    case 1:
      if (payload.length % _weightSampleSize != 0) {
        throw FormatException(
          'Weight payload of ${payload.length} bytes is not a multiple of '
          '$_weightSampleSize',
        );
      }
      return WeightSamples([
        for (var i = 0; i < payload.length; i += _weightSampleSize)
          (
            weightKg: data.getFloat32(i, Endian.little),
            timestampUs: data.getUint32(i + 4, Endian.little),
          ),
      ]);
    case 4:
      return LowPowerWarning();
    case 5:
      _expectLength(code, payload, 4);
      return CalibrationFactor(data.getFloat32(0, Endian.little));
    case 6:
      _expectLength(code, payload, 8);
      return CalibrationPointMessage(
        data.getFloat32(0, Endian.little),
        data.getFloat32(4, Endian.little),
      );
    case 7:
      _expectLength(code, payload, 2);
      return SampleRate(data.getUint16(0, Endian.little));
    case 8:
      _expectLength(code, payload, 2);
      return BatteryStatus(payload[0], payload[1] != 0);
    default:
      throw FormatException('Unknown response code $code');
  }
}

/// Battery voltage in millivolts from a [ControlOpCode.sampleBattery] response.
int decodeBatteryMillivolts(Uint8List payload) {
  _expectLength(0, payload, 4);
  return ByteData.sublistView(payload).getUint32(0, Endian.little);
}

List<int> encodeFloat32(double value) =>
    (ByteData(4)..setFloat32(0, value, Endian.little)).buffer.asUint8List();

List<int> encodeUint16(int value) =>
    (ByteData(2)..setUint16(0, value, Endian.little)).buffer.asUint8List();

void _expectLength(int code, Uint8List payload, int length) {
  if (payload.length != length) {
    throw FormatException(
      'Response code $code expects $length payload bytes, got ${payload.length}',
    );
  }
}

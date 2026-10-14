import 'dart:typed_data';

import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _bytes(List<int> values) => Uint8List.fromList(values);

List<int> _float32(double value) => encodeFloat32(value);

List<int> _uint32(int value) =>
    (ByteData(4)..setUint32(0, value, Endian.little)).buffer.asUint8List();

void main() {
  group('FrameReader', () {
    test('returns one frame per complete notification', () {
      final frames = FrameReader().add([7, 2, 175, 0]);

      expect(frames, hasLength(1));
      expect(frames.single.code, 7);
      expect(frames.single.payload, [175, 0]);
    });

    test('reassembles a frame split across chunks', () {
      final reader = FrameReader();

      expect(reader.add([5, 4, ..._float32(0.08).take(2)]), isEmpty);
      final frames = reader.add(_float32(0.08).skip(2).toList());

      expect(frames.single.code, 5);
      expect(frames.single.payload, _float32(0.08));
    });

    test('splits batched frames', () {
      final frames = FrameReader().add([4, 0, 7, 2, 20, 0, 0, 1, 65]);

      expect([for (final frame in frames) frame.code], [4, 7, 0]);
      expect(frames.last.payload, [65]);
    });
  });

  group('decodeMessage', () {
    test('decodes weight samples', () {
      final message = decodeMessage((
        code: 1,
        payload: _bytes([
          ..._float32(1.5),
          ..._uint32(1000),
          ..._float32(-0.25),
          ..._uint32(0xFFFFFFFF),
        ]),
      ));

      expect(message, isA<WeightSamples>());
      expect((message as WeightSamples).samples, [
        (weightKg: 1.5, timestampUs: 1000),
        (weightKg: -0.25, timestampUs: 0xFFFFFFFF),
      ]);
    });

    test('decodes the calibration factor and points', () {
      final factor = decodeMessage((code: 5, payload: _bytes(_float32(0.5))));
      final point = decodeMessage((
        code: 6,
        payload: _bytes([..._float32(12000), ..._float32(20)]),
      ));

      expect((factor as CalibrationFactor).factor, 0.5);
      expect((point as CalibrationPointMessage).raw, 12000);
      expect(point.weightKg, 20);
    });

    test('decodes the sample rate and the low power warning', () {
      final rate = decodeMessage((code: 7, payload: _bytes([0xE8, 0x03])));

      expect((rate as SampleRate).samplesPerSecond, 1000);
      expect(
        decodeMessage((code: 4, payload: _bytes([]))),
        isA<LowPowerWarning>(),
      );
    });

    test('keeps command responses raw', () {
      final message = decodeMessage((code: 0, payload: _bytes([0x48, 0x0D])));

      expect((message as CommandResponse).payload, [0x48, 0x0D]);
    });

    test('rejects malformed payloads and unknown codes', () {
      expect(
        () => decodeMessage((code: 1, payload: _bytes([1, 2, 3]))),
        throwsFormatException,
      );
      expect(
        () => decodeMessage((code: 5, payload: _bytes([1, 2]))),
        throwsFormatException,
      );
      expect(
        () => decodeMessage((code: 2, payload: _bytes([]))),
        throwsFormatException,
      );
    });
  });

  test('decodes battery voltages that look like text', () {
    // 3400 mV is "H\r" in ASCII, which a text heuristic took for a version.
    expect(decodeBatteryMillivolts(_bytes([0x48, 0x0D, 0, 0])), 3400);
    expect(
      () => decodeBatteryMillivolts(_bytes([1, 2])),
      throwsFormatException,
    );
  });

  test('encodes command payloads in little endian', () {
    expect(encodeUint16(330), [0x4A, 0x01]);
    expect(encodeFloat32(1), [0, 0, 0x80, 0x3F]);
  });
}

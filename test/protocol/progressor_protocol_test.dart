import 'dart:typed_data';

import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _bytes(List<int> values) => Uint8List.fromList(values);

List<int> _float32(double value) => encodeFloat32(value);

List<int> _uint32(int value) =>
    (ByteData(4)..setUint32(0, value, Endian.little)).buffer.asUint8List();

void main() {
  test('parses one frame per notification and drops mismatched lengths', () {
    final frame = parseFrame([7, 2, 175, 0])!;

    expect(frame.code, 7);
    expect(frame.payload, [175, 0]);
    // Truncated, then followed by another frame.
    expect(parseFrame([1, 16, ..._float32(1), ..._uint32(1000)]), isNull);
    expect(parseFrame([7, 2, 175, 0, 7, 2, 175, 0]), isNull);
    expect(parseFrame([4]), isNull);
  });

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

    test('drops the buffer at a known code with an impossible length', () {
      final reader = FrameReader();

      expect(reader.add([7, 2, 175, 0, 7, 3, 1, 2, 3, 4, 0]).single.code, 7);
      expect(reader.add([7, 2, 175, 0]).single.payload, [175, 0]);
    });

    test('keeps the frames after an unknown code', () {
      final frames = FrameReader().add([2, 1, 9, 4, 0]);

      expect([for (final frame in frames) frame.code], [2, 4]);
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

    test('drops non-finite weights', () {
      final message = decodeMessage((
        code: 1,
        payload: _bytes([
          ..._float32(double.nan),
          ..._uint32(1000),
          ..._float32(double.infinity),
          ..._uint32(2000),
          ..._float32(2),
          ..._uint32(3000),
        ]),
      ));

      expect((message as WeightSamples).samples, [
        (weightKg: 2.0, timestampUs: 3000),
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

    test('decodes the battery status', () {
      final status = decodeMessage((code: 8, payload: _bytes([21, 1])));

      expect((status as BatteryStatus).percent, 21);
      expect(status.charging, isTrue);
      expect(
        () => decodeMessage((code: 8, payload: _bytes([21]))),
        throwsFormatException,
      );
    });

    test('decodes the calibration point removal', () {
      final removed = decodeMessage((code: 9, payload: _bytes([1])));
      final kept = decodeMessage((code: 9, payload: _bytes([0])));

      expect((removed as CalibrationPointRemoved).removed, isTrue);
      expect((kept as CalibrationPointRemoved).removed, isFalse);
      expect(
        () => decodeMessage((code: 9, payload: _bytes([1, 0]))),
        throwsFormatException,
      );
    });

    group('calibration details', () {
      // The info that the firmware wire test encodes.
      test('decodes the info', () {
        final info = decodeMessage((
          code: calibrationDetailCode,
          payload: _bytes([0, 1, 0x7, 2, 16, 1, 1, 0x7A, 2, 3]),
        )) as CalibrationInfo;

        expect(info.version, 1);
        expect(info.supportedModels, CalibrationModel.values.toSet());
        expect(info.model, CalibrationModel.piecewise);
        expect(info.pointCount, 16);
        expect(info.hasFit, isTrue);
        expect(info.pending, CalibrationError.notEnoughPoints);
        expect(info.lastCommand, (
          opCode: 0x7A,
          disposition: CalibrationDisposition.rejected,
          error: CalibrationError.noMidRangeLevel,
        ));

        final idle = decodeMessage((
          code: calibrationDetailCode,
          payload: _bytes([0, 1, 0x1, 0, 0, 0, 0, 0, 0, 0]),
        )) as CalibrationInfo;
        expect(idle.supportedModels, {CalibrationModel.linear});
        expect(idle.pending, isNull);
        expect(idle.lastCommand, isNull);
      });

      test('decodes the curve, values and points', () {
        final curve = decodeMessage((
          code: calibrationDetailCode,
          payload: _bytes([
            1,
            1,
            ..._float32(-10),
            ..._float32(100),
            ..._float32(0),
            ..._float32(0),
          ]),
        )) as CalibrationCurveDetail;
        expect(curve.model, CalibrationModel.quadratic);
        expect(curve.coefficients, [-10, 100, 0, 0]);

        final fit = decodeMessage((
          code: calibrationDetailCode,
          payload: _bytes([
            3,
            ..._float32(double.nan),
            ..._float32(0.25),
            ..._float32(0),
            ..._float32(90.5),
          ]),
        )) as CalibrationFitSummary;
        expect(fit.rmsKg, isNull, reason: 'NaN is unknown');
        expect(fit.maxAbsKg, 0.25);
        expect(fit.loadMaxKg, 90.5);

        final point = decodeMessage((
          code: calibrationDetailCode,
          payload: _bytes([
            5,
            14,
            ..._float32(12000),
            ..._float32(20),
            ..._float32(20.125),
          ]),
        )) as CalibrationFittedPoint;
        expect(
          (point.index, point.raw, point.weightKg, point.fittedKg),
          (14, 12000, 20, 20.125),
        );
        expect(
          (decodeMessage((
            code: calibrationDetailCode,
            payload: _bytes([6, 16]),
          )) as CalibrationDetailsEnd).pointCount,
          16,
        );
      });

      test('rejects malformed details', () {
        for (final payload in [
          // Truncated info, an unknown model, kind and error.
          [0, 1, 7, 0, 0, 0, 0, 0, 0],
          [0, 1, 7, 9, 0, 0, 0, 0, 0, 0],
          [9, 0],
          [0, 1, 7, 0, 0, 0, 99, 0, 0, 0],
        ]) {
          expect(
            () => decodeMessage((
              code: calibrationDetailCode,
              payload: _bytes(payload),
            )),
            throwsFormatException,
            reason: '$payload',
          );
        }
        // Too long for any detail, so the reader drops the buffer.
        expect(
          () => decodeMessage((
            code: calibrationDetailCode,
            payload: _bytes(List.filled(19, 0)),
          )),
          throwsFormatException,
        );
      });
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

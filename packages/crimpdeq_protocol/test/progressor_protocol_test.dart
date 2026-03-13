import 'dart:async';
import 'dart:typed_data';

import 'package:crimpdeq_protocol/crimpdeq_protocol.dart';
import 'package:test/test.dart';

// ── Test helpers ──────────────────────────────────────────────────

class _RecordingTransport implements BleTransport {
  final List<List<int>> writes = [];

  @override
  Future<void> write(List<int> data) async {
    writes.add(List<int>.from(data));
  }
}

/// Build a framed weight-measurement notification.
///
/// Each sample is 8 bytes: float32 LE weight + uint32 LE timestamp.
List<int> _weightFrame(List<(double weight, int timestampUs)> samples) {
  final payload = ByteData(samples.length * 8);
  for (var i = 0; i < samples.length; i++) {
    payload.setFloat32(i * 8, samples[i].$1, Endian.little);
    payload.setUint32(i * 8 + 4, samples[i].$2, Endian.little);
  }
  return [
    ProgressorConstants.weightMeasure,
    payload.lengthInBytes,
    ...payload.buffer.asUint8List(),
  ];
}

/// Build a framed command-response containing a printable ASCII string.
List<int> _firmwareFrame(String version) {
  final bytes = version.codeUnits;
  return [ProgressorConstants.commandResponse, bytes.length, ...bytes];
}

/// Build a framed command-response with a uint32 LE battery voltage.
List<int> _batteryFrame(int millivolts) {
  final bd = ByteData(4)..setUint32(0, millivolts, Endian.little);
  return [ProgressorConstants.commandResponse, 4, ...bd.buffer.asUint8List()];
}

/// Build a legacy 5-byte battery frame (no length byte).
List<int> _legacyBatteryFrame(int millivolts) {
  final bd = ByteData(4)..setUint32(0, millivolts, Endian.little);
  return [ProgressorConstants.commandResponse, ...bd.buffer.asUint8List()];
}

/// Build a framed calibration-factor response (type 5).
List<int> _calibrationFactorFrame(double factor) {
  final bd = ByteData(4)..setFloat32(0, factor, Endian.little);
  return [5, 4, ...bd.buffer.asUint8List()];
}

/// Build a legacy calibration-factor frame (no length byte).
List<int> _legacyCalibrationFactorFrame(double factor) {
  final bd = ByteData(4)..setFloat32(0, factor, Endian.little);
  return [5, ...bd.buffer.asUint8List()];
}

/// Build a framed calibration-point response (type 6).
List<int> _calibrationPointFrame(double a, double b) {
  final bd = ByteData(8)
    ..setFloat32(0, a, Endian.little)
    ..setFloat32(4, b, Endian.little);
  return [6, 8, ...bd.buffer.asUint8List()];
}

/// Build a legacy calibration-point frame (no length byte).
List<int> _legacyCalibrationPointFrame(double a, double b) {
  final bd = ByteData(8)
    ..setFloat32(0, a, Endian.little)
    ..setFloat32(4, b, Endian.little);
  return [6, ...bd.buffer.asUint8List()];
}

// ── Tests ─────────────────────────────────────────────────────────

void main() {
  late _RecordingTransport transport;
  late ProgressorProtocol protocol;

  setUp(() {
    transport = _RecordingTransport();
    protocol = ProgressorProtocol(transport);
  });

  tearDown(() => protocol.dispose());

  group('weight measurement parsing', () {
    test('single sample emits WeightEvent', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      protocol.handleNotification(_weightFrame([(12.5, 1000000)]));
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      final e = events.first as WeightEvent;
      expect(e.measurements, hasLength(1));
      expect(e.measurements[0].weight, closeTo(12.5, 0.001));
      expect(e.measurements[0].timestampUs, 1000000);
    });

    test('multi-sample packet emits all measurements', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      protocol.handleNotification(_weightFrame([
        (5.0, 100000),
        (10.0, 200000),
        (15.0, 300000),
      ]));
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      final e = events.first as WeightEvent;
      expect(e.measurements, hasLength(3));
      expect(e.measurements[0].weight, closeTo(5.0, 0.001));
      expect(e.measurements[1].weight, closeTo(10.0, 0.001));
      expect(e.measurements[2].weight, closeTo(15.0, 0.001));
    });

    test('incomplete frame waits for remaining bytes', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      final frame = _weightFrame([(7.7, 500000)]);
      // Send first 5 bytes, then the rest.
      protocol.handleNotification(frame.sublist(0, 5));
      await Future.delayed(Duration.zero);
      expect(events, isEmpty);

      protocol.handleNotification(frame.sublist(5));
      await Future.delayed(Duration.zero);
      expect(events, hasLength(1));
      expect((events.first as WeightEvent).measurements[0].weight,
          closeTo(7.7, 0.01));
    });
  });

  group('command response parsing', () {
    test('firmware version string', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      protocol.handleNotification(_firmwareFrame('2.1.3'));
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect((events.first as FirmwareVersionEvent).version, '2.1.3');
    });

    test('battery voltage (framed)', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      protocol.handleNotification(_batteryFrame(3850));
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect((events.first as BatteryVoltageEvent).millivolts, 3850);
    });

    test('legacy 5-byte battery frame', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      protocol.handleNotification(_legacyBatteryFrame(4200));
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect((events.first as BatteryVoltageEvent).millivolts, 4200);
    });
  });

  group('calibration parsing', () {
    test('calibration factor (framed)', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      protocol.handleNotification(_calibrationFactorFrame(1.234));
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(
          (events.first as CalibrationFactorEvent).factor, closeTo(1.234, 0.001));
    });

    test('legacy calibration factor (no length byte)', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      protocol.handleNotification(_legacyCalibrationFactorFrame(2.0));
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(
          (events.first as CalibrationFactorEvent).factor, closeTo(2.0, 0.001));
    });

    test('calibration point (framed)', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      protocol.handleNotification(_calibrationPointFrame(0.5, 9.81));
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      final e = events.first as CalibrationPointEvent;
      expect(e.valueA, closeTo(0.5, 0.001));
      expect(e.valueB, closeTo(9.81, 0.01));
    });

    test('legacy calibration point (no length byte)', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      protocol.handleNotification(_legacyCalibrationPointFrame(1.0, 5.0));
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      final e = events.first as CalibrationPointEvent;
      expect(e.valueA, closeTo(1.0, 0.001));
      expect(e.valueB, closeTo(5.0, 0.001));
    });
  });

  group('low battery', () {
    test('single-byte low battery warning', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      protocol.handleNotification([ProgressorConstants.lowBatteryWarning]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first, isA<LowBatteryEvent>());
    });
  });

  group('outgoing commands', () {
    test('startMeasurement writes "e"', () async {
      await protocol.startMeasurement();
      expect(transport.writes, hasLength(1));
      expect(transport.writes[0], [0x65]); // 'e'
    });

    test('stopMeasurement writes "f"', () async {
      await protocol.stopMeasurement();
      expect(transport.writes, hasLength(1));
      expect(transport.writes[0], [0x66]); // 'f'
    });

    test('tareScale writes "d"', () async {
      await protocol.tareScale();
      expect(transport.writes, hasLength(1));
      expect(transport.writes[0], [0x64]); // 'd'
    });

    test('getFirmwareVersion writes "k"', () async {
      await protocol.getFirmwareVersion();
      expect(transport.writes, hasLength(1));
      expect(transport.writes[0], [0x6B]); // 'k'
    });

    test('getBatteryVoltage writes "o"', () async {
      await protocol.getBatteryVoltage();
      expect(transport.writes, hasLength(1));
      expect(transport.writes[0], [0x6F]); // 'o'
    });

    test('getCalibration sends opcode 0x72', () async {
      await protocol.getCalibration();
      expect(transport.writes, hasLength(1));
      expect(transport.writes[0], [0x72]);
    });

    test('addCalibrationPoint sends opcode 0x69 + float32', () async {
      await protocol.addCalibrationPoint(5.0);
      expect(transport.writes, hasLength(1));
      expect(transport.writes[0][0], 0x69);
      expect(transport.writes[0].length, 5); // opcode + 4-byte float
      final bd = ByteData.view(
          Uint8List.fromList(transport.writes[0].sublist(1)).buffer);
      expect(bd.getFloat32(0, Endian.little), closeTo(5.0, 0.001));
    });

    test('defaultCalibration sends opcode 0x74', () async {
      await protocol.defaultCalibration();
      expect(transport.writes, hasLength(1));
      expect(transport.writes[0], [0x74]);
    });
  });

  group('frame reassembly edge cases', () {
    test('multiple frames in one chunk', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      final frame1 = _firmwareFrame('1.0');
      final frame2 = _weightFrame([(3.3, 100000)]);
      protocol.handleNotification([...frame1, ...frame2]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(2));
      expect(events[0], isA<FirmwareVersionEvent>());
      expect(events[1], isA<WeightEvent>());
    });

    test('resetBuffer discards partial frame', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      // Send partial frame then reset.
      final frame = _weightFrame([(1.0, 100000)]);
      protocol.handleNotification(frame.sublist(0, 3));
      protocol.resetBuffer();

      // New complete frame should parse fine.
      protocol.handleNotification(_weightFrame([(2.0, 200000)]));
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect((events.first as WeightEvent).measurements[0].weight,
          closeTo(2.0, 0.001));
    });

    test('legacy battery frame batched with following notification', () async {
      final events = <ProgressorEvent>[];
      protocol.events.listen(events.add);

      final legacyBat = _legacyBatteryFrame(3700);
      final weight = _weightFrame([(8.0, 400000)]);
      protocol.handleNotification([...legacyBat, ...weight]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(2));
      expect((events[0] as BatteryVoltageEvent).millivolts, 3700);
      expect(
          (events[1] as WeightEvent).measurements[0].weight, closeTo(8.0, 0.01));
    });
  });
}

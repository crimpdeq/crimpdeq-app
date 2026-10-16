import 'dart:async';
import 'dart:typed_data';

import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_ble.dart';

/// Holds the start write open instead of using Bluetooth.
class _SlowStartProgressor extends ProgressorNotifier {
  final startWrite = Completer<bool>();

  @override
  ProgressorState build() => const ProgressorState();

  @override
  Future<void> startMeasurement() async {
    if (!await startWrite.future) return;
    state = state.copyWith.measurement(isMeasuring: true);
  }
}

/// Weight samples frame, with timestamps in milliseconds.
List<int> _weights(List<(double, int)> samples) {
  final payload = ByteData(samples.length * 8);
  for (final (i, (weightKg, timestampMs)) in samples.indexed) {
    payload
      ..setFloat32(i * 8, weightKg, Endian.little)
      ..setUint32(i * 8 + 4, timestampMs * 1000, Endian.little);
  }
  return [1, payload.lengthInBytes, ...payload.buffer.asUint8List()];
}

void main() {
  final ble = FakeBle();
  setUpAll(() => FlutterBluePlusPlatform.instance = ble);
  setUp(() {
    ble.writes.clear();
    ble.unanswered.clear();
  });

  Future<ProviderContainer> connect(
    WidgetTester tester, [
    ProviderContainer? container,
  ]) async {
    container ??= ProviderContainer()..listen(progressorProvider, (_, _) {});
    unawaited(container.read(progressorProvider.notifier).connect(ble.device));
    await tester.pump(const Duration(milliseconds: 1));
    expect(container.read(progressorProvider).connection.isConnected, isTrue);
    return container;
  }

  /// Disposes before the test ends, which fails on pending timers.
  Future<void> dispose(WidgetTester tester, ProviderContainer container) async {
    container.dispose();
    // Let the request timeouts expire.
    await tester.pump(const Duration(seconds: 3));
  }

  testWidgets('keeps the low battery warning after the device turns off', (
    tester,
  ) async {
    final container = await connect(tester);
    ble.notify([4, 0]);
    await tester.pump(const Duration(milliseconds: 500));
    ble.setConnected(false);
    await tester.pump();

    final state = container.read(progressorProvider);
    expect(state.connection.isConnected, isFalse);
    expect(state.deviceInfo.lowBattery, isTrue);

    await connect(tester, container);
    expect(container.read(progressorProvider).deviceInfo.lowBattery, isFalse);
    await dispose(tester, container);
  });

  testWidgets('ends the device info read when the connection drops', (
    tester,
  ) async {
    ble.unanswered.add(ControlOpCode.getAppVersion);
    final container = await connect(tester);
    await tester.pump(const Duration(milliseconds: 500));
    ble.setConnected(false);
    await tester.pump();
    ble.unanswered.clear();
    ble.writes.clear();

    await connect(tester, container);
    // The first read timed out after 2 s.
    await tester.pump(const Duration(seconds: 59));
    expect(ble.writeCount(ControlOpCode.sampleBattery), 1);
    expect(ble.writeCount(ControlOpCode.getCalibration), 1);
    final deviceInfo = container.read(progressorProvider).deviceInfo;
    expect(deviceInfo.firmwareVersion, '2.1.0');
    expect(deviceInfo.batteryMillivolts, 3900);
    expect(deviceInfo.batteryPercent, 80);

    await tester.pump(const Duration(minutes: 3));
    expect(ble.writeCount(ControlOpCode.sampleBattery), 4);
    await dispose(tester, container);
  });

  // The second previous measurement passed half the u32 range, where the jump
  // back after the start looks like a wrap.
  for (final staleMs in [5000, 2400000]) {
    testWidgets(
      'keeps the previous measurement out of a new one ($staleMs ms)',
      (tester) async {
        final container = await connect(tester);
        final notifier = container.read(progressorProvider.notifier);
        ProgressorState state() => container.read(progressorProvider);

        ble.notify(_weights([(150, staleMs - 10)]));
        await tester.pump();
        expect(state().measurement.receivedData, isEmpty);

        unawaited(notifier.startMeasurement());
        await tester.pump();
        // Sent before the device restarted its clock.
        ble.notify(
          _weights([
            for (var ms = staleMs; ms < staleMs + 100; ms += 10) (150, ms),
          ]),
        );
        // 0 kg for a second, then a 100 kg/s ramp.
        for (var ms = 0; ms <= 2000; ms += 100) {
          ble.notify(
            _weights([
              for (var t = ms; t < ms + 100 && t <= 2000; t += 10)
                (t < 1000 ? 0 : (t - 1000) / 10, t),
            ]),
          );
        }
        await tester.pump();
        unawaited(notifier.stopMeasurement());
        await tester.pump();

        final measurement = state().measurement;
        expect(measurement.peakKg, 100);
        expect(measurement.minKg, 0);
        expect(measurement.peakRfdKgPerS, closeTo(100, 1e-3));
        expect([
          for (final spot in measurement.weightHistory) spot.x,
        ], everyElement(lessThanOrEqualTo(2)));
        expect([
          for (final sample in measurement.receivedData) sample.timestampUs,
        ], everyElement(lessThanOrEqualTo(2000000)));
        await dispose(tester, container);
      },
    );
  }

  testWidgets('deletes a calibration point by its reported values', (
    tester,
  ) async {
    final container = await connect(tester);
    final notifier = container.read(progressorProvider.notifier);

    expect(
      await notifier.deleteCalibrationPoint((raw: 12000.5, weightKg: 20)),
      isTrue,
    );
    expect(ble.writes.last, [
      ControlOpCode.deleteCalibrationPoint.value,
      ...encodeFloat32(12000.5),
      ...encodeFloat32(20),
    ]);
    await dispose(tester, container);
  });

  test('locks the calibration before awaiting the start', () async {
    final notifier = _SlowStartProgressor();
    final container = ProviderContainer(
      overrides: [progressorProvider.overrideWith(() => notifier)],
    );
    addTearDown(container.dispose);
    container.read(progressorProvider);

    final first = notifier.addCalibrationPoint(10);
    expect(
      container.read(progressorProvider).calibration.waitingForSteadyLoad,
      isTrue,
    );
    await expectLater(notifier.addCalibrationPoint(10), throwsStateError);

    notifier.startWrite.complete(false);
    expect(await first, CalibrationPointResult.sendFailed);
    expect(
      container.read(progressorProvider).calibration.waitingForSteadyLoad,
      isFalse,
    );
  });
}

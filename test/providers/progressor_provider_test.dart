import 'dart:async';
import 'dart:typed_data';

import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // The connection stores the device to reconnect to.
    SharedPreferences.setMockInitialValues({});
    ble.scans = 0;
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

  group('reconnects to the last device', () {
    tearDown(() {
      ble.advertising = false;
      ble.failConnect = false;
    });

    /// A new start of the app, with Bluetooth on.
    Future<ProviderContainer> start(WidgetTester tester) async {
      final container = ProviderContainer()
        ..listen(progressorProvider, (_, _) {});
      await tester.pump(const Duration(milliseconds: 10));
      return container;
    }

    testWidgets('scans at the start and connects to it', (tester) async {
      ble.advertising = true;
      // Without a device yet, nothing to look for.
      final first = await start(tester);
      expect(ble.scans, 0);
      await dispose(tester, await connect(tester, first));

      final next = await start(tester);
      await tester.pump(const Duration(milliseconds: 10));
      expect(ble.scans, 1);
      expect(next.read(progressorProvider).connection.isConnected, isTrue);
      await dispose(tester, next);
    });

    testWidgets('lists it to choose once a reconnection fails', (tester) async {
      ble.advertising = true;
      final container = await connect(tester);
      // Dropped by the device, not the user: the next scan reconnects.
      ble.setConnected(false);
      await tester.pump();
      final notifier = container.read(progressorProvider.notifier);
      ble.failConnect = true;
      unawaited(notifier.startScanning());
      await tester.pump(const Duration(milliseconds: 10));
      final failed = container.read(progressorProvider).connection;
      expect(failed.isConnected, isFalse);
      expect(failed.status, startsWith('Connection failed'));

      ble.failConnect = false;
      unawaited(notifier.startScanning());
      await tester.pump(const Duration(milliseconds: 10));
      final connection = container.read(progressorProvider).connection;
      expect(connection.isConnected, isFalse);
      expect(connection.discoveredDevices.single.id, ble.device.id);
      await notifier.stopScanning();
      await tester.pump(const Duration(milliseconds: 10));
      await dispose(tester, container);
    });

    testWidgets('lists it to choose once disconnected by the user', (
      tester,
    ) async {
      ble.advertising = true;
      final container = await connect(tester);
      await container.read(progressorProvider.notifier).disconnect();
      unawaited(container.read(progressorProvider.notifier).startScanning());
      await tester.pump(const Duration(milliseconds: 10));
      final connection = container.read(progressorProvider).connection;
      expect(connection.isConnected, isFalse);
      expect(connection.discoveredDevices.single.id, ble.device.id);
      await container.read(progressorProvider.notifier).stopScanning();
      await tester.pump(const Duration(milliseconds: 10));
      await dispose(tester, container);
    });
  });

  testWidgets('stops a scan and explains a scan that finds nothing', (
    tester,
  ) async {
    final container = ProviderContainer()
      ..listen(progressorProvider, (_, _) {});
    await tester.pump(const Duration(milliseconds: 10));
    final notifier = container.read(progressorProvider.notifier);
    String status() => container.read(progressorProvider).connection.status;

    unawaited(notifier.startScanning());
    await tester.pump(const Duration(milliseconds: 10));
    expect(container.read(progressorProvider).connection.isScanning, isTrue);
    await notifier.stopScanning();
    await tester.pump(const Duration(milliseconds: 10));
    expect(status(), 'Turn on the Crimpdeq, then scan for it.');

    unawaited(notifier.startScanning());
    await tester.pump(const Duration(seconds: 11));
    expect(status(), startsWith('No Crimpdeq found. Turn it on'));
    await dispose(tester, container);
  });

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

  testWidgets('reads only the fuel gauge status while measuring', (
    tester,
  ) async {
    final container = await connect(tester);
    await tester.pump(const Duration(seconds: 1));
    final notifier = container.read(progressorProvider.notifier);
    unawaited(notifier.startMeasurement());
    await tester.pump();
    ble.writes.clear();

    await tester.pump(const Duration(minutes: 1));
    expect(ble.writeCount(ControlOpCode.sampleBattery), 0);
    expect(ble.writeCount(ControlOpCode.getBatteryStatus), 1);
    expect(container.read(progressorProvider).deviceInfo.batteryPercent, 80);
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
    expect((await first).result, CalibrationPointResult.sendFailed);
    expect(
      container.read(progressorProvider).calibration.waitingForSteadyLoad,
      isFalse,
    );
  });

  testWidgets('reports the removal the device answers', (tester) async {
    final container = await connect(tester);
    final notifier = container.read(progressorProvider.notifier);
    bool removingPoint() =>
        container.read(progressorProvider).calibration.removingPoint;

    final removed = notifier.removeCalibrationPoint(1);
    expect(removingPoint(), isTrue);
    await expectLater(notifier.removeCalibrationPoint(0), throwsStateError);
    await tester.pump();
    expect(
      ble.writes,
      contains(equals([ControlOpCode.removeCalibrationPoint.value, 1])),
    );
    // A factor answers other commands too, so it does not end the removal.
    ble.notify([5, 4, ...encodeFloat32(0.08)]);
    await tester.pump();
    expect(removingPoint(), isTrue);
    ble.notify([9, 1, 1]);
    await tester.pump();
    expect(await removed, CalibrationPointRemoval.removed);
    expect(removingPoint(), isFalse);

    final rejected = notifier.removeCalibrationPoint(0);
    await tester.pump();
    ble.notify([9, 1, 0]);
    await tester.pump();
    expect(await rejected, CalibrationPointRemoval.rejected);

    // Firmware without the command does not answer.
    final unsupported = notifier.removeCalibrationPoint(0);
    await tester.pump(const Duration(seconds: 6));
    expect(await unsupported, CalibrationPointRemoval.unsupported);
    expect(removingPoint(), isFalse);

    // A late answer cannot be taken for a later removal on this connection.
    final sent = ble.writeCount(ControlOpCode.removeCalibrationPoint);
    ble.notify([9, 1, 1]);
    await tester.pump();
    expect(
      await notifier.removeCalibrationPoint(0),
      CalibrationPointRemoval.unsupported,
    );
    expect(ble.writeCount(ControlOpCode.removeCalibrationPoint), sent);
    await dispose(tester, container);
  });

  testWidgets('reports a removal whose write outlives the connection', (
    tester,
  ) async {
    final container = await connect(tester);
    final notifier = container.read(progressorProvider.notifier);
    await tester.pump(const Duration(milliseconds: 100));

    final write = Completer<void>();
    ble.writeDelay = write.future;
    CalibrationPointRemoval? result;
    unawaited(notifier.removeCalibrationPoint(0).then((r) => result = r));
    await tester.pump();
    ble.setConnected(false);
    await tester.pump();
    ble.writeDelay = null;
    write.complete();
    await tester.pump();
    expect(result, CalibrationPointRemoval.disconnected);
    await dispose(tester, container);
  });

  testWidgets('ends a pending removal when the connection drops', (
    tester,
  ) async {
    final container = await connect(tester);
    final notifier = container.read(progressorProvider.notifier);

    CalibrationPointRemoval? result;
    unawaited(notifier.removeCalibrationPoint(0).then((r) => result = r));
    await tester.pump();
    ble.setConnected(false);
    await tester.pump();
    expect(result, CalibrationPointRemoval.disconnected);

    // The ended removal does not unlock one started on the next connection.
    await connect(tester, container);
    unawaited(notifier.removeCalibrationPoint(0));
    await tester.pump(const Duration(seconds: 4));
    expect(
      container.read(progressorProvider).calibration.removingPoint,
      isTrue,
    );
    await dispose(tester, container);
  });
}

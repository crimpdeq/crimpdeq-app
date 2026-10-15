import 'dart:async';

import 'package:crimpdeq/models/progressor_models.dart';
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

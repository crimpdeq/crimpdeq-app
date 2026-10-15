import 'dart:async';

import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

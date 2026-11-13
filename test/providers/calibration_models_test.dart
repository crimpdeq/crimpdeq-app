import 'dart:async';
import 'dart:typed_data';

import 'package:crimpdeq/analysis/calibration_curve.dart';
import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/calibration_details.dart';
import '../support/fake_ble.dart';

const _points = [
  (raw: 0.0, weightKg: 0.0, fittedKg: 0.0),
  (raw: 230000.0, weightKg: 25.0, fittedKg: 25.1),
  (raw: 460000.0, weightKg: 50.0, fittedKg: 49.9),
  (raw: 690000.0, weightKg: 75.0, fittedKg: 75.0),
];

List<int> _uint32(int value) =>
    (ByteData(4)..setUint32(0, value, Endian.little)).buffer.asUint8List();

void main() {
  final ble = FakeBle();
  setUpAll(() => FlutterBluePlusPlatform.instance = ble);
  setUp(() {
    ble.writes.clear();
    ble.unanswered.clear();
    ble.calibrationDetails = null;
  });

  Future<ProviderContainer> connect(
    WidgetTester tester, [
    ProviderContainer? container,
  ]) async {
    container ??= ProviderContainer()..listen(progressorProvider, (_, _) {});
    unawaited(container.read(progressorProvider.notifier).connect(ble.device));
    await tester.pump(const Duration(milliseconds: 1));
    expect(container.read(progressorProvider).connection.isConnected, isTrue);
    // The device info and calibration reads.
    await tester.pump(const Duration(milliseconds: 100));
    return container;
  }

  Future<void> dispose(WidgetTester tester, ProviderContainer container) async {
    container.dispose();
    await tester.pump(const Duration(seconds: 6));
  }

  CalibrationState calibration(ProviderContainer container) =>
      container.read(progressorProvider).calibration;

  testWidgets('reads the calibration details from firmware with models', (
    tester,
  ) async {
    ble.calibrationDetails = (_) => calibrationDetailFrames(
      model: CalibrationModel.piecewise,
      coefficients: [0, 90, 100, 0.5],
      scale: 920000,
      xMax: 0.75,
      loadMaxKg: 75,
      tareLoadKg: 2,
      points: _points,
    );
    final container = await connect(tester);

    final state = calibration(container);
    expect(state.supportsModels, isTrue);
    expect(state.details!.model, CalibrationModel.piecewise);
    expect(
      state.details!.info.supportedModels,
      CalibrationModel.values.toSet(),
    );
    expect(state.details!.loadRangeKg, (min: 0.0, max: 75.0));
    expect(state.details!.fit.rmsKg, closeTo(0.05, 1e-6));
    expect([for (final point in state.points) point.weightKg], [0, 25, 50, 75]);
    expect(state.details!.points[1].fittedKg, closeTo(25.1, 1e-5));
    // No single factor describes a nonlinear calibration.
    expect(state.factor, isNull);
    // The details replace the linear-only read.
    expect(ble.writeCount(ControlOpCode.getCalibrationDetails), 1);
    expect(ble.writeCount(ControlOpCode.getCalibration), 0);

    // Linear-only messages, which the firmware also sends, do not override
    // the details.
    ble.notify([5, 4, ...encodeFloat32(double.nan)]);
    ble.notify([6, 8, ...encodeFloat32(1), ...encodeFloat32(2)]);
    await tester.pump();
    expect(calibration(container).points, hasLength(4));
    await dispose(tester, container);
  });

  testWidgets('falls back to the linear calibration of older firmware', (
    tester,
  ) async {
    final container = await connect(tester);
    await tester.pump(const Duration(seconds: 6));

    final state = calibration(container);
    expect(state.supportsModels, isFalse);
    expect(state.details, isNull);
    expect(state.factor, closeTo(0.08, 1e-6));
    expect(ble.writeCount(ControlOpCode.getCalibration), 1);

    // Later reads skip the unanswered request.
    ble.writes.clear();
    await container.read(progressorProvider.notifier).getCalibration();
    expect(ble.writeCount(ControlOpCode.getCalibrationDetails), 0);
    expect(ble.writeCount(ControlOpCode.getCalibration), 1);
    await dispose(tester, container);
  });

  testWidgets('presents a model only once the device confirms it', (
    tester,
  ) async {
    var model = CalibrationModel.linear;
    CalibrationCommandResult? last;
    ble.calibrationDetails = (write) {
      if (write.first == ControlOpCode.setCalibrationModel.value) {
        final requested = CalibrationModel.fromCode(write[1])!;
        // The device fits the quadratic model, but has too few points for the
        // piecewise one.
        final fits = requested != CalibrationModel.piecewise;
        if (fits) model = requested;
        last = (
          opCode: write.first,
          disposition: fits
              ? CalibrationDisposition.applied
              : CalibrationDisposition.rejected,
          error: fits ? null : CalibrationError.notEnoughPoints,
        );
      }
      return calibrationDetailFrames(
        model: model,
        lastCommand: last,
        points: _points,
      );
    };
    final container = await connect(tester);
    final notifier = container.read(progressorProvider.notifier);

    final write = Completer<void>();
    ble.writeDelay = write.future;
    final selected = notifier.selectCalibrationModel(
      CalibrationModel.quadratic,
    );
    await tester.pump();
    expect(calibration(container).changingModel, isTrue);
    expect(calibration(container).details!.model, CalibrationModel.linear);
    await expectLater(
      notifier.selectCalibrationModel(CalibrationModel.piecewise),
      throwsStateError,
    );
    ble.writeDelay = null;
    write.complete();
    await tester.pump();

    expect((await selected)!.disposition, CalibrationDisposition.applied);
    expect(calibration(container).details!.model, CalibrationModel.quadratic);
    expect(calibration(container).changingModel, isFalse);

    // A change mid-measurement would mix two curves in one window.
    await notifier.startMeasurement();
    await expectLater(
      () => notifier.selectCalibrationModel(CalibrationModel.linear),
      throwsStateError,
    );
    await notifier.stopMeasurement();

    final rejected = await notifier.selectCalibrationModel(
      CalibrationModel.piecewise,
    );
    expect(rejected!.disposition, CalibrationDisposition.rejected);
    expect(rejected.error, CalibrationError.notEnoughPoints);
    expect(calibration(container).details!.model, CalibrationModel.quadratic);
    expect(
      ble.writes.where(
        (write) => write.first == ControlOpCode.setCalibrationModel.value,
      ),
      [
        [
          ControlOpCode.setCalibrationModel.value,
          CalibrationModel.quadratic.code,
        ],
        [
          ControlOpCode.setCalibrationModel.value,
          CalibrationModel.piecewise.code,
        ],
      ],
    );
    await dispose(tester, container);
  });

  testWidgets('reports no model when the device does not answer', (
    tester,
  ) async {
    ble.calibrationDetails = (_) => calibrationDetailFrames(points: _points);
    final container = await connect(tester);
    ble.unanswered.add(ControlOpCode.setCalibrationModel);

    final result = container
        .read(progressorProvider.notifier)
        .selectCalibrationModel(CalibrationModel.quadratic);
    await tester.pump(const Duration(seconds: 6));
    expect(await result, isNull);
    expect(calibration(container).details!.model, CalibrationModel.linear);
    expect(calibration(container).changingModel, isFalse);
    await dispose(tester, container);
  });

  testWidgets('reads the device state again after reconnecting', (
    tester,
  ) async {
    var model = CalibrationModel.quadratic;
    ble.calibrationDetails = (_) =>
        calibrationDetailFrames(model: model, points: _points);
    final container = await connect(tester);
    expect(calibration(container).details!.model, CalibrationModel.quadratic);

    ble.setConnected(false);
    await tester.pump();
    expect(calibration(container).details, isNull);
    expect(calibration(container).supportsModels, isNull);

    // The device rebooted with a calibration reset to the default.
    model = CalibrationModel.linear;
    ble.calibrationDetails = (_) =>
        calibrationDetailFrames(hasFit: false, coefficients: [0.109, 0, 0, 0]);
    await connect(tester, container);
    final state = calibration(container);
    expect(state.details!.model, CalibrationModel.linear);
    expect(state.details!.curve, isNull);
    expect(state.details!.loadRangeKg, isNull);
    expect(state.factor, closeTo(0.109, 1e-6));
    expect(state.points, isEmpty);
    await dispose(tester, container);
  });

  testWidgets('holds removals until the device reports the new points', (
    tester,
  ) async {
    ble.calibrationDetails = (_) => calibrationDetailFrames(
      model: CalibrationModel.quadratic,
      points: _points,
    );
    final container = await connect(tester);
    final notifier = container.read(progressorProvider.notifier);

    // The details after the removal do not arrive.
    ble.unanswered.add(ControlOpCode.getCalibrationDetails);
    CalibrationPointRemoval? result;
    unawaited(notifier.removeCalibrationPoint(1).then((r) => result = r));
    await tester.pump();
    ble.notify([9, 1, 1]);
    await tester.pump();
    expect(result, isNull);
    expect(calibration(container).removingPoint, isTrue);
    await expectLater(notifier.removeCalibrationPoint(1), throwsStateError);

    await tester.pump(const Duration(seconds: 6));
    expect(result, CalibrationPointRemoval.removed);
    expect(calibration(container).removingPoint, isFalse);
    // The stale points, whose indexes shifted on the device, are gone.
    expect(calibration(container).points, isEmpty);
    expect(calibration(container).details, isNull);

    // A read restores them.
    ble.unanswered.clear();
    await notifier.getCalibration();
    expect(calibration(container).points, hasLength(4));
    await dispose(tester, container);
  });

  testWidgets('forgets the load at the tare until the device reports it', (
    tester,
  ) async {
    var tareLoadKg = 0.0;
    ble.calibrationDetails = (_) => calibrationDetailFrames(
      loadMaxKg: 100,
      tareLoadKg: tareLoadKg,
      points: _points,
    );
    final container = await connect(tester);
    final notifier = container.read(progressorProvider.notifier);
    CalibrationDetails details() => calibration(container).details!;
    expect(details().isOutsideRange(90), isFalse);

    // Tared under a 20 kg attachment, but the details are lost.
    ble.unanswered.add(ControlOpCode.getCalibrationDetails);
    unawaited(notifier.tareScale());
    await tester.pump();
    expect(details().tare.tareLoadKg, isNull);
    expect(details().isOutsideRange(90), isNull);
    await tester.pump(const Duration(seconds: 6));
    expect(details().isOutsideRange(90), isNull);

    // The next read restores it: 90 kg on top of 20 kg is past 100 kg.
    ble.unanswered.clear();
    tareLoadKg = 20;
    await notifier.getCalibration();
    expect(details().isOutsideRange(90), isTrue);
    await dispose(tester, container);
  });

  testWidgets('ignores details with a lost notification', (tester) async {
    ble.calibrationDetails = (_) => calibrationDetailFrames(
      model: CalibrationModel.quadratic,
      points: _points,
    );
    final container = await connect(tester);
    final before = calibration(container).details;

    ble.calibrationDetails = (_) => [
      ...calibrationDetailFrames(
        model: CalibrationModel.piecewise,
        points: _points,
      ),
    ]..removeAt(6);
    await container.read(progressorProvider.notifier).getCalibration();
    expect(calibration(container).details, same(before));
    expect(calibration(container).supportsModels, isTrue);
    await dispose(tester, container);
  });

  testWidgets('reports the outcome of a point and of a zero update', (
    tester,
  ) async {
    CalibrationCommandResult? last;
    ble.calibrationDetails = (write) {
      if (write.first == ControlOpCode.setZero.value) {
        last = (
          opCode: write.first,
          disposition: CalibrationDisposition.rejected,
          error: CalibrationError.zeroOutOfRange,
        );
      }
      return calibrationDetailFrames(
        model: CalibrationModel.quadratic,
        lastCommand: last,
        points: _points,
      );
    };
    final container = await connect(tester);
    final notifier = container.read(progressorProvider.notifier);

    final zero = await notifier.setZero();
    expect(zero!.disposition, CalibrationDisposition.rejected);
    expect(zero.error, CalibrationError.zeroOutOfRange);
    expect(ble.writeCount(ControlOpCode.setZero), 1);

    // A point the device stores but cannot fit yet.
    last = (
      opCode: ControlOpCode.addCalibrationPoint.value,
      disposition: CalibrationDisposition.pending,
      error: CalibrationError.noMidRangeLevel,
    );
    final added = notifier.addCalibrationPoint(90);
    await tester.pump();
    for (var ms = 0; ms <= 1200; ms += 50) {
      ble.notify([1, 8, ...encodeFloat32(90), ..._uint32(ms * 1000)]);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 100));
    expect(await added, (
      result: CalibrationPointResult.pending,
      error: CalibrationError.noMidRangeLevel,
    ));
    expect(ble.writeCount(ControlOpCode.getCalibration), 0);
    await dispose(tester, container);
  });
}

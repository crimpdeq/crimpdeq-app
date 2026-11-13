import 'package:crimpdeq/analysis/calibration_curve.dart';
import 'package:crimpdeq/analysis/opengrips_curve.dart';
import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/models/training_models.dart';
import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:crimpdeq/providers/training_provider.dart';
import 'package:crimpdeq/screens/crimpdeq_screen.dart';
import 'package:crimpdeq/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/calibration_details.dart';

/// Serves a fixed state and records the commands instead of using Bluetooth.
class _FakeProgressor extends ProgressorNotifier {
  _FakeProgressor(this.initialState);

  final ProgressorState initialState;
  final calls = <String>[];

  @override
  ProgressorState build() => initialState;

  @override
  Future<CalibrationPointRemoval> removeCalibrationPoint(int index) async {
    calls.add('remove $index');
    return CalibrationPointRemoval.removed;
  }

  @override
  void resetMeasurement() => calls.add('reset');

  @override
  Future<void> tareScale() async => calls.add('tare');

  @override
  Future<void> defaultCalibration() async => calls.add('defaultCalibration');

  @override
  Future<CalibrationCommandResult?> selectCalibrationModel(
    CalibrationModel model,
  ) async {
    calls.add('select ${model.name}');
    return (
      opCode: ControlOpCode.setCalibrationModel.value,
      disposition: CalibrationDisposition.rejected,
      error: CalibrationError.notEnoughLoadLevels,
    );
  }

  @override
  Future<CalibrationCommandResult?> setZero() async {
    calls.add('zero');
    return null;
  }

  @override
  Future<void> disconnect() async => calls.add('disconnect');
}

/// A finished benchmark pull.
class _Recorded extends BenchmarkRecorder {
  _Recorded(this.bestKg);

  final double bestKg;

  @override
  BenchmarkRecording build() =>
      (recording: false, elapsedSeconds: 6, bestKg: bestKg);
}

const _deviceId = '00:11:22:33:44:55';

final _connected = DeviceConnection(
  device: BluetoothDevice.fromId(_deviceId),
  deviceName: 'Progressor_1A2B',
  writeCharacteristic: BluetoothCharacteristic(
    remoteId: const DeviceIdentifier(_deviceId),
    serviceUuid: Guid(progressorServiceUuid),
    characteristicUuid: Guid(progressorWriteCharUuid),
  ),
  bluetoothReady: true,
  status: 'Connected to Progressor',
);

/// Opens [part] of the app once connected.
Future<_FakeProgressor> _pumpScreen(
  WidgetTester tester,
  ProgressorState state, {
  String part = 'Debugging',
  List<Override> overrides = const [],
}) async {
  final fake = _FakeProgressor(state);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [progressorProvider.overrideWith(() => fake), ...overrides],
      child: MaterialApp(theme: buildDarkTheme(), home: const CrimpdeqScreen()),
    ),
  );
  // A pump, since a pending calibration point animates without settling.
  await tester.tap(find.widgetWithText(NavigationDestination, part));
  await tester.pump();
  return fake;
}

/// Details as the provider assembles them from the firmware notifications.
CalibrationDetails _details({
  CalibrationModel model = CalibrationModel.quadratic,
  CalibrationError? pending,
  List<({double raw, double weightKg, double fittedKg})> points = const [
    (raw: 0, weightKg: 0, fittedKg: 0),
    (raw: 250000, weightKg: 25, fittedKg: 25.1),
    (raw: 500000, weightKg: 50, fittedKg: 49.9),
    (raw: 750000, weightKg: 75, fittedKg: 75),
  ],
}) {
  final reader = CalibrationDetailsReader();
  CalibrationDetails? details;
  for (final frame in calibrationDetailFrames(
    model: model,
    coefficients: model == CalibrationModel.linear
        ? const [0.1, 0, 0, 0]
        : const [1, 99, 0, 0],
    scale: 750000,
    loadMaxKg: 75,
    rmsKg: 0.0707,
    maxAbsKg: 0.1,
    pending: pending,
    points: points,
  )) {
    details = reader.add(
      decodeMessage(parseFrame(frame)!) as CalibrationDetail,
    );
  }
  return details!;
}

CalibrationState _calibrationWith(CalibrationDetails details) =>
    CalibrationState(
      supportsModels: true,
      details: details,
      factor: details.linearFactor,
      points: [
        for (final point in details.points)
          (raw: point.raw, weightKg: point.weightKg),
      ],
    );

const _benchmark =
    '{"date":"2026-10-26T10:00:00.000","tool":"Photon","hand":"right",'
    '"forceKg":30}';

void main() {
  // Measure the app bar with the bundled font instead of the test font.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final inter = FontLoader(interFont);
    for (final weight in ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
      inter.addFont(rootBundle.load('assets/fonts/Inter-$weight.ttf'));
    }
    await inter.load();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the device and opens its details', (tester) async {
    final fake = await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        deviceInfo: const DeviceInfo(
          firmwareVersion: '1.2.3',
          batteryMillivolts: 3840,
          sampleRate: 80,
        ),
      ),
    );

    expect(find.text('Progressor_1A2B'), findsOneWidget);
    expect(find.text('~50% · 3.84 V'), findsOneWidget);
    expect(find.byIcon(Icons.battery_3_bar), findsOneWidget);
    expect(find.text('1.2.3'), findsNothing);
    expect(find.byType(TabBar), findsOneWidget);

    await tester.tap(find.text('Progressor_1A2B'));
    await tester.pumpAndSettle();
    expect(find.text(_deviceId), findsOneWidget);
    expect(find.text('1.2.3'), findsOneWidget);
    expect(find.text('~50%'), findsOneWidget);
    expect(find.text('3.84 V'), findsOneWidget);
    expect(find.text('80 Hz'), findsOneWidget);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Disconnect'));
    expect(fake.calls, ['disconnect']);
  });

  testWidgets('prefers the fuel gauge charge over the voltage estimate', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        deviceInfo: const DeviceInfo(
          batteryMillivolts: 3840,
          batteryPercent: 21,
          batteryCharging: true,
        ),
      ),
    );

    expect(find.text('21% · 3.84 V'), findsOneWidget);
    expect(find.byIcon(Icons.battery_charging_full), findsOneWidget);
    await tester.tap(find.text('Progressor_1A2B'));
    await tester.pumpAndSettle();
    expect(find.text('21%, charging'), findsOneWidget);
  });

  testWidgets('wraps a UUID device ID in the details on a phone', (
    tester,
  ) async {
    // iOS, macOS and Web identify devices by UUID instead of MAC address.
    const uuid = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected.copyWith(device: BluetoothDevice.fromId(uuid)),
      ),
    );

    await tester.tap(find.text('Progressor_1A2B'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text(uuid)).right, lessThanOrEqualTo(360));
  });

  testWidgets('shows the connection state without a device', (tester) async {
    await _pumpScreen(
      tester,
      const ProgressorState(
        connection: DeviceConnection(bluetoothReady: true, isScanning: true),
      ),
    );

    expect(find.text('Scanning…'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    expect(find.byTooltip('Disconnect'), findsNothing);
  });

  for (final (name, physicalSize, pixelRatio) in [
    ('394 dp phone', const Size(1280, 2772), 3.25),
    ('360 dp phone', const Size(1080, 2340), 3.0),
  ]) {
    testWidgets(
      'fits the status between the logo and the disconnect button on a '
      '$name',
      (tester) async {
        tester.view.physicalSize = physicalSize;
        tester.view.devicePixelRatio = pixelRatio;
        addTearDown(tester.view.reset);
        await _pumpScreen(
          tester,
          ProgressorState(
            connection: _connected,
            deviceInfo: const DeviceInfo(
              firmwareVersion: '2.0.4',
              batteryMillivolts: 3750,
            ),
          ),
        );

        final logo = tester.getRect(find.byType(Image));
        final disconnectButton = tester.getRect(find.byTooltip('Disconnect'));
        for (final text in ['Progressor_1A2B', '~25%']) {
          final rect = tester.getRect(find.text(text));
          expect(rect.left, greaterThanOrEqualTo(logo.right), reason: text);
          expect(
            rect.right,
            lessThanOrEqualTo(disconnectButton.left),
            reason: text,
          );
          expect(
            tester
                .renderObject<RenderParagraph>(find.text(text))
                .didExceedMaxLines,
            isFalse,
            reason: '$text is truncated',
          );
        }
      },
    );
  }

  testWidgets('warns when the battery runs out', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        deviceInfo: const DeviceInfo(lowBattery: true),
      ),
    );

    expect(find.textContaining('Battery empty'), findsOneWidget);
  });

  testWidgets('offers the app settings when scanning needs them', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      const ProgressorState(
        connection: DeviceConnection(
          bluetoothReady: true,
          needsSettings: true,
          status: 'Scan failed: permission denied',
        ),
      ),
    );

    expect(find.text('Open App Settings'), findsOneWidget);
    expect(find.text('Scan failed: permission denied'), findsOneWidget);
    expect(find.byType(TabBar), findsNothing);
  });

  testWidgets('shows the force summary and resets the window', (tester) async {
    final fake = await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        measurement: const MeasurementState(
          isMeasuring: true,
          currentKg: 12.345,
          minKg: -0.5,
          peakKg: 30.1,
          peakRfdKgPerS: 152.34,
          elapsedUs: 4200000,
          receivedData: [WeightMeasurement(weightKg: 12.345, timestampUs: 1)],
        ),
      ),
    );
    await tester.tap(find.text('Measurements'));
    await tester.pumpAndSettle();

    expect(find.text('12.35 kg'), findsOneWidget);
    expect(find.text('-0.50 kg'), findsOneWidget);
    expect(find.text('30.10 kg'), findsOneWidget);
    expect(find.text('152.3 kg/s'), findsOneWidget);
    expect(find.textContaining('Elapsed: 4.2 s'), findsOneWidget);

    await tester.tap(find.text('Tare'));
    await tester.tap(find.text('Reset'));
    expect(fake.calls, ['tare', 'reset']);
  });

  for (final isMeasuring in [false, true]) {
    testWidgets('${isMeasuring ? 'locks' : 'offers'} the sample rate '
        '${isMeasuring ? 'while' : 'when not'} measuring', (tester) async {
      await _pumpScreen(
        tester,
        ProgressorState(
          connection: _connected,
          deviceInfo: const DeviceInfo(sampleRate: 175),
          measurement: MeasurementState(isMeasuring: isMeasuring),
        ),
      );
      await tester.tap(find.text('Measurements'));
      await tester.pumpAndSettle();

      final selector = tester.widget<DropdownButton<int>>(
        find.byType(DropdownButton<int>),
      );
      expect(selector.onChanged == null, isMeasuring);
    });
  }

  testWidgets('shows dashes before any sample arrives', (tester) async {
    await _pumpScreen(tester, ProgressorState(connection: _connected));
    await tester.tap(find.text('Measurements'));
    await tester.pumpAndSettle();

    expect(find.text('—'), findsNWidgets(4));
  });

  testWidgets('checks the calibration against the device line', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: const CalibrationState(
          factor: 1,
          points: [
            (raw: 0, weightKg: 0),
            (raw: 10000, weightKg: 10.3),
            (raw: 20000, weightKg: 20),
          ],
        ),
      ),
    );

    expect(find.text('1.000000 g/count'), findsOneWidget);
    expect(
      find.textContaining('Calibration-fit residuals: max 0.300 kg (1.50%'),
      findsOneWidget,
    );
    expect(find.text('-0.300'), findsOneWidget);
  });

  testWidgets('shows the calibration-fit residuals the device reports', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: _calibrationWith(_details()),
      ),
    );

    expect(
      tester
          .widget<SegmentedButton<CalibrationModel>>(
            find.byType(SegmentedButton<CalibrationModel>),
          )
          .selected,
      {CalibrationModel.quadratic},
    );
    expect(find.text('0.00 – 75.00 kg'), findsOneWidget);
    // A nonlinear curve has no single factor.
    expect(find.text('Factor'), findsNothing);
    expect(
      find.text(
        'Calibration-fit residuals: max 0.100 kg (0.13%) · RMS 0.071 kg',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('not the accuracy at other loads'),
      findsOneWidget,
    );
    // Fitted loads and residuals of the device, not of a factor.
    expect(find.text('25.100'), findsOneWidget);
    expect(find.text('0.100'), findsOneWidget);
    expect(find.text('-0.100'), findsOneWidget);
  });

  testWidgets('asks the device for a model and reports its answer', (
    tester,
  ) async {
    final fake = await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: _calibrationWith(_details(model: CalibrationModel.linear)),
      ),
    );

    final segments = find.byType(SegmentedButton<CalibrationModel>);
    expect(
      tester.widget<SegmentedButton<CalibrationModel>>(segments).selected,
      {CalibrationModel.linear},
    );
    for (final label in ['Linear', 'Quadratic', 'Piecewise']) {
      expect(
        find.descendant(of: segments, matching: find.text(label)),
        findsOneWidget,
      );
    }
    expect(find.text('0.100000 g/count'), findsOneWidget);
    // The descriptions are one tap away, not on the card.
    expect(find.textContaining('Needs 6 different loads'), findsNothing);
    await tester.tap(find.byTooltip('About the calibration models'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Needs 6 different loads'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    // A linear reading is the same with any zero.
    expect(find.text('Set Unloaded Zero'), findsNothing);

    await tester.tap(find.text('Piecewise'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['select piecewise']);
    // The device keeps the linear model, and the selector shows it.
    expect(
      find.text(
        'Could not use Piecewise linear. ${CalibrationError.notEnoughLoadLevels.message} '
        'The device keeps Linear.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<SegmentedButton<CalibrationModel>>(segments).selected,
      {CalibrationModel.linear},
    );
  });

  testWidgets('sets the unloaded zero only after confirmation', (tester) async {
    final fake = await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: _calibrationWith(_details()),
      ),
    );
    final zero = find.widgetWithText(OutlinedButton, 'Set Unloaded Zero');
    await tester.ensureVisible(zero);

    await tester.tap(zero);
    await tester.pumpAndSettle();
    expect(find.text('Set unloaded zero?'), findsOneWidget);
    expect(find.textContaining('use Tare instead'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(fake.calls, isEmpty);

    await tester.tap(zero);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Set Zero'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['zero']);
    expect(
      find.text('The device did not answer, so the zero may not be set.'),
      findsOneWidget,
    );
  });

  testWidgets('fits the calibration model card on a 360 dp phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: _calibrationWith(
          _details(
            model: CalibrationModel.piecewise,
            pending: CalibrationError.insufficientSegmentSupport,
          ),
        ),
      ),
    );

    // Rendering would fail on an overflow.
    final selector = find.byType(SegmentedButton<CalibrationModel>);
    expect(tester.getRect(selector).right, lessThanOrEqualTo(360));
  });

  testWidgets('keeps the model and zero while measuring', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: _calibrationWith(_details()),
        measurement: const MeasurementState(isMeasuring: true),
      ),
    );

    final selector = tester.widget<SegmentedButton<CalibrationModel>>(
      find.byType(SegmentedButton<CalibrationModel>),
    );
    expect(selector.onSelectionChanged, isNull);
    expect(
      find.text('Stop the measurement to change the model or the zero.'),
      findsOneWidget,
    );
    final zero = find.widgetWithText(OutlinedButton, 'Set Unloaded Zero');
    await tester.ensureVisible(zero);
    expect(tester.widget<OutlinedButton>(zero).onPressed, isNull);
  });

  testWidgets('offers only the linear model on older firmware', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: const CalibrationState(supportsModels: false, factor: 0.1),
      ),
    );

    expect(
      find.textContaining('This firmware has only the linear model'),
      findsOneWidget,
    );
    final selector = tester.widget<SegmentedButton<CalibrationModel>>(
      find.byType(SegmentedButton<CalibrationModel>),
    );
    expect(selector.onSelectionChanged, isNull);
    expect(
      [for (final segment in selector.segments) segment.enabled],
      [true, false, false],
    );
  });

  testWidgets('explains points that are not applied', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: _calibrationWith(
          _details(
            model: CalibrationModel.piecewise,
            pending: CalibrationError.notEnoughPoints,
          ),
        ),
      ),
    );

    expect(
      find.textContaining(
        'Points not applied yet. The model needs more points.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('previous Piecewise linear calibration'),
      findsOneWidget,
    );
    expect(
      find.textContaining('which was not fit from these points'),
      findsOneWidget,
    );
  });

  testWidgets('flags readings outside the calibrated range', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: _calibrationWith(_details()),
        measurement: const MeasurementState(
          isMeasuring: true,
          currentKg: 40,
          minKg: 0,
          peakKg: 80,
        ),
      ),
    );
    await tester.tap(find.text('Measurements'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Outside the calibrated range (0.0 to 75.0 kg): peak. The device '
        'extrapolated these readings.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('asks for a second calibration point', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: const CalibrationState(
          factor: 0.08,
          points: [(raw: 5000, weightKg: 10)],
        ),
      ),
    );

    expect(find.text('Add another point to calibrate.'), findsOneWidget);
    expect(find.text('Fitted (kg)'), findsNothing);
  });

  testWidgets('does not report an error for two weights', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: const CalibrationState(
          factor: 20000,
          points: [(raw: 1000, weightKg: 0), (raw: 1001, weightKg: 20)],
        ),
      ),
    );

    expect(
      find.textContaining('Add a point at a third weight'),
      findsOneWidget,
    );
    expect(find.textContaining('Calibration-fit residuals'), findsNothing);
    expect(find.text('Residual (kg)'), findsNothing);
  });

  testWidgets('stops adding points at the device limit', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: CalibrationState(
          factor: 1,
          points: [
            for (var i = 0; i < maxCalibrationPoints; i++)
              (raw: i * 1000.0, weightKg: i.toDouble()),
          ],
        ),
      ),
    );

    final addButton = find.widgetWithText(
      OutlinedButton,
      'Add Calibration Point',
    );
    await tester.ensureVisible(addButton);
    expect(tester.widget<OutlinedButton>(addButton).onPressed, isNull);
    expect(find.textContaining('The device holds 20 points'), findsOneWidget);
  });

  testWidgets('removes a calibration point only after confirmation', (
    tester,
  ) async {
    final fake = await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: const CalibrationState(
          factor: 20,
          points: [(raw: 0, weightKg: 0), (raw: 500, weightKg: 10)],
        ),
      ),
    );
    final removeButton = find.byTooltip('Remove point 2');
    await tester.ensureVisible(removeButton);

    await tester.tap(removeButton);
    await tester.pumpAndSettle();
    expect(find.text('Remove point 2 (10.000 kg)?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(fake.calls, isEmpty);

    await tester.tap(removeButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Remove'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['remove 1']);
    expect(find.text('Removed point 2 (10.000 kg).'), findsOneWidget);
  });

  testWidgets('blocks removing points while a point waits for a steady load', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: const CalibrationState(
          factor: 20,
          points: [(raw: 0, weightKg: 0)],
          waitingForSteadyLoad: true,
        ),
      ),
    );

    final removeButton = find.widgetWithIcon(IconButton, Icons.delete_outline);
    await tester.ensureVisible(removeButton);
    expect(tester.widget<IconButton>(removeButton).onPressed, isNull);
  });

  testWidgets('blocks the reset while a point waits for a steady load', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: const CalibrationState(waitingForSteadyLoad: true),
      ),
    );

    final resetButton = find.widgetWithText(
      OutlinedButton,
      'Reset Calibration To Default',
    );
    await tester.ensureVisible(resetButton);
    expect(tester.widget<OutlinedButton>(resetButton).onPressed, isNull);
  });

  testWidgets('resets the calibration only after confirmation', (tester) async {
    final fake = await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        calibration: const CalibrationState(factor: 1),
      ),
    );
    final resetButton = find.widgetWithText(
      OutlinedButton,
      'Reset Calibration To Default',
    );
    await tester.ensureVisible(resetButton);

    await tester.tap(resetButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(fake.calls, isEmpty);

    await tester.tap(resetButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Reset'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['defaultCalibration']);
  });
  testWidgets('asks for a benchmark before the first workout', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      part: 'Training',
    );

    expect(
      find.textContaining('Record a benchmark in the Benchmarks tab first'),
      findsOneWidget,
    );
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('No workout results found.'), findsOneWidget);
  });

  testWidgets('unlocks the workout with the latest benchmark', (tester) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      part: 'Training',
    );

    expect(find.text('Workout Type: Endurance'), findsOneWidget);
    expect(find.text('Endurance (0) · suggested'), findsOneWidget);
    expect(find.text('Force: 6.8 kg'), findsOneWidget);
    expect(find.text('First hang: 193 s'), findsOneWidget);
    expect(find.text('No Endurance sessions yet.'), findsOneWidget);

    await tester.ensureVisible(find.text('Power (0)'));
    await tester.tap(find.text('Power (0)'));
    await tester.pumpAndSettle();
    expect(find.text('Workout Type: Power'), findsOneWidget);
    expect(find.text('Force: 20.0 kg'), findsOneWidget);
    expect(find.text('Reps: 6'), findsOneWidget);
  });

  for (final (bestKg, saves) in [(0.0, false), (3.0, false), (3.1, true)]) {
    testWidgets('${saves ? 'saves' : 'rejects'} a $bestKg kg pull', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        ProgressorState(connection: _connected),
        part: 'Training',
        overrides: [
          benchmarkRecorderProvider.overrideWith(() => _Recorded(bestKg)),
        ],
      );
      await tester.tap(find.text('Benchmarks'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Photon').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<Hand>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Right').last);
      await tester.pumpAndSettle();

      final save = find.widgetWithText(OutlinedButton, 'Save Benchmark');
      expect(tester.widget<OutlinedButton>(save).onPressed != null, saves);
      expect(
        find.text('Pull more than 3.0 kg for at least 5 s.'),
        saves ? findsNothing : findsOne,
      );
    });
  }

  testWidgets('blocks a workout whose target cannot start a hang', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks':
          '[{"date":"2026-10-26T10:00:00.000","tool":"Photon",'
          '"hand":"right","forceKg":6}]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      part: 'Training',
    );
    await tester.pumpAndSettle();
    final start = find.widgetWithText(FilledButton, 'Start Workout');

    // The Endurance target of a 6 kg benchmark is 1.36 kg.
    expect(find.textContaining('target is too light'), findsOneWidget);
    expect(tester.widget<FilledButton>(start).onPressed, isNull);

    await tester.tap(find.text('Power (0)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('target is too light'), findsNothing);
    expect(tester.widget<FilledButton>(start).onPressed, isNotNull);
  });

  testWidgets('keeps the benchmark tool and hand across the parts', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      part: 'Training',
    );
    Future<void> openBenchmarks() async {
      await tester.tap(find.text('Benchmarks'));
      await tester.pumpAndSettle();
    }

    Future<void> select(Type dropdown, String option) async {
      await tester.tap(find.byType(dropdown).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(option).last);
      await tester.pumpAndSettle();
    }

    await openBenchmarks();
    await select(DropdownButton<String>, 'Spark');
    await select(DropdownButton<Hand>, 'Left');

    // A pull recorded here saves under them after a visit to Debugging.
    await tester.tap(find.widgetWithText(NavigationDestination, 'Debugging'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Training'));
    await tester.pumpAndSettle();
    await openBenchmarks();
    final tool = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>).first,
    );
    final hand = tester.widget<DropdownButton<Hand>>(
      find.byType(DropdownButton<Hand>).first,
    );
    expect((tool.value, hand.value), ('Spark', Hand.left));
  });

  testWidgets('drops an edited plan when the default tool or hand moves', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      part: 'Training',
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CrimpdeqScreen)),
    );
    container
        .read(workoutSetupProvider.notifier)
        .updatePlan(
          WorkoutPlan.forSection(
            tool: 'Photon',
            hand: Hand.right,
            section: CurveSection.endurance,
            benchmarkKg: 30,
          ).copyWith(reps: 17),
        );
    await tester.pump();
    expect(find.text('Reps: 17'), findsOneWidget);

    // The latest benchmark sets the default tool and hand.
    await container
        .read(trainingLogProvider.notifier)
        .addBenchmark(
          Benchmark(
            date: DateTime(2026, 10, 27),
            tool: 'Spark',
            hand: Hand.left,
            forceKg: 30,
          ),
        );
    await tester.pumpAndSettle();
    expect(find.text('Reps: 17'), findsNothing);
  });

  testWidgets('falls back to a tool with benchmarks left', (tester) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks':
          '[{"date":"2026-10-25T10:00:00.000","tool":"Spark",'
          '"hand":"right","forceKg":30},$_benchmark]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      part: 'Training',
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CrimpdeqScreen)),
    );
    container.read(workoutSetupProvider.notifier).selectTool('Spark');
    await tester.pump();

    final log = await container.read(trainingLogProvider.future);
    await container
        .read(trainingLogProvider.notifier)
        .deleteBenchmark(log.benchmarks.first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Photon'), findsOneWidget);
  });

  testWidgets('saves a held weight as a benchmark and opens its workout', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      part: 'Training',
    );
    await tester.tap(find.text('Benchmarks'));
    await tester.pumpAndSettle();

    // The add form comes before the entries filter.
    Future<void> select(Type dropdown, String option) async {
      await tester.tap(find.byType(dropdown).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(option).last);
      await tester.pumpAndSettle();
    }

    await select(DropdownButton<String>, 'Spark');
    await select(DropdownButton<Hand>, 'Left');
    final weight = find.widgetWithText(TextField, 'Weight held (kg)');
    final save = find.widgetWithText(OutlinedButton, 'Save Hold');
    await tester.ensureVisible(save);
    await tester.enterText(weight, 'abc');
    await tester.tap(save);
    await tester.pump();
    expect(find.text('Enter the weight held, in kg.'), findsOneWidget);
    // Too light for even the Power target to start a hang.
    await tester.enterText(weight, '0.5');
    await tester.tap(save);
    await tester.pump();
    expect(find.textContaining('A workout needs more than 3.0 kg'), findsOne);

    // 30 kg for 10 s is a 32.92 kg 5 s max.
    await tester.enterText(weight, '30');
    await tester.enterText(
      find.widgetWithText(TextField, 'Time held (s)'),
      '10',
    );
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Spark · Left: 32.9 kg'), findsOneWidget);
    expect(find.text('PB'), findsOneWidget);

    await tester.tap(find.text('Open Workout'));
    await tester.pumpAndSettle();
    expect(find.text('Workout Type: Endurance'), findsOneWidget);
    expect(find.text('Force: 7.5 kg'), findsOneWidget);
  });

  testWidgets('compares benchmarks with the previous and best ones', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks':
          '[$_benchmark,'
          '{"date":"2026-10-27T10:00:00.000","tool":"Photon",'
          '"hand":"right","forceKg":28}]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      part: 'Training',
    );
    await tester.tap(find.text('Benchmarks'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Photon · Right: 28.0 kg'));

    expect(find.textContaining('vs Prev -2.0 kg · vs Best -2.0 kg'), findsOne);
    expect(find.textContaining('vs Prev — · vs Best 0.0 kg'), findsOne);
    expect(find.text('Tracking'), findsOneWidget);
    expect(find.text('PB'), findsOneWidget);
  });

  testWidgets('shows the workout history with each rep', (tester) async {
    String workout(String date, List<num> actual) =>
        '{"date":"$date","tool":"Photon","hand":"right",'
        '"section":"strength","targetForceKg":11.97,"forceKg":12.1,'
        '"restSeconds":20,"targetSeconds":[50,36],"actualSeconds":$actual,'
        '"perceivedExertion":7,"notes":"Felt good"}';
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
      'training.workouts':
          '[${workout('2026-10-26T10:00:00.000', [40, 30])},'
          '${workout('2026-10-27T10:00:00.000', [46, 36])}]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      part: 'Training',
    );
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    // Mean deltas of -2 s and -8 s.
    expect(find.text('-2.0 s'), findsOne);
    expect(find.text('-8.0 s'), findsOne);
    // Only the latest has a previous workout to compare with.
    expect(find.text('+6.0 s vs previous'), findsOne);
    expect(find.text('2 of 2 reps held'), findsNWidgets(2));

    final latest = find.text('Tue 27 Oct · 10:00');
    await tester.ensureVisible(latest);
    await tester.tap(latest);
    await tester.pumpAndSettle();
    expect(find.text('Notes: Felt good'), findsOneWidget);
    expect(find.text('-4.0 s'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete the workout?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(latest, findsNothing);
  });

  testWidgets('keeps the training available without a device', (tester) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    await _pumpScreen(
      tester,
      const ProgressorState(connection: DeviceConnection(bluetoothReady: true)),
      part: 'Training',
    );
    await tester.pumpAndSettle();

    expect(find.text('Connect a Crimpdeq to start'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Workout Type: Endurance'), findsOneWidget);
    final start = find.widgetWithText(FilledButton, 'Start Workout');
    await tester.ensureVisible(start);
    expect(tester.widget<FilledButton>(start).onPressed, isNull);

    await tester.tap(find.text('Benchmarks'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Start Pull'))
          .onPressed,
      isNull,
    );
    expect(
      find.textContaining('Connect a Crimpdeq in the Workout tab'),
      findsOne,
    );

    // Deleting asks first.
    final delete = find.byTooltip('Delete benchmark');
    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Photon · Right: 30.0 kg'), findsOneWidget);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Photon · Right: 30.0 kg'), findsNothing);
  });

  testWidgets('keeps the workout setup and defaults the benchmark form', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      part: 'Training',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Power (0)'));
    await tester.pumpAndSettle();
    expect(find.text('Workout Type: Power'), findsOneWidget);

    await tester.tap(find.text('Benchmarks'));
    await tester.pumpAndSettle();
    // The latest benchmark's tool and hand, so a hold saves at once.
    final save = find.widgetWithText(OutlinedButton, 'Save Hold');
    await tester.ensureVisible(save);
    expect(tester.widget<OutlinedButton>(save).onPressed, isNotNull);

    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();
    expect(find.text('Workout Type: Power'), findsOneWidget);
  });
}

import 'package:crimpdeq/analysis/calibration_curve.dart';
import 'package:crimpdeq/analysis/opengrips_curve.dart';
import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/models/training_models.dart';
import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:crimpdeq/providers/schedule_provider.dart';
import 'package:crimpdeq/providers/theme_mode_provider.dart';
import 'package:crimpdeq/providers/training_provider.dart';
import 'package:crimpdeq/providers/warmup_provider.dart';
import 'package:crimpdeq/screens/crimpdeq_screen.dart';
import 'package:crimpdeq/theme.dart';
import 'package:crimpdeq/widgets/training_charts.dart';
import 'package:crimpdeq/widgets/training_common.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/calibration_details.dart';
import '../support/fake_notifications.dart';

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

/// A finished benchmark pull, or one still recording.
class _Recorded extends BenchmarkRecorder {
  _Recorded(this.bestKg, {this.recording = false});

  final double bestKg;
  final bool recording;

  @override
  BenchmarkRecording build() => (
    recording: recording,
    elapsedSeconds: 6,
    bestKg: bestKg,
    trace: const [],
  );
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

/// A workout in a fixed state.
class _FixedWorkout extends WorkoutNotifier {
  _FixedWorkout(this.initialState);

  final WorkoutState initialState;

  @override
  WorkoutState build() => initialState;

  void set(WorkoutState workout) => state = workout;
}

/// An idle workout that records its starts instead of measuring.
class _StartedWorkout extends _FixedWorkout {
  _StartedWorkout() : super(const WorkoutState());

  final starts = <({List<WorkoutPlan> plans, bool alternating})>[];

  @override
  Future<void> start(
    List<WorkoutPlan> plans, {
    bool alternating = false,
  }) async => starts.add((plans: plans, alternating: alternating));
}

/// A workout in a fixed state that records its redone reps.
class _RedoneWorkout extends _FixedWorkout {
  _RedoneWorkout(super.initialState);

  var redone = 0;

  @override
  void redoRep() => redone++;
}

/// A workout in a fixed state that records how it stops.
class _StoppedWorkout extends _FixedWorkout {
  _StoppedWorkout(super.initialState);

  final stops = <String>[];

  @override
  Future<void> stop() async => stops.add('discard');

  @override
  Future<void> stopKeepingReps() async => stops.add('keep');
}

/// A warm-up in a fixed state.
class _FixedWarmup extends WarmupNotifier {
  _FixedWarmup(this.initialState);

  final WarmupState initialState;

  @override
  WarmupState build() => initialState;

  void set(WarmupState warmup) => state = warmup;
}

/// Opens the training pages, or the device tools from the app bar menu.
Future<_FakeProgressor> _pumpScreen(
  WidgetTester tester,
  ProgressorState state, {
  bool deviceTools = true,
  List<Override> overrides = const [],
  FakeNotifications? notifications,
}) async {
  notifications ??= FakeNotifications();
  final fake = _FakeProgressor(state);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        progressorProvider.overrideWith(() => fake),
        trainingNotificationsProvider.overrideWithValue(notifications),
        ...overrides,
      ],
      child: MaterialApp(theme: buildDarkTheme(), home: const CrimpdeqScreen()),
    ),
  );
  if (deviceTools) {
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Device tools'));
    // Pumps for the route transition, since a pending calibration point
    // animates without settling.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  } else {
    // Loads the training log.
    await tester.pump();
  }
  return fake;
}

/// Opens a training page from the navigation bar.
Future<void> _openPage(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(NavigationDestination, label));
  await tester.pumpAndSettle();
}

/// Unfolds the benchmark history of the first tool with benchmarks.
Future<void> _openBenchmarkHistory(WidgetTester tester) async {
  final history = find.widgetWithText(ExpansionTile, 'History');
  await tester.ensureVisible(history.first);
  await tester.tap(history.first);
  await tester.pumpAndSettle();
}

/// Taps a segment, such as a tool or hand, of the first selector with it.
Future<void> _select(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle();
}

bool _chipSelected(WidgetTester tester, String label) =>
    tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label)).selected;

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

/// A benchmark for every tool and hand, which the warm-ups need.
final _allBenchmarks = [
  for (final (tool, hand, forceKg) in [
    ('Photon', 'left', 20),
    ('Photon', 'right', 30),
    ('Spark', 'left', 40),
    ('Spark', 'right', 50),
  ])
    '{"date":"2026-10-26T10:00:00.000","tool":"$tool","hand":"$hand",'
        '"forceKg":$forceKg}',
].join(',');

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
      deviceTools: false,
    );

    expect(find.text('Progressor_1A2B'), findsOneWidget);
    expect(find.text('~50% · 3.84 V'), findsOneWidget);
    expect(find.byIcon(Icons.battery_3_bar), findsOneWidget);
    expect(find.text('1.2.3'), findsNothing);

    await tester.tap(find.text('Progressor_1A2B'));
    await tester.pumpAndSettle();
    expect(find.text(_deviceId), findsOneWidget);
    expect(find.text('1.2.3'), findsOneWidget);
    expect(find.text('~50%'), findsOneWidget);
    expect(find.text('3.84 V'), findsOneWidget);
    expect(find.text('80 Hz'), findsOneWidget);
    expect(fake.calls, isEmpty);

    // Disconnecting takes the menu, so a stray tap does not end a workout.
    await tester.tap(find.text('Disconnect'));
    // The menu closes before the action.
    await tester.pump();
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
      deviceTools: false,
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
      deviceTools: false,
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
      deviceTools: false,
    );

    expect(find.text('Scanning…'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
  });

  for (final (name, physicalSize, pixelRatio) in [
    ('394 dp phone', const Size(1280, 2772), 3.25),
    ('360 dp phone', const Size(1080, 2340), 3.0),
  ]) {
    testWidgets(
      'fits the status between the logo and the menu button on a $name',
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
          deviceTools: false,
        );

        final logo = tester.getRect(find.byType(Image));
        final menuButton = tester.getRect(find.byTooltip('More'));
        for (final text in ['Progressor_1A2B', '~25%']) {
          final rect = tester.getRect(find.text(text));
          expect(rect.left, greaterThanOrEqualTo(logo.right), reason: text);
          expect(rect.right, lessThanOrEqualTo(menuButton.left), reason: text);
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
      deviceTools: false,
    );

    expect(find.text('Record your first benchmark'), findsOneWidget);
    await _openPage(tester, 'History');
    expect(find.text('No workouts yet'), findsOneWidget);

    // Each empty page links to the one that fills it.
    await tester.tap(find.text('Go to Workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record a Benchmark'));
    await tester.pumpAndSettle();
    expect(find.text('New benchmark'), findsOneWidget);
  });

  testWidgets('unlocks the workout with the latest benchmark', (tester) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );

    expect(_chipSelected(tester, 'Endurance'), isTrue);
    expect(find.text('Suggested'), findsOneWidget);
    expect(find.text('6.8 kg'), findsOneWidget);
    expect(find.text('3:13'), findsOneWidget);
    expect(find.text('No Endurance workouts yet.'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Power'));
    await tester.pumpAndSettle();
    expect(_chipSelected(tester, 'Power'), isTrue);
    expect(find.text('Suggested'), findsNothing);
    expect(find.text('20.0 kg'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });

  for (final (bestKg, saves) in [(0.0, false), (3.0, false), (3.1, true)]) {
    testWidgets('${saves ? 'saves' : 'rejects'} a $bestKg kg pull', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        ProgressorState(connection: _connected),
        deviceTools: false,
        overrides: [
          benchmarkRecorderProvider.overrideWith(() => _Recorded(bestKg)),
        ],
      );
      await _openPage(tester, 'Benchmarks');
      await _select(tester, 'Photon');
      await _select(tester, 'Right');

      final save = find.widgetWithText(FilledButton, 'Save Benchmark');
      expect(tester.widget<FilledButton>(save).onPressed != null, saves);
      expect(
        find.text('Pull more than 3.0 kg for at least 5 s.'),
        saves ? findsNothing : findsOne,
      );
    });
  }

  testWidgets('blocks a workout whose target cannot start a hold', (
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
      deviceTools: false,
    );
    await tester.pumpAndSettle();
    final start = find.widgetWithText(FilledButton, 'Start Workout');

    // The Endurance target of a 6 kg benchmark is 1.36 kg.
    expect(find.textContaining('target is too light'), findsOneWidget);
    expect(tester.widget<FilledButton>(start).onPressed, isNull);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Power'));
    await tester.pumpAndSettle();
    expect(find.textContaining('target is too light'), findsNothing);
    expect(tester.widget<FilledButton>(start).onPressed, isNotNull);

    // A lower threshold lets the light target start a hold.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Endurance'));
    await ProviderScope.containerOf(tester.element(find.byType(CrimpdeqScreen)))
        .read(holdThresholdProvider.notifier)
        .set(1);
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
      deviceTools: false,
    );
    await _openPage(tester, 'Benchmarks');
    await _select(tester, 'Spark');
    await _select(tester, 'Left');

    // A pull recorded here saves under them after a visit to the workout
    // and the device tools.
    await _openPage(tester, 'Workout');
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Device tools'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await _openPage(tester, 'Benchmarks');
    final tool = tester.widget<SegmentedButton<String?>>(
      find.byType(SegmentedButton<String?>).first,
    );
    final hand = tester.widget<SegmentedButton<Hand>>(
      find.byType(SegmentedButton<Hand>),
    );
    expect(tool.selected, {'Spark'});
    expect(hand.selected, {Hand.left});
  });

  testWidgets('shapes the rep targets by energy systems once switched on', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CrimpdeqScreen)),
    );
    EnergySystems? energySystems() =>
        container.read(workoutSetupProvider).plan?.energySystems;
    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    await tap(find.text('Customize'));
    // The template, without the sliders that would change it.
    expect(find.textContaining('Power: '), findsNothing);

    final shape = find.text('Shape by energy systems');
    await tap(shape);
    expect(energySystems(), isNotNull);
    expect(find.textContaining('Power: '), findsOne);

    await tap(shape);
    expect(energySystems(), isNull);
    expect(find.textContaining('Power: '), findsNothing);
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
      deviceTools: false,
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
    expect(find.text('17'), findsOneWidget);

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
    expect(find.text('17'), findsNothing);
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
      deviceTools: false,
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

  for (final (benchmarks, tool, hand) in [
    // The missing hand of a tool trained, not of the others.
    ([('Spark', 'left')], 'Spark', Hand.right),
    // Else the other hand of the latest.
    ([('Spark', 'left'), ('Spark', 'right')], 'Spark', Hand.left),
  ]) {
    testWidgets('defaults a benchmark after $benchmarks to $tool $hand', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'training.benchmarks': [
          for (final (tool, hand) in benchmarks)
            '{"date":"2026-10-26T10:00:00.000","tool":"$tool",'
                '"hand":"$hand","forceKg":30}',
        ].toString(),
      });
      await _pumpScreen(
        tester,
        ProgressorState(connection: _connected),
        deviceTools: false,
      );
      await _openPage(tester, 'Benchmarks');
      expect(
        tester
            .widget<SegmentedButton<String?>>(
              find.byType(SegmentedButton<String?>),
            )
            .selected,
        {tool},
      );
      expect(
        tester
            .widget<SegmentedButton<Hand>>(find.byType(SegmentedButton<Hand>))
            .selected,
        {hand},
      );
    });
  }

  testWidgets('saves a held weight as a benchmark and opens its workout', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await _openPage(tester, 'Benchmarks');
    await _select(tester, 'Spark');
    await _select(tester, 'Left');
    // Folded while a device is connected.
    await tester.ensureVisible(find.text('Enter a held weight instead'));
    await tester.tap(find.text('Enter a held weight instead'));
    await tester.pumpAndSettle();
    final weight = find.widgetWithText(TextField, 'Weight held (kg)');
    final save = find.widgetWithText(OutlinedButton, 'Save Hold');
    await tester.ensureVisible(save);
    await tester.enterText(weight, 'abc');
    await tester.tap(save);
    await tester.pump();
    expect(find.text('Enter the weight held, in kg.'), findsOneWidget);
    // Too light for even the Power target to start a hold.
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
    // The left hand's best, the right hand without one.
    expect(find.widgetWithText(Card, '1 benchmark'), findsOne);
    expect(find.text('32.9 kg'), findsOneWidget);
    expect(find.text('No benchmark yet'), findsOne);
    // The other hand pulls next.
    expect(
      tester
          .widget<SegmentedButton<Hand>>(find.byType(SegmentedButton<Hand>))
          .selected,
      {Hand.right},
    );

    await tester.tap(find.text('Open Workout'));
    await tester.pumpAndSettle();
    expect(_chipSelected(tester, 'Endurance'), isTrue);
    expect(find.text('7.5 kg'), findsOneWidget);
  });

  testWidgets('hides the saved benchmark message after a while', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpScreen(
      tester,
      const ProgressorState(connection: DeviceConnection(bluetoothReady: true)),
      deviceTools: false,
    );
    await _openPage(tester, 'Benchmarks');
    await _select(tester, 'Photon');
    await _select(tester, 'Right');
    await tester.enterText(
      find.widgetWithText(TextField, 'Weight held (kg)'),
      '30',
    );
    final save = find.widgetWithText(OutlinedButton, 'Save Hold');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.textContaining('Benchmark saved'), findsOne);

    // Its action does not keep it on screen.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.textContaining('Benchmark saved'), findsNothing);
  });

  testWidgets('compares benchmarks with the previous and best ones', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks':
          '[$_benchmark,'
          '{"date":"2026-10-27T10:00:00.000","tool":"Photon",'
          '"hand":"right","forceKg":28}]',
      // Logged after the first benchmark's day, so only the second has it.
      'training.bodyWeights': '[{"day":"2026-10-27T00:00:00.000","kg":56}]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await _openPage(tester, 'Benchmarks');
    // The right hand's best, its latest and none for the left hand.
    expect(find.text('30.0 kg'), findsOne);
    expect(find.text('26 Oct 2026'), findsOne);
    expect(find.text('Latest 28.0 kg · 27 Oct'), findsOne);
    expect(find.text('No benchmark yet'), findsOne);
    expect(find.byType(BenchmarkProgressGraph), findsOne);

    await _openBenchmarkHistory(tester);
    expect(find.text('28.0 kg · 50% BW'), findsOne);
    expect(find.textContaining('-2.0 kg vs previous'), findsOne);
    expect(find.byTooltip('Personal best'), findsOne);
  });

  testWidgets('logs body weights from the app bar menu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Body weight'));
    await tester.pumpAndSettle();
    expect(find.text('No body weights yet.'), findsOne);

    final field = find.widgetWithText(TextField, 'Body weight (kg)');
    final save = find.text('Save Body Weight');
    for (final invalid in ['5', 'NaN']) {
      await tester.enterText(field, invalid);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.textContaining('from 20 to 300 kg'), findsOne);
    }
    expect(find.text('No body weights yet.'), findsOne);

    await tester.enterText(field, '61,5');
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('61.5 kg'), findsOne);

    await tester.tap(find.byTooltip('Delete body weight'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No body weights yet.'), findsOne);
  });

  testWidgets('shows each workout with its hands and reps', (tester) async {
    String workout(
      String date,
      String hand,
      double forceKg,
      List<num> actual, {
      String details = '',
    }) =>
        '{"date":"$date","tool":"Photon","hand":"$hand",'
        '"section":"strength","targetForceKg":11.97,"forceKg":$forceKg,'
        '"restSeconds":20,"targetSeconds":[50,36],"actualSeconds":$actual,'
        '$details"perceivedExertion":7,"notes":"Felt good"}';
    const tuesday = '2026-10-27T10:00:00.000';
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
      // The first one is from before the rep forces and durations were
      // stored; the next one trained both hands.
      'training.workouts':
          '[${workout('2026-10-26T10:00:00.000', 'right', 11.8, [40, 30])},'
          '${workout(tuesday, 'right', 12.1, [46, 36], details: '"repForcesKg":[12.3,11.9],"durationSeconds":754,')},'
          '${workout(tuesday, 'left', 8, [50, 36], details: '"repForcesKg":[8.1,7.9],"durationSeconds":754,')}]',
      'training.bodyWeights': '[{"day":"2026-10-27T00:00:00.000","kg":60.5}]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await _openPage(tester, 'History');

    // One card per workout, with the totals of its hands.
    expect(find.text('Photon · #1 in Oct'), findsOne);
    expect(find.text('Photon · #2 in Oct'), findsOne);
    expect(find.text('Right hand'), findsNWidgets(2));
    expect(find.text('Left hand'), findsOne);
    expect(find.text('12:34'), findsOne);
    expect(find.text('2:48'), findsOne);
    expect(find.text('1680 kg·s'), findsOne);
    // Without a stored duration.
    expect(find.text('—'), findsOne);
    expect(find.text('826 kg·s'), findsOne);
    // Mean deltas of -8 s and -2 s for the right hand, 0 s for the left.
    expect(find.text('-8.0 s'), findsOne);
    expect(find.text('-2.0 s'), findsOne);
    expect(find.text('0.0 s'), findsOne);
    // Only the latest right hand has a previous workout to compare with.
    expect(find.text('+6.0 s vs previous'), findsOne);

    final latest = find.text('Tue 27 Oct · 10:00');
    await tester.ensureVisible(latest);
    await tester.tap(latest);
    await tester.pumpAndSettle();
    expect(find.text('Strength · Photon'), findsOne);
    expect(find.text('Tue 27 Oct · 10:00 · Photon · #2 in Oct'), findsOne);
    expect(find.text('Felt good'), findsOne);
    expect(
      find.text('20% BW · 20 s rest · under load 1:22 · 992 kg·s'),
      findsOne,
    );
    expect(
      find.text(
        'vs Mon 26 Oct · 10:00: force +0.3 kg, Avg Δ +6.0 s, '
        'workload +166 kg·s',
      ),
      findsOne,
    );
    // The force of each rep.
    for (final kg in ['12.3 kg', '11.9 kg', '8.1 kg', '7.9 kg']) {
      expect(find.text(kg), findsOne);
    }
    expect(find.text('-4.0 s'), findsOne);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'The results of both hands leave the history and the force curve.',
      ),
      findsOne,
    );
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(latest, findsNothing);
    expect(find.text('Photon · #1 in Oct'), findsOne);
    expect(find.text('Left hand'), findsNothing);
  });

  testWidgets('draws each tool on the curve of its own benchmark', (
    tester,
  ) async {
    String workout(String tool, String date) =>
        '{"date":"$date","tool":"$tool","hand":"right",'
        '"section":"strength","targetForceKg":12,"forceKg":12,'
        '"restSeconds":20,"targetSeconds":[50],"actualSeconds":[50],'
        '"perceivedExertion":7,"notes":""}';
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
      'training.workouts':
          '[${workout('Photon', '2026-10-26T10:00:00.000')},'
          '${workout('Spark', '2026-10-27T10:00:00.000')}]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await _openPage(tester, 'History');

    expect(find.text('Photon force curve'), findsOne);
    expect(find.text('Spark force curve'), findsOne);
    expect(
      find.text('Record a Spark benchmark to draw its force curve.'),
      findsOne,
    );

    await _select(tester, 'Photon');
    expect(find.text('Photon force curve'), findsOne);
    expect(find.text('Spark force curve'), findsNothing);
  });

  testWidgets('counts the rest down before the other gripper', (tester) async {
    final saved = DateTime.now().subtract(const Duration(minutes: 15));
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_allBenchmarks]',
      'training.workouts':
          '[{"date":"${saved.toIso8601String()}","tool":"Photon",'
          '"hand":"right","section":"strength","targetForceKg":12,'
          '"forceKg":12,"restSeconds":20,"targetSeconds":[50,36],'
          '"actualSeconds":[50,36],"perceivedExertion":7,"notes":""}]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await tester.pump();

    // The latest benchmark's Spark, an hour after the Photon workout.
    expect(find.text('Rest before Spark'), findsOne);
    expect(find.textContaining(RegExp(r'^4[45]:\d\d$')), findsOne);
    // The other hand on Photon needs no rest.
    await tester.tap(find.text('Photon').first);
    await tester.pump();
    expect(find.textContaining('Rest before'), findsNothing);
  });

  testWidgets('schedules reminders and the end of the rest', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final notifications = FakeNotifications();
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
      notifications: notifications,
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(find.text('Rest: 60 min'), findsOne);

    final add = find.text('Add Reminder');
    await tester.tap(add);
    await tester.pumpAndSettle();
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(notifications.calls, [
      'request',
      'reminders Photon [1, 3, 5] 10:0',
      'request',
      'reminders Photon [1, 3, 5] 10:0, Spark [1, 3, 5] 10:0',
    ]);
    // Each gripper's name on one line, on a 360 dp phone.
    for (final element in find.text('Photon').evaluate()) {
      final name = element.renderObject! as RenderParagraph;
      expect(
        name.getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: 6),
        ),
        hasLength(1),
      );
    }

    notifications.calls.clear();
    await tester.tap(find.text('Tue').first);
    await tester.pumpAndSettle();
    final delete = find.byTooltip('Delete reminder').last;
    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(notifications.calls, [
      'reminders Photon [1, 2, 3, 5] 10:0, Spark [1, 3, 5] 10:0',
      'reminders Photon [1, 2, 3, 5] 10:0',
    ]);

    notifications.calls.clear();
    final notify = find.text('Notify when the rest is over');
    await tester.ensureVisible(notify);
    await tester.tap(notify);
    await tester.pumpAndSettle();
    expect(notifications.calls, ['request', 'cancel rest']);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );
  });

  testWidgets('keeps the rest notice off without permission', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
      notifications: FakeNotifications(allowed: false),
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notify when the rest is over'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(find.textContaining('Notifications are off'), findsOne);
  });

  testWidgets('warns while reminders cannot notify', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
      notifications: FakeNotifications(allowed: false),
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    const warning =
        'Notifications are off for Crimpdeq, so the reminders and the rest '
        'notice do not show.';
    // Nothing to notify yet.
    expect(find.text(warning), findsNothing);

    await tester.tap(find.text('Add Reminder'));
    await tester.pumpAndSettle();
    // The reminder is kept, and the warning stays with it.
    expect(find.text('10:00'), findsOne);
    expect(find.text(warning), findsOne);
    expect(find.text('Open App Settings'), findsOne);
  });

  testWidgets('keeps the training available without a device', (tester) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    await _pumpScreen(
      tester,
      const ProgressorState(connection: DeviceConnection(bluetoothReady: true)),
      deviceTools: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('Connect your Crimpdeq'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(_chipSelected(tester, 'Endurance'), isTrue);
    final start = find.widgetWithText(FilledButton, 'Start Workout');
    await tester.ensureVisible(start);
    expect(tester.widget<FilledButton>(start).onPressed, isNull);
    // Saying why.
    expect(find.text('Connect your Crimpdeq to start.'), findsOne);

    // Without a device, a held weight, and the way to connect one.
    await _openPage(tester, 'Benchmarks');
    expect(find.text('Connect your Crimpdeq'), findsOneWidget);
    expect(find.text('Start Pull'), findsNothing);
    expect(find.text('Save Hold'), findsOneWidget);

    // Deleting asks first.
    await _openBenchmarkHistory(tester);
    final delete = find.byTooltip('Delete benchmark');
    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    // The best and the history entry.
    expect(find.text('30.0 kg'), findsNWidgets(2));
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('30.0 kg'), findsNothing);
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
      deviceTools: false,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Power'));
    await tester.pumpAndSettle();
    expect(_chipSelected(tester, 'Power'), isTrue);

    await _openPage(tester, 'Benchmarks');
    await tester.ensureVisible(find.text('Enter a held weight instead'));
    await tester.tap(find.text('Enter a held weight instead'));
    await tester.pumpAndSettle();
    // The latest benchmark's tool and hand, so a hold saves at once.
    final save = find.widgetWithText(OutlinedButton, 'Save Hold');
    await tester.ensureVisible(save);
    expect(tester.widget<OutlinedButton>(save).onPressed, isNotNull);

    await _openPage(tester, 'Workout');
    expect(_chipSelected(tester, 'Power'), isTrue);
  });

  final strength = WorkoutPlan.forSection(
    tool: 'Photon',
    hand: Hand.right,
    section: CurveSection.strength,
    benchmarkKg: 30,
  );

  testWidgets('keeps the whole screen for a running workout', (tester) async {
    final fake = await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        measurement: const MeasurementState(isMeasuring: true, currentKg: 1.2),
      ),
      deviceTools: false,
      overrides: [
        workoutProvider.overrideWith(
          () => _FixedWorkout(
            WorkoutState(
              plans: [strength],
              phase: WorkoutPhase.hold,
              actualSeconds: const [101],
              // The latest 15 s, 72.3 s into the workout.
              forceTrace: [
                for (var i = 573; i <= 723; i++) FlSpot(i / 10, 1.2),
              ],
            ),
          ),
        ),
      ],
    );

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('HOLD'), findsOneWidget);
    expect(find.text('Rep 2 of 5'), findsOneWidget);
    expect(
      find.text('Pull more than 2.0 kg to start the timer'),
      findsOneWidget,
    );
    // The graph shows the force over the time since the start, and tares.
    expect(find.text('1.2 kg'), findsOneWidget);
    for (final label in ['1:00', '1:05', '1:10']) {
      expect(find.text(label), findsOne);
    }
    await tester.tap(find.text('Tare'));
    await tester.pump();
    expect(fake.calls, ['tare']);
  });

  for (final (held, notice) in [
    (1.0, 'rep 1 held 1 s of 101 s'),
    (0.0, 'rep 1 held 0 s of 101 s'),
    // Short by more than the tolerance before rounding, as the scaling is.
    (97.6, 'rep 1 held 98 s of 101 s'),
    (99.0, null),
  ]) {
    testWidgets('offers to redo a first rep held $held s', (tester) async {
      final workout = _RedoneWorkout(
        WorkoutState(
          plans: [strength],
          phase: WorkoutPhase.rest,
          actualSeconds: [held],
          repForcesKg: [held > 0 ? 12 : null],
          restRemainingSeconds: 15,
        ),
      );
      await _pumpScreen(
        tester,
        ProgressorState(connection: _connected),
        deviceTools: false,
        overrides: [workoutProvider.overrideWith(() => workout)],
      );

      if (notice == null) {
        expect(find.textContaining('Redo Rep'), findsNothing);
        return;
      }
      expect(find.byTooltip(notice), findsOne);
      await tester.ensureVisible(find.text('Redo Rep 1'));
      await tester.tap(find.text('Redo Rep 1'));
      expect(workout.redone, 1);
    });
  }

  testWidgets('keeps the tare off while a hold counts', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        measurement: const MeasurementState(isMeasuring: true, currentKg: 12),
      ),
      deviceTools: false,
      overrides: [
        workoutProvider.overrideWith(
          () => _FixedWorkout(
            WorkoutState(
              plans: [strength],
              phase: WorkoutPhase.hold,
              holding: true,
              heldSeconds: 20,
            ),
          ),
        ),
      ],
    );

    final tare = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Tare'),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
    expect(tare.onPressed, isNull);
  });

  for (final (name, workout, message) in [
    (
      'a running workout',
      WorkoutState(plans: [strength], phase: WorkoutPhase.hold),
      'Stop the workout or warm-up to leave.',
    ),
    (
      'unsaved results',
      WorkoutState(
        plans: [strength],
        phase: WorkoutPhase.done,
        actualSeconds: const [98, 34, 30, 22, 20],
        repForcesKg: const [12, 12, 12, 12, 12],
      ),
      'Save or discard the workout to leave.',
    ),
  ]) {
    testWidgets('keeps $name from the back gesture', (tester) async {
      await _pumpScreen(
        tester,
        ProgressorState(connection: _connected),
        deviceTools: false,
        overrides: [workoutProvider.overrideWith(() => _FixedWorkout(workout))],
      );

      // Handled by the app, so the system does not close it.
      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pump();
      expect(find.text(message), findsOne);
      expect(find.byType(CrimpdeqScreen), findsOne);
    });
  }

  for (final (size, ratio, scale) in [
    (const Size(1080, 2340), 3.0, 1.0),
    (const Size(1280, 2772), 3.25, 1.3),
  ]) {
    testWidgets('keeps the timer controls on a phone at $scale× text', (
      tester,
    ) async {
      final workout = _FixedWorkout(
        WorkoutState(
          plans: [strength],
          phase: WorkoutPhase.rest,
          actualSeconds: const [1],
          repForcesKg: const [12],
          restRemainingSeconds: 15,
        ),
      );
      // A load at rest adds the longest message, and the short rep its redo.
      await _pumpScreen(
        tester,
        ProgressorState(
          connection: _connected,
          measurement: const MeasurementState(isMeasuring: true, currentKg: 3),
        ),
        deviceTools: false,
        overrides: [workoutProvider.overrideWith(() => workout)],
      );
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = ratio;
      tester.view.padding = FakeViewPadding(
        top: 24 * ratio,
        bottom: 16 * ratio,
      );
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      for (final state in [
        workout.initialState,
        WorkoutState(
          plans: [strength],
          phase: WorkoutPhase.hold,
          actualSeconds: const [101],
          holding: true,
          heldSeconds: 10,
        ),
      ]) {
        workout.set(state);
        await tester.pumpAndSettle();
        // Above the gesture bar, without scrolling.
        expect(
          tester.getRect(find.text('Stop')).bottom,
          lessThanOrEqualTo(size.height / ratio - 16),
        );
      }
    });
  }

  for (final (repsDone, action) in [
    (0, 'Stop'),
    (1, 'Discard'),
    (1, 'Save Reps'),
  ]) {
    testWidgets('stops a workout with $repsDone reps done: $action', (
      tester,
    ) async {
      final workout = _StoppedWorkout(
        WorkoutState(
          plans: [strength],
          phase: WorkoutPhase.hold,
          actualSeconds: [for (var rep = 0; rep < repsDone; rep++) 101],
          repForcesKg: [for (var rep = 0; rep < repsDone; rep++) 12],
        ),
      );
      await _pumpScreen(
        tester,
        ProgressorState(connection: _connected),
        deviceTools: false,
        overrides: [workoutProvider.overrideWith(() => workout)],
      );
      final stop = find.widgetWithText(OutlinedButton, 'Stop');
      await tester.ensureVisible(stop);
      await tester.tap(stop);
      await tester.pumpAndSettle();
      expect(find.text('Save Reps'), repsDone == 0 ? findsNothing : findsOne);

      await tester.tap(find.widgetWithText(TextButton, action));
      await tester.pumpAndSettle();
      expect(workout.stops, [action == 'Save Reps' ? 'keep' : 'discard']);
    });
  }

  testWidgets('shows the workout that starts on another page', (tester) async {
    final workout = _FixedWorkout(const WorkoutState());
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
      overrides: [workoutProvider.overrideWith(() => workout)],
    );
    // The start awaits the device, meanwhile the user opens another page.
    await _openPage(tester, 'Benchmarks');
    workout.set(WorkoutState(plans: [strength], phase: WorkoutPhase.hold));
    await tester.pump();

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('HOLD'), findsOneWidget);
  });

  testWidgets('discards the results only after confirmation', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
      overrides: [
        workoutProvider.overrideWith(
          () => _FixedWorkout(
            WorkoutState(
              plans: [strength],
              phase: WorkoutPhase.done,
              actualSeconds: const [98, 34, 30, 22, 20],
              repForcesKg: const [12, 12, 12, 12, 12],
            ),
          ),
        ),
      ],
    );
    expect(find.byType(NavigationBar), findsOneWidget);
    final discard = find.widgetWithText(OutlinedButton, 'Discard');
    await tester.ensureVisible(discard);

    await tester.tap(discard);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Workout complete'), findsOneWidget);

    await tester.tap(discard);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Workout complete'), findsNothing);
  });

  testWidgets('saves the results and opens them in the history', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
      overrides: [
        workoutProvider.overrideWith(
          () => _FixedWorkout(
            WorkoutState(
              plans: [strength],
              phase: WorkoutPhase.done,
              actualSeconds: const [98, 34, 30, 22, 20],
              repForcesKg: const [12, 12, 12, 12, 12],
              startedAt: DateTime(2026, 10, 27, 10),
              endedAt: DateTime(2026, 10, 27, 10, 6, 40),
            ),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
    // The mean delta of the reps against their targets.
    expect(find.text('-2.2 s'), findsOneWidget);
    final save = find.widgetWithText(FilledButton, 'Save Results');
    await tester.ensureVisible(save);
    // Saving waits for the effort.
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    final effort = find.byType(Slider);
    await tester.ensureVisible(effort);
    await tester.tap(effort);
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r'^Effort: \d+/10 · ')), findsOne);
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Saved to your history.'), findsOneWidget);

    await tester.tap(find.text('View History'));
    await tester.pumpAndSettle();
    expect(
      find.text('Photon · #1 in ${formatMonth(DateTime.now())}'),
      findsOne,
    );
    expect(find.text('6:40'), findsOne);
  });

  testWidgets('starts a workout of both hands at their benchmarks', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    final workout = _StartedWorkout();
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
      overrides: [workoutProvider.overrideWith(() => workout)],
    );
    await tester.pumpAndSettle();
    final start = find.widgetWithText(FilledButton, 'Start Workout');

    await _select(tester, 'Both in turn');
    expect(
      find.text(
        'Record a benchmark for Photon with the Left hand to train both '
        'hands.',
      ),
      findsOne,
    );
    expect(tester.widget<FilledButton>(start).onPressed, isNull);

    await ProviderScope.containerOf(tester.element(find.byType(CrimpdeqScreen)))
        .read(trainingLogProvider.notifier)
        .addBenchmark(
          Benchmark(
            date: DateTime(2026, 10, 25),
            tool: 'Photon',
            hand: Hand.left,
            forceKg: 20,
          ),
        );
    await tester.pumpAndSettle();
    // The new benchmark is the latest, which moves the default hand.
    await _select(tester, 'Right');
    // The 193 s Endurance first hold does not fit in the 20 s rest.
    bool alternateEnabled() => tester
        .widget<SegmentedButton<WorkoutHands>>(
          find.byType(SegmentedButton<WorkoutHands>),
        )
        .segments
        .last
        .enabled;
    expect(alternateEnabled(), isFalse);
    expect(find.textContaining('Alternate needs at least 203 s'), findsOne);

    final setup = ProviderScope.containerOf(
      tester.element(find.byType(CrimpdeqScreen)),
    ).read(workoutSetupProvider.notifier);
    final fits = WorkoutPlan.forSection(
      tool: 'Photon',
      hand: Hand.right,
      section: CurveSection.endurance,
      benchmarkKg: 30,
    ).copyWith(firstHangSeconds: 40, restSeconds: 50);
    setup.updatePlan(fits);
    await tester.pumpAndSettle();
    expect(alternateEnabled(), isTrue);
    await _select(tester, 'Alternate');
    expect(
      find.text(
        'Each rep with the Right hand, then the Left: the other hand holds '
        'during each rest.',
      ),
      findsOne,
    );
    // The Endurance targets of 30 and 20 kg benchmarks.
    expect(find.text('Right force'), findsOne);
    expect(find.text('6.8 kg'), findsOne);
    expect(find.text('4.5 kg'), findsOne);
    expect(
      find.text('23% of your Right 30.0 kg and Left 20.0 kg benchmarks.'),
      findsOne,
    );

    // A rest that no longer fits blocks the start.
    setup.updatePlan(fits.copyWith(restSeconds: 49));
    await tester.pumpAndSettle();
    expect(find.textContaining('Alternate needs at least 50 s'), findsOne);
    expect(tester.widget<FilledButton>(start).onPressed, isNull);

    setup.updatePlan(fits);
    await tester.pumpAndSettle();
    await tester.ensureVisible(start);
    await tester.tap(start);
    final started = workout.starts.single;
    expect(started.alternating, isTrue);
    expect(
      [for (final plan in started.plans) plan.hand],
      [Hand.right, Hand.left],
    );
    expect(started.plans.last.benchmarkKg, 20);
  });

  testWidgets('shows each hand of a workout of both hands', (tester) async {
    // A rest that fits the 101 s first hold.
    final right = strength.copyWith(restSeconds: 120);
    final left = right.copyWith(hand: Hand.left, benchmarkKg: 20);
    final workout = _FixedWorkout(
      WorkoutState(
        plans: [right, left],
        alternating: true,
        phase: WorkoutPhase.rest,
        restRemainingSeconds: 3,
        actualSeconds: const [101, 90],
        repForcesKg: const [12, 8],
      ),
    );
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
      overrides: [workoutProvider.overrideWith(() => workout)],
    );
    expect(find.text('Right hand · Rep 1 of 5 done'), findsOne);
    expect(find.textContaining('Next: Right hand, rep 2,'), findsOne);

    workout.set(
      workout.state.copyWith(
        phase: WorkoutPhase.done,
        actualSeconds: const [101, 90, 34],
        repForcesKg: const [12, 8, 12],
        endedEarly: WorkoutEnd.disconnected,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('after rep 3 of 10.'), findsOne);
    for (final hand in ['Right', 'Left']) {
      expect(find.text('Strength · Photon · $hand hand'), findsOne);
    }
  });

  test('shows the inactive slider and switch tracks on a card', () {
    for (final theme in [buildDarkTheme(), buildLightTheme()]) {
      final track = theme.colorScheme.surfaceContainerHighest;
      expect(track, isNot(theme.colorScheme.surface));
      expect(track, isNot(theme.cardTheme.color));
    }
  });

  testWidgets('stores the theme and threshold in the settings', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    );
    expect(container.read(themeModeProvider), ThemeMode.system);
    // A new start reads it back before its first frame.
    expect(await ThemeModeNotifier.load(), ThemeMode.system);

    expect(find.text('Hold threshold: 2.0 kg'), findsOne);
    await tester.drag(find.byType(Slider), const Offset(-1000, 0));
    await tester.pumpAndSettle();
    expect(find.text('Hold threshold: 0.5 kg'), findsOne);
    expect(await container.read(holdThresholdProvider.future), 0.5);
  });
  testWidgets('asks for every benchmark a warm-up needs', (tester) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_benchmark]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await _openPage(tester, 'Warm-up');

    expect(
      find.text(
        'The forces are fractions of your benchmarks. Record one for '
        'Photon Left, Spark Left, Spark Right.',
      ),
      findsOne,
    );
    await _select(tester, 'Before training');
    expect(
      find.text(
        'The forces are fractions of your benchmarks. Record one for '
        'Photon Left.',
      ),
      findsOne,
    );
    expect(
      find.text(
        'No readiness checks yet. Run one after a climbing '
        'warm-up.',
      ),
      findsOne,
    );
  });

  testWidgets('shows the holds of each warm-up before it starts', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_allBenchmarks]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await _openPage(tester, 'Warm-up');

    // Before climbing: Spark, then Photon, 2:55 with the hand changes.
    expect(find.text('10'), findsOne);
    expect(find.text('02:55'), findsOne);
    expect(find.text('75%'), findsOne);
    expect(find.text('22.5 kg'), findsOne);
    final start = find.widgetWithText(FilledButton, 'Start Warm-up');
    await tester.ensureVisible(start);
    expect(tester.widget<FilledButton>(start).onPressed, isNotNull);

    // Before training a heavy session: 85% for 3 s more.
    await tester.ensureVisible(find.text('Before training'));
    await _select(tester, 'Before training');
    await _select(tester, 'Spark');
    expect(find.text('6'), findsOne);
    expect(find.text('85%'), findsNothing);
    await tester.tap(find.text('Heavy session'));
    await tester.pumpAndSettle();
    expect(find.text('8'), findsOne);
    expect(find.text('85%'), findsOne);
    expect(find.text('42.5 kg'), findsOne);
  });

  testWidgets('warms up for the tool of the next workout', (tester) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_allBenchmarks]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CrimpdeqScreen)),
    );
    container.read(workoutSetupProvider.notifier).selectTool('Photon');
    await _openPage(tester, 'Warm-up');
    await _select(tester, 'Before training');
    SegmentedButton<String?> tools() =>
        tester.widget(find.byType(SegmentedButton<String?>));
    expect(tools().selected, {'Photon'});

    // And the workout follows the warm-up's tool.
    await _select(tester, 'Spark');
    expect(container.read(workoutSetupProvider).tool, 'Spark');
  });

  testWidgets('blocks a warm-up whose lightest hold cannot start', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_allBenchmarks]',
      'training.holdThresholdKg': 7.0,
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await _openPage(tester, 'Warm-up');
    await _select(tester, 'Before training');
    await _select(tester, 'Photon');

    expect(
      find.text(
        'The lightest hold, 6.0 kg, is too light to start above 7.0 kg. '
        'Lower the threshold in Settings, in the menu.',
      ),
      findsOne,
    );
    final start = find.widgetWithText(FilledButton, 'Start Warm-up');
    await tester.ensureVisible(start);
    expect(tester.widget<FilledButton>(start).onPressed, isNull);
  });

  const warmupStep = (
    tool: 'Spark',
    hand: Hand.left,
    benchmarkKg: 40.0,
    forceKg: 16.0,
    seconds: 20,
    restSeconds: 0,
  );

  testWidgets('keeps the whole screen for a running warm-up', (tester) async {
    final warmup = _FixedWarmup(const WarmupState());
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        measurement: const MeasurementState(isMeasuring: true, currentKg: 19),
      ),
      deviceTools: false,
      overrides: [warmupProvider.overrideWith(() => warmup)],
    );
    // Started from the Warm-up page, the timer opens it.
    warmup.set(
      const WarmupState(
        kind: WarmupKind.climbing,
        steps: [warmupStep, warmupStep],
        phase: WorkoutPhase.hold,
        holding: true,
        heldSeconds: 4,
        overshooting: true,
      ),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('HOLD'), findsOne);
    expect(find.text('Before climbing · step 1 of 2'), findsOne);
    expect(find.text('Spark · Left hand'), findsOne);
    expect(find.text('00:16'), findsOne);
    expect(find.text('Hold 00:20 at 16.0 kg (40%)'), findsOne);
    expect(
      find.text('Ease off to 16.0 kg: a warm-up stays far from your max.'),
      findsOne,
    );

    // Before the pull, the tool and hand to take.
    warmup.set(
      const WarmupState(
        kind: WarmupKind.climbing,
        steps: [warmupStep, warmupStep],
        phase: WorkoutPhase.hold,
      ),
    );
    await tester.pump();
    expect(
      find.text(
        'Take Spark. Left hand: pull more than 2.0 kg to start the timer',
      ),
      findsOne,
    );
  });

  testWidgets('fits the warm-up and its timer on a 360 dp phone', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'training.benchmarks': '[$_allBenchmarks]',
      'training.readiness':
          '[{"date":"2026-10-26T18:00:00.000","tool":"Photon","pulls":['
          '{"hand":"left","forceKg":19,"benchmarkKg":20},'
          '{"hand":"right","forceKg":27,"benchmarkKg":30}]}]',
    });
    final warmup = _FixedWarmup(const WarmupState());
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        measurement: const MeasurementState(isMeasuring: true, currentKg: 19),
      ),
      deviceTools: false,
      overrides: [warmupProvider.overrideWith(() => warmup)],
    );
    await _openPage(tester, 'Warm-up');
    // Rendering would fail on an overflow.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    await _select(tester, 'Before training');
    await tester.tap(find.text('Heavy session'));
    await tester.pumpAndSettle();

    for (final phase in [WorkoutPhase.rest, WorkoutPhase.hold]) {
      warmup.set(
        WarmupState(
          kind: WarmupKind.climbing,
          steps: const [warmupStep, warmupStep],
          phase: phase,
          step: 1,
          restRemainingSeconds: 10,
          holding: true,
        ),
      );
      await tester.pump();
    }
    expect(find.text('Spark · Left hand'), findsOne);
  });

  for (final recording in [false, true]) {
    testWidgets(
      '${recording ? 'blocks' : 'offers'} a readiness check after a climbing '
      'warm-up${recording ? ' while a benchmark records' : ''}',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'training.benchmarks': '[$_allBenchmarks]',
        });
        await _pumpScreen(
          tester,
          ProgressorState(connection: _connected),
          deviceTools: false,
          overrides: [
            benchmarkRecorderProvider.overrideWith(
              () => _Recorded(20, recording: recording),
            ),
            warmupProvider.overrideWith(
              () => _FixedWarmup(
                const WarmupState(
                  kind: WarmupKind.climbing,
                  steps: [warmupStep],
                  phase: WorkoutPhase.done,
                  bestKg: [null],
                ),
              ),
            ),
          ],
        );

        expect(find.byType(NavigationBar), findsOne);
        await _openPage(tester, 'Warm-up');
        expect(find.text('Warm-up complete'), findsOne);
        final check = find.widgetWithText(FilledButton, 'Readiness Check');
        await tester.ensureVisible(check);
        expect(
          tester.widget<FilledButton>(check).onPressed != null,
          !recording,
        );
      },
    );
  }

  for (final (remaining, message, clock) in [
    (75, 'Rest before your workout', '01:15'),
    (0, 'Rested: start your workout.', '00:00'),
  ]) {
    testWidgets('shows the rest before the workout at $clock', (tester) async {
      await _pumpScreen(
        tester,
        ProgressorState(connection: _connected),
        deviceTools: false,
        overrides: [
          warmupProvider.overrideWith(
            () => _FixedWarmup(
              WarmupState(
                kind: WarmupKind.training,
                steps: const [warmupStep],
                phase: WorkoutPhase.done,
                bestKg: const [null],
                restRemainingSeconds: remaining,
              ),
            ),
          ),
        ],
      );
      await _openPage(tester, 'Warm-up');

      expect(find.text('Warm-up complete'), findsOne);
      expect(find.text(message), findsOne);
      expect(find.text(clock), findsOne);
      expect(find.text('Go to Workout'), findsOne);
    });
  }

  testWidgets('shows a readiness check result', (tester) async {
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
      overrides: [
        warmupProvider.overrideWith(
          () => _FixedWarmup(
            WarmupState(
              kind: WarmupKind.readiness,
              steps: [
                for (final hand in Hand.values)
                  (
                    tool: 'Photon',
                    hand: hand,
                    benchmarkKg: 30.0,
                    forceKg: null,
                    seconds: 6,
                    restSeconds: 15,
                  ),
              ],
              phase: WorkoutPhase.done,
              bestKg: const [28.5, null],
              saved: true,
            ),
          ),
        ),
      ],
    );

    await _openPage(tester, 'Warm-up');
    expect(find.text('Readiness check complete'), findsOne);
    expect(
      find.text('Left: 95% of your benchmark, 28.5 kg of 30.0 kg'),
      findsOne,
    );
    expect(find.text('Right: held under 5 s, not measured'), findsOne);
    expect(find.text('Saved to your readiness history.'), findsOne);
  });

  testWidgets('lists the readiness checks and deletes one', (tester) async {
    String check(String date, double left, double right) =>
        '{"date":"$date","tool":"Photon","pulls":['
        '{"hand":"left","forceKg":$left,"benchmarkKg":20},'
        '{"hand":"right","forceKg":$right,"benchmarkKg":30}]}';
    SharedPreferences.setMockInitialValues({
      'training.readiness':
          '[${check('2026-10-26T18:00:00.000', 19, 27)},'
          '${check('2026-10-27T18:00:00.000', 18, 30)}]',
    });
    await _pumpScreen(
      tester,
      ProgressorState(connection: _connected),
      deviceTools: false,
    );
    await _openPage(tester, 'Warm-up');

    // The newest first, against the previous check.
    final latest = find.text(
      'Left 90% (18.0 kg) · -5 pts vs previous\n'
      'Right 100% (30.0 kg) · +10 pts vs previous',
    );
    await tester.ensureVisible(latest);
    expect(latest, findsOne);
    expect(find.text('Left 95% (19.0 kg)\nRight 90% (27.0 kg)'), findsOne);

    await tester.tap(find.byTooltip('Delete readiness check').first);
    await tester.pumpAndSettle();
    expect(find.text('Delete the readiness check?'), findsOne);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(latest, findsNothing);
    final readiness = (await ProviderScope.containerOf(
      tester.element(find.byType(CrimpdeqScreen)),
    ).read(trainingLogProvider.future)).readiness;
    expect(readiness.single.date, DateTime(2026, 10, 26, 18));
  });
}

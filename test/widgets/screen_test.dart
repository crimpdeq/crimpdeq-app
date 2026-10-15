import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:crimpdeq/screens/crimpdeq_screen.dart';
import 'package:crimpdeq/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves a fixed state and records the commands instead of using Bluetooth.
class _FakeProgressor extends ProgressorNotifier {
  _FakeProgressor(this.initialState);

  final ProgressorState initialState;
  final calls = <String>[];

  @override
  ProgressorState build() => initialState;

  @override
  void resetMeasurement() => calls.add('reset');

  @override
  Future<void> tareScale() async => calls.add('tare');
}

const _deviceId = '00:11:22:33:44:55';

final _connected = DeviceConnection(
  device: BluetoothDevice.fromId(_deviceId),
  writeCharacteristic: BluetoothCharacteristic(
    remoteId: const DeviceIdentifier(_deviceId),
    serviceUuid: Guid(progressorServiceUuid),
    characteristicUuid: Guid(progressorWriteCharUuid),
  ),
  bluetoothReady: true,
  status: 'Connected to Progressor',
);

Future<_FakeProgressor> _pumpScreen(
  WidgetTester tester,
  ProgressorState state,
) async {
  final fake = _FakeProgressor(state);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [progressorProvider.overrideWith(() => fake)],
      child: MaterialApp(theme: buildDarkTheme(), home: const CrimpdeqScreen()),
    ),
  );
  return fake;
}

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

  testWidgets('shows the device status with the battery charge', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      ProgressorState(
        connection: _connected,
        deviceInfo: const DeviceInfo(
          firmwareVersion: '1.2.3',
          batteryMillivolts: 3840,
        ),
      ),
    );

    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Firmware: 1.2.3'), findsOneWidget);
    expect(find.text('Battery: ~50% (3.84 V)'), findsOneWidget);
    expect(find.text('Disconnect'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
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

    expect(find.text('Battery: 21%, charging (3.84 V)'), findsOneWidget);
  });

  for (final (name, physicalSize, pixelRatio, fitsWholeLines) in [
    ('394 dp phone', const Size(1280, 2772), 3.25, true),
    ('360 dp phone', const Size(1080, 2340), 3.0, false),
  ]) {
    testWidgets('keeps the status clear of the title on a $name', (
      tester,
    ) async {
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

      final titleLeft = tester.getRect(find.byType(Image)).left;
      for (final line in [
        'Connected',
        'FW: 2.0.4',
        'Bat: ~25%',
        'Bat: 3.75 V',
      ]) {
        final text = find.text(line);
        expect(
          tester.getRect(text).right,
          lessThanOrEqualTo(titleLeft),
          reason: line,
        );
        if (fitsWholeLines) {
          expect(
            tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
            isFalse,
            reason: '$line is truncated',
          );
        }
      }
    });
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

    expect(find.text('Current Calibration Factor: 1.000000'), findsOneWidget);
    expect(find.textContaining('Max error 0.300 kg (1.50%'), findsOneWidget);
    expect(find.text('-0.300'), findsOneWidget);
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
}

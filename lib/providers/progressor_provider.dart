import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../analysis/calibration_check.dart';
import '../analysis/force_stats.dart';
import '../analysis/steady_load.dart';
import '../analysis/timestamp_unwrapper.dart';
import '../constants/progressor_constants.dart';
import '../models/progressor_models.dart';
import '../protocol/progressor_protocol.dart';

part 'progressor_provider.g.dart';

enum CalibrationPointResult {
  added,
  notSteady,
  readingUnchanged,
  noMeasurements,
  limitReached,
  sendFailed,
  disconnected,
}

@riverpod
class ProgressorNotifier extends _$ProgressorNotifier {
  static const _uiUpdateInterval = Duration(milliseconds: 66);
  static const _commandResponseTimeout = Duration(seconds: 2);
  static const _batteryPollInterval = Duration(minutes: 1);
  // The firmware sends the samples taken before a tare, then pauses 200 ms to
  // tare. Clearing after that keeps those samples out of the new window.
  static const _tareSettleDelay = Duration(milliseconds: 300);
  // Firmware before 2.1 stops measuring after a tare and ignores a start that
  // arrives while it still tares, up to 1.6 s. Restart until samples follow.
  static const _tareResumeTimeout = Duration(milliseconds: 700);
  static const _tareResumeAttempts = 3;
  static const _steadyLoadTimeout = Duration(seconds: 15);
  // The device clock restarts at each start and passes half its u32 range,
  // where a jump back starts to look like a wrap, only after this long.
  static const _clockRestartWindow = Duration(microseconds: 0x80000000);

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _notifySubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  Timer? _batteryTimer;
  // Counts closed connections, so a read that outlives its connection stops
  // instead of continuing on the next one.
  int _connectionId = 0;

  var _frameReader = FrameReader();
  // Requests whose responses share one response code, answered in order.
  final _commandResponses = Queue<Completer<Uint8List>>();

  var _timestamps = TimestampUnwrapper();
  final _sinceStart = Stopwatch();
  // Device time of the latest sample, and of the start of the window, which a
  // tare or reset moves without restarting the device clock.
  int _lastDeviceUs = 0;
  int _windowStartUs = 0;
  var _stats = ForceStats();
  final _pendingSamples = <WeightMeasurement>[];
  final _lastSecondTimestamps = Queue<int>();
  final _notifyIntervalsMs = <double>[];
  DateTime? _lastNotifyTime;
  DateTime? _lastPublishTime;
  int _packetCount = 0;

  SteadyLoadDetector? _steadyLoad;
  Completer<bool>? _steadyLoadReached;
  // Steady reading of the last point sent, in tared ADC counts, to catch a
  // weight that was not hung.
  ({double weightKg, double counts})? _lastPointReading;

  @override
  ProgressorState build() {
    ref.onDispose(() {
      _adapterStateSubscription?.cancel();
      _isScanningSubscription?.cancel();
      _scanSubscription?.cancel();
      _closeConnection();
    });

    _initializeBle();
    return const ProgressorState();
  }

  void _log(String message) {
    debugPrint('[ProgressorNotifier] $message');
  }

  Future<void> _initializeBle() async {
    if (!await FlutterBluePlus.isSupported) {
      state = state.copyWith.connection(
        status: 'Bluetooth not supported on this device',
      );
      return;
    }

    _isScanningSubscription = FlutterBluePlus.isScanning.listen(
      (scanning) => state = state.copyWith.connection(isScanning: scanning),
    );
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen(
      _onAdapterStateChanged,
    );
  }

  void _onAdapterStateChanged(BluetoothAdapterState adapterState) {
    switch (adapterState) {
      case BluetoothAdapterState.on:
        final connection = state.connection;
        state = state.copyWith.connection(
          bluetoothReady: true,
          needsSettings: false,
          status: connection.device == null
              ? 'Bluetooth ready - Press scan button'
              : connection.status,
        );
      case BluetoothAdapterState.unauthorized:
        _resetConnection(
          'Bluetooth permission denied. Allow it in the app settings.',
          bluetoothReady: false,
          needsSettings: true,
        );
      case BluetoothAdapterState.unknown || BluetoothAdapterState.turningOn:
        _resetConnection('Initializing Bluetooth...', bluetoothReady: false);
      case BluetoothAdapterState.unavailable:
        _resetConnection('Bluetooth unavailable', bluetoothReady: false);
      case BluetoothAdapterState.off || BluetoothAdapterState.turningOff:
        _resetConnection('Please turn on Bluetooth', bluetoothReady: false);
    }
  }

  /// Scans for devices advertising the Progressor service. flutter_blue_plus
  /// requests the Bluetooth permissions each Android version needs.
  Future<void> startScanning() async {
    final connection = state.connection;
    if (!connection.bluetoothReady ||
        connection.isScanning ||
        connection.device != null) {
      return;
    }

    state = state.copyWith.connection(
      discoveredDevices: const [],
      needsSettings: false,
      status: 'Scanning for devices...',
    );
    _scanSubscription ??= FlutterBluePlus.onScanResults.listen(_onScanResults);

    try {
      await FlutterBluePlus.startScan(
        timeout: AppConstants.scanTimeout,
        withServices: [Guid(progressorServiceUuid)],
        webOptionalServices: [Guid(progressorServiceUuid)],
      );
      await FlutterBluePlus.isScanning.firstWhere((scanning) => !scanning);
    } catch (e) {
      state = state.copyWith.connection(
        needsSettings: !kIsWeb,
        status: 'Scan failed: $e',
      );
      return;
    }

    // Bluetooth turned off or a connection started during the scan.
    final afterScan = state.connection;
    if (!afterScan.bluetoothReady ||
        afterScan.device != null ||
        afterScan.isConnecting) {
      return;
    }
    state = state.copyWith.connection(
      status: afterScan.discoveredDevices.isEmpty
          ? 'No compatible devices found. Please try scanning again.'
          : 'Scan complete. Select a device to connect.',
    );
  }

  void _onScanResults(List<ScanResult> results) {
    if (state.connection.device != null || state.connection.isConnecting) {
      return;
    }

    // Sorted by name and ID so the list does not reorder as the RSSI changes.
    final devices = [for (final result in results) _toDiscoveredDevice(result)]
      ..sort((a, b) {
        final byName = a.name.compareTo(b.name);
        return byName != 0 ? byName : a.id.compareTo(b.id);
      });
    state = state.copyWith.connection(
      discoveredDevices: devices,
      status: devices.isEmpty
          ? 'Scanning for devices...'
          : 'Found ${devices.length} device${devices.length == 1 ? '' : 's'}. '
                'Select one to connect.',
    );
  }

  DiscoveredDevice _toDiscoveredDevice(ScanResult result) {
    final name = [
      result.device.platformName,
      result.advertisementData.advName,
    ].map((name) => name.trim()).where((name) => name.isNotEmpty).firstOrNull;
    return DiscoveredDevice(
      id: result.device.remoteId.str,
      name: name ?? 'Unknown device',
      rssi: result.rssi,
      device: result.device,
    );
  }

  Future<void> connect(DiscoveredDevice discovered) async {
    if (state.connection.device != null || state.connection.isConnecting) {
      return;
    }

    state = state.copyWith.connection(
      isConnecting: true,
      status: 'Connecting to ${discovered.name}...',
    );
    final device = discovered.device;
    try {
      await FlutterBluePlus.stopScan();
      await device.connect(license: License.nonprofit);
      state = state.copyWith(
        connection: state.connection.copyWith(
          device: device,
          status: 'Discovering services...',
        ),
        deviceInfo: const DeviceInfo(),
      );

      final service = (await device.discoverServices())
          .where((service) => service.uuid == Guid(progressorServiceUuid))
          .firstOrNull;
      BluetoothCharacteristic? characteristic(String uuid) => service
          ?.characteristics
          .where((characteristic) => characteristic.uuid == Guid(uuid))
          .firstOrNull;
      final notifyChar = characteristic(progressorNotifyCharUuid);
      final writeChar = characteristic(progressorWriteCharUuid);
      if (notifyChar == null || writeChar == null) {
        await _failConnection(device, 'Progressor service not found');
        return;
      }

      _connectionSubscription = device.connectionState.listen((
        connectionState,
      ) {
        if (connectionState == BluetoothConnectionState.disconnected) {
          _resetConnection('Device disconnected');
        }
      });
      await _subscribeToNotifications(device, notifyChar);
      state = state.copyWith.connection(
        writeCharacteristic: writeChar,
        isConnecting: false,
        status: 'Connected to ${discovered.name}',
      );
    } catch (e) {
      await _failConnection(device, 'Connection failed: $e');
      return;
    }

    await _readDeviceInfo();
  }

  Future<void> _failConnection(BluetoothDevice device, String status) async {
    _resetConnection(status);
    await device.disconnect().catchError(
      (Object e) => _log('Disconnect after failed setup: $e'),
    );
  }

  Future<void> disconnect() async {
    final device = state.connection.device;
    if (device == null) return;

    try {
      await device.disconnect();
    } catch (e) {
      state = state.copyWith.connection(status: 'Disconnect failed: $e');
      return;
    }
    _resetConnection('Disconnected');
  }

  /// Drops the connection and every value read from the device, except the
  /// low battery warning: the device turns off after it, until it is charged.
  void _resetConnection(
    String status, {
    bool? bluetoothReady,
    bool needsSettings = false,
  }) {
    _closeConnection();
    state = ProgressorState(
      connection: DeviceConnection(
        bluetoothReady: bluetoothReady ?? state.connection.bluetoothReady,
        needsSettings: needsSettings,
        status: status,
      ),
      deviceInfo: DeviceInfo(lowBattery: state.deviceInfo.lowBattery),
    );
  }

  void _closeConnection() {
    _connectionId++;
    _notifySubscription?.cancel();
    _notifySubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _batteryTimer?.cancel();
    _batteryTimer = null;
    // Pending requests time out.
    _commandResponses.clear();
    final steadyLoadReached = _steadyLoadReached;
    if (steadyLoadReached != null && !steadyLoadReached.isCompleted) {
      steadyLoadReached.complete(false);
    }
    _lastPointReading = null;
    _frameReader = FrameReader();
    _resetMeasurementRuntime();
  }

  Future<void> _subscribeToNotifications(
    BluetoothDevice device,
    BluetoothCharacteristic characteristic,
  ) async {
    // Listen before enabling notifications to avoid missing early packets.
    final notifications = kIsWeb
        ? _webNotifications(device, characteristic)
        : characteristic.onValueReceived;
    _notifySubscription = notifications.listen(_onNotification);
    await characteristic.setNotifyValue(true);
  }

  /// Web Bluetooth does not match the characteristic instance reliably, so
  /// match the notifications by device, service and characteristic UUIDs.
  Stream<List<int>> _webNotifications(
    BluetoothDevice device,
    BluetoothCharacteristic characteristic,
  ) => FlutterBluePlus.events.onCharacteristicReceived
      .where(
        (event) =>
            event.error == null &&
            event.device.remoteId == device.remoteId &&
            event.characteristic.serviceUuid == characteristic.serviceUuid &&
            event.characteristic.uuid == characteristic.uuid,
      )
      .map((event) => event.value);

  void _onNotification(List<int> notification) {
    // Native platforms deliver one frame per notification, so a malformed one
    // is dropped alone instead of swallowing the next ones.
    final List<Frame> frames;
    if (kIsWeb) {
      frames = _frameReader.add(notification);
    } else if (parseFrame(notification) case final frame?) {
      frames = [frame];
    } else {
      _log('Ignoring malformed notification: $notification');
      return;
    }
    for (final frame in frames) {
      final ProgressorMessage message;
      try {
        message = decodeMessage(frame);
      } on FormatException catch (e) {
        _log('Ignoring frame: ${e.message}');
        continue;
      }
      _handleMessage(message);
    }
  }

  void _handleMessage(ProgressorMessage message) {
    switch (message) {
      case WeightSamples(:final samples):
        _onWeightSamples(samples);
      case CommandResponse(:final payload):
        if (_commandResponses.isEmpty) {
          _log('Ignoring unrequested command response: $payload');
          return;
        }
        _commandResponses.removeFirst().complete(payload);
      case LowPowerWarning():
        state = state.copyWith.deviceInfo(lowBattery: true);
      case CalibrationFactor(:final factor):
        // The stored points follow the factor.
        state = state.copyWith.calibration(factor: factor, points: const []);
      case CalibrationPointMessage(:final raw, :final weightKg):
        state = state.copyWith.calibration(
          points: [...state.calibration.points, (raw: raw, weightKg: weightKg)],
        );
      case SampleRate(:final samplesPerSecond):
        state = state.copyWith.deviceInfo(sampleRate: samplesPerSecond);
      case BatteryStatus(:final percent, :final charging):
        state = state.copyWith.deviceInfo(
          batteryPercent: percent,
          batteryCharging: charging,
        );
    }
  }

  void _onWeightSamples(List<RawWeightSample> rawSamples) {
    // Drop the samples still in flight after a stop.
    if (rawSamples.isEmpty || !state.measurement.isMeasuring) return;

    final now = DateTime.now();
    final lastNotifyTime = _lastNotifyTime;
    if (lastNotifyTime != null) {
      _notifyIntervalsMs.add(
        now.difference(lastNotifyTime).inMicroseconds /
            Duration.microsecondsPerMillisecond,
      );
      if (_notifyIntervalsMs.length > AppConstants.maxIntervalHistorySize) {
        _notifyIntervalsMs.removeAt(0);
      }
    }
    _lastNotifyTime = now;
    _packetCount++;

    final samples = <WeightMeasurement>[];
    for (final rawSample in rawSamples) {
      // Soon after a start, a jump back is the device restarting its clock,
      // not a wrap: the samples so far were still in flight from the previous
      // measurement.
      final lastRawUs = _timestamps.lastRawUs;
      if (lastRawUs != null &&
          rawSample.timestampUs < lastRawUs &&
          _sinceStart.elapsed < _clockRestartWindow) {
        _resetTimeline();
        samples.clear();
        state = state.copyWith(
          measurement: const MeasurementState(isMeasuring: true),
        );
      }
      _lastDeviceUs = _timestamps.unwrap(rawSample.timestampUs);
      _lastSecondTimestamps.addLast(_lastDeviceUs);
      final sample = WeightMeasurement(
        weightKg: rawSample.weightKg,
        timestampUs: _lastDeviceUs - _windowStartUs,
      );
      _stats.add(sample);
      samples.add(sample);
    }
    while (_lastDeviceUs - _lastSecondTimestamps.first >
        Duration.microsecondsPerSecond) {
      _lastSecondTimestamps.removeFirst();
    }

    final steadyLoadReached = _steadyLoadReached;
    if (steadyLoadReached != null &&
        !steadyLoadReached.isCompleted &&
        _steadyLoad!.add(samples)) {
      steadyLoadReached.complete(true);
    }

    // Process every sample, but publish state on a throttled cadence.
    _pendingSamples.addAll(samples);
    final lastPublishTime = _lastPublishTime;
    if (lastPublishTime != null &&
        now.difference(lastPublishTime) < _uiUpdateInterval) {
      return;
    }
    _lastPublishTime = now;
    _publishSamples();
    state = state.copyWith(
      performance: PerformanceMetrics(
        currentHz: _lastSecondTimestamps.length.toDouble(),
        currentNotifyIntervalMs: _notifyIntervalsMs.lastOrNull ?? 0,
        dataPacketCount: _packetCount,
        samplesPerPacket: samples.length,
        notifyIntervalHistory: List.of(_notifyIntervalsMs),
      ),
    );
  }

  /// Moves the throttled samples into the measurement state. The stats cover
  /// every sample, and the chart plots each batch mean so it does not alias.
  void _publishSamples() {
    if (_pendingSamples.isEmpty) return;

    final samples = List.of(_pendingSamples);
    _pendingSamples.clear();
    double mean(Iterable<double> values) =>
        values.reduce((a, b) => a + b) / samples.length;

    final measurement = state.measurement;
    final history = [
      ...measurement.weightHistory,
      FlSpot(
        mean(samples.map((sample) => sample.timestampSec)),
        mean(samples.map((sample) => sample.weightKg)),
      ),
    ];
    final excess = history.length - AppConstants.maxHistorySize;
    state = state.copyWith(
      measurement: measurement.copyWith(
        currentKg: samples.last.weightKg,
        minKg: _stats.minKg,
        peakKg: _stats.peakKg,
        peakRfdKgPerS: _stats.peakRfdKgPerS,
        elapsedUs: samples.last.timestampUs,
        weightHistory: excess > 0 ? history.sublist(excess) : history,
        receivedData: [
          ...samples.reversed,
          ...measurement.receivedData,
        ].take(AppConstants.maxReceivedDataSize).toList(),
      ),
    );
  }

  void _resetTimeline() {
    _timestamps = TimestampUnwrapper();
    _lastDeviceUs = 0;
    _windowStartUs = 0;
    _stats = ForceStats();
    _pendingSamples.clear();
    _lastSecondTimestamps.clear();
  }

  void _resetMeasurementRuntime() {
    _resetTimeline();
    _notifyIntervalsMs.clear();
    _lastNotifyTime = null;
    _lastPublishTime = null;
    _packetCount = 0;
  }

  Future<bool> _send(
    ControlOpCode opCode, [
    List<int> payload = const [],
  ]) async {
    final writeChar = state.connection.writeCharacteristic;
    if (writeChar == null) {
      _log('Cannot send ${opCode.name}: not connected');
      return false;
    }

    try {
      // Prefer acknowledged writes, which the Crimpdeq firmware supports.
      await writeChar.write([
        opCode.value,
        ...payload,
      ], withoutResponse: !writeChar.properties.write);
      return true;
    } catch (e) {
      _log('Failed to send ${opCode.name}: $e');
      if (state.connection.writeCharacteristic == writeChar) {
        state = state.copyWith.connection(
          status: 'Failed to send ${opCode.name}: $e',
        );
      }
      return false;
    }
  }

  /// Sends a request answered by a command response. Returns null when the
  /// request fails or the device does not answer.
  Future<Uint8List?> _request(ControlOpCode opCode) async {
    final response = Completer<Uint8List>();
    _commandResponses.add(response);
    if (!await _send(opCode)) {
      _commandResponses.remove(response);
      return null;
    }

    try {
      return await response.future.timeout(_commandResponseTimeout);
    } on TimeoutException {
      _commandResponses.remove(response);
      _log('No response to ${opCode.name}');
      return null;
    }
  }

  Future<void> _readDeviceInfo() async {
    final connectionId = _connectionId;
    final version = await _request(ControlOpCode.getAppVersion);
    if (connectionId != _connectionId) return;
    if (version != null) {
      state = state.copyWith.deviceInfo(
        firmwareVersion: utf8.decode(version, allowMalformed: true).trim(),
      );
    }
    await _readBattery();
    if (connectionId != _connectionId) return;
    await getCalibration();
    if (connectionId != _connectionId) return;
    await _send(ControlOpCode.getSampleRate);
    if (connectionId != _connectionId) return;
    _batteryTimer = Timer.periodic(_batteryPollInterval, (_) => _readBattery());
  }

  Future<void> _readBattery() async {
    // A Tindeq Progressor must stop measuring before it samples the battery.
    if (state.measurement.isMeasuring) return;
    final connectionId = _connectionId;
    final payload = await _request(ControlOpCode.sampleBattery);
    if (payload == null || connectionId != _connectionId) return;

    // Before the next await, so a reconnect cannot receive this reading.
    try {
      state = state.copyWith.deviceInfo(
        batteryMillivolts: decodeBatteryMillivolts(payload),
      );
    } on FormatException catch (e) {
      _log('Invalid battery response: ${e.message}');
    }
    await _send(ControlOpCode.getBatteryStatus);
  }

  Future<void> startMeasurement() async {
    // Mark it started before the write, so a second tap cannot start again.
    state = state.copyWith.measurement(isMeasuring: true);
    if (!await _send(ControlOpCode.startMeasurement)) {
      state = state.copyWith.measurement(isMeasuring: false);
      return;
    }
    // The device restarts its clock, so start a new timeline. Samples that
    // arrive before the write completes belong to the previous measurement,
    // and so do any that arrive after it until the clock moves back.
    _resetMeasurementRuntime();
    _sinceStart
      ..reset()
      ..start();
    state = state.copyWith(
      measurement: const MeasurementState(isMeasuring: true),
      performance: const PerformanceMetrics(),
    );
  }

  Future<void> stopMeasurement() async {
    if (!await _send(ControlOpCode.stopMeasurement)) return;
    _publishSamples();
    state = state.copyWith.measurement(isMeasuring: false);
  }

  /// Tares on the device, which keeps measuring, and starts a new window.
  Future<void> tareScale() async {
    if (!await _send(ControlOpCode.tareScale)) return;
    // The tare moves the readings.
    _lastPointReading = null;
    await Future<void>.delayed(_tareSettleDelay);
    resetMeasurement();

    for (var attempt = 0; attempt < _tareResumeAttempts; attempt++) {
      final packets = _packetCount;
      await Future<void>.delayed(_tareResumeTimeout);
      if (!state.measurement.isMeasuring || _packetCount != packets) return;
      _log('No samples after the tare, restarting the measurement');
      await startMeasurement();
    }
  }

  /// Starts a new measurement window without changing the device.
  void resetMeasurement() {
    _windowStartUs = _lastDeviceUs;
    _stats = ForceStats();
    _pendingSamples.clear();
    state = state.copyWith(
      measurement: MeasurementState(isMeasuring: state.measurement.isMeasuring),
    );
  }

  /// Waits for the load to hold steady, then adds the calibration point. The
  /// firmware samples the point itself, after the steady check.
  Future<CalibrationPointResult> addCalibrationPoint(double weightKg) async {
    if (state.calibration.waitingForSteadyLoad) {
      throw StateError('Already waiting for a steady load');
    }
    if (state.calibration.points.length >= maxCalibrationPoints) {
      return CalibrationPointResult.limitReached;
    }

    // Lock until the point is sent, so a second point or a reset cannot
    // interleave with it.
    state = state.copyWith.calibration(waitingForSteadyLoad: true);
    try {
      return await _addSteadyCalibrationPoint(weightKg);
    } finally {
      state = state.copyWith.calibration(waitingForSteadyLoad: false);
    }
  }

  /// Ends the measurement after the steady check, also one the user started:
  /// firmware before 2.1 stops streaming to sample the point.
  Future<CalibrationPointResult> _addSteadyCalibrationPoint(
    double weightKg,
  ) async {
    if (!state.measurement.isMeasuring) {
      await startMeasurement();
      if (!state.measurement.isMeasuring) {
        return CalibrationPointResult.sendFailed;
      }
    }
    final steadyLoad = _steadyLoad = SteadyLoadDetector();
    final steadyLoadReached = _steadyLoadReached = Completer<bool>();
    final steady = await steadyLoadReached.future.timeout(
      _steadyLoadTimeout,
      onTimeout: () => false,
    );
    _steadyLoad = null;
    _steadyLoadReached = null;

    if (!state.connection.isConnected) {
      return CalibrationPointResult.disconnected;
    }
    await stopMeasurement();
    if (!steady) {
      return steadyLoad.receivedSamples
          ? CalibrationPointResult.notSteady
          : CalibrationPointResult.noMeasurements;
    }

    // The device reports kg = counts * factor / 1000. Without a factor yet,
    // the readings cannot be compared.
    final factor = state.calibration.factor;
    final counts = factor == null
        ? null
        : steadyLoad.steadyLoadKg! * 1000 / factor;
    final previous = _lastPointReading;
    if (previous != null &&
        factor != null &&
        counts != null &&
        isReadingUnchanged(
          previousWeightKg: previous.weightKg,
          previousCounts: previous.counts,
          weightKg: weightKg,
          counts: counts,
          factor: factor,
        )) {
      return CalibrationPointResult.readingUnchanged;
    }

    if (!await _send(
      ControlOpCode.addCalibrationPoint,
      encodeFloat32(weightKg),
    )) {
      return CalibrationPointResult.sendFailed;
    }
    _lastPointReading = counts == null
        ? null
        : (weightKg: weightKg, counts: counts);
    // The firmware reports the points only once two of them define a
    // calibration, so read them back.
    await getCalibration();
    return CalibrationPointResult.added;
  }

  Future<void> getCalibration() => _send(ControlOpCode.getCalibration);

  /// Reads the calibration back, because the firmware clears its points even
  /// when it fails to store the default factor and skips the notification.
  Future<void> defaultCalibration() async {
    if (!await _send(ControlOpCode.defaultCalibration)) return;
    _lastPointReading = null;
    await getCalibration();
  }

  Future<void> setSampleRate(int samplesPerSecond) =>
      _send(ControlOpCode.setSampleRate, encodeUint16(samplesPerSecond));
}

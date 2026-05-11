import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:crimpdeq_protocol/crimpdeq_protocol.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/progressor_constants.dart';
import '../models/progressor_models.dart';
import '../models/session_models.dart';
import 'session_provider.dart';

part 'progressor_provider.g.dart';

// ── BleTransport backed by flutter_blue_plus ──────────────────────

class _FlutterBluePlusTransport implements BleTransport {
  final BluetoothCharacteristic _writeChar;

  _FlutterBluePlusTransport(this._writeChar);

  @override
  Future<void> write(List<int> data) async {
    final supportsWrite = _writeChar.properties.write;
    final supportsWriteNoResponse = _writeChar.properties.writeWithoutResponse;
    if (!supportsWrite && !supportsWriteNoResponse) {
      throw StateError('Write characteristic is not writable');
    }

    final preferredWithoutResponse = !supportsWrite;
    try {
      await _writeChar.write(data, withoutResponse: preferredWithoutResponse);
    } catch (e) {
      final canRetry = (preferredWithoutResponse && supportsWrite) ||
          (!preferredWithoutResponse && supportsWriteNoResponse);
      if (!canRetry) rethrow;
      await _writeChar.write(data, withoutResponse: !preferredWithoutResponse);
    }
  }
}

// ── Notifier ──────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class ProgressorNotifier extends _$ProgressorNotifier {
  static const Duration _uiUpdateInterval = Duration(milliseconds: 66);
  static const Duration _commandSettleDelay = Duration(milliseconds: 120);
  static const Duration _resumeCheckDelay = Duration(milliseconds: 300);

  StreamSubscription? _scanSubscription;
  StreamSubscription? _notifySubscription;
  StreamSubscription? _notifyEventSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<ProgressorEvent>? _protocolSubscription;
  StreamSubscription? _craneScaleScanSubscription;
  Timer? _scanTimeoutTimer;
  Timer? _craneScaleWatchdogTimer;
  Timer? _simulatorTimer;
  int _simulatorTimestampUs = 0;
  DateTime? _simulatorStartTime;
  DateTime? _craneScaleStartTime;
  double _craneScaleTareOffset = 0.0;
  final _simulatorRng = Random();
  ProtocolConfig? _simulatorConfig;
  DateTime? _lastNotifyTime;
  DateTime? _lastUiUpdateTime;
  DateTime? _lastMeasurementReceivedAt;
  final List<WeightMeasurement> _recentMeasurements = [];
  final List<WeightMeasurement> _pendingMeasurements = [];
  final List<double> _notifyIntervalHistory = [];
  // Internal mutable lists — avoids List.from() copies on every UI publish
  final List<FlSpot> _weightHistory = [];
  final List<WeightMeasurement> _receivedData = [];
  double _currentNotifyIntervalMs = 0.0;
  int _dataPacketCount = 0;
  double? _calibrationFactor;
  final Map<String, ScanResult> _scanResultCache = {};
  final List<List<double>> _calibrationPoints = [];

  ProgressorProtocol? _protocol;

  @override
  ProgressorState build() {
    ref.onDispose(() {
      _simulatorTimer?.cancel();
      _simulatorTimer = null;
      _craneScaleWatchdogTimer?.cancel();
      _craneScaleWatchdogTimer = null;
      _craneScaleScanSubscription?.cancel();
      _craneScaleScanSubscription = null;
      _cleanupSubscriptions();
      _cancelScanTimeoutTimer();
      _adapterStateSubscription?.cancel();
      _adapterStateSubscription = null;
      _protocol?.dispose();
      _protocol = null;
    });

    _initializeBle();
    return const ProgressorState();
  }

  void _log(String message) {
    debugPrint('[ProgressorNotifier] $message');
  }

  // ── Protocol event handler ─────────────────────────────────────

  void _handleProtocolEvent(ProgressorEvent event) {
    switch (event) {
      case WeightEvent():
        _handleWeightMeasurements(event.measurements);
      case FirmwareVersionEvent():
        _log('Firmware version: ${event.version}');
        state = state.copyWith(
          deviceInfo:
              state.deviceInfo.copyWith(firmwareVersion: event.version),
        );
      case BatteryVoltageEvent():
        _log('Battery voltage: ${event.millivolts} mV');
        state = state.copyWith(
          deviceInfo: state.deviceInfo.copyWith(
            batteryVoltage: event.millivolts.toString(),
          ),
        );
      case LowBatteryEvent():
        _log('Low battery warning received');
      case CalibrationFactorEvent():
        _calibrationPoints.clear();
        _calibrationFactor = event.factor;
        _updateCalibrationInfo();
      case CalibrationPointEvent():
        _appendCalibrationPoint(event.valueA, event.valueB);
        _updateCalibrationInfo();
    }
  }

  // ── Weight measurement UI handling ─────────────────────────────

  void _handleWeightMeasurements(List<WeightMeasurement> newMeasurements) {
    if (newMeasurements.isEmpty) return;

    final now = DateTime.now();
    _lastMeasurementReceivedAt = now;

    // Performance tracking
    if (_lastNotifyTime != null) {
      final currentNotifyIntervalMs =
          now.difference(_lastNotifyTime!).inMicroseconds / 1000.0;
      _currentNotifyIntervalMs = currentNotifyIntervalMs;
      _notifyIntervalHistory.add(currentNotifyIntervalMs);
      if (_notifyIntervalHistory.length > AppConstants.maxIntervalHistorySize) {
        _notifyIntervalHistory.removeAt(0);
      }
    }
    _lastNotifyTime = now;

    final samplesPerPacket = newMeasurements.length;

    for (final m in newMeasurements) {
      _recentMeasurements.add(m);
    }

    _dataPacketCount++;

    _pendingMeasurements.addAll(newMeasurements);
    final shouldPublish =
        _lastUiUpdateTime == null ||
        now.difference(_lastUiUpdateTime!) >= _uiUpdateInterval;
    if (!shouldPublish) return;
    _lastUiUpdateTime = now;

    final lastMeasurement = _pendingMeasurements.last;

    // Mutate internal lists in-place, then snapshot for state
    _weightHistory.add(FlSpot(lastMeasurement.timestampSec, lastMeasurement.weight));
    if (_weightHistory.length > AppConstants.maxHistorySize) {
      _weightHistory.removeAt(0);
    }

    // Prepend pending (reversed) to received data
    _receivedData.insertAll(0, _pendingMeasurements.reversed);
    if (_receivedData.length > AppConstants.maxReceivedDataSize) {
      _receivedData.removeRange(AppConstants.maxReceivedDataSize, _receivedData.length);
    }
    _pendingMeasurements.clear();

    // Calculate Hz based on actual timestamps from device
    const oneSecondInMicroseconds = 1000000;
    if (_recentMeasurements.isNotEmpty) {
      final latestTimestamp = _recentMeasurements.last.timestampUs;
      _recentMeasurements.removeWhere(
        (measurement) =>
            (latestTimestamp - measurement.timestampUs) >
            oneSecondInMicroseconds,
      );
    }
    final currentHz = _recentMeasurements.length.toDouble();

    state = state.copyWith(
      measurement: state.measurement.copyWith(
        currentWeight: lastMeasurement.weight,
        maxWeight: lastMeasurement.weight > state.measurement.maxWeight
            ? lastMeasurement.weight
            : state.measurement.maxWeight,
        minWeight:
            state.measurement.minWeight == 0.0 ||
                lastMeasurement.weight < state.measurement.minWeight
            ? lastMeasurement.weight
            : state.measurement.minWeight,
        sampleCount: lastMeasurement.timestampUs,
        weightHistory: List.unmodifiable(_weightHistory),
        receivedData: List.unmodifiable(_receivedData),
      ),
      performance: state.performance.copyWith(
        currentNotifyIntervalMs: _currentNotifyIntervalMs,
        notifyIntervalHistory: List.unmodifiable(_notifyIntervalHistory),
        currentHz: currentHz,
        dataPacketCount: _dataPacketCount,
        samplesPerPacket: samplesPerPacket,
      ),
    );
  }

  // ── Calibration display ────────────────────────────────────────

  void _appendCalibrationPoint(double valueA, double valueB) {
    _calibrationPoints.add([valueA, valueB]);
    if (_calibrationPoints.length > 20) {
      _calibrationPoints.removeAt(0);
    }
  }

  void _updateCalibrationInfo() {
    final lines = <String>[];

    if (_calibrationFactor != null) {
      lines.add(
        'Calibration factor: ${_calibrationFactor!.toStringAsFixed(6)}',
      );
    }

    if (_calibrationPoints.isNotEmpty) {
      lines.add(
        'Calibration points: ${_calibrationPoints.map((point) => '(${point[0].toStringAsFixed(3)}, ${point[1].toStringAsFixed(3)})').join(', ')}',
      );
    }

    state = state.copyWith(
      errorMessage: lines.isEmpty ? null : lines.join('\n'),
    );
  }

  // ── BLE initialization ────────────────────────────────────────

  Future<void> _initializeBle() async {
    if (await FlutterBluePlus.isSupported == false) {
      state = state.copyWith(
        connection: state.connection.copyWith(
          status: 'Bluetooth not supported on this device',
        ),
      );
      return;
    }

    await _requestPermissions();
    await _checkBluetoothState();
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) {
      state = state.copyWith(
        connection: state.connection.copyWith(
          status: 'Browser Bluetooth ready - use scan to choose a device',
        ),
      );
      return;
    }

    state = state.copyWith(
      connection: state.connection.copyWith(
        status: 'Requesting permissions...',
      ),
    );

    try {
      if (Platform.isAndroid) {
        await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();

        final hasPermissions = await _checkAndroidPermissions();
        if (!hasPermissions) {
          state = state.copyWith(
            connection: state.connection.copyWith(
              status:
                  'Bluetooth permissions required.\nGo to Settings → App → Permissions to allow Bluetooth and Location permissions.',
            ),
          );
          return;
        }
      } else if (Platform.isIOS) {
        final status = await Permission.bluetooth.request();
        if (status != PermissionStatus.granted &&
            status != PermissionStatus.limited) {
          state = state.copyWith(
            connection: state.connection.copyWith(
              status:
                  'Bluetooth permissions required.\nGo to Settings → App → Permissions to allow Bluetooth permissions.',
            ),
          );
          return;
        }
      }
    } catch (e) {
      state = state.copyWith(
        connection: state.connection.copyWith(
          status: 'Permission request failed: $e',
        ),
      );
    }
  }

  Future<bool> _checkAndroidPermissions() async {
    final bluetoothScan = await Permission.bluetoothScan.isGranted;
    final bluetoothConnect = await Permission.bluetoothConnect.isGranted;
    final location =
        await Permission.location.isGranted ||
        await Permission.locationWhenInUse.isGranted;
    return bluetoothScan && bluetoothConnect && location;
  }

  Future<void> _checkBluetoothState() async {
    final currentState = await FlutterBluePlus.adapterState.first;

    if (currentState == BluetoothAdapterState.on) {
      state = state.copyWith(
        connection: state.connection.copyWith(
          bluetoothReady: true,
          status: 'Bluetooth ready - Press scan button',
        ),
      );
    } else {
      state = state.copyWith(
        connection: state.connection.copyWith(
          bluetoothReady: false,
          status: 'Please turn on Bluetooth',
        ),
      );
    }

    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((
      BluetoothAdapterState adapterState,
    ) async {
      if (adapterState == BluetoothAdapterState.on) {
        state = state.copyWith(
          connection: state.connection.copyWith(
            bluetoothReady: true,
            status:
                state.connection.device == null && !state.connection.isScanning
                ? 'Bluetooth ready - Press scan button'
                : state.connection.status,
          ),
        );
      } else {
        state = state.copyWith(
          connection: state.connection.copyWith(
            bluetoothReady: false,
            status: 'Please turn on Bluetooth',
            isScanning: false,
          ),
        );
        await disconnectDevice();
      }
    });
  }

  // ── Scanning / connecting ──────────────────────────────────────

  Future<void> startScanning() async {
    if (!state.connection.bluetoothReady || state.connection.isScanning) return;

    if (state.connection.isSimulator) {
      await _simulatorConnect();
      return;
    }

    _scanResultCache.clear();
    state = state.copyWith(
      connection: state.connection.copyWith(
        isScanning: true,
        status: 'Scanning for devices...',
      ),
      discoveredDevices: [],
    );

    try {
      await FlutterBluePlus.startScan(
        timeout: AppConstants.scanTimeout,
        webOptionalServices: [Guid(ProgressorConstants.serviceUuid)],
      );

      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (state.connection.isConnected || state.connection.isConnecting) {
          return;
        }

        var changed = false;
        for (final result in results) {
          final id = result.device.remoteId.str;
          final name = result.device.platformName;
          DeviceType? type;

          if (name.toLowerCase().contains('progressor') ||
              result.advertisementData.serviceUuids.any(
                (uuid) =>
                    uuid.toString().toLowerCase() ==
                    ProgressorConstants.serviceUuid.toLowerCase(),
              )) {
            type = DeviceType.progressor;
          } else if (result.advertisementData.manufacturerData
                  .containsKey(CraneScaleProtocol.manufacturerId) ||
              name.toLowerCase().startsWith('if_')) {
            type = DeviceType.craneScale;
          }

          if (type == null) continue;
          if (_scanResultCache.containsKey(id)) continue;

          _scanResultCache[id] = result;
          changed = true;
        }

        if (changed) {
          state = state.copyWith(
            discoveredDevices: _scanResultCache.entries
                .map((e) {
                  final r = e.value;
                  final name = r.device.platformName;
                  final isProgressor =
                      name.toLowerCase().contains('progressor') ||
                      r.advertisementData.serviceUuids.any(
                        (uuid) =>
                            uuid.toString().toLowerCase() ==
                            ProgressorConstants.serviceUuid.toLowerCase(),
                      );
                  return DiscoveredDevice(
                    name: name.isEmpty ? 'Unknown' : name,
                    id: e.key,
                    type: isProgressor
                        ? DeviceType.progressor
                        : DeviceType.craneScale,
                    rssi: r.rssi,
                  );
                })
                .toList(),
          );
        }
      });

      _cancelScanTimeoutTimer();
      _scanTimeoutTimer = Timer(AppConstants.scanExtendedTimeout, () {
        if (!state.connection.isConnected && state.connection.isScanning) {
          unawaited(stopScanning());
        }
      });
    } catch (e) {
      state = state.copyWith(
        connection: state.connection.copyWith(
          isScanning: false,
          status: 'Scan failed: $e',
        ),
      );
    }
  }

  Future<void> connectToDiscoveredDevice(String id) async {
    final scanResult = _scanResultCache[id];
    if (scanResult == null) return;

    final device = state.discoveredDevices.where((d) => d.id == id).firstOrNull;
    if (device == null) return;

    if (device.type == DeviceType.craneScale) {
      await _connectToCraneScale(scanResult);
    } else {
      await _connectToDevice(scanResult.device);
    }
  }

  Future<void> stopScanning() async {
    _cancelScanTimeoutTimer();
    if (!state.connection.isScanning) return;

    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;

      state = state.copyWith(
        connection: state.connection.copyWith(
          isScanning: false,
          status: state.connection.device == null
              ? 'Scan stopped'
              : state.connection.status,
        ),
      );
    } catch (e) {
      _log('Failed to stop scan: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (state.connection.device != null || state.connection.isConnecting) {
      return;
    }
    await stopScanning();

    state = state.copyWith(
      connection: state.connection.copyWith(
        isConnecting: true,
        status: 'Connecting to ${device.platformName}...',
      ),
    );

    try {
      await device.connect(license: License.free);

      state = state.copyWith(
        connection: state.connection.copyWith(
          device: device,
          status: 'Discovering services...',
        ),
      );

      final services = await device.discoverServices();
      BluetoothService? progressorService;
      for (final service in services) {
        if (service.uuid.toString().toLowerCase() ==
            ProgressorConstants.serviceUuid.toLowerCase()) {
          progressorService = service;
          break;
        }
      }

      if (progressorService == null) {
        await _failConnectionSetup(device, 'Progressor service not found');
        return;
      }

      BluetoothCharacteristic? notifyChar;
      BluetoothCharacteristic? writeChar;
      for (final characteristic in progressorService.characteristics) {
        final charUuid = characteristic.uuid.toString().toLowerCase();

        if (charUuid ==
            ProgressorConstants.notifyCharUuid.toLowerCase()) {
          notifyChar = characteristic;
        } else if (charUuid ==
            ProgressorConstants.writeCharUuid.toLowerCase()) {
          writeChar = characteristic;
        }
      }

      if (notifyChar == null || writeChar == null) {
        await _failConnectionSetup(
          device,
          'Required characteristics not found',
        );
        return;
      }

      // Create protocol instance and subscribe to events.
      _protocol?.dispose();
      _protocol = ProgressorProtocol(_FlutterBluePlusTransport(writeChar));
      _protocolSubscription?.cancel();
      _protocolSubscription = _protocol!.events.listen(_handleProtocolEvent);

      // Subscribe to BLE notifications and forward to protocol.
      await _subscribeToNotifications(notifyChar);

      state = state.copyWith(
        connection: state.connection.copyWith(
          notifyCharacteristic: notifyChar,
          writeCharacteristic: writeChar,
          isConnecting: false,
          status: 'Connected to Progressor',
        ),
      );

      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((
        connectionState,
      ) {
        if (connectionState == BluetoothConnectionState.disconnected) {
          _handleUnexpectedDisconnect();
        }
      });

      await _requestInitialDeviceInfo();
    } catch (e) {
      await _failConnectionSetup(device, 'Connection failed: $e');
    }
  }

  // ── Crane scale (advertisement-only) connection ──────────────

  Future<void> _connectToCraneScale(ScanResult initialResult) async {
    if (state.connection.isCraneScale || state.connection.isConnecting) return;

    // Set state immediately (before any async gap) to prevent re-entry.
    state = state.copyWith(
      connection: state.connection.copyWith(
        isScanning: false,
        isConnecting: false,
        deviceType: DeviceType.craneScale,
        status: 'Connected to Crane Scale',
      ),
    );

    try {
      _cancelScanTimeoutTimer();
      await _scanSubscription?.cancel();
      _scanSubscription = null;

      // Stop the initial scan — we'll restart with continuousUpdates.
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}

      _craneScaleStartTime = null;
      _craneScaleTareOffset = 0.0;
      _craneScaleWatchdogTimer?.cancel();

      // Process the first advertisement we already have.
      _handleCraneScaleAdvertisement(initialResult);

      // Restart scan with continuous updates to keep receiving advertisements.
      _craneScaleScanSubscription?.cancel();
      _craneScaleScanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          if (result.advertisementData.manufacturerData
              .containsKey(CraneScaleProtocol.manufacturerId)) {
            _handleCraneScaleAdvertisement(result);
            break;
          }
        }
    });

      await FlutterBluePlus.startScan(
        continuousUpdates: true,
        continuousDivisor: 1,
      );
    } catch (e) {
      _log('_connectToCraneScale error: $e');
    }
  }

  void _resetCraneScaleWatchdog() {
    _craneScaleWatchdogTimer?.cancel();
    _craneScaleWatchdogTimer = Timer(const Duration(seconds: 3), () {
      // No advertisement for 3 s — restart the scan to clear the
      // flutter_blue_plus result cache so that when the device resumes
      // advertising (e.g. after physical TARE) its fresh packets are
      // delivered instead of the stale cached ScanResult.
      if (state.connection.isCraneScale) {
        unawaited(FlutterBluePlus.startScan(
          continuousUpdates: true,
          continuousDivisor: 1,
        ));
      }
    });
  }

  void _handleCraneScaleAdvertisement(ScanResult result) {
    if (!state.connection.isCraneScale) return;

    final mfgData = result
        .advertisementData.manufacturerData[CraneScaleProtocol.manufacturerId];
    if (mfgData == null) return;

    final parsed = CraneScaleProtocol.parse(mfgData);
    if (parsed == null) return;

    // Only feed weight data when actively measuring.
    if (!state.measurement.isMeasuring) return;

    final now = DateTime.now();
    _craneScaleStartTime ??= now;
    final timestampUs = now.difference(_craneScaleStartTime!).inMicroseconds;

    final weight = parsed.weightKg - _craneScaleTareOffset;

    final measurement = WeightMeasurement(
      weight: weight,
      timestampUs: timestampUs,
      receivedAt: now,
    );

    _resetCraneScaleWatchdog();
    _handleWeightMeasurements([measurement]);
  }

  Future<void> _failConnectionSetup(
    BluetoothDevice device,
    String status,
  ) async {
    try {
      await device.disconnect();
    } catch (_) {}

    _cleanupSubscriptions();
    state = state.copyWith(
      connection: state.connection.copyWith(
        device: null,
        notifyCharacteristic: null,
        writeCharacteristic: null,
        isConnecting: false,
        isScanning: false,
        status: status,
      ),
    );
  }

  Future<void> _subscribeToNotifications(
    BluetoothCharacteristic characteristic,
  ) async {
    try {
      _notifySubscription?.cancel();
      _notifyEventSubscription?.cancel();
      final useIndications =
          characteristic.properties.indicate &&
          !characteristic.properties.notify;
      _log(
        'Subscribing to notifications on ${characteristic.uuid} '
        '(notify=${characteristic.properties.notify}, '
        'indicate=${characteristic.properties.indicate}, '
        'read=${characteristic.properties.read}, '
        'write=${characteristic.properties.write}, '
        'writeNoResp=${characteristic.properties.writeWithoutResponse})',
      );

      if (kIsWeb) {
        final device = state.connection.device;
        final targetServiceUuid = characteristic.serviceUuid
            .toString()
            .toLowerCase();
        final targetCharUuid = characteristic.uuid.toString().toLowerCase();

        _notifyEventSubscription = FlutterBluePlus
            .events
            .onCharacteristicReceived
            .where((event) => event.error == null)
            .where(
              (event) =>
                  device != null && event.device.remoteId == device.remoteId,
            )
            .where(
              (event) =>
                  event.characteristic.serviceUuid.toString().toLowerCase() ==
                  targetServiceUuid,
            )
            .where(
              (event) =>
                  event.characteristic.characteristicUuid
                      .toString()
                      .toLowerCase() ==
                  targetCharUuid,
            )
            .listen((event) {
              _log(
                'Web RX event (${event.value.length} bytes) '
                'svc=${event.characteristic.serviceUuid} '
                'chr=${event.characteristic.characteristicUuid} '
                'instance=${event.characteristic.instanceId}',
              );
              _protocol?.handleNotification(event.value);
            });
      } else {
        _notifySubscription = characteristic.onValueReceived.listen((value) {
          if (value.isEmpty) return;
          _log('Characteristic stream RX (${value.length} bytes)');
          _protocol?.handleNotification(value);
        });
      }

      await characteristic.setNotifyValue(
        true,
        forceIndications: useIndications,
      );
      _log('Notification subscription enabled for ${characteristic.uuid}');
    } catch (e) {
      state = state.copyWith(
        connection: state.connection.copyWith(
          status: 'Notification subscription failed: $e',
        ),
      );
    }
  }

  // ── Commands ───────────────────────────────────────────────────

  Future<void> _requestInitialDeviceInfo() async {
    const maxAttempts = 2;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (state.connection.device == null) return;

      await _protocol?.getFirmwareVersion();
      await Future.delayed(_commandSettleDelay);
      await _protocol?.getBatteryVoltage();
      await Future.delayed(_commandSettleDelay);
      await getCalibration();

      final hasFirmware = state.deviceInfo.firmwareVersion.isNotEmpty;
      final hasBattery = state.deviceInfo.batteryVoltage.isNotEmpty;
      if (hasFirmware && hasBattery) {
        return;
      }

      await Future.delayed(_resumeCheckDelay);
    }
  }

  Future<void> tareScale() async {
    if (state.connection.isSimulator) {
      final tareWeight = state.measurement.currentWeight;
      _resetMeasurementState();
      state = state.copyWith(
        deviceInfo: state.deviceInfo.copyWith(tareValue: tareWeight),
      );
      return;
    }
    if (state.connection.isCraneScale) {
      // Software tare: store current weight as offset.
      _craneScaleTareOffset += state.measurement.currentWeight;
      final tareWeight = state.measurement.currentWeight;
      _resetMeasurementState();
      state = state.copyWith(
        deviceInfo: state.deviceInfo.copyWith(tareValue: tareWeight),
      );
      return;
    }
    final wasMeasuring = state.measurement.isMeasuring;
    var tareWeight = state.measurement.currentWeight;

    if (wasMeasuring) {
      await _protocol?.stopMeasurement();
      _flushPendingMeasurements();
      tareWeight = state.measurement.currentWeight;
      state = state.copyWith(
        measurement: state.measurement.copyWith(isMeasuring: false),
      );
      await Future.delayed(_commandSettleDelay);
    }

    await _protocol?.tareScale();
    _resetMeasurementState();
    state = state.copyWith(
      deviceInfo: state.deviceInfo.copyWith(tareValue: tareWeight),
    );

    if (wasMeasuring) {
      await Future.delayed(_commandSettleDelay);
      final lastMeasurementBeforeResume = _lastMeasurementReceivedAt;
      await _protocol?.startMeasurement();
      state = state.copyWith(
        measurement: state.measurement.copyWith(isMeasuring: true),
      );

      await Future.delayed(_resumeCheckDelay);
      if (_lastMeasurementReceivedAt == lastMeasurementBeforeResume) {
        await _protocol?.startMeasurement();
      }
    }
  }

  Future<void> startMeasurement() async {
    if (state.connection.isSimulator) {
      _simulatorStartMeasurement();
      return;
    }
    if (state.connection.isCraneScale) {
      _craneScaleStartTime = null;
      _resetMeasurementRuntimeState();
      state = state.copyWith(
        measurement: state.measurement.copyWith(
          isMeasuring: true,
          weightHistory: [],
          maxWeight: 0.0,
          minWeight: 0.0,
          sampleCount: 0,
        ),
      );
      return;
    }
    await _protocol?.startMeasurement();
    _resetMeasurementRuntimeState();
    state = state.copyWith(
      measurement: state.measurement.copyWith(
        isMeasuring: true,
        weightHistory: [],
        maxWeight: 0.0,
        minWeight: 0.0,
        sampleCount: 0,
      ),
    );
  }

  Future<void> stopMeasurement() async {
    if (state.connection.isSimulator) {
      _simulatorStopMeasurement();
      return;
    }
    if (state.connection.isCraneScale) {
      _craneScaleWatchdogTimer?.cancel();
      _flushPendingMeasurements();
      state = state.copyWith(
        measurement: state.measurement.copyWith(isMeasuring: false),
      );
      return;
    }
    await _protocol?.stopMeasurement();
    _flushPendingMeasurements();

    state = state.copyWith(
      measurement: state.measurement.copyWith(isMeasuring: false),
    );
  }

  Future<void> addCalibrationPoint(double weightKg) {
    if (state.connection.isCraneScale) return Future.value();
    return _protocol?.addCalibrationPoint(weightKg) ?? Future.value();
  }

  Future<void> getCalibration() async {
    if (state.connection.isCraneScale) return;
    _calibrationPoints.clear();
    _updateCalibrationInfo();
    await _protocol?.getCalibration();
  }

  Future<void> defaultCalibration() async {
    if (state.connection.isCraneScale) return;
    _calibrationFactor = null;
    _calibrationPoints.clear();
    _updateCalibrationInfo();
    await _protocol?.defaultCalibration();
  }

  // ── Internal state helpers ─────────────────────────────────────

  void _resetMeasurementState() {
    state = state.copyWith(
      measurement: state.measurement.copyWith(
        currentWeight: 0.0,
        maxWeight: 0.0,
        minWeight: 0.0,
        sampleCount: 0,
        weightHistory: [],
        receivedData: [],
      ),
    );
    _resetMeasurementRuntimeState(clearRxBuffer: true);
  }

  void _resetMeasurementRuntimeState({bool clearRxBuffer = false}) {
    _pendingMeasurements.clear();
    _recentMeasurements.clear();
    _notifyIntervalHistory.clear();
    _weightHistory.clear();
    _receivedData.clear();
    _currentNotifyIntervalMs = 0.0;
    _dataPacketCount = 0;
    _lastNotifyTime = null;
    _lastUiUpdateTime = null;
    _lastMeasurementReceivedAt = null;

    if (clearRxBuffer) {
      _protocol?.resetBuffer();
    }
  }

  void _flushPendingMeasurements() {
    if (_pendingMeasurements.isEmpty) return;

    final lastMeasurement = _pendingMeasurements.last;

    _weightHistory.add(FlSpot(lastMeasurement.timestampSec, lastMeasurement.weight));
    if (_weightHistory.length > AppConstants.maxHistorySize) {
      _weightHistory.removeAt(0);
    }

    _receivedData.insertAll(0, _pendingMeasurements.reversed);
    if (_receivedData.length > AppConstants.maxReceivedDataSize) {
      _receivedData.removeRange(AppConstants.maxReceivedDataSize, _receivedData.length);
    }
    _pendingMeasurements.clear();

    state = state.copyWith(
      measurement: state.measurement.copyWith(
        currentWeight: lastMeasurement.weight,
        maxWeight: lastMeasurement.weight > state.measurement.maxWeight
            ? lastMeasurement.weight
            : state.measurement.maxWeight,
        minWeight:
            state.measurement.minWeight == 0.0 ||
                lastMeasurement.weight < state.measurement.minWeight
            ? lastMeasurement.weight
            : state.measurement.minWeight,
        sampleCount: lastMeasurement.timestampUs,
        weightHistory: List.unmodifiable(_weightHistory),
        receivedData: List.unmodifiable(_receivedData),
      ),
    );
  }

  // ── Disconnect ─────────────────────────────────────────────────

  void _handleUnexpectedDisconnect() {
    _cleanupSubscriptions();
    _resetDisconnectedState(
      bluetoothReady: state.connection.bluetoothReady,
      status: 'Device disconnected',
    );
  }

  void _resetDisconnectedState({
    required bool bluetoothReady,
    required String status,
  }) {
    state = state.copyWith(
      connection: ConnectionState(
        bluetoothReady: bluetoothReady,
        status: status,
      ),
      deviceInfo: const DeviceInfo(),
      measurement: const MeasurementState(),
      performance: const PerformanceMetrics(),
      errorMessage: null,
    );

    _calibrationFactor = null;
    _calibrationPoints.clear();
    _resetMeasurementRuntimeState(clearRxBuffer: true);
  }

  Future<bool> _isDeviceDisconnected(BluetoothDevice device) async {
    try {
      final connectionState = await device.connectionState.first.timeout(
        const Duration(seconds: 1),
      );
      return connectionState == BluetoothConnectionState.disconnected;
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnectDevice() async {
    if (state.connection.isSimulator) {
      _simulatorDisconnect();
      return;
    }
    if (state.connection.isCraneScale) {
      _disconnectCraneScale();
      return;
    }

    final bluetoothReady = state.connection.bluetoothReady;
    final device = state.connection.device;

    if (device == null) {
      _cleanupSubscriptions();
      _resetDisconnectedState(
        bluetoothReady: bluetoothReady,
        status: 'Disconnected',
      );
      return;
    }

    Object? disconnectError;
    try {
      await device.disconnect();
    } catch (e) {
      disconnectError = e;
      _log('Failed to disconnect: $e');
    }

    if (state.connection.device == null) {
      return;
    }

    final isDisconnected = await _isDeviceDisconnected(device);
    if (!isDisconnected) {
      state = state.copyWith(
        connection: state.connection.copyWith(
          isConnecting: false,
          isScanning: false,
          status: disconnectError == null
              ? 'Waiting for device to disconnect...'
              : 'Disconnect failed: $disconnectError',
        ),
      );
      return;
    }

    _cleanupSubscriptions();
    _resetDisconnectedState(
      bluetoothReady: bluetoothReady,
      status: 'Disconnected',
    );
  }

  // ── Crane scale disconnect ────────────────────────────────────

  void _disconnectCraneScale() {
    _craneScaleScanSubscription?.cancel();
    _craneScaleScanSubscription = null;
    _craneScaleStartTime = null;
    _craneScaleTareOffset = 0.0;

    try {
      FlutterBluePlus.stopScan();
    } catch (_) {}

    _resetMeasurementRuntimeState(clearRxBuffer: true);
    _resetDisconnectedState(
      bluetoothReady: state.connection.bluetoothReady,
      status: 'Disconnected',
    );
  }

  // ── Simulator ──────────────────────────────────────────────────

  void configureSimulator(ProtocolConfig config) {
    _simulatorConfig = config;
  }

  Future<void> connectSimulator() async {
    state = state.copyWith(
      connection: state.connection.copyWith(isSimulator: true),
    );
    await _simulatorConnect();
  }

  Future<void> _simulatorConnect() async {
    state = state.copyWith(
      connection: state.connection.copyWith(
        isScanning: true,
        status: 'Scanning (simulator)...',
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      connection: state.connection.copyWith(
        isScanning: false,
        isSimulator: true,
        bluetoothReady: true,
        status: 'Connected (simulator)',
      ),
      deviceInfo: const DeviceInfo(
        firmwareVersion: 'SIM-1.0.0',
        batteryVoltage: '4200',
      ),
    );
  }

  void _simulatorStartMeasurement() {
    _resetMeasurementRuntimeState();
    _simulatorTimestampUs = 0;
    _simulatorStartTime = DateTime.now();
    state = state.copyWith(
      measurement: state.measurement.copyWith(
        isMeasuring: true,
        weightHistory: [],
        maxWeight: 0.0,
        minWeight: 0.0,
        sampleCount: 0,
      ),
    );

    _simulatorTimer?.cancel();
    _simulatorTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _simulatorTick(),
    );
  }

  void _simulatorTick() {
    final now = DateTime.now();
    // Use real wall-clock elapsed time — web timers don't fire at 12ms
    _simulatorStartTime ??= now;
    _simulatorTimestampUs = now.difference(_simulatorStartTime!).inMicroseconds;

    final weight = _computeSimulatorWeight();

    final measurement = WeightMeasurement(
      weight: weight,
      timestampUs: _simulatorTimestampUs,
      receivedAt: now,
    );

    _recentMeasurements.add(measurement);
    _dataPacketCount++;

    if (_lastNotifyTime != null) {
      final intervalMs =
          now.difference(_lastNotifyTime!).inMicroseconds / 1000.0;
      _currentNotifyIntervalMs = intervalMs;
      _notifyIntervalHistory.add(intervalMs);
      if (_notifyIntervalHistory.length > AppConstants.maxIntervalHistorySize) {
        _notifyIntervalHistory.removeAt(0);
      }
    }
    _lastNotifyTime = now;

    final shouldPublish =
        _lastUiUpdateTime == null ||
        now.difference(_lastUiUpdateTime!) >= _uiUpdateInterval;
    if (!shouldPublish) return;
    _lastUiUpdateTime = now;

    _weightHistory.add(FlSpot(measurement.timestampSec, measurement.weight));
    if (_weightHistory.length > AppConstants.maxHistorySize) {
      _weightHistory.removeAt(0);
    }

    _receivedData.insert(0, measurement);
    if (_receivedData.length > AppConstants.maxReceivedDataSize) {
      _receivedData.removeRange(AppConstants.maxReceivedDataSize, _receivedData.length);
    }

    const oneSecondInMicroseconds = 1000000;
    final latestTs = _recentMeasurements.last.timestampUs;
    _recentMeasurements.removeWhere(
      (m) => (latestTs - m.timestampUs) > oneSecondInMicroseconds,
    );
    final currentHz = _recentMeasurements.length.toDouble();

    state = state.copyWith(
      measurement: state.measurement.copyWith(
        currentWeight: measurement.weight,
        maxWeight: measurement.weight > state.measurement.maxWeight
            ? measurement.weight
            : state.measurement.maxWeight,
        minWeight:
            state.measurement.minWeight == 0.0 ||
                measurement.weight < state.measurement.minWeight
            ? measurement.weight
            : state.measurement.minWeight,
        sampleCount: measurement.timestampUs,
        weightHistory: List.unmodifiable(_weightHistory),
        receivedData: List.unmodifiable(_receivedData),
      ),
      performance: state.performance.copyWith(
        currentNotifyIntervalMs: _currentNotifyIntervalMs,
        notifyIntervalHistory: List.unmodifiable(_notifyIntervalHistory),
        currentHz: currentHz,
        dataPacketCount: _dataPacketCount,
        samplesPerPacket: 1,
      ),
    );
  }

  /// Computes simulated weight by reading the session's current phase.
  /// This keeps the simulator perfectly in sync with the session state machine.
  double _computeSimulatorWeight() {
    final config = _simulatorConfig;
    final sessionState = ref.read(sessionProvider);

    // No active session: fallback to simple cycle (freeform measurement mode)
    if (sessionState == null || config == null) {
      final cycleMs = (_simulatorTimestampUs ~/ 1000) % 10000;
      if (cycleMs < 7000) {
        return 17.0 + (_simulatorRng.nextDouble() - 0.5) * 4.0;
      }
      return _simulatorRng.nextDouble() * 1.5;
    }

    switch (sessionState.phase) {
      case SessionPhase.hanging:
        // Max hang simulator: drop weight after 10s to trigger rep detection
        if (config.type == ProtocolType.maxHang &&
            sessionState.phaseElapsedMs > 10000) {
          return _simulatorRng.nextDouble() * 0.5;
        }
        final targetAvg = config.targetWeightKg > 0 ? config.targetWeightKg : 17.0;
        final setIndex = sessionState.currentSetIndex;
        final repIndex = sessionState.currentSetReps.length;
        final fatigue = 1.0 - (setIndex * 0.03) - (repIndex * 0.01);
        final noise = (_simulatorRng.nextDouble() - 0.5) * (targetAvg * 0.15);
        return (targetAvg * fatigue + noise).clamp(0.5, targetAvg * 1.5);
      case SessionPhase.idle:
      case SessionPhase.countdown:
      case SessionPhase.resting:
      case SessionPhase.restBetweenSets:
      case SessionPhase.complete:
        return _simulatorRng.nextDouble() * 0.5;
    }
  }

  void _simulatorStopMeasurement() {
    _simulatorTimer?.cancel();
    _simulatorTimer = null;
    state = state.copyWith(
      measurement: state.measurement.copyWith(isMeasuring: false),
    );
  }

  void _simulatorDisconnect() {
    _simulatorTimer?.cancel();
    _simulatorTimer = null;
    _resetMeasurementRuntimeState(clearRxBuffer: true);
    state = state.copyWith(
      connection: ConnectionState(
        bluetoothReady: true,
        isSimulator: true,
        status: 'Simulator mode — no Bluetooth available',
      ),
      deviceInfo: const DeviceInfo(),
      measurement: const MeasurementState(),
      performance: const PerformanceMetrics(),
      errorMessage: null,
    );
  }

  // ── Subscriptions cleanup ────────────────────────────────────

  void _cleanupSubscriptions() {
    _cancelScanTimeoutTimer();
    _scanSubscription?.cancel();
    _notifySubscription?.cancel();
    _notifyEventSubscription?.cancel();
    _connectionSubscription?.cancel();
    _protocolSubscription?.cancel();
    _craneScaleScanSubscription?.cancel();
    _scanSubscription = null;
    _notifySubscription = null;
    _notifyEventSubscription = null;
    _connectionSubscription = null;
    _protocolSubscription = null;
    _craneScaleScanSubscription = null;
    _protocol?.dispose();
    _protocol = null;
  }

  void _cancelScanTimeoutTimer() {
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = null;
  }
}

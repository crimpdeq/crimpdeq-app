import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_chart/fl_chart.dart';

import '../constants/progressor_constants.dart';
import '../models/progressor_models.dart';

part 'progressor_provider.g.dart';

@riverpod
class ProgressorNotifier extends _$ProgressorNotifier {
  static const Duration _uiUpdateInterval = Duration(milliseconds: 66);
  static const Duration _commandSettleDelay = Duration(milliseconds: 120);
  static const Duration _resumeCheckDelay = Duration(milliseconds: 300);

  StreamSubscription? _scanSubscription;
  StreamSubscription? _notifySubscription;
  StreamSubscription? _notifyEventSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  Timer? _scanTimeoutTimer;
  DateTime? _lastNotifyTime;
  DateTime? _lastUiUpdateTime;
  DateTime? _lastMeasurementReceivedAt;
  final List<WeightMeasurement> _recentMeasurements = [];
  final List<WeightMeasurement> _pendingMeasurements = [];
  final List<double> _notifyIntervalHistory = [];
  final List<int> _rxBuffer = [];
  double _currentNotifyIntervalMs = 0.0;
  int _dataPacketCount = 0;
  double? _calibrationFactor;
  final List<List<double>> _calibrationPoints = [];

  @override
  ProgressorState build() {
    ref.onDispose(() {
      _cleanupSubscriptions();
      _cancelScanTimeoutTimer();
      _adapterStateSubscription?.cancel();
      _adapterStateSubscription = null;
    });

    _initializeBle();
    return const ProgressorState();
  }

  void _log(String message) {
    debugPrint('[ProgressorNotifier] $message');
  }

  bool _isCandidateDevice(ScanResult result) {
    final deviceName = result.device.platformName.trim().toLowerCase();
    final advertisedName = result.advertisementData.advName
        .trim()
        .toLowerCase();

    return deviceName.contains('progressor') ||
        advertisedName.contains('progressor') ||
        result.advertisementData.serviceUuids.any(
          (uuid) =>
              uuid.toString().toLowerCase() ==
              ProgressorConstants.instance.serviceUuid.toLowerCase(),
        );
  }

  DiscoveredDevice _toDiscoveredDevice(ScanResult result) {
    final deviceName = result.device.platformName.trim();
    final advertisedName = result.advertisementData.advName.trim();
    final resolvedName = deviceName.isNotEmpty
        ? deviceName
        : advertisedName.isNotEmpty
        ? advertisedName
        : 'Unknown device';

    return DiscoveredDevice(
      id: result.device.remoteId.str,
      name: resolvedName,
      rssi: result.rssi,
      device: result.device,
    );
  }

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
            discoveredDevices: const [],
          ),
        );
        await disconnectDevice();
      }
    });
  }

  Future<void> startScanning() async {
    if (!state.connection.bluetoothReady || state.connection.isScanning) return;

    state = state.copyWith(
      connection: state.connection.copyWith(
        isScanning: true,
        discoveredDevices: const [],
        status: 'Scanning for devices...',
      ),
    );

    try {
      await FlutterBluePlus.startScan(
        timeout: AppConstants.scanTimeout,
        withServices: [Guid(ProgressorConstants.instance.serviceUuid)],
        webOptionalServices: [Guid(ProgressorConstants.instance.serviceUuid)],
      );

      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (state.connection.device != null || state.connection.isConnecting) {
          return;
        }

        final devicesById = <String, DiscoveredDevice>{
          for (final device in state.connection.discoveredDevices)
            device.id: device,
        };

        for (final result in results) {
          if (!_isCandidateDevice(result)) continue;
          final discoveredDevice = _toDiscoveredDevice(result);
          devicesById[discoveredDevice.id] = discoveredDevice;
        }

        final discoveredDevices = devicesById.values.toList()
          ..sort((a, b) {
            final nameCompare = a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            );
            if (nameCompare != 0) return nameCompare;
            return b.rssi.compareTo(a.rssi);
          });

        final previousSignature = state.connection.discoveredDevices
            .map((device) => '${device.id}:${device.rssi}')
            .join('|');
        final nextSignature = discoveredDevices
            .map((device) => '${device.id}:${device.rssi}')
            .join('|');

        if (previousSignature != nextSignature &&
            discoveredDevices.isNotEmpty) {
          _log(
            'Possible devices: ${discoveredDevices.map((device) => '${device.name} (${device.id}, RSSI ${device.rssi})').join(', ')}',
          );
        }

        state = state.copyWith(
          connection: state.connection.copyWith(
            discoveredDevices: discoveredDevices,
            status: discoveredDevices.isEmpty
                ? 'Scanning for devices...'
                : 'Found ${discoveredDevices.length} possible device${discoveredDevices.length == 1 ? '' : 's'}. Select one to connect.',
          ),
        );
      });

      _cancelScanTimeoutTimer();
      _scanTimeoutTimer = Timer(AppConstants.scanExtendedTimeout, () {
        if (state.connection.device == null && state.connection.isScanning) {
          unawaited(stopScanning());
          state = state.copyWith(
            connection: state.connection.copyWith(
              status: state.connection.discoveredDevices.isEmpty
                  ? 'No compatible devices found. Please try scanning again.'
                  : 'Scan complete. Select a device to connect.',
            ),
          );
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
              ? state.connection.discoveredDevices.isEmpty
                    ? 'Scan stopped'
                    : 'Scan stopped. Select a device to connect.'
              : state.connection.status,
        ),
      );
    } catch (e) {
      _log('Failed to stop scan: $e');
    }
  }

  Future<void> connectToDiscoveredDevice(DiscoveredDevice device) async {
    await _connectToDevice(device.device, displayName: device.name);
  }

  Future<void> _connectToDevice(
    BluetoothDevice device, {
    String? displayName,
  }) async {
    if (state.connection.device != null || state.connection.isConnecting) {
      return;
    }
    await stopScanning();

    final resolvedDisplayName =
        displayName ??
        (device.platformName.trim().isEmpty
            ? device.remoteId.str
            : device.platformName.trim());

    state = state.copyWith(
      connection: state.connection.copyWith(
        isConnecting: true,
        status: 'Connecting to $resolvedDisplayName...',
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
            ProgressorConstants.instance.serviceUuid.toLowerCase()) {
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
            ProgressorConstants.instance.notifyCharUuid.toLowerCase()) {
          notifyChar = characteristic;
          await _subscribeToNotifications(characteristic);
        } else if (charUuid ==
            ProgressorConstants.instance.writeCharUuid.toLowerCase()) {
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

  Future<void> _failConnectionSetup(
    BluetoothDevice device,
    String status,
  ) async {
    try {
      await device.disconnect();
    } catch (_) {
      // Device might already be disconnected.
    }

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

        // Web fallback: bypass strict characteristic stream matching
        // (instanceId/primaryServiceUuid) and match by device+UUIDs only.
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
              _handleIncomingNotificationChunk(event.value);
            });
      } else {
        // Listen before enabling notifications to avoid missing early packets.
        _notifySubscription = characteristic.onValueReceived.listen((value) {
          if (value.isEmpty) return;
          _log('Characteristic stream RX (${value.length} bytes)');
          _handleIncomingNotificationChunk(value);
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

  void _handleIncomingNotificationChunk(List<int> chunk) {
    if (chunk.isEmpty) return;

    _rxBuffer.addAll(chunk);

    // Reassemble framed packets: [messageType, payloadLength, payload...].
    // Web Bluetooth may surface smaller chunks than native platforms.
    while (_rxBuffer.isNotEmpty) {
      final messageType = _rxBuffer.first;

      // Low battery can be a single-byte message on some firmware variants.
      if (messageType == ProgressorConstants.instance.lowBatteryWarning &&
          _rxBuffer.length == 1) {
        _parseReceivedData(List<int>.from(_rxBuffer));
        _rxBuffer.clear();
        return;
      }

      if (_rxBuffer.length < 2) {
        return;
      }

      final payloadLength = _rxBuffer[1];
      final expectedFrameLength = payloadLength + 2;

      // Some firmware variants send battery command responses as
      // [0, v0, v1, v2, v3] (no payload-length byte).
      // When Web Bluetooth batches this legacy 5-byte frame with following
      // notifications in the same chunk, consume only the first 5 bytes.
      if (messageType == ProgressorConstants.instance.commandResponse &&
          _rxBuffer.length >= 5) {
        final legacyBatteryFrame = List<int>.from(_rxBuffer.take(5));
        if (_looksLikeLegacyBatteryFrame(legacyBatteryFrame)) {
          _parseReceivedData(legacyBatteryFrame);
          _rxBuffer.removeRange(0, 5);
          continue;
        }
      }

      if (expectedFrameLength <= 1 || expectedFrameLength > 512) {
        _log(
          'Dropping desynced byte while parsing notifications (type=$messageType, lenByte=$payloadLength)',
        );
        _rxBuffer.removeAt(0);
        continue;
      }

      // Legacy firmware variants may omit the payload-length byte for calibration.
      if (messageType == 5 && _rxBuffer.length == 5) {
        _parseReceivedData(List<int>.from(_rxBuffer));
        _rxBuffer.clear();
        return;
      }
      if (messageType == 6 && _rxBuffer.length == 9) {
        _parseReceivedData(List<int>.from(_rxBuffer));
        _rxBuffer.clear();
        return;
      }

      if (_rxBuffer.length < expectedFrameLength) {
        return;
      }

      final frame = List<int>.from(_rxBuffer.take(expectedFrameLength));
      _rxBuffer.removeRange(0, expectedFrameLength);
      _parseReceivedData(frame);
    }
  }

  void _parseReceivedData(List<int> rawData) {
    if (rawData.isEmpty) return;

    final messageType = rawData[0];

    switch (messageType) {
      case 1: // WEIGHT_MEASURE
        _handleWeightMeasurement(rawData);
        break;
      case 0: // COMMAND_RESPONSE
        _handleCommandResponse(rawData);
        break;
      case 5: // CALIBRATION_RESPONSE
        _handleCalibrationResponse(rawData);
        break;
      case 6: // CALIBRATION_POINT_RESPONSE
        _handleCalibrationPointResponse(rawData);
        break;
      case 4: // LOW_BATTERY_WARNING
        _log('Low battery warning received');
        break;
      default:
        _log('Unknown message type: $messageType');
    }
  }

  bool _looksLikeLegacyBatteryFrame(List<int> frame) {
    if (frame.length != 5 ||
        frame.first != ProgressorConstants.instance.commandResponse) {
      return false;
    }

    final voltage =
        frame[1] | (frame[2] << 8) | (frame[3] << 16) | (frame[4] << 24);

    // Typical battery voltage range (mV) reported by this device.
    return voltage >= 1000 && voltage <= 10000;
  }

  void _handleWeightMeasurement(List<int> data) {
    if (data.length < 2) return;

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

    final payload = data.sublist(2);
    if (payload.length % 8 != 0) return;

    final samplesPerPacket = payload.length ~/ 8;
    final bytes = Uint8List.fromList(payload);
    final byteData = ByteData.view(bytes.buffer);

    final newMeasurements = <WeightMeasurement>[];

    for (int i = 0; i < samplesPerPacket; i++) {
      final offset = i * 8;
      final weight = byteData.getFloat32(offset, Endian.little);
      final timestampUs = byteData.getUint32(offset + 4, Endian.little);

      final measurement = WeightMeasurement(
        weight: weight,
        timestampUs: timestampUs,
        receivedAt: now,
      );

      newMeasurements.add(measurement);
      _recentMeasurements.add(measurement);
    }

    _dataPacketCount++;

    // Process every sample, but publish state on a throttled cadence for web/browser smoothness.
    if (newMeasurements.isNotEmpty) {
      _pendingMeasurements.addAll(newMeasurements);
      final shouldPublish =
          _lastUiUpdateTime == null ||
          now.difference(_lastUiUpdateTime!) >= _uiUpdateInterval;
      if (!shouldPublish) return;
      _lastUiUpdateTime = now;

      final publishMeasurements = List<WeightMeasurement>.from(
        _pendingMeasurements,
      );
      _pendingMeasurements.clear();

      final lastMeasurement = publishMeasurements.last;
      final newWeightHistory = List<FlSpot>.from(
        state.measurement.weightHistory,
      )..add(FlSpot(lastMeasurement.timestampSec, lastMeasurement.weight));

      if (newWeightHistory.length > AppConstants.maxHistorySize) {
        newWeightHistory.removeAt(0);
      }

      final newReceivedData = List<WeightMeasurement>.from(
        publishMeasurements.reversed,
      )..addAll(state.measurement.receivedData);

      if (newReceivedData.length > AppConstants.maxReceivedDataSize) {
        newReceivedData.removeRange(
          AppConstants.maxReceivedDataSize,
          newReceivedData.length,
        );
      }

      // Calculate Hz based on actual timestamps from device
      final oneSecondInMicroseconds = 1000000;
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
          weightHistory: newWeightHistory,
          receivedData: newReceivedData,
        ),
        performance: state.performance.copyWith(
          currentNotifyIntervalMs: _currentNotifyIntervalMs,
          notifyIntervalHistory: List<double>.from(_notifyIntervalHistory),
          currentHz: currentHz,
          dataPacketCount: _dataPacketCount,
          samplesPerPacket: samplesPerPacket,
        ),
      );
    }
  }

  void _handleCommandResponse(List<int> rawData) {
    if (rawData.length < 2) return;

    try {
      final framedPayload = _payloadFromDataMessage(rawData);
      final responseData =
          framedPayload ??
          Uint8List.fromList(
            rawData.length > 1 ? rawData.sublist(1) : const <int>[],
          );
      if (responseData.isEmpty) return;

      // Try to parse as string first (firmware version)
      try {
        final stringResponse = String.fromCharCodes(
          responseData,
        ).replaceAll('\x00', '').trim();
        final looksPrintable =
            stringResponse.isNotEmpty &&
            stringResponse.runes.every(
              (r) => r == 9 || r == 10 || r == 13 || (r >= 32 && r <= 126),
            );
        if (looksPrintable) {
          _log('Command response (string): $stringResponse');
          state = state.copyWith(
            deviceInfo: state.deviceInfo.copyWith(
              firmwareVersion: stringResponse,
            ),
          );
          return;
        }
      } catch (_) {
        // Not a string, try other formats
      }

      // Try to parse as battery voltage (uint32)
      if (responseData.length >= 4) {
        final byteData = ByteData.view(responseData.buffer);
        final voltage = byteData.getUint32(0, Endian.little);
        _log('Command response (u32): $voltage');

        state = state.copyWith(
          deviceInfo: state.deviceInfo.copyWith(
            batteryVoltage: voltage.toString(),
          ),
        );
      }
    } catch (e) {
      _log('Error parsing command response: $e');
    }
  }

  void _handleCalibrationResponse(List<int> rawData) {
    if (rawData.length < 5) return;

    try {
      final responseData = _payloadFromCalibrationMessage(rawData, 4);
      if (responseData == null) return;

      final byteData = ByteData.view(
        responseData.buffer,
        responseData.offsetInBytes,
      );
      final calibrationFactor = byteData.getFloat32(0, Endian.little);
      _calibrationPoints.clear();
      _calibrationFactor = calibrationFactor;
      _updateCalibrationInfo();
    } catch (e) {
      _log('Error parsing calibration response: $e');
    }
  }

  void _handleCalibrationPointResponse(List<int> rawData) {
    if (rawData.length < 9) return;

    try {
      final responseData = _payloadFromCalibrationMessage(rawData, 8);
      if (responseData == null) return;

      final byteData = ByteData.view(
        responseData.buffer,
        responseData.offsetInBytes,
      );
      final valueA = byteData.getFloat32(0, Endian.little);
      final valueB = byteData.getFloat32(4, Endian.little);
      _appendCalibrationPoint(valueA, valueB);
      _updateCalibrationInfo();
    } catch (e) {
      _log('Error parsing calibration point response: $e');
    }
  }

  Uint8List? _payloadFromDataMessage(List<int> rawData) {
    if (rawData.length < 2) return null;

    final payloadSize = rawData[1];
    if (rawData.length < payloadSize + 2) {
      return null;
    }

    return Uint8List.fromList(rawData.sublist(2, payloadSize + 2));
  }

  Uint8List? _payloadFromCalibrationMessage(List<int> rawData, int minBytes) {
    final payloadWithLength = _payloadFromDataMessage(rawData);
    if (payloadWithLength != null && payloadWithLength.length >= minBytes) {
      return payloadWithLength;
    }

    // Some firmware variants send calibration notifications as:
    // [messageType, payload...] without a payload-length byte.
    if (rawData.length - 1 < minBytes) return null;
    return Uint8List.fromList(rawData.sublist(1));
  }

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

  Future<void> _sendCommand(String command) async {
    await _writeToDevice(utf8.encode(command), action: 'command "$command"');
  }

  Future<void> _writeToDevice(List<int> data, {required String action}) async {
    final writeChar = state.connection.writeCharacteristic;
    if (writeChar == null) {
      state = state.copyWith(
        connection: state.connection.copyWith(
          status: 'Cannot send $action: write characteristic unavailable',
        ),
      );
      return;
    }
    try {
      final supportsWrite = writeChar.properties.write;
      final supportsWriteNoResponse = writeChar.properties.writeWithoutResponse;
      if (!supportsWrite && !supportsWriteNoResponse) {
        state = state.copyWith(
          connection: state.connection.copyWith(
            status: 'Cannot send $action: characteristic is not writable',
          ),
        );
        return;
      }

      final preferredWithoutResponse = supportsWrite ? false : true;
      _log(
        'Sending $action (${data.length} bytes) '
        'with withoutResponse=$preferredWithoutResponse',
      );

      try {
        await writeChar.write(data, withoutResponse: preferredWithoutResponse);
      } catch (e) {
        final canRetryWithAlternateMode =
            (preferredWithoutResponse && supportsWrite) ||
            (!preferredWithoutResponse && supportsWriteNoResponse);
        if (!canRetryWithAlternateMode) rethrow;

        final alternateWithoutResponse = !preferredWithoutResponse;
        _log(
          'Retrying $action with withoutResponse=$alternateWithoutResponse after write failure: $e',
        );
        await writeChar.write(data, withoutResponse: alternateWithoutResponse);
      }
    } catch (e) {
      state = state.copyWith(
        connection: state.connection.copyWith(
          status: 'Failed to send $action: $e',
        ),
      );
      _log('Failed to send $action: $e');
    }
  }

  Future<void> _sendControlOpCode(
    int opCode, [
    List<int> payload = const [],
  ]) async {
    final data = Uint8List(1 + payload.length);
    data[0] = opCode;
    if (payload.isNotEmpty) {
      data.setRange(1, data.length, payload);
    }
    await _writeToDevice(
      data,
      action: 'control opcode 0x${opCode.toRadixString(16)}',
    );
  }

  Future<void> _requestInitialDeviceInfo() async {
    const maxAttempts = 2;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (state.connection.device == null) return;

      await _getFirmwareVersion();
      await Future.delayed(_commandSettleDelay);
      await _getBatteryVoltage();
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

  Future<void> _getFirmwareVersion() => _sendCommand('k');
  Future<void> _getBatteryVoltage() => _sendCommand('o');

  Future<void> tareScale() async {
    final wasMeasuring = state.measurement.isMeasuring;
    var tareWeight = state.measurement.currentWeight;

    if (wasMeasuring) {
      await _sendCommand('f');
      _flushPendingMeasurements();
      tareWeight = state.measurement.currentWeight;
      state = state.copyWith(
        measurement: state.measurement.copyWith(isMeasuring: false),
      );
      await Future.delayed(_commandSettleDelay);
    }

    await _sendCommand('d');
    _resetMeasurementState();
    state = state.copyWith(
      deviceInfo: state.deviceInfo.copyWith(tareValue: tareWeight),
    );

    if (wasMeasuring) {
      await Future.delayed(_commandSettleDelay);
      final lastMeasurementBeforeResume = _lastMeasurementReceivedAt;
      await _sendCommand('e');
      state = state.copyWith(
        measurement: state.measurement.copyWith(isMeasuring: true),
      );

      // Some devices ignore an immediate start after tare, so retry once if
      // no fresh measurement packet arrives shortly after resuming.
      await Future.delayed(_resumeCheckDelay);
      if (_lastMeasurementReceivedAt == lastMeasurementBeforeResume) {
        await _sendCommand('e');
      }
    }
  }

  Future<void> startMeasurement() async {
    await _sendCommand('e');
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
    await _sendCommand('f');
    _flushPendingMeasurements();

    state = state.copyWith(
      measurement: state.measurement.copyWith(isMeasuring: false),
    );
  }

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
    _currentNotifyIntervalMs = 0.0;
    _dataPacketCount = 0;
    _lastNotifyTime = null;
    _lastUiUpdateTime = null;
    _lastMeasurementReceivedAt = null;

    if (clearRxBuffer) {
      _rxBuffer.clear();
    }
  }

  void _flushPendingMeasurements() {
    // Flush throttled samples so the UI reflects the latest value immediately.
    if (_pendingMeasurements.isEmpty) return;

    final publishMeasurements = List<WeightMeasurement>.from(
      _pendingMeasurements,
    );
    _pendingMeasurements.clear();
    final lastMeasurement = publishMeasurements.last;

    final newWeightHistory = List<FlSpot>.from(state.measurement.weightHistory)
      ..add(FlSpot(lastMeasurement.timestampSec, lastMeasurement.weight));

    if (newWeightHistory.length > AppConstants.maxHistorySize) {
      newWeightHistory.removeAt(0);
    }

    final newReceivedData = List<WeightMeasurement>.from(
      publishMeasurements.reversed,
    )..addAll(state.measurement.receivedData);

    if (newReceivedData.length > AppConstants.maxReceivedDataSize) {
      newReceivedData.removeRange(
        AppConstants.maxReceivedDataSize,
        newReceivedData.length,
      );
    }

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
        weightHistory: newWeightHistory,
        receivedData: newReceivedData,
      ),
    );
  }

  Future<void> addCalibrationPoint(double weightKg) async {
    final payload = ByteData(4)..setFloat32(0, weightKg, Endian.little);
    await _sendControlOpCode(
      ControlOpCode.addCalibrationPoint.value,
      payload.buffer.asUint8List(),
    );
  }

  Future<void> getCalibration() async {
    _calibrationPoints.clear();
    _updateCalibrationInfo();
    await _sendControlOpCode(ControlOpCode.getCalibration.value);
  }

  Future<void> defaultCalibration() async {
    _calibrationFactor = null;
    _calibrationPoints.clear();
    _updateCalibrationInfo();
    await _sendControlOpCode(ControlOpCode.defaultCalibration.value);
  }

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

    // Connection-state listener may have already handled the disconnect.
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

  void _cleanupSubscriptions() {
    _cancelScanTimeoutTimer();
    _scanSubscription?.cancel();
    _notifySubscription?.cancel();
    _notifyEventSubscription?.cancel();
    _connectionSubscription?.cancel();
    _scanSubscription = null;
    _notifySubscription = null;
    _notifyEventSubscription = null;
    _connectionSubscription = null;
  }

  void _cancelScanTimeoutTimer() {
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = null;
  }
}

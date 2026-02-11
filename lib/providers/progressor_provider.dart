import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

  StreamSubscription? _scanSubscription;
  StreamSubscription? _notifySubscription;
  StreamSubscription? _connectionSubscription;
  DateTime? _lastNotifyTime;
  DateTime? _lastUiUpdateTime;
  List<DateTime> _dataTimestamps = [];
  List<WeightMeasurement> _recentMeasurements = [];
  final List<WeightMeasurement> _pendingMeasurements = [];
  final List<double> _notifyIntervalHistory = [];
  double _currentNotifyIntervalMs = 0.0;
  int _dataPacketCount = 0;
  List<int>? _lastRawData;
  double? _calibrationFactor;
  final List<List<double>> _calibrationPoints = [];

  @override
  ProgressorState build() {
    ref.onDispose(() {
      _cleanupSubscriptions();
    });

    _initializeBle();
    return const ProgressorState();
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
    final location = await Permission.location.isGranted ||
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

    FlutterBluePlus.adapterState.listen((BluetoothAdapterState adapterState) {
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
        disconnectDevice();
      }
    });
  }

  Future<void> startScanning() async {
    if (!state.connection.bluetoothReady || state.connection.isScanning) return;

    state = state.copyWith(
      connection: state.connection.copyWith(
        isScanning: true,
        status: 'Scanning for Progressor...',
      ),
    );

    try {
      await FlutterBluePlus.startScan(
        timeout: AppConstants.scanTimeout,
        withServices: [Guid(ProgressorConstants.instance.serviceUuid)],
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          if (result.device.platformName.toLowerCase().contains('progressor') ||
              result.advertisementData.serviceUuids.any(
                (uuid) =>
                    uuid.toString().toLowerCase() ==
                    ProgressorConstants.instance.serviceUuid.toLowerCase(),
              )) {
            _connectToDevice(result.device);
            break;
          }
        }
      });

      Timer(AppConstants.scanExtendedTimeout, () {
        if (state.connection.device == null && state.connection.isScanning) {
          stopScanning();
          state = state.copyWith(
            connection: state.connection.copyWith(
              status: 'Progressor device not found. Please try scanning again.',
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
    if (!state.connection.isScanning) return;

    try {
      await FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();

      state = state.copyWith(
        connection: state.connection.copyWith(
          isScanning: false,
          status: state.connection.device == null
              ? 'Scan stopped'
              : state.connection.status,
        ),
      );
    } catch (e) {
      print('Failed to stop scan: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    stopScanning();

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

      for (final service in services) {
        if (service.uuid.toString().toLowerCase() ==
            ProgressorConstants.instance.serviceUuid.toLowerCase()) {
          BluetoothCharacteristic? notifyChar;
          BluetoothCharacteristic? writeChar;

          for (final characteristic in service.characteristics) {
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

          if (notifyChar != null && writeChar != null) {
            state = state.copyWith(
              connection: state.connection.copyWith(
                notifyCharacteristic: notifyChar,
                writeCharacteristic: writeChar,
                isConnecting: false,
                status: 'Connected to Progressor',
              ),
            );

            _connectionSubscription?.cancel();
            _connectionSubscription =
                device.connectionState.listen((connectionState) {
              if (connectionState == BluetoothConnectionState.disconnected) {
                state = state.copyWith(
                  connection: state.connection.copyWith(
                    device: null,
                    notifyCharacteristic: null,
                    writeCharacteristic: null,
                    isConnecting: false,
                    isScanning: false,
                    status: 'Device disconnected',
                  ),
                );
              }
            });

            await _getFirmwareVersion();
            await _getBatteryVoltage();
            await getCalibration();
          } else {
            state = state.copyWith(
              connection: state.connection.copyWith(
                isConnecting: false,
                status: 'Required characteristics not found',
              ),
            );
          }
        }
      }
    } catch (e) {
      state = state.copyWith(
        connection: state.connection.copyWith(
          isConnecting: false,
          status: 'Connection failed: $e',
        ),
      );
    }
  }

  Future<void> _subscribeToNotifications(
    BluetoothCharacteristic characteristic,
  ) async {
    try {
      _notifySubscription?.cancel();
      final useIndications = characteristic.properties.indicate &&
          !characteristic.properties.notify;
      await characteristic.setNotifyValue(
        true,
        forceIndications: useIndications,
      );
      _notifySubscription = characteristic.onValueReceived.listen((value) {
        _parseReceivedData(value);
      });
    } catch (e) {
      state = state.copyWith(
        connection: state.connection.copyWith(
          status: 'Notification subscription failed: $e',
        ),
      );
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
        print('⚠️ Low battery warning received');
        break;
      default:
        print('Unknown message type: $messageType');
    }
  }

  void _handleWeightMeasurement(List<int> data) {
    if (data.length < 2) return;

    final now = DateTime.now();

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
      final shouldPublish = _lastUiUpdateTime == null ||
          now.difference(_lastUiUpdateTime!) >= _uiUpdateInterval;
      if (!shouldPublish) return;
      _lastUiUpdateTime = now;

      final publishMeasurements =
          List<WeightMeasurement>.from(_pendingMeasurements);
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
          minWeight: state.measurement.minWeight == 0.0 ||
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
      final responseData = Uint8List.fromList(rawData.skip(2).toList());

      // Try to parse as string first (firmware version)
      try {
        final stringResponse = String.fromCharCodes(responseData);
        if (stringResponse.isNotEmpty && !stringResponse.contains('\x00')) {
          state = state.copyWith(
            deviceInfo: state.deviceInfo.copyWith(
              firmwareVersion: stringResponse,
            ),
          );
          return;
        }
      } catch (e) {
        // Not a string, try other formats
      }

      // Try to parse as battery voltage (uint32)
      if (responseData.length >= 4) {
        final byteData = ByteData.view(responseData.buffer);
        final voltage = byteData.getUint32(0, Endian.little);

        state = state.copyWith(
          deviceInfo: state.deviceInfo.copyWith(
            batteryVoltage: voltage.toString(),
          ),
        );
      }
    } catch (e) {
      print('Error parsing command response: $e');
    }
  }

  void _handleCalibrationResponse(List<int> rawData) {
    if (rawData.length < 6) return;

    try {
      final responseData = _payloadFromDataMessage(rawData);
      if (responseData == null || responseData.length < 4) return;

      final byteData =
          ByteData.view(responseData.buffer, responseData.offsetInBytes);
      final calibrationFactor = byteData.getFloat32(0, Endian.little);
      _calibrationPoints.clear();
      _calibrationFactor = calibrationFactor;
      _updateCalibrationInfo();
    } catch (e) {
      print('Error parsing calibration response: $e');
    }
  }

  void _handleCalibrationPointResponse(List<int> rawData) {
    if (rawData.length < 10) return;

    try {
      final responseData = _payloadFromDataMessage(rawData);
      if (responseData == null || responseData.length < 8) return;

      final byteData =
          ByteData.view(responseData.buffer, responseData.offsetInBytes);
      final valueA = byteData.getFloat32(0, Endian.little);
      final valueB = byteData.getFloat32(4, Endian.little);
      _appendCalibrationPoint(valueA, valueB);
      _updateCalibrationInfo();
    } catch (e) {
      print('Error parsing calibration point response: $e');
    }
  }

  Uint8List? _payloadFromDataMessage(List<int> rawData) {
    if (rawData.length < 2) return null;

    final payloadSize = rawData[1];
    if (payloadSize < 0 || rawData.length < payloadSize + 2) {
      return null;
    }

    return Uint8List.fromList(rawData.sublist(2, payloadSize + 2));
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
      lines
          .add('Calibration factor: ${_calibrationFactor!.toStringAsFixed(6)}');
    }

    if (_calibrationPoints.isNotEmpty) {
      lines.add(
        'Calibration points: ${_calibrationPoints.map((point) => '(${point[0].toStringAsFixed(3)}, ${point[1].toStringAsFixed(3)})').join(', ')}',
      );
    }

    state =
        state.copyWith(errorMessage: lines.isEmpty ? null : lines.join('\n'));
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

      final withoutResponse = supportsWrite ? false : true;
      await writeChar.write(data, withoutResponse: withoutResponse);
    } catch (e) {
      state = state.copyWith(
        connection:
            state.connection.copyWith(status: 'Failed to send $action: $e'),
      );
      print('Failed to send $action: $e');
    }
  }

  Future<void> _sendControlOpCode(int opCode,
      [List<int> payload = const []]) async {
    final data = Uint8List(1 + payload.length);
    data[0] = opCode;
    if (payload.isNotEmpty) {
      data.setRange(1, data.length, payload);
    }
    await _writeToDevice(data,
        action: 'control opcode 0x${opCode.toRadixString(16)}');
  }

  Future<void> _getFirmwareVersion() => _sendCommand('k');
  Future<void> _getBatteryVoltage() => _sendCommand('o');

  Future<void> tareScale() async {
    await _sendCommand('d');
    state = state.copyWith(
      deviceInfo: state.deviceInfo.copyWith(
        tareValue: state.measurement.currentWeight,
      ),
    );
  }

  Future<void> startMeasurement() async {
    await _sendCommand('e');
    _pendingMeasurements.clear();
    _recentMeasurements.clear();
    _notifyIntervalHistory.clear();
    _currentNotifyIntervalMs = 0.0;
    _dataPacketCount = 0;
    _lastNotifyTime = null;
    _lastUiUpdateTime = null;
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

    // Flush any throttled samples so the UI shows the latest measurement when stopping.
    if (_pendingMeasurements.isNotEmpty) {
      final publishMeasurements =
          List<WeightMeasurement>.from(_pendingMeasurements);
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

      state = state.copyWith(
        measurement: state.measurement.copyWith(
          currentWeight: lastMeasurement.weight,
          maxWeight: lastMeasurement.weight > state.measurement.maxWeight
              ? lastMeasurement.weight
              : state.measurement.maxWeight,
          minWeight: state.measurement.minWeight == 0.0 ||
                  lastMeasurement.weight < state.measurement.minWeight
              ? lastMeasurement.weight
              : state.measurement.minWeight,
          sampleCount: lastMeasurement.timestampUs,
          weightHistory: newWeightHistory,
          receivedData: newReceivedData,
        ),
      );
    }

    state = state.copyWith(
      measurement: state.measurement.copyWith(isMeasuring: false),
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
    await _sendControlOpCode(ControlOpCode.defaultCalibration.value);
    _calibrationFactor = null;
    _calibrationPoints.clear();
    _updateCalibrationInfo();
  }

  Future<void> disconnectDevice() async {
    try {
      await state.connection.device?.disconnect();
      _cleanupSubscriptions();

      state = state.copyWith(
        connection: const ConnectionState(
          bluetoothReady: true,
          status: 'Disconnected',
        ),
        deviceInfo: const DeviceInfo(),
        measurement: const MeasurementState(),
        performance: const PerformanceMetrics(),
        errorMessage: null,
      );

      _calibrationFactor = null;
      _calibrationPoints.clear();
      _lastNotifyTime = null;
      _lastUiUpdateTime = null;
      _dataTimestamps.clear();
      _recentMeasurements.clear();
      _pendingMeasurements.clear();
      _notifyIntervalHistory.clear();
      _currentNotifyIntervalMs = 0.0;
      _dataPacketCount = 0;
      _lastRawData = null;
    } catch (e) {
      print('Failed to disconnect: $e');
    }
  }

  void _cleanupSubscriptions() {
    _scanSubscription?.cancel();
    _notifySubscription?.cancel();
    _connectionSubscription?.cancel();
    _scanSubscription = null;
    _notifySubscription = null;
    _connectionSubscription = null;
  }
}

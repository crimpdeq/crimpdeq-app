import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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
  StreamSubscription? _scanSubscription;
  StreamSubscription? _notifySubscription;
  DateTime? _lastNotifyTime;
  List<DateTime> _dataTimestamps = [];
  List<WeightMeasurement> _recentMeasurements = [];
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
          status:
              state.connection.device == null
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
      await device.connect();

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

            await _getFirmwareVersion();
            await _getBatteryVoltage();
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
      await characteristic.setNotifyValue(true);
      _notifySubscription = characteristic.lastValueStream.listen((value) {
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

      final newHistory = List<double>.from(
        state.performance.notifyIntervalHistory,
      )..add(currentNotifyIntervalMs);

      if (newHistory.length > AppConstants.maxIntervalHistorySize) {
        newHistory.removeAt(0);
      }

      state = state.copyWith(
        performance: state.performance.copyWith(
          currentNotifyIntervalMs: currentNotifyIntervalMs,
          notifyIntervalHistory: newHistory,
        ),
      );
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

    // Update state with new measurements
    if (newMeasurements.isNotEmpty) {
      final lastMeasurement = newMeasurements.last;
      final newWeightHistory = List<FlSpot>.from(
        state.measurement.weightHistory,
      )..add(FlSpot(lastMeasurement.timestampSec, lastMeasurement.weight));

      if (newWeightHistory.length > AppConstants.maxHistorySize) {
        newWeightHistory.removeAt(0);
      }

      final newReceivedData = List<WeightMeasurement>.from(
        newMeasurements.reversed,
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
          maxWeight:
              lastMeasurement.weight > state.measurement.maxWeight
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
          currentHz: currentHz,
          dataPacketCount: state.performance.dataPacketCount + 1,
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

      debugPrint(
        'Calibration factor payload received: ${responseData.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('-')}',
      );

      final byteData = ByteData.view(responseData.buffer, responseData.offsetInBytes);
      final calibrationFactor = byteData.getFloat32(0, Endian.little);
      debugPrint('Calibration factor parsed: $calibrationFactor');

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

      debugPrint(
        'Calibration point payload received: ${responseData.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('-')}',
      );

      final byteData = ByteData.view(responseData.buffer, responseData.offsetInBytes);
      final valueA = byteData.getFloat32(0, Endian.little);
      final valueB = byteData.getFloat32(4, Endian.little);
      debugPrint('Calibration point parsed: valueA=$valueA, valueB=$valueB');

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
    final factorText =
        _calibrationFactor == null
            ? 'Calibration factor: -'
            : 'Calibration factor: ${_calibrationFactor!.toStringAsFixed(6)}';

    final pointsText =
        _calibrationPoints.isEmpty
            ? 'Calibration points: -'
            : 'Calibration points: ${_calibrationPoints.map((point) => '(${point[0].toStringAsFixed(3)}, ${point[1].toStringAsFixed(3)})').join(', ')}';

    state = state.copyWith(errorMessage: '$factorText\n$pointsText');
  }

  Future<void> _sendCommand(String command) async {
    final writeChar = state.connection.writeCharacteristic;
    if (writeChar == null) return;

    try {
      await writeChar.write(command.codeUnits, withoutResponse: false);
    } catch (e) {
      print('Failed to send command: $e');
    }
  }

  Future<void> _sendControlOpCode(int opCode, [List<int> payload = const []]) async {
    final writeChar = state.connection.writeCharacteristic;
    if (writeChar == null) return;

    try {
      final data = Uint8List(1 + payload.length);
      data[0] = opCode;
      if (payload.isNotEmpty) {
        data.setRange(1, data.length, payload);
      }
      await writeChar.write(data, withoutResponse: false);
    } catch (e) {
      print('Failed to send control opcode: $e');
    }
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
    state = state.copyWith(
      measurement: state.measurement.copyWith(isMeasuring: false),
    );
  }

  Future<void> addCalibrationPoint(double weightKg) async {
    final payload = ByteData(4)..setFloat32(0, weightKg, Endian.big);
    await _sendControlOpCode(
      ControlOpCode.addCalibrationPoint.value,
      payload.buffer.asUint8List(),
    );
  }

  Future<void> getCalibration() async {
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
      _dataTimestamps.clear();
      _recentMeasurements.clear();
      _lastRawData = null;
    } catch (e) {
      print('Failed to disconnect: $e');
    }
  }

  void _cleanupSubscriptions() {
    _scanSubscription?.cancel();
    _notifySubscription?.cancel();
    _scanSubscription = null;
    _notifySubscription = null;
  }
}

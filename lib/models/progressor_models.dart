import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../analysis/calibration_curve.dart';

part 'progressor_models.freezed.dart';

@freezed
sealed class WeightMeasurement with _$WeightMeasurement {
  const WeightMeasurement._();

  const factory WeightMeasurement({
    required double weightKg,

    /// Microseconds since the measurement started on the device.
    required int timestampUs,
  }) = _WeightMeasurement;

  double get timestampSec => timestampUs / Duration.microsecondsPerSecond;
}

/// Raw ADC count (untared) and the known weight that produced it.
typedef CalibrationPoint = ({double raw, double weightKg});

@freezed
sealed class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    @Default('') String firmwareVersion,
    int? batteryMillivolts,

    /// Fuel gauge state of charge. Null for devices that only report the
    /// voltage, whose charge is estimated from it.
    int? batteryPercent,
    @Default(false) bool batteryCharging,

    /// Null until the firmware reports it; firmware without SetSampleRate never does.
    int? sampleRate,

    /// The device warned that the battery is empty and is turning off.
    @Default(false) bool lowBattery,
  }) = _DeviceInfo;
}

@freezed
sealed class PerformanceMetrics with _$PerformanceMetrics {
  const factory PerformanceMetrics({
    @Default(0.0) double currentHz,
    @Default(0.0) double currentNotifyIntervalMs,
    @Default(0) int dataPacketCount,
    @Default(0) int samplesPerPacket,
    @Default([]) List<double> notifyIntervalHistory,
  }) = _PerformanceMetrics;
}

/// Measurement window since the last start, tare or reset.
@freezed
sealed class MeasurementState with _$MeasurementState {
  const factory MeasurementState({
    @Default(false) bool isMeasuring,
    double? currentKg,
    double? minKg,
    double? peakKg,
    double? peakRfdKgPerS,

    /// Device timestamp of the latest sample.
    @Default(0) int elapsedUs,

    /// Mean of each published batch, so the chart does not alias.
    @Default([]) List<FlSpot> weightHistory,

    /// Latest samples, newest first.
    @Default([]) List<WeightMeasurement> receivedData,
  }) = _MeasurementState;
}

/// Mirror of the calibration stored on the device.
@freezed
sealed class CalibrationState with _$CalibrationState {
  const factory CalibrationState({
    /// Linear factor in g per count; null for a nonlinear calibration.
    double? factor,
    @Default([]) List<CalibrationPoint> points,

    /// Whether the firmware has calibration models, null until known.
    /// Firmware without them has only the linear model.
    bool? supportsModels,

    /// Calibration the firmware reports, null until read and for firmware
    /// without calibration models.
    CalibrationDetails? details,
    @Default(false) bool waitingForSteadyLoad,

    /// A removal shifts the indexes of the later points, so adding and
    /// removing points wait for it.
    @Default(false) bool removingPoint,

    /// A model selection or zero update waits for the device.
    @Default(false) bool changingModel,
  }) = _CalibrationState;
}

@freezed
sealed class DiscoveredDevice with _$DiscoveredDevice {
  const factory DiscoveredDevice({
    required String id,
    required String name,
    required int rssi,
    required BluetoothDevice device,
  }) = _DiscoveredDevice;
}

@freezed
sealed class DeviceConnection with _$DeviceConnection {
  const DeviceConnection._();

  const factory DeviceConnection({
    BluetoothDevice? device,

    /// Name the device was discovered with, set together with [device].
    @Default('') String deviceName,
    BluetoothCharacteristic? writeCharacteristic,
    @Default('Initializing Bluetooth...') String status,
    @Default(false) bool isScanning,
    @Default(false) bool isConnecting,
    @Default(false) bool bluetoothReady,

    /// Scanning failed or Bluetooth is unauthorized; the fix is in the app
    /// settings (permissions) or the system settings (location services).
    @Default(false) bool needsSettings,
    @Default([]) List<DiscoveredDevice> discoveredDevices,
  }) = _DeviceConnection;

  bool get isConnected => device != null && writeCharacteristic != null;
}

@freezed
sealed class ProgressorState with _$ProgressorState {
  const factory ProgressorState({
    @Default(DeviceConnection()) DeviceConnection connection,
    @Default(DeviceInfo()) DeviceInfo deviceInfo,
    @Default(MeasurementState()) MeasurementState measurement,
    @Default(PerformanceMetrics()) PerformanceMetrics performance,
    @Default(CalibrationState()) CalibrationState calibration,
  }) = _ProgressorState;
}

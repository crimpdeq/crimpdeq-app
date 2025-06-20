import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'progressor_models.freezed.dart';

@freezed
class WeightMeasurement with _$WeightMeasurement {
  const WeightMeasurement._();

  const factory WeightMeasurement({
    required double weight,
    required int timestampUs,
    required DateTime receivedAt,
  }) = _WeightMeasurement;

  double get timestampSec => timestampUs / 1000000.0;
}

@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    @Default('') String firmwareVersion,
    @Default('') String batteryVoltage,
    @Default(0.0) double tareValue,
  }) = _DeviceInfo;
}

@freezed
class PerformanceMetrics with _$PerformanceMetrics {
  const factory PerformanceMetrics({
    @Default(0.0) double currentHz,
    @Default(0.0) double currentNotifyIntervalMs,
    @Default(0) int dataPacketCount,
    @Default(0) int duplicatePacketCount,
    @Default(1) int samplesPerPacket,
    @Default([]) List<double> notifyIntervalHistory,
  }) = _PerformanceMetrics;
}

@freezed
class MeasurementState with _$MeasurementState {
  const factory MeasurementState({
    @Default(0.0) double currentWeight,
    @Default(0.0) double maxWeight,
    @Default(0.0) double minWeight,
    @Default(0) int sampleCount,
    @Default(false) bool isMeasuring,
    @Default([]) List<FlSpot> weightHistory,
    @Default([]) List<WeightMeasurement> receivedData,
  }) = _MeasurementState;
}

@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState({
    BluetoothDevice? device,
    BluetoothCharacteristic? notifyCharacteristic,
    BluetoothCharacteristic? writeCharacteristic,
    @Default('Scanning...') String status,
    @Default(false) bool isScanning,
    @Default(false) bool isConnecting,
    @Default(false) bool bluetoothReady,
  }) = _ConnectionState;
}

@freezed
class ProgressorState with _$ProgressorState {
  const factory ProgressorState({
    @Default(ConnectionState()) ConnectionState connection,
    @Default(DeviceInfo()) DeviceInfo deviceInfo,
    @Default(MeasurementState()) MeasurementState measurement,
    @Default(PerformanceMetrics()) PerformanceMetrics performance,
    String? errorMessage,
  }) = _ProgressorState;
}

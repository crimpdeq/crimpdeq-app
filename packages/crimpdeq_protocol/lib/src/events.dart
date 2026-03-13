import 'models.dart';

/// Typed events emitted by [ProgressorProtocol] when BLE notifications arrive.
sealed class ProgressorEvent {
  const ProgressorEvent();
}

/// One or more weight samples parsed from a single notification packet.
class WeightEvent extends ProgressorEvent {
  final List<WeightMeasurement> measurements;

  const WeightEvent(this.measurements);
}

/// Firmware version string returned by the device.
class FirmwareVersionEvent extends ProgressorEvent {
  final String version;

  const FirmwareVersionEvent(this.version);
}

/// Battery voltage in millivolts.
class BatteryVoltageEvent extends ProgressorEvent {
  final int millivolts;

  const BatteryVoltageEvent(this.millivolts);
}

/// Low-battery warning flag (no payload).
class LowBatteryEvent extends ProgressorEvent {
  const LowBatteryEvent();
}

/// Calibration factor received from the device.
class CalibrationFactorEvent extends ProgressorEvent {
  final double factor;

  const CalibrationFactorEvent(this.factor);
}

/// Single calibration point (two floats).
class CalibrationPointEvent extends ProgressorEvent {
  final double valueA;
  final double valueB;

  const CalibrationPointEvent(this.valueA, this.valueB);
}

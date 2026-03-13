/// BLE UUIDs, message-type identifiers, and control op-codes for the
/// Tindeq Progressor protocol.
class ProgressorConstants {
  const ProgressorConstants._();

  // BLE service & characteristic UUIDs
  static const serviceUuid = '7e4e1701-1ea6-40c9-9dcc-13d34ffead57';
  static const notifyCharUuid = '7e4e1702-1ea6-40c9-9dcc-13d34ffead57';
  static const writeCharUuid = '7e4e1703-1ea6-40c9-9dcc-13d34ffead57';

  // Notification message types
  static const commandResponse = 0;
  static const weightMeasure = 1;
  static const peakRfdMeas = 2;
  static const peakRfdMeasSeries = 3;
  static const lowBatteryWarning = 4;
}

enum ControlOpCode {
  getCalibration(0x72),
  addCalibrationPoint(0x69),
  defaultCalibration(0x74);

  const ControlOpCode(this.value);

  final int value;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'progressor_constants.freezed.dart';

@freezed
sealed class ProgressorConstants with _$ProgressorConstants {
  const factory ProgressorConstants({
    required String serviceUuid,
    required String notifyCharUuid,
    required String writeCharUuid,
    required int commandResponse,
    required int weightMeasure,
    required int peakRfdMeas,
    required int peakRfdMeasSeries,
    required int lowBatteryWarning,
  }) = _ProgressorConstants;

  static const instance = ProgressorConstants(
    serviceUuid: '7e4e1701-1ea6-40c9-9dcc-13d34ffead57',
    notifyCharUuid: '7e4e1702-1ea6-40c9-9dcc-13d34ffead57',
    writeCharUuid: '7e4e1703-1ea6-40c9-9dcc-13d34ffead57',
    commandResponse: 0,
    weightMeasure: 1,
    peakRfdMeas: 2,
    peakRfdMeasSeries: 3,
    lowBatteryWarning: 4,
  );
}

class AppConstants {
  static const int maxHistorySize = 100;
  static const int maxIntervalHistorySize = 100;
  static const int maxReceivedDataSize = 10;
  static const Duration scanTimeout = Duration(seconds: 10);
  static const Duration scanExtendedTimeout = Duration(seconds: 12);
  // ADS1220 normal-mode data rates supported by the firmware, with their use
  // case. Lower rates filter more noise in the ADC; higher rates resolve
  // faster force changes.
  static const Map<int, String> sampleRateUseCases = {
    20: 'Precision',
    45: 'Precision',
    90: 'Precision',
    175: 'Balanced',
    330: 'Balanced',
    600: 'Balanced',
    1000: 'RFD',
  };
  static const int defaultSampleRate = 600;
}

enum ControlOpCode {
  getCalibration(0x72),
  addCalibrationPoint(0x69),
  defaultCalibration(0x74),
  setSampleRate(0x75);

  const ControlOpCode(this.value);

  final int value;
}

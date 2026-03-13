import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

@freezed
sealed class WeightMeasurement with _$WeightMeasurement {
  const WeightMeasurement._();

  const factory WeightMeasurement({
    required double weight,
    required int timestampUs,
    required DateTime receivedAt,
  }) = _WeightMeasurement;

  double get timestampSec => timestampUs / 1000000.0;
}

@freezed
sealed class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    @Default('') String firmwareVersion,
    @Default('') String batteryVoltage,
    @Default(0.0) double tareValue,
  }) = _DeviceInfo;
}

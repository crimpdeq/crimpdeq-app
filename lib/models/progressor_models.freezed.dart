// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progressor_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WeightMeasurement {
  double get weight => throw _privateConstructorUsedError;
  int get timestampUs => throw _privateConstructorUsedError;
  DateTime get receivedAt => throw _privateConstructorUsedError;

  /// Create a copy of WeightMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeightMeasurementCopyWith<WeightMeasurement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeightMeasurementCopyWith<$Res> {
  factory $WeightMeasurementCopyWith(
    WeightMeasurement value,
    $Res Function(WeightMeasurement) then,
  ) = _$WeightMeasurementCopyWithImpl<$Res, WeightMeasurement>;
  @useResult
  $Res call({double weight, int timestampUs, DateTime receivedAt});
}

/// @nodoc
class _$WeightMeasurementCopyWithImpl<$Res, $Val extends WeightMeasurement>
    implements $WeightMeasurementCopyWith<$Res> {
  _$WeightMeasurementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeightMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? timestampUs = null,
    Object? receivedAt = null,
  }) {
    return _then(
      _value.copyWith(
            weight:
                null == weight
                    ? _value.weight
                    : weight // ignore: cast_nullable_to_non_nullable
                        as double,
            timestampUs:
                null == timestampUs
                    ? _value.timestampUs
                    : timestampUs // ignore: cast_nullable_to_non_nullable
                        as int,
            receivedAt:
                null == receivedAt
                    ? _value.receivedAt
                    : receivedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeightMeasurementImplCopyWith<$Res>
    implements $WeightMeasurementCopyWith<$Res> {
  factory _$$WeightMeasurementImplCopyWith(
    _$WeightMeasurementImpl value,
    $Res Function(_$WeightMeasurementImpl) then,
  ) = __$$WeightMeasurementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double weight, int timestampUs, DateTime receivedAt});
}

/// @nodoc
class __$$WeightMeasurementImplCopyWithImpl<$Res>
    extends _$WeightMeasurementCopyWithImpl<$Res, _$WeightMeasurementImpl>
    implements _$$WeightMeasurementImplCopyWith<$Res> {
  __$$WeightMeasurementImplCopyWithImpl(
    _$WeightMeasurementImpl _value,
    $Res Function(_$WeightMeasurementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeightMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? timestampUs = null,
    Object? receivedAt = null,
  }) {
    return _then(
      _$WeightMeasurementImpl(
        weight:
            null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                    as double,
        timestampUs:
            null == timestampUs
                ? _value.timestampUs
                : timestampUs // ignore: cast_nullable_to_non_nullable
                    as int,
        receivedAt:
            null == receivedAt
                ? _value.receivedAt
                : receivedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$WeightMeasurementImpl extends _WeightMeasurement {
  const _$WeightMeasurementImpl({
    required this.weight,
    required this.timestampUs,
    required this.receivedAt,
  }) : super._();

  @override
  final double weight;
  @override
  final int timestampUs;
  @override
  final DateTime receivedAt;

  @override
  String toString() {
    return 'WeightMeasurement(weight: $weight, timestampUs: $timestampUs, receivedAt: $receivedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightMeasurementImpl &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.timestampUs, timestampUs) ||
                other.timestampUs == timestampUs) &&
            (identical(other.receivedAt, receivedAt) ||
                other.receivedAt == receivedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, weight, timestampUs, receivedAt);

  /// Create a copy of WeightMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightMeasurementImplCopyWith<_$WeightMeasurementImpl> get copyWith =>
      __$$WeightMeasurementImplCopyWithImpl<_$WeightMeasurementImpl>(
        this,
        _$identity,
      );
}

abstract class _WeightMeasurement extends WeightMeasurement {
  const factory _WeightMeasurement({
    required final double weight,
    required final int timestampUs,
    required final DateTime receivedAt,
  }) = _$WeightMeasurementImpl;
  const _WeightMeasurement._() : super._();

  @override
  double get weight;
  @override
  int get timestampUs;
  @override
  DateTime get receivedAt;

  /// Create a copy of WeightMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeightMeasurementImplCopyWith<_$WeightMeasurementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DeviceInfo {
  String get firmwareVersion => throw _privateConstructorUsedError;
  String get batteryVoltage => throw _privateConstructorUsedError;
  double get tareValue => throw _privateConstructorUsedError;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceInfoCopyWith<DeviceInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceInfoCopyWith<$Res> {
  factory $DeviceInfoCopyWith(
    DeviceInfo value,
    $Res Function(DeviceInfo) then,
  ) = _$DeviceInfoCopyWithImpl<$Res, DeviceInfo>;
  @useResult
  $Res call({String firmwareVersion, String batteryVoltage, double tareValue});
}

/// @nodoc
class _$DeviceInfoCopyWithImpl<$Res, $Val extends DeviceInfo>
    implements $DeviceInfoCopyWith<$Res> {
  _$DeviceInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firmwareVersion = null,
    Object? batteryVoltage = null,
    Object? tareValue = null,
  }) {
    return _then(
      _value.copyWith(
            firmwareVersion:
                null == firmwareVersion
                    ? _value.firmwareVersion
                    : firmwareVersion // ignore: cast_nullable_to_non_nullable
                        as String,
            batteryVoltage:
                null == batteryVoltage
                    ? _value.batteryVoltage
                    : batteryVoltage // ignore: cast_nullable_to_non_nullable
                        as String,
            tareValue:
                null == tareValue
                    ? _value.tareValue
                    : tareValue // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceInfoImplCopyWith<$Res>
    implements $DeviceInfoCopyWith<$Res> {
  factory _$$DeviceInfoImplCopyWith(
    _$DeviceInfoImpl value,
    $Res Function(_$DeviceInfoImpl) then,
  ) = __$$DeviceInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String firmwareVersion, String batteryVoltage, double tareValue});
}

/// @nodoc
class __$$DeviceInfoImplCopyWithImpl<$Res>
    extends _$DeviceInfoCopyWithImpl<$Res, _$DeviceInfoImpl>
    implements _$$DeviceInfoImplCopyWith<$Res> {
  __$$DeviceInfoImplCopyWithImpl(
    _$DeviceInfoImpl _value,
    $Res Function(_$DeviceInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firmwareVersion = null,
    Object? batteryVoltage = null,
    Object? tareValue = null,
  }) {
    return _then(
      _$DeviceInfoImpl(
        firmwareVersion:
            null == firmwareVersion
                ? _value.firmwareVersion
                : firmwareVersion // ignore: cast_nullable_to_non_nullable
                    as String,
        batteryVoltage:
            null == batteryVoltage
                ? _value.batteryVoltage
                : batteryVoltage // ignore: cast_nullable_to_non_nullable
                    as String,
        tareValue:
            null == tareValue
                ? _value.tareValue
                : tareValue // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc

class _$DeviceInfoImpl implements _DeviceInfo {
  const _$DeviceInfoImpl({
    this.firmwareVersion = '',
    this.batteryVoltage = '',
    this.tareValue = 0.0,
  });

  @override
  @JsonKey()
  final String firmwareVersion;
  @override
  @JsonKey()
  final String batteryVoltage;
  @override
  @JsonKey()
  final double tareValue;

  @override
  String toString() {
    return 'DeviceInfo(firmwareVersion: $firmwareVersion, batteryVoltage: $batteryVoltage, tareValue: $tareValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceInfoImpl &&
            (identical(other.firmwareVersion, firmwareVersion) ||
                other.firmwareVersion == firmwareVersion) &&
            (identical(other.batteryVoltage, batteryVoltage) ||
                other.batteryVoltage == batteryVoltage) &&
            (identical(other.tareValue, tareValue) ||
                other.tareValue == tareValue));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, firmwareVersion, batteryVoltage, tareValue);

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      __$$DeviceInfoImplCopyWithImpl<_$DeviceInfoImpl>(this, _$identity);
}

abstract class _DeviceInfo implements DeviceInfo {
  const factory _DeviceInfo({
    final String firmwareVersion,
    final String batteryVoltage,
    final double tareValue,
  }) = _$DeviceInfoImpl;

  @override
  String get firmwareVersion;
  @override
  String get batteryVoltage;
  @override
  double get tareValue;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PerformanceMetrics {
  double get currentHz => throw _privateConstructorUsedError;
  double get currentNotifyIntervalMs => throw _privateConstructorUsedError;
  int get dataPacketCount => throw _privateConstructorUsedError;
  int get duplicatePacketCount => throw _privateConstructorUsedError;
  int get samplesPerPacket => throw _privateConstructorUsedError;
  List<double> get notifyIntervalHistory => throw _privateConstructorUsedError;

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PerformanceMetricsCopyWith<PerformanceMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerformanceMetricsCopyWith<$Res> {
  factory $PerformanceMetricsCopyWith(
    PerformanceMetrics value,
    $Res Function(PerformanceMetrics) then,
  ) = _$PerformanceMetricsCopyWithImpl<$Res, PerformanceMetrics>;
  @useResult
  $Res call({
    double currentHz,
    double currentNotifyIntervalMs,
    int dataPacketCount,
    int duplicatePacketCount,
    int samplesPerPacket,
    List<double> notifyIntervalHistory,
  });
}

/// @nodoc
class _$PerformanceMetricsCopyWithImpl<$Res, $Val extends PerformanceMetrics>
    implements $PerformanceMetricsCopyWith<$Res> {
  _$PerformanceMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentHz = null,
    Object? currentNotifyIntervalMs = null,
    Object? dataPacketCount = null,
    Object? duplicatePacketCount = null,
    Object? samplesPerPacket = null,
    Object? notifyIntervalHistory = null,
  }) {
    return _then(
      _value.copyWith(
            currentHz:
                null == currentHz
                    ? _value.currentHz
                    : currentHz // ignore: cast_nullable_to_non_nullable
                        as double,
            currentNotifyIntervalMs:
                null == currentNotifyIntervalMs
                    ? _value.currentNotifyIntervalMs
                    : currentNotifyIntervalMs // ignore: cast_nullable_to_non_nullable
                        as double,
            dataPacketCount:
                null == dataPacketCount
                    ? _value.dataPacketCount
                    : dataPacketCount // ignore: cast_nullable_to_non_nullable
                        as int,
            duplicatePacketCount:
                null == duplicatePacketCount
                    ? _value.duplicatePacketCount
                    : duplicatePacketCount // ignore: cast_nullable_to_non_nullable
                        as int,
            samplesPerPacket:
                null == samplesPerPacket
                    ? _value.samplesPerPacket
                    : samplesPerPacket // ignore: cast_nullable_to_non_nullable
                        as int,
            notifyIntervalHistory:
                null == notifyIntervalHistory
                    ? _value.notifyIntervalHistory
                    : notifyIntervalHistory // ignore: cast_nullable_to_non_nullable
                        as List<double>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PerformanceMetricsImplCopyWith<$Res>
    implements $PerformanceMetricsCopyWith<$Res> {
  factory _$$PerformanceMetricsImplCopyWith(
    _$PerformanceMetricsImpl value,
    $Res Function(_$PerformanceMetricsImpl) then,
  ) = __$$PerformanceMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double currentHz,
    double currentNotifyIntervalMs,
    int dataPacketCount,
    int duplicatePacketCount,
    int samplesPerPacket,
    List<double> notifyIntervalHistory,
  });
}

/// @nodoc
class __$$PerformanceMetricsImplCopyWithImpl<$Res>
    extends _$PerformanceMetricsCopyWithImpl<$Res, _$PerformanceMetricsImpl>
    implements _$$PerformanceMetricsImplCopyWith<$Res> {
  __$$PerformanceMetricsImplCopyWithImpl(
    _$PerformanceMetricsImpl _value,
    $Res Function(_$PerformanceMetricsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentHz = null,
    Object? currentNotifyIntervalMs = null,
    Object? dataPacketCount = null,
    Object? duplicatePacketCount = null,
    Object? samplesPerPacket = null,
    Object? notifyIntervalHistory = null,
  }) {
    return _then(
      _$PerformanceMetricsImpl(
        currentHz:
            null == currentHz
                ? _value.currentHz
                : currentHz // ignore: cast_nullable_to_non_nullable
                    as double,
        currentNotifyIntervalMs:
            null == currentNotifyIntervalMs
                ? _value.currentNotifyIntervalMs
                : currentNotifyIntervalMs // ignore: cast_nullable_to_non_nullable
                    as double,
        dataPacketCount:
            null == dataPacketCount
                ? _value.dataPacketCount
                : dataPacketCount // ignore: cast_nullable_to_non_nullable
                    as int,
        duplicatePacketCount:
            null == duplicatePacketCount
                ? _value.duplicatePacketCount
                : duplicatePacketCount // ignore: cast_nullable_to_non_nullable
                    as int,
        samplesPerPacket:
            null == samplesPerPacket
                ? _value.samplesPerPacket
                : samplesPerPacket // ignore: cast_nullable_to_non_nullable
                    as int,
        notifyIntervalHistory:
            null == notifyIntervalHistory
                ? _value._notifyIntervalHistory
                : notifyIntervalHistory // ignore: cast_nullable_to_non_nullable
                    as List<double>,
      ),
    );
  }
}

/// @nodoc

class _$PerformanceMetricsImpl implements _PerformanceMetrics {
  const _$PerformanceMetricsImpl({
    this.currentHz = 0.0,
    this.currentNotifyIntervalMs = 0.0,
    this.dataPacketCount = 0,
    this.duplicatePacketCount = 0,
    this.samplesPerPacket = 1,
    final List<double> notifyIntervalHistory = const [],
  }) : _notifyIntervalHistory = notifyIntervalHistory;

  @override
  @JsonKey()
  final double currentHz;
  @override
  @JsonKey()
  final double currentNotifyIntervalMs;
  @override
  @JsonKey()
  final int dataPacketCount;
  @override
  @JsonKey()
  final int duplicatePacketCount;
  @override
  @JsonKey()
  final int samplesPerPacket;
  final List<double> _notifyIntervalHistory;
  @override
  @JsonKey()
  List<double> get notifyIntervalHistory {
    if (_notifyIntervalHistory is EqualUnmodifiableListView)
      return _notifyIntervalHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifyIntervalHistory);
  }

  @override
  String toString() {
    return 'PerformanceMetrics(currentHz: $currentHz, currentNotifyIntervalMs: $currentNotifyIntervalMs, dataPacketCount: $dataPacketCount, duplicatePacketCount: $duplicatePacketCount, samplesPerPacket: $samplesPerPacket, notifyIntervalHistory: $notifyIntervalHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerformanceMetricsImpl &&
            (identical(other.currentHz, currentHz) ||
                other.currentHz == currentHz) &&
            (identical(
                  other.currentNotifyIntervalMs,
                  currentNotifyIntervalMs,
                ) ||
                other.currentNotifyIntervalMs == currentNotifyIntervalMs) &&
            (identical(other.dataPacketCount, dataPacketCount) ||
                other.dataPacketCount == dataPacketCount) &&
            (identical(other.duplicatePacketCount, duplicatePacketCount) ||
                other.duplicatePacketCount == duplicatePacketCount) &&
            (identical(other.samplesPerPacket, samplesPerPacket) ||
                other.samplesPerPacket == samplesPerPacket) &&
            const DeepCollectionEquality().equals(
              other._notifyIntervalHistory,
              _notifyIntervalHistory,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentHz,
    currentNotifyIntervalMs,
    dataPacketCount,
    duplicatePacketCount,
    samplesPerPacket,
    const DeepCollectionEquality().hash(_notifyIntervalHistory),
  );

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PerformanceMetricsImplCopyWith<_$PerformanceMetricsImpl> get copyWith =>
      __$$PerformanceMetricsImplCopyWithImpl<_$PerformanceMetricsImpl>(
        this,
        _$identity,
      );
}

abstract class _PerformanceMetrics implements PerformanceMetrics {
  const factory _PerformanceMetrics({
    final double currentHz,
    final double currentNotifyIntervalMs,
    final int dataPacketCount,
    final int duplicatePacketCount,
    final int samplesPerPacket,
    final List<double> notifyIntervalHistory,
  }) = _$PerformanceMetricsImpl;

  @override
  double get currentHz;
  @override
  double get currentNotifyIntervalMs;
  @override
  int get dataPacketCount;
  @override
  int get duplicatePacketCount;
  @override
  int get samplesPerPacket;
  @override
  List<double> get notifyIntervalHistory;

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PerformanceMetricsImplCopyWith<_$PerformanceMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MeasurementState {
  double get currentWeight => throw _privateConstructorUsedError;
  double get maxWeight => throw _privateConstructorUsedError;
  double get minWeight => throw _privateConstructorUsedError;
  int get sampleCount => throw _privateConstructorUsedError;
  bool get isMeasuring => throw _privateConstructorUsedError;
  List<FlSpot> get weightHistory => throw _privateConstructorUsedError;
  List<WeightMeasurement> get receivedData =>
      throw _privateConstructorUsedError;

  /// Create a copy of MeasurementState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasurementStateCopyWith<MeasurementState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementStateCopyWith<$Res> {
  factory $MeasurementStateCopyWith(
    MeasurementState value,
    $Res Function(MeasurementState) then,
  ) = _$MeasurementStateCopyWithImpl<$Res, MeasurementState>;
  @useResult
  $Res call({
    double currentWeight,
    double maxWeight,
    double minWeight,
    int sampleCount,
    bool isMeasuring,
    List<FlSpot> weightHistory,
    List<WeightMeasurement> receivedData,
  });
}

/// @nodoc
class _$MeasurementStateCopyWithImpl<$Res, $Val extends MeasurementState>
    implements $MeasurementStateCopyWith<$Res> {
  _$MeasurementStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeasurementState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentWeight = null,
    Object? maxWeight = null,
    Object? minWeight = null,
    Object? sampleCount = null,
    Object? isMeasuring = null,
    Object? weightHistory = null,
    Object? receivedData = null,
  }) {
    return _then(
      _value.copyWith(
            currentWeight:
                null == currentWeight
                    ? _value.currentWeight
                    : currentWeight // ignore: cast_nullable_to_non_nullable
                        as double,
            maxWeight:
                null == maxWeight
                    ? _value.maxWeight
                    : maxWeight // ignore: cast_nullable_to_non_nullable
                        as double,
            minWeight:
                null == minWeight
                    ? _value.minWeight
                    : minWeight // ignore: cast_nullable_to_non_nullable
                        as double,
            sampleCount:
                null == sampleCount
                    ? _value.sampleCount
                    : sampleCount // ignore: cast_nullable_to_non_nullable
                        as int,
            isMeasuring:
                null == isMeasuring
                    ? _value.isMeasuring
                    : isMeasuring // ignore: cast_nullable_to_non_nullable
                        as bool,
            weightHistory:
                null == weightHistory
                    ? _value.weightHistory
                    : weightHistory // ignore: cast_nullable_to_non_nullable
                        as List<FlSpot>,
            receivedData:
                null == receivedData
                    ? _value.receivedData
                    : receivedData // ignore: cast_nullable_to_non_nullable
                        as List<WeightMeasurement>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeasurementStateImplCopyWith<$Res>
    implements $MeasurementStateCopyWith<$Res> {
  factory _$$MeasurementStateImplCopyWith(
    _$MeasurementStateImpl value,
    $Res Function(_$MeasurementStateImpl) then,
  ) = __$$MeasurementStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double currentWeight,
    double maxWeight,
    double minWeight,
    int sampleCount,
    bool isMeasuring,
    List<FlSpot> weightHistory,
    List<WeightMeasurement> receivedData,
  });
}

/// @nodoc
class __$$MeasurementStateImplCopyWithImpl<$Res>
    extends _$MeasurementStateCopyWithImpl<$Res, _$MeasurementStateImpl>
    implements _$$MeasurementStateImplCopyWith<$Res> {
  __$$MeasurementStateImplCopyWithImpl(
    _$MeasurementStateImpl _value,
    $Res Function(_$MeasurementStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeasurementState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentWeight = null,
    Object? maxWeight = null,
    Object? minWeight = null,
    Object? sampleCount = null,
    Object? isMeasuring = null,
    Object? weightHistory = null,
    Object? receivedData = null,
  }) {
    return _then(
      _$MeasurementStateImpl(
        currentWeight:
            null == currentWeight
                ? _value.currentWeight
                : currentWeight // ignore: cast_nullable_to_non_nullable
                    as double,
        maxWeight:
            null == maxWeight
                ? _value.maxWeight
                : maxWeight // ignore: cast_nullable_to_non_nullable
                    as double,
        minWeight:
            null == minWeight
                ? _value.minWeight
                : minWeight // ignore: cast_nullable_to_non_nullable
                    as double,
        sampleCount:
            null == sampleCount
                ? _value.sampleCount
                : sampleCount // ignore: cast_nullable_to_non_nullable
                    as int,
        isMeasuring:
            null == isMeasuring
                ? _value.isMeasuring
                : isMeasuring // ignore: cast_nullable_to_non_nullable
                    as bool,
        weightHistory:
            null == weightHistory
                ? _value._weightHistory
                : weightHistory // ignore: cast_nullable_to_non_nullable
                    as List<FlSpot>,
        receivedData:
            null == receivedData
                ? _value._receivedData
                : receivedData // ignore: cast_nullable_to_non_nullable
                    as List<WeightMeasurement>,
      ),
    );
  }
}

/// @nodoc

class _$MeasurementStateImpl implements _MeasurementState {
  const _$MeasurementStateImpl({
    this.currentWeight = 0.0,
    this.maxWeight = 0.0,
    this.minWeight = 0.0,
    this.sampleCount = 0,
    this.isMeasuring = false,
    final List<FlSpot> weightHistory = const [],
    final List<WeightMeasurement> receivedData = const [],
  }) : _weightHistory = weightHistory,
       _receivedData = receivedData;

  @override
  @JsonKey()
  final double currentWeight;
  @override
  @JsonKey()
  final double maxWeight;
  @override
  @JsonKey()
  final double minWeight;
  @override
  @JsonKey()
  final int sampleCount;
  @override
  @JsonKey()
  final bool isMeasuring;
  final List<FlSpot> _weightHistory;
  @override
  @JsonKey()
  List<FlSpot> get weightHistory {
    if (_weightHistory is EqualUnmodifiableListView) return _weightHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weightHistory);
  }

  final List<WeightMeasurement> _receivedData;
  @override
  @JsonKey()
  List<WeightMeasurement> get receivedData {
    if (_receivedData is EqualUnmodifiableListView) return _receivedData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_receivedData);
  }

  @override
  String toString() {
    return 'MeasurementState(currentWeight: $currentWeight, maxWeight: $maxWeight, minWeight: $minWeight, sampleCount: $sampleCount, isMeasuring: $isMeasuring, weightHistory: $weightHistory, receivedData: $receivedData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementStateImpl &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight) &&
            (identical(other.maxWeight, maxWeight) ||
                other.maxWeight == maxWeight) &&
            (identical(other.minWeight, minWeight) ||
                other.minWeight == minWeight) &&
            (identical(other.sampleCount, sampleCount) ||
                other.sampleCount == sampleCount) &&
            (identical(other.isMeasuring, isMeasuring) ||
                other.isMeasuring == isMeasuring) &&
            const DeepCollectionEquality().equals(
              other._weightHistory,
              _weightHistory,
            ) &&
            const DeepCollectionEquality().equals(
              other._receivedData,
              _receivedData,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentWeight,
    maxWeight,
    minWeight,
    sampleCount,
    isMeasuring,
    const DeepCollectionEquality().hash(_weightHistory),
    const DeepCollectionEquality().hash(_receivedData),
  );

  /// Create a copy of MeasurementState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementStateImplCopyWith<_$MeasurementStateImpl> get copyWith =>
      __$$MeasurementStateImplCopyWithImpl<_$MeasurementStateImpl>(
        this,
        _$identity,
      );
}

abstract class _MeasurementState implements MeasurementState {
  const factory _MeasurementState({
    final double currentWeight,
    final double maxWeight,
    final double minWeight,
    final int sampleCount,
    final bool isMeasuring,
    final List<FlSpot> weightHistory,
    final List<WeightMeasurement> receivedData,
  }) = _$MeasurementStateImpl;

  @override
  double get currentWeight;
  @override
  double get maxWeight;
  @override
  double get minWeight;
  @override
  int get sampleCount;
  @override
  bool get isMeasuring;
  @override
  List<FlSpot> get weightHistory;
  @override
  List<WeightMeasurement> get receivedData;

  /// Create a copy of MeasurementState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasurementStateImplCopyWith<_$MeasurementStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ConnectionState {
  BluetoothDevice? get device => throw _privateConstructorUsedError;
  BluetoothCharacteristic? get notifyCharacteristic =>
      throw _privateConstructorUsedError;
  BluetoothCharacteristic? get writeCharacteristic =>
      throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  bool get isScanning => throw _privateConstructorUsedError;
  bool get isConnecting => throw _privateConstructorUsedError;
  bool get bluetoothReady => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionStateCopyWith<ConnectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionStateCopyWith<$Res> {
  factory $ConnectionStateCopyWith(
    ConnectionState value,
    $Res Function(ConnectionState) then,
  ) = _$ConnectionStateCopyWithImpl<$Res, ConnectionState>;
  @useResult
  $Res call({
    BluetoothDevice? device,
    BluetoothCharacteristic? notifyCharacteristic,
    BluetoothCharacteristic? writeCharacteristic,
    String status,
    bool isScanning,
    bool isConnecting,
    bool bluetoothReady,
  });
}

/// @nodoc
class _$ConnectionStateCopyWithImpl<$Res, $Val extends ConnectionState>
    implements $ConnectionStateCopyWith<$Res> {
  _$ConnectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? device = freezed,
    Object? notifyCharacteristic = freezed,
    Object? writeCharacteristic = freezed,
    Object? status = null,
    Object? isScanning = null,
    Object? isConnecting = null,
    Object? bluetoothReady = null,
  }) {
    return _then(
      _value.copyWith(
            device:
                freezed == device
                    ? _value.device
                    : device // ignore: cast_nullable_to_non_nullable
                        as BluetoothDevice?,
            notifyCharacteristic:
                freezed == notifyCharacteristic
                    ? _value.notifyCharacteristic
                    : notifyCharacteristic // ignore: cast_nullable_to_non_nullable
                        as BluetoothCharacteristic?,
            writeCharacteristic:
                freezed == writeCharacteristic
                    ? _value.writeCharacteristic
                    : writeCharacteristic // ignore: cast_nullable_to_non_nullable
                        as BluetoothCharacteristic?,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            isScanning:
                null == isScanning
                    ? _value.isScanning
                    : isScanning // ignore: cast_nullable_to_non_nullable
                        as bool,
            isConnecting:
                null == isConnecting
                    ? _value.isConnecting
                    : isConnecting // ignore: cast_nullable_to_non_nullable
                        as bool,
            bluetoothReady:
                null == bluetoothReady
                    ? _value.bluetoothReady
                    : bluetoothReady // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConnectionStateImplCopyWith<$Res>
    implements $ConnectionStateCopyWith<$Res> {
  factory _$$ConnectionStateImplCopyWith(
    _$ConnectionStateImpl value,
    $Res Function(_$ConnectionStateImpl) then,
  ) = __$$ConnectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BluetoothDevice? device,
    BluetoothCharacteristic? notifyCharacteristic,
    BluetoothCharacteristic? writeCharacteristic,
    String status,
    bool isScanning,
    bool isConnecting,
    bool bluetoothReady,
  });
}

/// @nodoc
class __$$ConnectionStateImplCopyWithImpl<$Res>
    extends _$ConnectionStateCopyWithImpl<$Res, _$ConnectionStateImpl>
    implements _$$ConnectionStateImplCopyWith<$Res> {
  __$$ConnectionStateImplCopyWithImpl(
    _$ConnectionStateImpl _value,
    $Res Function(_$ConnectionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? device = freezed,
    Object? notifyCharacteristic = freezed,
    Object? writeCharacteristic = freezed,
    Object? status = null,
    Object? isScanning = null,
    Object? isConnecting = null,
    Object? bluetoothReady = null,
  }) {
    return _then(
      _$ConnectionStateImpl(
        device:
            freezed == device
                ? _value.device
                : device // ignore: cast_nullable_to_non_nullable
                    as BluetoothDevice?,
        notifyCharacteristic:
            freezed == notifyCharacteristic
                ? _value.notifyCharacteristic
                : notifyCharacteristic // ignore: cast_nullable_to_non_nullable
                    as BluetoothCharacteristic?,
        writeCharacteristic:
            freezed == writeCharacteristic
                ? _value.writeCharacteristic
                : writeCharacteristic // ignore: cast_nullable_to_non_nullable
                    as BluetoothCharacteristic?,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        isScanning:
            null == isScanning
                ? _value.isScanning
                : isScanning // ignore: cast_nullable_to_non_nullable
                    as bool,
        isConnecting:
            null == isConnecting
                ? _value.isConnecting
                : isConnecting // ignore: cast_nullable_to_non_nullable
                    as bool,
        bluetoothReady:
            null == bluetoothReady
                ? _value.bluetoothReady
                : bluetoothReady // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$ConnectionStateImpl implements _ConnectionState {
  const _$ConnectionStateImpl({
    this.device,
    this.notifyCharacteristic,
    this.writeCharacteristic,
    this.status = 'Scanning...',
    this.isScanning = false,
    this.isConnecting = false,
    this.bluetoothReady = false,
  });

  @override
  final BluetoothDevice? device;
  @override
  final BluetoothCharacteristic? notifyCharacteristic;
  @override
  final BluetoothCharacteristic? writeCharacteristic;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final bool isScanning;
  @override
  @JsonKey()
  final bool isConnecting;
  @override
  @JsonKey()
  final bool bluetoothReady;

  @override
  String toString() {
    return 'ConnectionState(device: $device, notifyCharacteristic: $notifyCharacteristic, writeCharacteristic: $writeCharacteristic, status: $status, isScanning: $isScanning, isConnecting: $isConnecting, bluetoothReady: $bluetoothReady)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionStateImpl &&
            (identical(other.device, device) || other.device == device) &&
            (identical(other.notifyCharacteristic, notifyCharacteristic) ||
                other.notifyCharacteristic == notifyCharacteristic) &&
            (identical(other.writeCharacteristic, writeCharacteristic) ||
                other.writeCharacteristic == writeCharacteristic) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isScanning, isScanning) ||
                other.isScanning == isScanning) &&
            (identical(other.isConnecting, isConnecting) ||
                other.isConnecting == isConnecting) &&
            (identical(other.bluetoothReady, bluetoothReady) ||
                other.bluetoothReady == bluetoothReady));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    device,
    notifyCharacteristic,
    writeCharacteristic,
    status,
    isScanning,
    isConnecting,
    bluetoothReady,
  );

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionStateImplCopyWith<_$ConnectionStateImpl> get copyWith =>
      __$$ConnectionStateImplCopyWithImpl<_$ConnectionStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ConnectionState implements ConnectionState {
  const factory _ConnectionState({
    final BluetoothDevice? device,
    final BluetoothCharacteristic? notifyCharacteristic,
    final BluetoothCharacteristic? writeCharacteristic,
    final String status,
    final bool isScanning,
    final bool isConnecting,
    final bool bluetoothReady,
  }) = _$ConnectionStateImpl;

  @override
  BluetoothDevice? get device;
  @override
  BluetoothCharacteristic? get notifyCharacteristic;
  @override
  BluetoothCharacteristic? get writeCharacteristic;
  @override
  String get status;
  @override
  bool get isScanning;
  @override
  bool get isConnecting;
  @override
  bool get bluetoothReady;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionStateImplCopyWith<_$ConnectionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProgressorState {
  ConnectionState get connection => throw _privateConstructorUsedError;
  DeviceInfo get deviceInfo => throw _privateConstructorUsedError;
  MeasurementState get measurement => throw _privateConstructorUsedError;
  PerformanceMetrics get performance => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ProgressorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressorStateCopyWith<ProgressorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressorStateCopyWith<$Res> {
  factory $ProgressorStateCopyWith(
    ProgressorState value,
    $Res Function(ProgressorState) then,
  ) = _$ProgressorStateCopyWithImpl<$Res, ProgressorState>;
  @useResult
  $Res call({
    ConnectionState connection,
    DeviceInfo deviceInfo,
    MeasurementState measurement,
    PerformanceMetrics performance,
    String? errorMessage,
  });

  $ConnectionStateCopyWith<$Res> get connection;
  $DeviceInfoCopyWith<$Res> get deviceInfo;
  $MeasurementStateCopyWith<$Res> get measurement;
  $PerformanceMetricsCopyWith<$Res> get performance;
}

/// @nodoc
class _$ProgressorStateCopyWithImpl<$Res, $Val extends ProgressorState>
    implements $ProgressorStateCopyWith<$Res> {
  _$ProgressorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connection = null,
    Object? deviceInfo = null,
    Object? measurement = null,
    Object? performance = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            connection:
                null == connection
                    ? _value.connection
                    : connection // ignore: cast_nullable_to_non_nullable
                        as ConnectionState,
            deviceInfo:
                null == deviceInfo
                    ? _value.deviceInfo
                    : deviceInfo // ignore: cast_nullable_to_non_nullable
                        as DeviceInfo,
            measurement:
                null == measurement
                    ? _value.measurement
                    : measurement // ignore: cast_nullable_to_non_nullable
                        as MeasurementState,
            performance:
                null == performance
                    ? _value.performance
                    : performance // ignore: cast_nullable_to_non_nullable
                        as PerformanceMetrics,
            errorMessage:
                freezed == errorMessage
                    ? _value.errorMessage
                    : errorMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ProgressorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConnectionStateCopyWith<$Res> get connection {
    return $ConnectionStateCopyWith<$Res>(_value.connection, (value) {
      return _then(_value.copyWith(connection: value) as $Val);
    });
  }

  /// Create a copy of ProgressorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceInfoCopyWith<$Res> get deviceInfo {
    return $DeviceInfoCopyWith<$Res>(_value.deviceInfo, (value) {
      return _then(_value.copyWith(deviceInfo: value) as $Val);
    });
  }

  /// Create a copy of ProgressorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MeasurementStateCopyWith<$Res> get measurement {
    return $MeasurementStateCopyWith<$Res>(_value.measurement, (value) {
      return _then(_value.copyWith(measurement: value) as $Val);
    });
  }

  /// Create a copy of ProgressorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PerformanceMetricsCopyWith<$Res> get performance {
    return $PerformanceMetricsCopyWith<$Res>(_value.performance, (value) {
      return _then(_value.copyWith(performance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProgressorStateImplCopyWith<$Res>
    implements $ProgressorStateCopyWith<$Res> {
  factory _$$ProgressorStateImplCopyWith(
    _$ProgressorStateImpl value,
    $Res Function(_$ProgressorStateImpl) then,
  ) = __$$ProgressorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ConnectionState connection,
    DeviceInfo deviceInfo,
    MeasurementState measurement,
    PerformanceMetrics performance,
    String? errorMessage,
  });

  @override
  $ConnectionStateCopyWith<$Res> get connection;
  @override
  $DeviceInfoCopyWith<$Res> get deviceInfo;
  @override
  $MeasurementStateCopyWith<$Res> get measurement;
  @override
  $PerformanceMetricsCopyWith<$Res> get performance;
}

/// @nodoc
class __$$ProgressorStateImplCopyWithImpl<$Res>
    extends _$ProgressorStateCopyWithImpl<$Res, _$ProgressorStateImpl>
    implements _$$ProgressorStateImplCopyWith<$Res> {
  __$$ProgressorStateImplCopyWithImpl(
    _$ProgressorStateImpl _value,
    $Res Function(_$ProgressorStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgressorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connection = null,
    Object? deviceInfo = null,
    Object? measurement = null,
    Object? performance = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$ProgressorStateImpl(
        connection:
            null == connection
                ? _value.connection
                : connection // ignore: cast_nullable_to_non_nullable
                    as ConnectionState,
        deviceInfo:
            null == deviceInfo
                ? _value.deviceInfo
                : deviceInfo // ignore: cast_nullable_to_non_nullable
                    as DeviceInfo,
        measurement:
            null == measurement
                ? _value.measurement
                : measurement // ignore: cast_nullable_to_non_nullable
                    as MeasurementState,
        performance:
            null == performance
                ? _value.performance
                : performance // ignore: cast_nullable_to_non_nullable
                    as PerformanceMetrics,
        errorMessage:
            freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$ProgressorStateImpl implements _ProgressorState {
  const _$ProgressorStateImpl({
    this.connection = const ConnectionState(),
    this.deviceInfo = const DeviceInfo(),
    this.measurement = const MeasurementState(),
    this.performance = const PerformanceMetrics(),
    this.errorMessage,
  });

  @override
  @JsonKey()
  final ConnectionState connection;
  @override
  @JsonKey()
  final DeviceInfo deviceInfo;
  @override
  @JsonKey()
  final MeasurementState measurement;
  @override
  @JsonKey()
  final PerformanceMetrics performance;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ProgressorState(connection: $connection, deviceInfo: $deviceInfo, measurement: $measurement, performance: $performance, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressorStateImpl &&
            (identical(other.connection, connection) ||
                other.connection == connection) &&
            (identical(other.deviceInfo, deviceInfo) ||
                other.deviceInfo == deviceInfo) &&
            (identical(other.measurement, measurement) ||
                other.measurement == measurement) &&
            (identical(other.performance, performance) ||
                other.performance == performance) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    connection,
    deviceInfo,
    measurement,
    performance,
    errorMessage,
  );

  /// Create a copy of ProgressorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressorStateImplCopyWith<_$ProgressorStateImpl> get copyWith =>
      __$$ProgressorStateImplCopyWithImpl<_$ProgressorStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProgressorState implements ProgressorState {
  const factory _ProgressorState({
    final ConnectionState connection,
    final DeviceInfo deviceInfo,
    final MeasurementState measurement,
    final PerformanceMetrics performance,
    final String? errorMessage,
  }) = _$ProgressorStateImpl;

  @override
  ConnectionState get connection;
  @override
  DeviceInfo get deviceInfo;
  @override
  MeasurementState get measurement;
  @override
  PerformanceMetrics get performance;
  @override
  String? get errorMessage;

  /// Create a copy of ProgressorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressorStateImplCopyWith<_$ProgressorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

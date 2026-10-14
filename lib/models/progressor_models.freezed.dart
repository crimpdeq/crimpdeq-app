// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progressor_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeightMeasurement {

 double get weightKg;/// Microseconds since the measurement started on the device.
 int get timestampUs;
/// Create a copy of WeightMeasurement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeightMeasurementCopyWith<WeightMeasurement> get copyWith => _$WeightMeasurementCopyWithImpl<WeightMeasurement>(this as WeightMeasurement, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeightMeasurement&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.timestampUs, timestampUs) || other.timestampUs == timestampUs));
}


@override
int get hashCode => Object.hash(runtimeType,weightKg,timestampUs);

@override
String toString() {
  return 'WeightMeasurement(weightKg: $weightKg, timestampUs: $timestampUs)';
}


}

/// @nodoc
abstract mixin class $WeightMeasurementCopyWith<$Res>  {
  factory $WeightMeasurementCopyWith(WeightMeasurement value, $Res Function(WeightMeasurement) _then) = _$WeightMeasurementCopyWithImpl;
@useResult
$Res call({
 double weightKg, int timestampUs
});




}
/// @nodoc
class _$WeightMeasurementCopyWithImpl<$Res>
    implements $WeightMeasurementCopyWith<$Res> {
  _$WeightMeasurementCopyWithImpl(this._self, this._then);

  final WeightMeasurement _self;
  final $Res Function(WeightMeasurement) _then;

/// Create a copy of WeightMeasurement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weightKg = null,Object? timestampUs = null,}) {
  return _then(_self.copyWith(
weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,timestampUs: null == timestampUs ? _self.timestampUs : timestampUs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WeightMeasurement].
extension WeightMeasurementPatterns on WeightMeasurement {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeightMeasurement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeightMeasurement() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeightMeasurement value)  $default,){
final _that = this;
switch (_that) {
case _WeightMeasurement():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeightMeasurement value)?  $default,){
final _that = this;
switch (_that) {
case _WeightMeasurement() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double weightKg,  int timestampUs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeightMeasurement() when $default != null:
return $default(_that.weightKg,_that.timestampUs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double weightKg,  int timestampUs)  $default,) {final _that = this;
switch (_that) {
case _WeightMeasurement():
return $default(_that.weightKg,_that.timestampUs);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double weightKg,  int timestampUs)?  $default,) {final _that = this;
switch (_that) {
case _WeightMeasurement() when $default != null:
return $default(_that.weightKg,_that.timestampUs);case _:
  return null;

}
}

}

/// @nodoc


class _WeightMeasurement extends WeightMeasurement {
  const _WeightMeasurement({required this.weightKg, required this.timestampUs}): super._();
  

@override final  double weightKg;
/// Microseconds since the measurement started on the device.
@override final  int timestampUs;

/// Create a copy of WeightMeasurement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeightMeasurementCopyWith<_WeightMeasurement> get copyWith => __$WeightMeasurementCopyWithImpl<_WeightMeasurement>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeightMeasurement&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.timestampUs, timestampUs) || other.timestampUs == timestampUs));
}


@override
int get hashCode => Object.hash(runtimeType,weightKg,timestampUs);

@override
String toString() {
  return 'WeightMeasurement(weightKg: $weightKg, timestampUs: $timestampUs)';
}


}

/// @nodoc
abstract mixin class _$WeightMeasurementCopyWith<$Res> implements $WeightMeasurementCopyWith<$Res> {
  factory _$WeightMeasurementCopyWith(_WeightMeasurement value, $Res Function(_WeightMeasurement) _then) = __$WeightMeasurementCopyWithImpl;
@override @useResult
$Res call({
 double weightKg, int timestampUs
});




}
/// @nodoc
class __$WeightMeasurementCopyWithImpl<$Res>
    implements _$WeightMeasurementCopyWith<$Res> {
  __$WeightMeasurementCopyWithImpl(this._self, this._then);

  final _WeightMeasurement _self;
  final $Res Function(_WeightMeasurement) _then;

/// Create a copy of WeightMeasurement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weightKg = null,Object? timestampUs = null,}) {
  return _then(_WeightMeasurement(
weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,timestampUs: null == timestampUs ? _self.timestampUs : timestampUs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DeviceInfo {

 String get firmwareVersion; int? get batteryMillivolts;/// Null until the firmware reports it; firmware without SetSampleRate never does.
 int? get sampleRate;/// The device warned that the battery is empty and is turning off.
 bool get lowBattery;
/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceInfoCopyWith<DeviceInfo> get copyWith => _$DeviceInfoCopyWithImpl<DeviceInfo>(this as DeviceInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceInfo&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&(identical(other.batteryMillivolts, batteryMillivolts) || other.batteryMillivolts == batteryMillivolts)&&(identical(other.sampleRate, sampleRate) || other.sampleRate == sampleRate)&&(identical(other.lowBattery, lowBattery) || other.lowBattery == lowBattery));
}


@override
int get hashCode => Object.hash(runtimeType,firmwareVersion,batteryMillivolts,sampleRate,lowBattery);

@override
String toString() {
  return 'DeviceInfo(firmwareVersion: $firmwareVersion, batteryMillivolts: $batteryMillivolts, sampleRate: $sampleRate, lowBattery: $lowBattery)';
}


}

/// @nodoc
abstract mixin class $DeviceInfoCopyWith<$Res>  {
  factory $DeviceInfoCopyWith(DeviceInfo value, $Res Function(DeviceInfo) _then) = _$DeviceInfoCopyWithImpl;
@useResult
$Res call({
 String firmwareVersion, int? batteryMillivolts, int? sampleRate, bool lowBattery
});




}
/// @nodoc
class _$DeviceInfoCopyWithImpl<$Res>
    implements $DeviceInfoCopyWith<$Res> {
  _$DeviceInfoCopyWithImpl(this._self, this._then);

  final DeviceInfo _self;
  final $Res Function(DeviceInfo) _then;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firmwareVersion = null,Object? batteryMillivolts = freezed,Object? sampleRate = freezed,Object? lowBattery = null,}) {
  return _then(_self.copyWith(
firmwareVersion: null == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String,batteryMillivolts: freezed == batteryMillivolts ? _self.batteryMillivolts : batteryMillivolts // ignore: cast_nullable_to_non_nullable
as int?,sampleRate: freezed == sampleRate ? _self.sampleRate : sampleRate // ignore: cast_nullable_to_non_nullable
as int?,lowBattery: null == lowBattery ? _self.lowBattery : lowBattery // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceInfo].
extension DeviceInfoPatterns on DeviceInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceInfo value)  $default,){
final _that = this;
switch (_that) {
case _DeviceInfo():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firmwareVersion,  int? batteryMillivolts,  int? sampleRate,  bool lowBattery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that.firmwareVersion,_that.batteryMillivolts,_that.sampleRate,_that.lowBattery);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firmwareVersion,  int? batteryMillivolts,  int? sampleRate,  bool lowBattery)  $default,) {final _that = this;
switch (_that) {
case _DeviceInfo():
return $default(_that.firmwareVersion,_that.batteryMillivolts,_that.sampleRate,_that.lowBattery);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firmwareVersion,  int? batteryMillivolts,  int? sampleRate,  bool lowBattery)?  $default,) {final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that.firmwareVersion,_that.batteryMillivolts,_that.sampleRate,_that.lowBattery);case _:
  return null;

}
}

}

/// @nodoc


class _DeviceInfo implements DeviceInfo {
  const _DeviceInfo({this.firmwareVersion = '', this.batteryMillivolts, this.sampleRate, this.lowBattery = false});
  

@override@JsonKey() final  String firmwareVersion;
@override final  int? batteryMillivolts;
/// Null until the firmware reports it; firmware without SetSampleRate never does.
@override final  int? sampleRate;
/// The device warned that the battery is empty and is turning off.
@override@JsonKey() final  bool lowBattery;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceInfoCopyWith<_DeviceInfo> get copyWith => __$DeviceInfoCopyWithImpl<_DeviceInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceInfo&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&(identical(other.batteryMillivolts, batteryMillivolts) || other.batteryMillivolts == batteryMillivolts)&&(identical(other.sampleRate, sampleRate) || other.sampleRate == sampleRate)&&(identical(other.lowBattery, lowBattery) || other.lowBattery == lowBattery));
}


@override
int get hashCode => Object.hash(runtimeType,firmwareVersion,batteryMillivolts,sampleRate,lowBattery);

@override
String toString() {
  return 'DeviceInfo(firmwareVersion: $firmwareVersion, batteryMillivolts: $batteryMillivolts, sampleRate: $sampleRate, lowBattery: $lowBattery)';
}


}

/// @nodoc
abstract mixin class _$DeviceInfoCopyWith<$Res> implements $DeviceInfoCopyWith<$Res> {
  factory _$DeviceInfoCopyWith(_DeviceInfo value, $Res Function(_DeviceInfo) _then) = __$DeviceInfoCopyWithImpl;
@override @useResult
$Res call({
 String firmwareVersion, int? batteryMillivolts, int? sampleRate, bool lowBattery
});




}
/// @nodoc
class __$DeviceInfoCopyWithImpl<$Res>
    implements _$DeviceInfoCopyWith<$Res> {
  __$DeviceInfoCopyWithImpl(this._self, this._then);

  final _DeviceInfo _self;
  final $Res Function(_DeviceInfo) _then;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firmwareVersion = null,Object? batteryMillivolts = freezed,Object? sampleRate = freezed,Object? lowBattery = null,}) {
  return _then(_DeviceInfo(
firmwareVersion: null == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String,batteryMillivolts: freezed == batteryMillivolts ? _self.batteryMillivolts : batteryMillivolts // ignore: cast_nullable_to_non_nullable
as int?,sampleRate: freezed == sampleRate ? _self.sampleRate : sampleRate // ignore: cast_nullable_to_non_nullable
as int?,lowBattery: null == lowBattery ? _self.lowBattery : lowBattery // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$PerformanceMetrics {

 double get currentHz; double get currentNotifyIntervalMs; int get dataPacketCount; int get samplesPerPacket; List<double> get notifyIntervalHistory;
/// Create a copy of PerformanceMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformanceMetricsCopyWith<PerformanceMetrics> get copyWith => _$PerformanceMetricsCopyWithImpl<PerformanceMetrics>(this as PerformanceMetrics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerformanceMetrics&&(identical(other.currentHz, currentHz) || other.currentHz == currentHz)&&(identical(other.currentNotifyIntervalMs, currentNotifyIntervalMs) || other.currentNotifyIntervalMs == currentNotifyIntervalMs)&&(identical(other.dataPacketCount, dataPacketCount) || other.dataPacketCount == dataPacketCount)&&(identical(other.samplesPerPacket, samplesPerPacket) || other.samplesPerPacket == samplesPerPacket)&&const DeepCollectionEquality().equals(other.notifyIntervalHistory, notifyIntervalHistory));
}


@override
int get hashCode => Object.hash(runtimeType,currentHz,currentNotifyIntervalMs,dataPacketCount,samplesPerPacket,const DeepCollectionEquality().hash(notifyIntervalHistory));

@override
String toString() {
  return 'PerformanceMetrics(currentHz: $currentHz, currentNotifyIntervalMs: $currentNotifyIntervalMs, dataPacketCount: $dataPacketCount, samplesPerPacket: $samplesPerPacket, notifyIntervalHistory: $notifyIntervalHistory)';
}


}

/// @nodoc
abstract mixin class $PerformanceMetricsCopyWith<$Res>  {
  factory $PerformanceMetricsCopyWith(PerformanceMetrics value, $Res Function(PerformanceMetrics) _then) = _$PerformanceMetricsCopyWithImpl;
@useResult
$Res call({
 double currentHz, double currentNotifyIntervalMs, int dataPacketCount, int samplesPerPacket, List<double> notifyIntervalHistory
});




}
/// @nodoc
class _$PerformanceMetricsCopyWithImpl<$Res>
    implements $PerformanceMetricsCopyWith<$Res> {
  _$PerformanceMetricsCopyWithImpl(this._self, this._then);

  final PerformanceMetrics _self;
  final $Res Function(PerformanceMetrics) _then;

/// Create a copy of PerformanceMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentHz = null,Object? currentNotifyIntervalMs = null,Object? dataPacketCount = null,Object? samplesPerPacket = null,Object? notifyIntervalHistory = null,}) {
  return _then(_self.copyWith(
currentHz: null == currentHz ? _self.currentHz : currentHz // ignore: cast_nullable_to_non_nullable
as double,currentNotifyIntervalMs: null == currentNotifyIntervalMs ? _self.currentNotifyIntervalMs : currentNotifyIntervalMs // ignore: cast_nullable_to_non_nullable
as double,dataPacketCount: null == dataPacketCount ? _self.dataPacketCount : dataPacketCount // ignore: cast_nullable_to_non_nullable
as int,samplesPerPacket: null == samplesPerPacket ? _self.samplesPerPacket : samplesPerPacket // ignore: cast_nullable_to_non_nullable
as int,notifyIntervalHistory: null == notifyIntervalHistory ? _self.notifyIntervalHistory : notifyIntervalHistory // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [PerformanceMetrics].
extension PerformanceMetricsPatterns on PerformanceMetrics {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerformanceMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerformanceMetrics() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerformanceMetrics value)  $default,){
final _that = this;
switch (_that) {
case _PerformanceMetrics():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerformanceMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _PerformanceMetrics() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double currentHz,  double currentNotifyIntervalMs,  int dataPacketCount,  int samplesPerPacket,  List<double> notifyIntervalHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerformanceMetrics() when $default != null:
return $default(_that.currentHz,_that.currentNotifyIntervalMs,_that.dataPacketCount,_that.samplesPerPacket,_that.notifyIntervalHistory);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double currentHz,  double currentNotifyIntervalMs,  int dataPacketCount,  int samplesPerPacket,  List<double> notifyIntervalHistory)  $default,) {final _that = this;
switch (_that) {
case _PerformanceMetrics():
return $default(_that.currentHz,_that.currentNotifyIntervalMs,_that.dataPacketCount,_that.samplesPerPacket,_that.notifyIntervalHistory);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double currentHz,  double currentNotifyIntervalMs,  int dataPacketCount,  int samplesPerPacket,  List<double> notifyIntervalHistory)?  $default,) {final _that = this;
switch (_that) {
case _PerformanceMetrics() when $default != null:
return $default(_that.currentHz,_that.currentNotifyIntervalMs,_that.dataPacketCount,_that.samplesPerPacket,_that.notifyIntervalHistory);case _:
  return null;

}
}

}

/// @nodoc


class _PerformanceMetrics implements PerformanceMetrics {
  const _PerformanceMetrics({this.currentHz = 0.0, this.currentNotifyIntervalMs = 0.0, this.dataPacketCount = 0, this.samplesPerPacket = 0, final  List<double> notifyIntervalHistory = const []}): _notifyIntervalHistory = notifyIntervalHistory;
  

@override@JsonKey() final  double currentHz;
@override@JsonKey() final  double currentNotifyIntervalMs;
@override@JsonKey() final  int dataPacketCount;
@override@JsonKey() final  int samplesPerPacket;
 final  List<double> _notifyIntervalHistory;
@override@JsonKey() List<double> get notifyIntervalHistory {
  if (_notifyIntervalHistory is EqualUnmodifiableListView) return _notifyIntervalHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifyIntervalHistory);
}


/// Create a copy of PerformanceMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerformanceMetricsCopyWith<_PerformanceMetrics> get copyWith => __$PerformanceMetricsCopyWithImpl<_PerformanceMetrics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerformanceMetrics&&(identical(other.currentHz, currentHz) || other.currentHz == currentHz)&&(identical(other.currentNotifyIntervalMs, currentNotifyIntervalMs) || other.currentNotifyIntervalMs == currentNotifyIntervalMs)&&(identical(other.dataPacketCount, dataPacketCount) || other.dataPacketCount == dataPacketCount)&&(identical(other.samplesPerPacket, samplesPerPacket) || other.samplesPerPacket == samplesPerPacket)&&const DeepCollectionEquality().equals(other._notifyIntervalHistory, _notifyIntervalHistory));
}


@override
int get hashCode => Object.hash(runtimeType,currentHz,currentNotifyIntervalMs,dataPacketCount,samplesPerPacket,const DeepCollectionEquality().hash(_notifyIntervalHistory));

@override
String toString() {
  return 'PerformanceMetrics(currentHz: $currentHz, currentNotifyIntervalMs: $currentNotifyIntervalMs, dataPacketCount: $dataPacketCount, samplesPerPacket: $samplesPerPacket, notifyIntervalHistory: $notifyIntervalHistory)';
}


}

/// @nodoc
abstract mixin class _$PerformanceMetricsCopyWith<$Res> implements $PerformanceMetricsCopyWith<$Res> {
  factory _$PerformanceMetricsCopyWith(_PerformanceMetrics value, $Res Function(_PerformanceMetrics) _then) = __$PerformanceMetricsCopyWithImpl;
@override @useResult
$Res call({
 double currentHz, double currentNotifyIntervalMs, int dataPacketCount, int samplesPerPacket, List<double> notifyIntervalHistory
});




}
/// @nodoc
class __$PerformanceMetricsCopyWithImpl<$Res>
    implements _$PerformanceMetricsCopyWith<$Res> {
  __$PerformanceMetricsCopyWithImpl(this._self, this._then);

  final _PerformanceMetrics _self;
  final $Res Function(_PerformanceMetrics) _then;

/// Create a copy of PerformanceMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentHz = null,Object? currentNotifyIntervalMs = null,Object? dataPacketCount = null,Object? samplesPerPacket = null,Object? notifyIntervalHistory = null,}) {
  return _then(_PerformanceMetrics(
currentHz: null == currentHz ? _self.currentHz : currentHz // ignore: cast_nullable_to_non_nullable
as double,currentNotifyIntervalMs: null == currentNotifyIntervalMs ? _self.currentNotifyIntervalMs : currentNotifyIntervalMs // ignore: cast_nullable_to_non_nullable
as double,dataPacketCount: null == dataPacketCount ? _self.dataPacketCount : dataPacketCount // ignore: cast_nullable_to_non_nullable
as int,samplesPerPacket: null == samplesPerPacket ? _self.samplesPerPacket : samplesPerPacket // ignore: cast_nullable_to_non_nullable
as int,notifyIntervalHistory: null == notifyIntervalHistory ? _self._notifyIntervalHistory : notifyIntervalHistory // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}

/// @nodoc
mixin _$MeasurementState {

 bool get isMeasuring; double? get currentKg; double? get minKg; double? get peakKg; double? get peakRfdKgPerS;/// Device timestamp of the latest sample.
 int get elapsedUs;/// Mean of each published batch, so the chart does not alias.
 List<FlSpot> get weightHistory;/// Latest samples, newest first.
 List<WeightMeasurement> get receivedData;
/// Create a copy of MeasurementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementStateCopyWith<MeasurementState> get copyWith => _$MeasurementStateCopyWithImpl<MeasurementState>(this as MeasurementState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementState&&(identical(other.isMeasuring, isMeasuring) || other.isMeasuring == isMeasuring)&&(identical(other.currentKg, currentKg) || other.currentKg == currentKg)&&(identical(other.minKg, minKg) || other.minKg == minKg)&&(identical(other.peakKg, peakKg) || other.peakKg == peakKg)&&(identical(other.peakRfdKgPerS, peakRfdKgPerS) || other.peakRfdKgPerS == peakRfdKgPerS)&&(identical(other.elapsedUs, elapsedUs) || other.elapsedUs == elapsedUs)&&const DeepCollectionEquality().equals(other.weightHistory, weightHistory)&&const DeepCollectionEquality().equals(other.receivedData, receivedData));
}


@override
int get hashCode => Object.hash(runtimeType,isMeasuring,currentKg,minKg,peakKg,peakRfdKgPerS,elapsedUs,const DeepCollectionEquality().hash(weightHistory),const DeepCollectionEquality().hash(receivedData));

@override
String toString() {
  return 'MeasurementState(isMeasuring: $isMeasuring, currentKg: $currentKg, minKg: $minKg, peakKg: $peakKg, peakRfdKgPerS: $peakRfdKgPerS, elapsedUs: $elapsedUs, weightHistory: $weightHistory, receivedData: $receivedData)';
}


}

/// @nodoc
abstract mixin class $MeasurementStateCopyWith<$Res>  {
  factory $MeasurementStateCopyWith(MeasurementState value, $Res Function(MeasurementState) _then) = _$MeasurementStateCopyWithImpl;
@useResult
$Res call({
 bool isMeasuring, double? currentKg, double? minKg, double? peakKg, double? peakRfdKgPerS, int elapsedUs, List<FlSpot> weightHistory, List<WeightMeasurement> receivedData
});




}
/// @nodoc
class _$MeasurementStateCopyWithImpl<$Res>
    implements $MeasurementStateCopyWith<$Res> {
  _$MeasurementStateCopyWithImpl(this._self, this._then);

  final MeasurementState _self;
  final $Res Function(MeasurementState) _then;

/// Create a copy of MeasurementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isMeasuring = null,Object? currentKg = freezed,Object? minKg = freezed,Object? peakKg = freezed,Object? peakRfdKgPerS = freezed,Object? elapsedUs = null,Object? weightHistory = null,Object? receivedData = null,}) {
  return _then(_self.copyWith(
isMeasuring: null == isMeasuring ? _self.isMeasuring : isMeasuring // ignore: cast_nullable_to_non_nullable
as bool,currentKg: freezed == currentKg ? _self.currentKg : currentKg // ignore: cast_nullable_to_non_nullable
as double?,minKg: freezed == minKg ? _self.minKg : minKg // ignore: cast_nullable_to_non_nullable
as double?,peakKg: freezed == peakKg ? _self.peakKg : peakKg // ignore: cast_nullable_to_non_nullable
as double?,peakRfdKgPerS: freezed == peakRfdKgPerS ? _self.peakRfdKgPerS : peakRfdKgPerS // ignore: cast_nullable_to_non_nullable
as double?,elapsedUs: null == elapsedUs ? _self.elapsedUs : elapsedUs // ignore: cast_nullable_to_non_nullable
as int,weightHistory: null == weightHistory ? _self.weightHistory : weightHistory // ignore: cast_nullable_to_non_nullable
as List<FlSpot>,receivedData: null == receivedData ? _self.receivedData : receivedData // ignore: cast_nullable_to_non_nullable
as List<WeightMeasurement>,
  ));
}

}


/// Adds pattern-matching-related methods to [MeasurementState].
extension MeasurementStatePatterns on MeasurementState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeasurementState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeasurementState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeasurementState value)  $default,){
final _that = this;
switch (_that) {
case _MeasurementState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeasurementState value)?  $default,){
final _that = this;
switch (_that) {
case _MeasurementState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isMeasuring,  double? currentKg,  double? minKg,  double? peakKg,  double? peakRfdKgPerS,  int elapsedUs,  List<FlSpot> weightHistory,  List<WeightMeasurement> receivedData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeasurementState() when $default != null:
return $default(_that.isMeasuring,_that.currentKg,_that.minKg,_that.peakKg,_that.peakRfdKgPerS,_that.elapsedUs,_that.weightHistory,_that.receivedData);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isMeasuring,  double? currentKg,  double? minKg,  double? peakKg,  double? peakRfdKgPerS,  int elapsedUs,  List<FlSpot> weightHistory,  List<WeightMeasurement> receivedData)  $default,) {final _that = this;
switch (_that) {
case _MeasurementState():
return $default(_that.isMeasuring,_that.currentKg,_that.minKg,_that.peakKg,_that.peakRfdKgPerS,_that.elapsedUs,_that.weightHistory,_that.receivedData);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isMeasuring,  double? currentKg,  double? minKg,  double? peakKg,  double? peakRfdKgPerS,  int elapsedUs,  List<FlSpot> weightHistory,  List<WeightMeasurement> receivedData)?  $default,) {final _that = this;
switch (_that) {
case _MeasurementState() when $default != null:
return $default(_that.isMeasuring,_that.currentKg,_that.minKg,_that.peakKg,_that.peakRfdKgPerS,_that.elapsedUs,_that.weightHistory,_that.receivedData);case _:
  return null;

}
}

}

/// @nodoc


class _MeasurementState implements MeasurementState {
  const _MeasurementState({this.isMeasuring = false, this.currentKg, this.minKg, this.peakKg, this.peakRfdKgPerS, this.elapsedUs = 0, final  List<FlSpot> weightHistory = const [], final  List<WeightMeasurement> receivedData = const []}): _weightHistory = weightHistory,_receivedData = receivedData;
  

@override@JsonKey() final  bool isMeasuring;
@override final  double? currentKg;
@override final  double? minKg;
@override final  double? peakKg;
@override final  double? peakRfdKgPerS;
/// Device timestamp of the latest sample.
@override@JsonKey() final  int elapsedUs;
/// Mean of each published batch, so the chart does not alias.
 final  List<FlSpot> _weightHistory;
/// Mean of each published batch, so the chart does not alias.
@override@JsonKey() List<FlSpot> get weightHistory {
  if (_weightHistory is EqualUnmodifiableListView) return _weightHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weightHistory);
}

/// Latest samples, newest first.
 final  List<WeightMeasurement> _receivedData;
/// Latest samples, newest first.
@override@JsonKey() List<WeightMeasurement> get receivedData {
  if (_receivedData is EqualUnmodifiableListView) return _receivedData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_receivedData);
}


/// Create a copy of MeasurementState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeasurementStateCopyWith<_MeasurementState> get copyWith => __$MeasurementStateCopyWithImpl<_MeasurementState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeasurementState&&(identical(other.isMeasuring, isMeasuring) || other.isMeasuring == isMeasuring)&&(identical(other.currentKg, currentKg) || other.currentKg == currentKg)&&(identical(other.minKg, minKg) || other.minKg == minKg)&&(identical(other.peakKg, peakKg) || other.peakKg == peakKg)&&(identical(other.peakRfdKgPerS, peakRfdKgPerS) || other.peakRfdKgPerS == peakRfdKgPerS)&&(identical(other.elapsedUs, elapsedUs) || other.elapsedUs == elapsedUs)&&const DeepCollectionEquality().equals(other._weightHistory, _weightHistory)&&const DeepCollectionEquality().equals(other._receivedData, _receivedData));
}


@override
int get hashCode => Object.hash(runtimeType,isMeasuring,currentKg,minKg,peakKg,peakRfdKgPerS,elapsedUs,const DeepCollectionEquality().hash(_weightHistory),const DeepCollectionEquality().hash(_receivedData));

@override
String toString() {
  return 'MeasurementState(isMeasuring: $isMeasuring, currentKg: $currentKg, minKg: $minKg, peakKg: $peakKg, peakRfdKgPerS: $peakRfdKgPerS, elapsedUs: $elapsedUs, weightHistory: $weightHistory, receivedData: $receivedData)';
}


}

/// @nodoc
abstract mixin class _$MeasurementStateCopyWith<$Res> implements $MeasurementStateCopyWith<$Res> {
  factory _$MeasurementStateCopyWith(_MeasurementState value, $Res Function(_MeasurementState) _then) = __$MeasurementStateCopyWithImpl;
@override @useResult
$Res call({
 bool isMeasuring, double? currentKg, double? minKg, double? peakKg, double? peakRfdKgPerS, int elapsedUs, List<FlSpot> weightHistory, List<WeightMeasurement> receivedData
});




}
/// @nodoc
class __$MeasurementStateCopyWithImpl<$Res>
    implements _$MeasurementStateCopyWith<$Res> {
  __$MeasurementStateCopyWithImpl(this._self, this._then);

  final _MeasurementState _self;
  final $Res Function(_MeasurementState) _then;

/// Create a copy of MeasurementState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isMeasuring = null,Object? currentKg = freezed,Object? minKg = freezed,Object? peakKg = freezed,Object? peakRfdKgPerS = freezed,Object? elapsedUs = null,Object? weightHistory = null,Object? receivedData = null,}) {
  return _then(_MeasurementState(
isMeasuring: null == isMeasuring ? _self.isMeasuring : isMeasuring // ignore: cast_nullable_to_non_nullable
as bool,currentKg: freezed == currentKg ? _self.currentKg : currentKg // ignore: cast_nullable_to_non_nullable
as double?,minKg: freezed == minKg ? _self.minKg : minKg // ignore: cast_nullable_to_non_nullable
as double?,peakKg: freezed == peakKg ? _self.peakKg : peakKg // ignore: cast_nullable_to_non_nullable
as double?,peakRfdKgPerS: freezed == peakRfdKgPerS ? _self.peakRfdKgPerS : peakRfdKgPerS // ignore: cast_nullable_to_non_nullable
as double?,elapsedUs: null == elapsedUs ? _self.elapsedUs : elapsedUs // ignore: cast_nullable_to_non_nullable
as int,weightHistory: null == weightHistory ? _self._weightHistory : weightHistory // ignore: cast_nullable_to_non_nullable
as List<FlSpot>,receivedData: null == receivedData ? _self._receivedData : receivedData // ignore: cast_nullable_to_non_nullable
as List<WeightMeasurement>,
  ));
}


}

/// @nodoc
mixin _$CalibrationState {

 double? get factor; List<CalibrationPoint> get points; bool get waitingForSteadyLoad;
/// Create a copy of CalibrationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalibrationStateCopyWith<CalibrationState> get copyWith => _$CalibrationStateCopyWithImpl<CalibrationState>(this as CalibrationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalibrationState&&(identical(other.factor, factor) || other.factor == factor)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.waitingForSteadyLoad, waitingForSteadyLoad) || other.waitingForSteadyLoad == waitingForSteadyLoad));
}


@override
int get hashCode => Object.hash(runtimeType,factor,const DeepCollectionEquality().hash(points),waitingForSteadyLoad);

@override
String toString() {
  return 'CalibrationState(factor: $factor, points: $points, waitingForSteadyLoad: $waitingForSteadyLoad)';
}


}

/// @nodoc
abstract mixin class $CalibrationStateCopyWith<$Res>  {
  factory $CalibrationStateCopyWith(CalibrationState value, $Res Function(CalibrationState) _then) = _$CalibrationStateCopyWithImpl;
@useResult
$Res call({
 double? factor, List<CalibrationPoint> points, bool waitingForSteadyLoad
});




}
/// @nodoc
class _$CalibrationStateCopyWithImpl<$Res>
    implements $CalibrationStateCopyWith<$Res> {
  _$CalibrationStateCopyWithImpl(this._self, this._then);

  final CalibrationState _self;
  final $Res Function(CalibrationState) _then;

/// Create a copy of CalibrationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? factor = freezed,Object? points = null,Object? waitingForSteadyLoad = null,}) {
  return _then(_self.copyWith(
factor: freezed == factor ? _self.factor : factor // ignore: cast_nullable_to_non_nullable
as double?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<CalibrationPoint>,waitingForSteadyLoad: null == waitingForSteadyLoad ? _self.waitingForSteadyLoad : waitingForSteadyLoad // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CalibrationState].
extension CalibrationStatePatterns on CalibrationState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalibrationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalibrationState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalibrationState value)  $default,){
final _that = this;
switch (_that) {
case _CalibrationState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalibrationState value)?  $default,){
final _that = this;
switch (_that) {
case _CalibrationState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? factor,  List<CalibrationPoint> points,  bool waitingForSteadyLoad)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalibrationState() when $default != null:
return $default(_that.factor,_that.points,_that.waitingForSteadyLoad);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? factor,  List<CalibrationPoint> points,  bool waitingForSteadyLoad)  $default,) {final _that = this;
switch (_that) {
case _CalibrationState():
return $default(_that.factor,_that.points,_that.waitingForSteadyLoad);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? factor,  List<CalibrationPoint> points,  bool waitingForSteadyLoad)?  $default,) {final _that = this;
switch (_that) {
case _CalibrationState() when $default != null:
return $default(_that.factor,_that.points,_that.waitingForSteadyLoad);case _:
  return null;

}
}

}

/// @nodoc


class _CalibrationState implements CalibrationState {
  const _CalibrationState({this.factor, final  List<CalibrationPoint> points = const [], this.waitingForSteadyLoad = false}): _points = points;
  

@override final  double? factor;
 final  List<CalibrationPoint> _points;
@override@JsonKey() List<CalibrationPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override@JsonKey() final  bool waitingForSteadyLoad;

/// Create a copy of CalibrationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalibrationStateCopyWith<_CalibrationState> get copyWith => __$CalibrationStateCopyWithImpl<_CalibrationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalibrationState&&(identical(other.factor, factor) || other.factor == factor)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.waitingForSteadyLoad, waitingForSteadyLoad) || other.waitingForSteadyLoad == waitingForSteadyLoad));
}


@override
int get hashCode => Object.hash(runtimeType,factor,const DeepCollectionEquality().hash(_points),waitingForSteadyLoad);

@override
String toString() {
  return 'CalibrationState(factor: $factor, points: $points, waitingForSteadyLoad: $waitingForSteadyLoad)';
}


}

/// @nodoc
abstract mixin class _$CalibrationStateCopyWith<$Res> implements $CalibrationStateCopyWith<$Res> {
  factory _$CalibrationStateCopyWith(_CalibrationState value, $Res Function(_CalibrationState) _then) = __$CalibrationStateCopyWithImpl;
@override @useResult
$Res call({
 double? factor, List<CalibrationPoint> points, bool waitingForSteadyLoad
});




}
/// @nodoc
class __$CalibrationStateCopyWithImpl<$Res>
    implements _$CalibrationStateCopyWith<$Res> {
  __$CalibrationStateCopyWithImpl(this._self, this._then);

  final _CalibrationState _self;
  final $Res Function(_CalibrationState) _then;

/// Create a copy of CalibrationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? factor = freezed,Object? points = null,Object? waitingForSteadyLoad = null,}) {
  return _then(_CalibrationState(
factor: freezed == factor ? _self.factor : factor // ignore: cast_nullable_to_non_nullable
as double?,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<CalibrationPoint>,waitingForSteadyLoad: null == waitingForSteadyLoad ? _self.waitingForSteadyLoad : waitingForSteadyLoad // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$DiscoveredDevice {

 String get id; String get name; int get rssi; BluetoothDevice get device;
/// Create a copy of DiscoveredDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveredDeviceCopyWith<DiscoveredDevice> get copyWith => _$DiscoveredDeviceCopyWithImpl<DiscoveredDevice>(this as DiscoveredDevice, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveredDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.rssi, rssi) || other.rssi == rssi)&&(identical(other.device, device) || other.device == device));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,rssi,device);

@override
String toString() {
  return 'DiscoveredDevice(id: $id, name: $name, rssi: $rssi, device: $device)';
}


}

/// @nodoc
abstract mixin class $DiscoveredDeviceCopyWith<$Res>  {
  factory $DiscoveredDeviceCopyWith(DiscoveredDevice value, $Res Function(DiscoveredDevice) _then) = _$DiscoveredDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String name, int rssi, BluetoothDevice device
});




}
/// @nodoc
class _$DiscoveredDeviceCopyWithImpl<$Res>
    implements $DiscoveredDeviceCopyWith<$Res> {
  _$DiscoveredDeviceCopyWithImpl(this._self, this._then);

  final DiscoveredDevice _self;
  final $Res Function(DiscoveredDevice) _then;

/// Create a copy of DiscoveredDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? rssi = null,Object? device = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rssi: null == rssi ? _self.rssi : rssi // ignore: cast_nullable_to_non_nullable
as int,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as BluetoothDevice,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscoveredDevice].
extension DiscoveredDevicePatterns on DiscoveredDevice {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscoveredDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscoveredDevice() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscoveredDevice value)  $default,){
final _that = this;
switch (_that) {
case _DiscoveredDevice():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscoveredDevice value)?  $default,){
final _that = this;
switch (_that) {
case _DiscoveredDevice() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int rssi,  BluetoothDevice device)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscoveredDevice() when $default != null:
return $default(_that.id,_that.name,_that.rssi,_that.device);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int rssi,  BluetoothDevice device)  $default,) {final _that = this;
switch (_that) {
case _DiscoveredDevice():
return $default(_that.id,_that.name,_that.rssi,_that.device);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int rssi,  BluetoothDevice device)?  $default,) {final _that = this;
switch (_that) {
case _DiscoveredDevice() when $default != null:
return $default(_that.id,_that.name,_that.rssi,_that.device);case _:
  return null;

}
}

}

/// @nodoc


class _DiscoveredDevice implements DiscoveredDevice {
  const _DiscoveredDevice({required this.id, required this.name, required this.rssi, required this.device});
  

@override final  String id;
@override final  String name;
@override final  int rssi;
@override final  BluetoothDevice device;

/// Create a copy of DiscoveredDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscoveredDeviceCopyWith<_DiscoveredDevice> get copyWith => __$DiscoveredDeviceCopyWithImpl<_DiscoveredDevice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscoveredDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.rssi, rssi) || other.rssi == rssi)&&(identical(other.device, device) || other.device == device));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,rssi,device);

@override
String toString() {
  return 'DiscoveredDevice(id: $id, name: $name, rssi: $rssi, device: $device)';
}


}

/// @nodoc
abstract mixin class _$DiscoveredDeviceCopyWith<$Res> implements $DiscoveredDeviceCopyWith<$Res> {
  factory _$DiscoveredDeviceCopyWith(_DiscoveredDevice value, $Res Function(_DiscoveredDevice) _then) = __$DiscoveredDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int rssi, BluetoothDevice device
});




}
/// @nodoc
class __$DiscoveredDeviceCopyWithImpl<$Res>
    implements _$DiscoveredDeviceCopyWith<$Res> {
  __$DiscoveredDeviceCopyWithImpl(this._self, this._then);

  final _DiscoveredDevice _self;
  final $Res Function(_DiscoveredDevice) _then;

/// Create a copy of DiscoveredDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? rssi = null,Object? device = null,}) {
  return _then(_DiscoveredDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rssi: null == rssi ? _self.rssi : rssi // ignore: cast_nullable_to_non_nullable
as int,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as BluetoothDevice,
  ));
}


}

/// @nodoc
mixin _$DeviceConnection {

 BluetoothDevice? get device; BluetoothCharacteristic? get writeCharacteristic; String get status; bool get isScanning; bool get isConnecting; bool get bluetoothReady;/// Scanning failed or Bluetooth is unauthorized; the fix is in the app
/// settings (permissions) or the system settings (location services).
 bool get needsSettings; List<DiscoveredDevice> get discoveredDevices;
/// Create a copy of DeviceConnection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceConnectionCopyWith<DeviceConnection> get copyWith => _$DeviceConnectionCopyWithImpl<DeviceConnection>(this as DeviceConnection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceConnection&&(identical(other.device, device) || other.device == device)&&(identical(other.writeCharacteristic, writeCharacteristic) || other.writeCharacteristic == writeCharacteristic)&&(identical(other.status, status) || other.status == status)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.isConnecting, isConnecting) || other.isConnecting == isConnecting)&&(identical(other.bluetoothReady, bluetoothReady) || other.bluetoothReady == bluetoothReady)&&(identical(other.needsSettings, needsSettings) || other.needsSettings == needsSettings)&&const DeepCollectionEquality().equals(other.discoveredDevices, discoveredDevices));
}


@override
int get hashCode => Object.hash(runtimeType,device,writeCharacteristic,status,isScanning,isConnecting,bluetoothReady,needsSettings,const DeepCollectionEquality().hash(discoveredDevices));

@override
String toString() {
  return 'DeviceConnection(device: $device, writeCharacteristic: $writeCharacteristic, status: $status, isScanning: $isScanning, isConnecting: $isConnecting, bluetoothReady: $bluetoothReady, needsSettings: $needsSettings, discoveredDevices: $discoveredDevices)';
}


}

/// @nodoc
abstract mixin class $DeviceConnectionCopyWith<$Res>  {
  factory $DeviceConnectionCopyWith(DeviceConnection value, $Res Function(DeviceConnection) _then) = _$DeviceConnectionCopyWithImpl;
@useResult
$Res call({
 BluetoothDevice? device, BluetoothCharacteristic? writeCharacteristic, String status, bool isScanning, bool isConnecting, bool bluetoothReady, bool needsSettings, List<DiscoveredDevice> discoveredDevices
});




}
/// @nodoc
class _$DeviceConnectionCopyWithImpl<$Res>
    implements $DeviceConnectionCopyWith<$Res> {
  _$DeviceConnectionCopyWithImpl(this._self, this._then);

  final DeviceConnection _self;
  final $Res Function(DeviceConnection) _then;

/// Create a copy of DeviceConnection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? device = freezed,Object? writeCharacteristic = freezed,Object? status = null,Object? isScanning = null,Object? isConnecting = null,Object? bluetoothReady = null,Object? needsSettings = null,Object? discoveredDevices = null,}) {
  return _then(_self.copyWith(
device: freezed == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as BluetoothDevice?,writeCharacteristic: freezed == writeCharacteristic ? _self.writeCharacteristic : writeCharacteristic // ignore: cast_nullable_to_non_nullable
as BluetoothCharacteristic?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,isConnecting: null == isConnecting ? _self.isConnecting : isConnecting // ignore: cast_nullable_to_non_nullable
as bool,bluetoothReady: null == bluetoothReady ? _self.bluetoothReady : bluetoothReady // ignore: cast_nullable_to_non_nullable
as bool,needsSettings: null == needsSettings ? _self.needsSettings : needsSettings // ignore: cast_nullable_to_non_nullable
as bool,discoveredDevices: null == discoveredDevices ? _self.discoveredDevices : discoveredDevices // ignore: cast_nullable_to_non_nullable
as List<DiscoveredDevice>,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceConnection].
extension DeviceConnectionPatterns on DeviceConnection {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceConnection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceConnection() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceConnection value)  $default,){
final _that = this;
switch (_that) {
case _DeviceConnection():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceConnection value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceConnection() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BluetoothDevice? device,  BluetoothCharacteristic? writeCharacteristic,  String status,  bool isScanning,  bool isConnecting,  bool bluetoothReady,  bool needsSettings,  List<DiscoveredDevice> discoveredDevices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceConnection() when $default != null:
return $default(_that.device,_that.writeCharacteristic,_that.status,_that.isScanning,_that.isConnecting,_that.bluetoothReady,_that.needsSettings,_that.discoveredDevices);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BluetoothDevice? device,  BluetoothCharacteristic? writeCharacteristic,  String status,  bool isScanning,  bool isConnecting,  bool bluetoothReady,  bool needsSettings,  List<DiscoveredDevice> discoveredDevices)  $default,) {final _that = this;
switch (_that) {
case _DeviceConnection():
return $default(_that.device,_that.writeCharacteristic,_that.status,_that.isScanning,_that.isConnecting,_that.bluetoothReady,_that.needsSettings,_that.discoveredDevices);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BluetoothDevice? device,  BluetoothCharacteristic? writeCharacteristic,  String status,  bool isScanning,  bool isConnecting,  bool bluetoothReady,  bool needsSettings,  List<DiscoveredDevice> discoveredDevices)?  $default,) {final _that = this;
switch (_that) {
case _DeviceConnection() when $default != null:
return $default(_that.device,_that.writeCharacteristic,_that.status,_that.isScanning,_that.isConnecting,_that.bluetoothReady,_that.needsSettings,_that.discoveredDevices);case _:
  return null;

}
}

}

/// @nodoc


class _DeviceConnection extends DeviceConnection {
  const _DeviceConnection({this.device, this.writeCharacteristic, this.status = 'Initializing Bluetooth...', this.isScanning = false, this.isConnecting = false, this.bluetoothReady = false, this.needsSettings = false, final  List<DiscoveredDevice> discoveredDevices = const []}): _discoveredDevices = discoveredDevices,super._();
  

@override final  BluetoothDevice? device;
@override final  BluetoothCharacteristic? writeCharacteristic;
@override@JsonKey() final  String status;
@override@JsonKey() final  bool isScanning;
@override@JsonKey() final  bool isConnecting;
@override@JsonKey() final  bool bluetoothReady;
/// Scanning failed or Bluetooth is unauthorized; the fix is in the app
/// settings (permissions) or the system settings (location services).
@override@JsonKey() final  bool needsSettings;
 final  List<DiscoveredDevice> _discoveredDevices;
@override@JsonKey() List<DiscoveredDevice> get discoveredDevices {
  if (_discoveredDevices is EqualUnmodifiableListView) return _discoveredDevices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discoveredDevices);
}


/// Create a copy of DeviceConnection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceConnectionCopyWith<_DeviceConnection> get copyWith => __$DeviceConnectionCopyWithImpl<_DeviceConnection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceConnection&&(identical(other.device, device) || other.device == device)&&(identical(other.writeCharacteristic, writeCharacteristic) || other.writeCharacteristic == writeCharacteristic)&&(identical(other.status, status) || other.status == status)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.isConnecting, isConnecting) || other.isConnecting == isConnecting)&&(identical(other.bluetoothReady, bluetoothReady) || other.bluetoothReady == bluetoothReady)&&(identical(other.needsSettings, needsSettings) || other.needsSettings == needsSettings)&&const DeepCollectionEquality().equals(other._discoveredDevices, _discoveredDevices));
}


@override
int get hashCode => Object.hash(runtimeType,device,writeCharacteristic,status,isScanning,isConnecting,bluetoothReady,needsSettings,const DeepCollectionEquality().hash(_discoveredDevices));

@override
String toString() {
  return 'DeviceConnection(device: $device, writeCharacteristic: $writeCharacteristic, status: $status, isScanning: $isScanning, isConnecting: $isConnecting, bluetoothReady: $bluetoothReady, needsSettings: $needsSettings, discoveredDevices: $discoveredDevices)';
}


}

/// @nodoc
abstract mixin class _$DeviceConnectionCopyWith<$Res> implements $DeviceConnectionCopyWith<$Res> {
  factory _$DeviceConnectionCopyWith(_DeviceConnection value, $Res Function(_DeviceConnection) _then) = __$DeviceConnectionCopyWithImpl;
@override @useResult
$Res call({
 BluetoothDevice? device, BluetoothCharacteristic? writeCharacteristic, String status, bool isScanning, bool isConnecting, bool bluetoothReady, bool needsSettings, List<DiscoveredDevice> discoveredDevices
});




}
/// @nodoc
class __$DeviceConnectionCopyWithImpl<$Res>
    implements _$DeviceConnectionCopyWith<$Res> {
  __$DeviceConnectionCopyWithImpl(this._self, this._then);

  final _DeviceConnection _self;
  final $Res Function(_DeviceConnection) _then;

/// Create a copy of DeviceConnection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? device = freezed,Object? writeCharacteristic = freezed,Object? status = null,Object? isScanning = null,Object? isConnecting = null,Object? bluetoothReady = null,Object? needsSettings = null,Object? discoveredDevices = null,}) {
  return _then(_DeviceConnection(
device: freezed == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as BluetoothDevice?,writeCharacteristic: freezed == writeCharacteristic ? _self.writeCharacteristic : writeCharacteristic // ignore: cast_nullable_to_non_nullable
as BluetoothCharacteristic?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,isConnecting: null == isConnecting ? _self.isConnecting : isConnecting // ignore: cast_nullable_to_non_nullable
as bool,bluetoothReady: null == bluetoothReady ? _self.bluetoothReady : bluetoothReady // ignore: cast_nullable_to_non_nullable
as bool,needsSettings: null == needsSettings ? _self.needsSettings : needsSettings // ignore: cast_nullable_to_non_nullable
as bool,discoveredDevices: null == discoveredDevices ? _self._discoveredDevices : discoveredDevices // ignore: cast_nullable_to_non_nullable
as List<DiscoveredDevice>,
  ));
}


}

/// @nodoc
mixin _$ProgressorState {

 DeviceConnection get connection; DeviceInfo get deviceInfo; MeasurementState get measurement; PerformanceMetrics get performance; CalibrationState get calibration;
/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressorStateCopyWith<ProgressorState> get copyWith => _$ProgressorStateCopyWithImpl<ProgressorState>(this as ProgressorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressorState&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.measurement, measurement) || other.measurement == measurement)&&(identical(other.performance, performance) || other.performance == performance)&&(identical(other.calibration, calibration) || other.calibration == calibration));
}


@override
int get hashCode => Object.hash(runtimeType,connection,deviceInfo,measurement,performance,calibration);

@override
String toString() {
  return 'ProgressorState(connection: $connection, deviceInfo: $deviceInfo, measurement: $measurement, performance: $performance, calibration: $calibration)';
}


}

/// @nodoc
abstract mixin class $ProgressorStateCopyWith<$Res>  {
  factory $ProgressorStateCopyWith(ProgressorState value, $Res Function(ProgressorState) _then) = _$ProgressorStateCopyWithImpl;
@useResult
$Res call({
 DeviceConnection connection, DeviceInfo deviceInfo, MeasurementState measurement, PerformanceMetrics performance, CalibrationState calibration
});


$DeviceConnectionCopyWith<$Res> get connection;$DeviceInfoCopyWith<$Res> get deviceInfo;$MeasurementStateCopyWith<$Res> get measurement;$PerformanceMetricsCopyWith<$Res> get performance;$CalibrationStateCopyWith<$Res> get calibration;

}
/// @nodoc
class _$ProgressorStateCopyWithImpl<$Res>
    implements $ProgressorStateCopyWith<$Res> {
  _$ProgressorStateCopyWithImpl(this._self, this._then);

  final ProgressorState _self;
  final $Res Function(ProgressorState) _then;

/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? connection = null,Object? deviceInfo = null,Object? measurement = null,Object? performance = null,Object? calibration = null,}) {
  return _then(_self.copyWith(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as DeviceConnection,deviceInfo: null == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as DeviceInfo,measurement: null == measurement ? _self.measurement : measurement // ignore: cast_nullable_to_non_nullable
as MeasurementState,performance: null == performance ? _self.performance : performance // ignore: cast_nullable_to_non_nullable
as PerformanceMetrics,calibration: null == calibration ? _self.calibration : calibration // ignore: cast_nullable_to_non_nullable
as CalibrationState,
  ));
}
/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceConnectionCopyWith<$Res> get connection {
  
  return $DeviceConnectionCopyWith<$Res>(_self.connection, (value) {
    return _then(_self.copyWith(connection: value));
  });
}/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceInfoCopyWith<$Res> get deviceInfo {
  
  return $DeviceInfoCopyWith<$Res>(_self.deviceInfo, (value) {
    return _then(_self.copyWith(deviceInfo: value));
  });
}/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeasurementStateCopyWith<$Res> get measurement {
  
  return $MeasurementStateCopyWith<$Res>(_self.measurement, (value) {
    return _then(_self.copyWith(measurement: value));
  });
}/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PerformanceMetricsCopyWith<$Res> get performance {
  
  return $PerformanceMetricsCopyWith<$Res>(_self.performance, (value) {
    return _then(_self.copyWith(performance: value));
  });
}/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalibrationStateCopyWith<$Res> get calibration {
  
  return $CalibrationStateCopyWith<$Res>(_self.calibration, (value) {
    return _then(_self.copyWith(calibration: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProgressorState].
extension ProgressorStatePatterns on ProgressorState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgressorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgressorState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgressorState value)  $default,){
final _that = this;
switch (_that) {
case _ProgressorState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgressorState value)?  $default,){
final _that = this;
switch (_that) {
case _ProgressorState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeviceConnection connection,  DeviceInfo deviceInfo,  MeasurementState measurement,  PerformanceMetrics performance,  CalibrationState calibration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgressorState() when $default != null:
return $default(_that.connection,_that.deviceInfo,_that.measurement,_that.performance,_that.calibration);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeviceConnection connection,  DeviceInfo deviceInfo,  MeasurementState measurement,  PerformanceMetrics performance,  CalibrationState calibration)  $default,) {final _that = this;
switch (_that) {
case _ProgressorState():
return $default(_that.connection,_that.deviceInfo,_that.measurement,_that.performance,_that.calibration);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeviceConnection connection,  DeviceInfo deviceInfo,  MeasurementState measurement,  PerformanceMetrics performance,  CalibrationState calibration)?  $default,) {final _that = this;
switch (_that) {
case _ProgressorState() when $default != null:
return $default(_that.connection,_that.deviceInfo,_that.measurement,_that.performance,_that.calibration);case _:
  return null;

}
}

}

/// @nodoc


class _ProgressorState implements ProgressorState {
  const _ProgressorState({this.connection = const DeviceConnection(), this.deviceInfo = const DeviceInfo(), this.measurement = const MeasurementState(), this.performance = const PerformanceMetrics(), this.calibration = const CalibrationState()});
  

@override@JsonKey() final  DeviceConnection connection;
@override@JsonKey() final  DeviceInfo deviceInfo;
@override@JsonKey() final  MeasurementState measurement;
@override@JsonKey() final  PerformanceMetrics performance;
@override@JsonKey() final  CalibrationState calibration;

/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressorStateCopyWith<_ProgressorState> get copyWith => __$ProgressorStateCopyWithImpl<_ProgressorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressorState&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.measurement, measurement) || other.measurement == measurement)&&(identical(other.performance, performance) || other.performance == performance)&&(identical(other.calibration, calibration) || other.calibration == calibration));
}


@override
int get hashCode => Object.hash(runtimeType,connection,deviceInfo,measurement,performance,calibration);

@override
String toString() {
  return 'ProgressorState(connection: $connection, deviceInfo: $deviceInfo, measurement: $measurement, performance: $performance, calibration: $calibration)';
}


}

/// @nodoc
abstract mixin class _$ProgressorStateCopyWith<$Res> implements $ProgressorStateCopyWith<$Res> {
  factory _$ProgressorStateCopyWith(_ProgressorState value, $Res Function(_ProgressorState) _then) = __$ProgressorStateCopyWithImpl;
@override @useResult
$Res call({
 DeviceConnection connection, DeviceInfo deviceInfo, MeasurementState measurement, PerformanceMetrics performance, CalibrationState calibration
});


@override $DeviceConnectionCopyWith<$Res> get connection;@override $DeviceInfoCopyWith<$Res> get deviceInfo;@override $MeasurementStateCopyWith<$Res> get measurement;@override $PerformanceMetricsCopyWith<$Res> get performance;@override $CalibrationStateCopyWith<$Res> get calibration;

}
/// @nodoc
class __$ProgressorStateCopyWithImpl<$Res>
    implements _$ProgressorStateCopyWith<$Res> {
  __$ProgressorStateCopyWithImpl(this._self, this._then);

  final _ProgressorState _self;
  final $Res Function(_ProgressorState) _then;

/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? connection = null,Object? deviceInfo = null,Object? measurement = null,Object? performance = null,Object? calibration = null,}) {
  return _then(_ProgressorState(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as DeviceConnection,deviceInfo: null == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as DeviceInfo,measurement: null == measurement ? _self.measurement : measurement // ignore: cast_nullable_to_non_nullable
as MeasurementState,performance: null == performance ? _self.performance : performance // ignore: cast_nullable_to_non_nullable
as PerformanceMetrics,calibration: null == calibration ? _self.calibration : calibration // ignore: cast_nullable_to_non_nullable
as CalibrationState,
  ));
}

/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceConnectionCopyWith<$Res> get connection {
  
  return $DeviceConnectionCopyWith<$Res>(_self.connection, (value) {
    return _then(_self.copyWith(connection: value));
  });
}/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceInfoCopyWith<$Res> get deviceInfo {
  
  return $DeviceInfoCopyWith<$Res>(_self.deviceInfo, (value) {
    return _then(_self.copyWith(deviceInfo: value));
  });
}/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeasurementStateCopyWith<$Res> get measurement {
  
  return $MeasurementStateCopyWith<$Res>(_self.measurement, (value) {
    return _then(_self.copyWith(measurement: value));
  });
}/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PerformanceMetricsCopyWith<$Res> get performance {
  
  return $PerformanceMetricsCopyWith<$Res>(_self.performance, (value) {
    return _then(_self.copyWith(performance: value));
  });
}/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalibrationStateCopyWith<$Res> get calibration {
  
  return $CalibrationStateCopyWith<$Res>(_self.calibration, (value) {
    return _then(_self.copyWith(calibration: value));
  });
}
}

// dart format on

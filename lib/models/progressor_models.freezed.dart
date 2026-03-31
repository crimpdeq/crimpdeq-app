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

 double get weight; int get timestampUs; DateTime get receivedAt;
/// Create a copy of WeightMeasurement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeightMeasurementCopyWith<WeightMeasurement> get copyWith => _$WeightMeasurementCopyWithImpl<WeightMeasurement>(this as WeightMeasurement, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeightMeasurement&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.timestampUs, timestampUs) || other.timestampUs == timestampUs)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt));
}


@override
int get hashCode => Object.hash(runtimeType,weight,timestampUs,receivedAt);

@override
String toString() {
  return 'WeightMeasurement(weight: $weight, timestampUs: $timestampUs, receivedAt: $receivedAt)';
}


}

/// @nodoc
abstract mixin class $WeightMeasurementCopyWith<$Res>  {
  factory $WeightMeasurementCopyWith(WeightMeasurement value, $Res Function(WeightMeasurement) _then) = _$WeightMeasurementCopyWithImpl;
@useResult
$Res call({
 double weight, int timestampUs, DateTime receivedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? weight = null,Object? timestampUs = null,Object? receivedAt = null,}) {
  return _then(_self.copyWith(
weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,timestampUs: null == timestampUs ? _self.timestampUs : timestampUs // ignore: cast_nullable_to_non_nullable
as int,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double weight,  int timestampUs,  DateTime receivedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeightMeasurement() when $default != null:
return $default(_that.weight,_that.timestampUs,_that.receivedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double weight,  int timestampUs,  DateTime receivedAt)  $default,) {final _that = this;
switch (_that) {
case _WeightMeasurement():
return $default(_that.weight,_that.timestampUs,_that.receivedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double weight,  int timestampUs,  DateTime receivedAt)?  $default,) {final _that = this;
switch (_that) {
case _WeightMeasurement() when $default != null:
return $default(_that.weight,_that.timestampUs,_that.receivedAt);case _:
  return null;

}
}

}

/// @nodoc


class _WeightMeasurement extends WeightMeasurement {
  const _WeightMeasurement({required this.weight, required this.timestampUs, required this.receivedAt}): super._();
  

@override final  double weight;
@override final  int timestampUs;
@override final  DateTime receivedAt;

/// Create a copy of WeightMeasurement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeightMeasurementCopyWith<_WeightMeasurement> get copyWith => __$WeightMeasurementCopyWithImpl<_WeightMeasurement>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeightMeasurement&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.timestampUs, timestampUs) || other.timestampUs == timestampUs)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt));
}


@override
int get hashCode => Object.hash(runtimeType,weight,timestampUs,receivedAt);

@override
String toString() {
  return 'WeightMeasurement(weight: $weight, timestampUs: $timestampUs, receivedAt: $receivedAt)';
}


}

/// @nodoc
abstract mixin class _$WeightMeasurementCopyWith<$Res> implements $WeightMeasurementCopyWith<$Res> {
  factory _$WeightMeasurementCopyWith(_WeightMeasurement value, $Res Function(_WeightMeasurement) _then) = __$WeightMeasurementCopyWithImpl;
@override @useResult
$Res call({
 double weight, int timestampUs, DateTime receivedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? weight = null,Object? timestampUs = null,Object? receivedAt = null,}) {
  return _then(_WeightMeasurement(
weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,timestampUs: null == timestampUs ? _self.timestampUs : timestampUs // ignore: cast_nullable_to_non_nullable
as int,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$DeviceInfo {

 String get firmwareVersion; String get batteryVoltage; double get tareValue;
/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceInfoCopyWith<DeviceInfo> get copyWith => _$DeviceInfoCopyWithImpl<DeviceInfo>(this as DeviceInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceInfo&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&(identical(other.batteryVoltage, batteryVoltage) || other.batteryVoltage == batteryVoltage)&&(identical(other.tareValue, tareValue) || other.tareValue == tareValue));
}


@override
int get hashCode => Object.hash(runtimeType,firmwareVersion,batteryVoltage,tareValue);

@override
String toString() {
  return 'DeviceInfo(firmwareVersion: $firmwareVersion, batteryVoltage: $batteryVoltage, tareValue: $tareValue)';
}


}

/// @nodoc
abstract mixin class $DeviceInfoCopyWith<$Res>  {
  factory $DeviceInfoCopyWith(DeviceInfo value, $Res Function(DeviceInfo) _then) = _$DeviceInfoCopyWithImpl;
@useResult
$Res call({
 String firmwareVersion, String batteryVoltage, double tareValue
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
@pragma('vm:prefer-inline') @override $Res call({Object? firmwareVersion = null,Object? batteryVoltage = null,Object? tareValue = null,}) {
  return _then(_self.copyWith(
firmwareVersion: null == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String,batteryVoltage: null == batteryVoltage ? _self.batteryVoltage : batteryVoltage // ignore: cast_nullable_to_non_nullable
as String,tareValue: null == tareValue ? _self.tareValue : tareValue // ignore: cast_nullable_to_non_nullable
as double,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firmwareVersion,  String batteryVoltage,  double tareValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that.firmwareVersion,_that.batteryVoltage,_that.tareValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firmwareVersion,  String batteryVoltage,  double tareValue)  $default,) {final _that = this;
switch (_that) {
case _DeviceInfo():
return $default(_that.firmwareVersion,_that.batteryVoltage,_that.tareValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firmwareVersion,  String batteryVoltage,  double tareValue)?  $default,) {final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that.firmwareVersion,_that.batteryVoltage,_that.tareValue);case _:
  return null;

}
}

}

/// @nodoc


class _DeviceInfo implements DeviceInfo {
  const _DeviceInfo({this.firmwareVersion = '', this.batteryVoltage = '', this.tareValue = 0.0});
  

@override@JsonKey() final  String firmwareVersion;
@override@JsonKey() final  String batteryVoltage;
@override@JsonKey() final  double tareValue;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceInfoCopyWith<_DeviceInfo> get copyWith => __$DeviceInfoCopyWithImpl<_DeviceInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceInfo&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&(identical(other.batteryVoltage, batteryVoltage) || other.batteryVoltage == batteryVoltage)&&(identical(other.tareValue, tareValue) || other.tareValue == tareValue));
}


@override
int get hashCode => Object.hash(runtimeType,firmwareVersion,batteryVoltage,tareValue);

@override
String toString() {
  return 'DeviceInfo(firmwareVersion: $firmwareVersion, batteryVoltage: $batteryVoltage, tareValue: $tareValue)';
}


}

/// @nodoc
abstract mixin class _$DeviceInfoCopyWith<$Res> implements $DeviceInfoCopyWith<$Res> {
  factory _$DeviceInfoCopyWith(_DeviceInfo value, $Res Function(_DeviceInfo) _then) = __$DeviceInfoCopyWithImpl;
@override @useResult
$Res call({
 String firmwareVersion, String batteryVoltage, double tareValue
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
@override @pragma('vm:prefer-inline') $Res call({Object? firmwareVersion = null,Object? batteryVoltage = null,Object? tareValue = null,}) {
  return _then(_DeviceInfo(
firmwareVersion: null == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String,batteryVoltage: null == batteryVoltage ? _self.batteryVoltage : batteryVoltage // ignore: cast_nullable_to_non_nullable
as String,tareValue: null == tareValue ? _self.tareValue : tareValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$PerformanceMetrics {

 double get currentHz; double get currentNotifyIntervalMs; int get dataPacketCount; int get duplicatePacketCount; int get samplesPerPacket; List<double> get notifyIntervalHistory;
/// Create a copy of PerformanceMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformanceMetricsCopyWith<PerformanceMetrics> get copyWith => _$PerformanceMetricsCopyWithImpl<PerformanceMetrics>(this as PerformanceMetrics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerformanceMetrics&&(identical(other.currentHz, currentHz) || other.currentHz == currentHz)&&(identical(other.currentNotifyIntervalMs, currentNotifyIntervalMs) || other.currentNotifyIntervalMs == currentNotifyIntervalMs)&&(identical(other.dataPacketCount, dataPacketCount) || other.dataPacketCount == dataPacketCount)&&(identical(other.duplicatePacketCount, duplicatePacketCount) || other.duplicatePacketCount == duplicatePacketCount)&&(identical(other.samplesPerPacket, samplesPerPacket) || other.samplesPerPacket == samplesPerPacket)&&const DeepCollectionEquality().equals(other.notifyIntervalHistory, notifyIntervalHistory));
}


@override
int get hashCode => Object.hash(runtimeType,currentHz,currentNotifyIntervalMs,dataPacketCount,duplicatePacketCount,samplesPerPacket,const DeepCollectionEquality().hash(notifyIntervalHistory));

@override
String toString() {
  return 'PerformanceMetrics(currentHz: $currentHz, currentNotifyIntervalMs: $currentNotifyIntervalMs, dataPacketCount: $dataPacketCount, duplicatePacketCount: $duplicatePacketCount, samplesPerPacket: $samplesPerPacket, notifyIntervalHistory: $notifyIntervalHistory)';
}


}

/// @nodoc
abstract mixin class $PerformanceMetricsCopyWith<$Res>  {
  factory $PerformanceMetricsCopyWith(PerformanceMetrics value, $Res Function(PerformanceMetrics) _then) = _$PerformanceMetricsCopyWithImpl;
@useResult
$Res call({
 double currentHz, double currentNotifyIntervalMs, int dataPacketCount, int duplicatePacketCount, int samplesPerPacket, List<double> notifyIntervalHistory
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
@pragma('vm:prefer-inline') @override $Res call({Object? currentHz = null,Object? currentNotifyIntervalMs = null,Object? dataPacketCount = null,Object? duplicatePacketCount = null,Object? samplesPerPacket = null,Object? notifyIntervalHistory = null,}) {
  return _then(_self.copyWith(
currentHz: null == currentHz ? _self.currentHz : currentHz // ignore: cast_nullable_to_non_nullable
as double,currentNotifyIntervalMs: null == currentNotifyIntervalMs ? _self.currentNotifyIntervalMs : currentNotifyIntervalMs // ignore: cast_nullable_to_non_nullable
as double,dataPacketCount: null == dataPacketCount ? _self.dataPacketCount : dataPacketCount // ignore: cast_nullable_to_non_nullable
as int,duplicatePacketCount: null == duplicatePacketCount ? _self.duplicatePacketCount : duplicatePacketCount // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double currentHz,  double currentNotifyIntervalMs,  int dataPacketCount,  int duplicatePacketCount,  int samplesPerPacket,  List<double> notifyIntervalHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerformanceMetrics() when $default != null:
return $default(_that.currentHz,_that.currentNotifyIntervalMs,_that.dataPacketCount,_that.duplicatePacketCount,_that.samplesPerPacket,_that.notifyIntervalHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double currentHz,  double currentNotifyIntervalMs,  int dataPacketCount,  int duplicatePacketCount,  int samplesPerPacket,  List<double> notifyIntervalHistory)  $default,) {final _that = this;
switch (_that) {
case _PerformanceMetrics():
return $default(_that.currentHz,_that.currentNotifyIntervalMs,_that.dataPacketCount,_that.duplicatePacketCount,_that.samplesPerPacket,_that.notifyIntervalHistory);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double currentHz,  double currentNotifyIntervalMs,  int dataPacketCount,  int duplicatePacketCount,  int samplesPerPacket,  List<double> notifyIntervalHistory)?  $default,) {final _that = this;
switch (_that) {
case _PerformanceMetrics() when $default != null:
return $default(_that.currentHz,_that.currentNotifyIntervalMs,_that.dataPacketCount,_that.duplicatePacketCount,_that.samplesPerPacket,_that.notifyIntervalHistory);case _:
  return null;

}
}

}

/// @nodoc


class _PerformanceMetrics implements PerformanceMetrics {
  const _PerformanceMetrics({this.currentHz = 0.0, this.currentNotifyIntervalMs = 0.0, this.dataPacketCount = 0, this.duplicatePacketCount = 0, this.samplesPerPacket = 1, final  List<double> notifyIntervalHistory = const []}): _notifyIntervalHistory = notifyIntervalHistory;
  

@override@JsonKey() final  double currentHz;
@override@JsonKey() final  double currentNotifyIntervalMs;
@override@JsonKey() final  int dataPacketCount;
@override@JsonKey() final  int duplicatePacketCount;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerformanceMetrics&&(identical(other.currentHz, currentHz) || other.currentHz == currentHz)&&(identical(other.currentNotifyIntervalMs, currentNotifyIntervalMs) || other.currentNotifyIntervalMs == currentNotifyIntervalMs)&&(identical(other.dataPacketCount, dataPacketCount) || other.dataPacketCount == dataPacketCount)&&(identical(other.duplicatePacketCount, duplicatePacketCount) || other.duplicatePacketCount == duplicatePacketCount)&&(identical(other.samplesPerPacket, samplesPerPacket) || other.samplesPerPacket == samplesPerPacket)&&const DeepCollectionEquality().equals(other._notifyIntervalHistory, _notifyIntervalHistory));
}


@override
int get hashCode => Object.hash(runtimeType,currentHz,currentNotifyIntervalMs,dataPacketCount,duplicatePacketCount,samplesPerPacket,const DeepCollectionEquality().hash(_notifyIntervalHistory));

@override
String toString() {
  return 'PerformanceMetrics(currentHz: $currentHz, currentNotifyIntervalMs: $currentNotifyIntervalMs, dataPacketCount: $dataPacketCount, duplicatePacketCount: $duplicatePacketCount, samplesPerPacket: $samplesPerPacket, notifyIntervalHistory: $notifyIntervalHistory)';
}


}

/// @nodoc
abstract mixin class _$PerformanceMetricsCopyWith<$Res> implements $PerformanceMetricsCopyWith<$Res> {
  factory _$PerformanceMetricsCopyWith(_PerformanceMetrics value, $Res Function(_PerformanceMetrics) _then) = __$PerformanceMetricsCopyWithImpl;
@override @useResult
$Res call({
 double currentHz, double currentNotifyIntervalMs, int dataPacketCount, int duplicatePacketCount, int samplesPerPacket, List<double> notifyIntervalHistory
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
@override @pragma('vm:prefer-inline') $Res call({Object? currentHz = null,Object? currentNotifyIntervalMs = null,Object? dataPacketCount = null,Object? duplicatePacketCount = null,Object? samplesPerPacket = null,Object? notifyIntervalHistory = null,}) {
  return _then(_PerformanceMetrics(
currentHz: null == currentHz ? _self.currentHz : currentHz // ignore: cast_nullable_to_non_nullable
as double,currentNotifyIntervalMs: null == currentNotifyIntervalMs ? _self.currentNotifyIntervalMs : currentNotifyIntervalMs // ignore: cast_nullable_to_non_nullable
as double,dataPacketCount: null == dataPacketCount ? _self.dataPacketCount : dataPacketCount // ignore: cast_nullable_to_non_nullable
as int,duplicatePacketCount: null == duplicatePacketCount ? _self.duplicatePacketCount : duplicatePacketCount // ignore: cast_nullable_to_non_nullable
as int,samplesPerPacket: null == samplesPerPacket ? _self.samplesPerPacket : samplesPerPacket // ignore: cast_nullable_to_non_nullable
as int,notifyIntervalHistory: null == notifyIntervalHistory ? _self._notifyIntervalHistory : notifyIntervalHistory // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}

/// @nodoc
mixin _$MeasurementState {

 double get currentWeight; double get maxWeight; double get minWeight; int get sampleCount; bool get isMeasuring; List<FlSpot> get weightHistory; List<WeightMeasurement> get receivedData;
/// Create a copy of MeasurementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementStateCopyWith<MeasurementState> get copyWith => _$MeasurementStateCopyWithImpl<MeasurementState>(this as MeasurementState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementState&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.maxWeight, maxWeight) || other.maxWeight == maxWeight)&&(identical(other.minWeight, minWeight) || other.minWeight == minWeight)&&(identical(other.sampleCount, sampleCount) || other.sampleCount == sampleCount)&&(identical(other.isMeasuring, isMeasuring) || other.isMeasuring == isMeasuring)&&const DeepCollectionEquality().equals(other.weightHistory, weightHistory)&&const DeepCollectionEquality().equals(other.receivedData, receivedData));
}


@override
int get hashCode => Object.hash(runtimeType,currentWeight,maxWeight,minWeight,sampleCount,isMeasuring,const DeepCollectionEquality().hash(weightHistory),const DeepCollectionEquality().hash(receivedData));

@override
String toString() {
  return 'MeasurementState(currentWeight: $currentWeight, maxWeight: $maxWeight, minWeight: $minWeight, sampleCount: $sampleCount, isMeasuring: $isMeasuring, weightHistory: $weightHistory, receivedData: $receivedData)';
}


}

/// @nodoc
abstract mixin class $MeasurementStateCopyWith<$Res>  {
  factory $MeasurementStateCopyWith(MeasurementState value, $Res Function(MeasurementState) _then) = _$MeasurementStateCopyWithImpl;
@useResult
$Res call({
 double currentWeight, double maxWeight, double minWeight, int sampleCount, bool isMeasuring, List<FlSpot> weightHistory, List<WeightMeasurement> receivedData
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
@pragma('vm:prefer-inline') @override $Res call({Object? currentWeight = null,Object? maxWeight = null,Object? minWeight = null,Object? sampleCount = null,Object? isMeasuring = null,Object? weightHistory = null,Object? receivedData = null,}) {
  return _then(_self.copyWith(
currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,maxWeight: null == maxWeight ? _self.maxWeight : maxWeight // ignore: cast_nullable_to_non_nullable
as double,minWeight: null == minWeight ? _self.minWeight : minWeight // ignore: cast_nullable_to_non_nullable
as double,sampleCount: null == sampleCount ? _self.sampleCount : sampleCount // ignore: cast_nullable_to_non_nullable
as int,isMeasuring: null == isMeasuring ? _self.isMeasuring : isMeasuring // ignore: cast_nullable_to_non_nullable
as bool,weightHistory: null == weightHistory ? _self.weightHistory : weightHistory // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double currentWeight,  double maxWeight,  double minWeight,  int sampleCount,  bool isMeasuring,  List<FlSpot> weightHistory,  List<WeightMeasurement> receivedData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeasurementState() when $default != null:
return $default(_that.currentWeight,_that.maxWeight,_that.minWeight,_that.sampleCount,_that.isMeasuring,_that.weightHistory,_that.receivedData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double currentWeight,  double maxWeight,  double minWeight,  int sampleCount,  bool isMeasuring,  List<FlSpot> weightHistory,  List<WeightMeasurement> receivedData)  $default,) {final _that = this;
switch (_that) {
case _MeasurementState():
return $default(_that.currentWeight,_that.maxWeight,_that.minWeight,_that.sampleCount,_that.isMeasuring,_that.weightHistory,_that.receivedData);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double currentWeight,  double maxWeight,  double minWeight,  int sampleCount,  bool isMeasuring,  List<FlSpot> weightHistory,  List<WeightMeasurement> receivedData)?  $default,) {final _that = this;
switch (_that) {
case _MeasurementState() when $default != null:
return $default(_that.currentWeight,_that.maxWeight,_that.minWeight,_that.sampleCount,_that.isMeasuring,_that.weightHistory,_that.receivedData);case _:
  return null;

}
}

}

/// @nodoc


class _MeasurementState implements MeasurementState {
  const _MeasurementState({this.currentWeight = 0.0, this.maxWeight = 0.0, this.minWeight = 0.0, this.sampleCount = 0, this.isMeasuring = false, final  List<FlSpot> weightHistory = const [], final  List<WeightMeasurement> receivedData = const []}): _weightHistory = weightHistory,_receivedData = receivedData;
  

@override@JsonKey() final  double currentWeight;
@override@JsonKey() final  double maxWeight;
@override@JsonKey() final  double minWeight;
@override@JsonKey() final  int sampleCount;
@override@JsonKey() final  bool isMeasuring;
 final  List<FlSpot> _weightHistory;
@override@JsonKey() List<FlSpot> get weightHistory {
  if (_weightHistory is EqualUnmodifiableListView) return _weightHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weightHistory);
}

 final  List<WeightMeasurement> _receivedData;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeasurementState&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.maxWeight, maxWeight) || other.maxWeight == maxWeight)&&(identical(other.minWeight, minWeight) || other.minWeight == minWeight)&&(identical(other.sampleCount, sampleCount) || other.sampleCount == sampleCount)&&(identical(other.isMeasuring, isMeasuring) || other.isMeasuring == isMeasuring)&&const DeepCollectionEquality().equals(other._weightHistory, _weightHistory)&&const DeepCollectionEquality().equals(other._receivedData, _receivedData));
}


@override
int get hashCode => Object.hash(runtimeType,currentWeight,maxWeight,minWeight,sampleCount,isMeasuring,const DeepCollectionEquality().hash(_weightHistory),const DeepCollectionEquality().hash(_receivedData));

@override
String toString() {
  return 'MeasurementState(currentWeight: $currentWeight, maxWeight: $maxWeight, minWeight: $minWeight, sampleCount: $sampleCount, isMeasuring: $isMeasuring, weightHistory: $weightHistory, receivedData: $receivedData)';
}


}

/// @nodoc
abstract mixin class _$MeasurementStateCopyWith<$Res> implements $MeasurementStateCopyWith<$Res> {
  factory _$MeasurementStateCopyWith(_MeasurementState value, $Res Function(_MeasurementState) _then) = __$MeasurementStateCopyWithImpl;
@override @useResult
$Res call({
 double currentWeight, double maxWeight, double minWeight, int sampleCount, bool isMeasuring, List<FlSpot> weightHistory, List<WeightMeasurement> receivedData
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
@override @pragma('vm:prefer-inline') $Res call({Object? currentWeight = null,Object? maxWeight = null,Object? minWeight = null,Object? sampleCount = null,Object? isMeasuring = null,Object? weightHistory = null,Object? receivedData = null,}) {
  return _then(_MeasurementState(
currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,maxWeight: null == maxWeight ? _self.maxWeight : maxWeight // ignore: cast_nullable_to_non_nullable
as double,minWeight: null == minWeight ? _self.minWeight : minWeight // ignore: cast_nullable_to_non_nullable
as double,sampleCount: null == sampleCount ? _self.sampleCount : sampleCount // ignore: cast_nullable_to_non_nullable
as int,isMeasuring: null == isMeasuring ? _self.isMeasuring : isMeasuring // ignore: cast_nullable_to_non_nullable
as bool,weightHistory: null == weightHistory ? _self._weightHistory : weightHistory // ignore: cast_nullable_to_non_nullable
as List<FlSpot>,receivedData: null == receivedData ? _self._receivedData : receivedData // ignore: cast_nullable_to_non_nullable
as List<WeightMeasurement>,
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
mixin _$ConnectionState {

 BluetoothDevice? get device; BluetoothCharacteristic? get notifyCharacteristic; BluetoothCharacteristic? get writeCharacteristic; String get status; bool get isScanning; bool get isConnecting; bool get bluetoothReady; List<DiscoveredDevice> get discoveredDevices;
/// Create a copy of ConnectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionStateCopyWith<ConnectionState> get copyWith => _$ConnectionStateCopyWithImpl<ConnectionState>(this as ConnectionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionState&&(identical(other.device, device) || other.device == device)&&(identical(other.notifyCharacteristic, notifyCharacteristic) || other.notifyCharacteristic == notifyCharacteristic)&&(identical(other.writeCharacteristic, writeCharacteristic) || other.writeCharacteristic == writeCharacteristic)&&(identical(other.status, status) || other.status == status)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.isConnecting, isConnecting) || other.isConnecting == isConnecting)&&(identical(other.bluetoothReady, bluetoothReady) || other.bluetoothReady == bluetoothReady)&&const DeepCollectionEquality().equals(other.discoveredDevices, discoveredDevices));
}


@override
int get hashCode => Object.hash(runtimeType,device,notifyCharacteristic,writeCharacteristic,status,isScanning,isConnecting,bluetoothReady,const DeepCollectionEquality().hash(discoveredDevices));

@override
String toString() {
  return 'ConnectionState(device: $device, notifyCharacteristic: $notifyCharacteristic, writeCharacteristic: $writeCharacteristic, status: $status, isScanning: $isScanning, isConnecting: $isConnecting, bluetoothReady: $bluetoothReady, discoveredDevices: $discoveredDevices)';
}


}

/// @nodoc
abstract mixin class $ConnectionStateCopyWith<$Res>  {
  factory $ConnectionStateCopyWith(ConnectionState value, $Res Function(ConnectionState) _then) = _$ConnectionStateCopyWithImpl;
@useResult
$Res call({
 BluetoothDevice? device, BluetoothCharacteristic? notifyCharacteristic, BluetoothCharacteristic? writeCharacteristic, String status, bool isScanning, bool isConnecting, bool bluetoothReady, List<DiscoveredDevice> discoveredDevices
});




}
/// @nodoc
class _$ConnectionStateCopyWithImpl<$Res>
    implements $ConnectionStateCopyWith<$Res> {
  _$ConnectionStateCopyWithImpl(this._self, this._then);

  final ConnectionState _self;
  final $Res Function(ConnectionState) _then;

/// Create a copy of ConnectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? device = freezed,Object? notifyCharacteristic = freezed,Object? writeCharacteristic = freezed,Object? status = null,Object? isScanning = null,Object? isConnecting = null,Object? bluetoothReady = null,Object? discoveredDevices = null,}) {
  return _then(_self.copyWith(
device: freezed == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as BluetoothDevice?,notifyCharacteristic: freezed == notifyCharacteristic ? _self.notifyCharacteristic : notifyCharacteristic // ignore: cast_nullable_to_non_nullable
as BluetoothCharacteristic?,writeCharacteristic: freezed == writeCharacteristic ? _self.writeCharacteristic : writeCharacteristic // ignore: cast_nullable_to_non_nullable
as BluetoothCharacteristic?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,isConnecting: null == isConnecting ? _self.isConnecting : isConnecting // ignore: cast_nullable_to_non_nullable
as bool,bluetoothReady: null == bluetoothReady ? _self.bluetoothReady : bluetoothReady // ignore: cast_nullable_to_non_nullable
as bool,discoveredDevices: null == discoveredDevices ? _self.discoveredDevices : discoveredDevices // ignore: cast_nullable_to_non_nullable
as List<DiscoveredDevice>,
  ));
}

}


/// Adds pattern-matching-related methods to [ConnectionState].
extension ConnectionStatePatterns on ConnectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionState value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionState value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BluetoothDevice? device,  BluetoothCharacteristic? notifyCharacteristic,  BluetoothCharacteristic? writeCharacteristic,  String status,  bool isScanning,  bool isConnecting,  bool bluetoothReady,  List<DiscoveredDevice> discoveredDevices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionState() when $default != null:
return $default(_that.device,_that.notifyCharacteristic,_that.writeCharacteristic,_that.status,_that.isScanning,_that.isConnecting,_that.bluetoothReady,_that.discoveredDevices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BluetoothDevice? device,  BluetoothCharacteristic? notifyCharacteristic,  BluetoothCharacteristic? writeCharacteristic,  String status,  bool isScanning,  bool isConnecting,  bool bluetoothReady,  List<DiscoveredDevice> discoveredDevices)  $default,) {final _that = this;
switch (_that) {
case _ConnectionState():
return $default(_that.device,_that.notifyCharacteristic,_that.writeCharacteristic,_that.status,_that.isScanning,_that.isConnecting,_that.bluetoothReady,_that.discoveredDevices);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BluetoothDevice? device,  BluetoothCharacteristic? notifyCharacteristic,  BluetoothCharacteristic? writeCharacteristic,  String status,  bool isScanning,  bool isConnecting,  bool bluetoothReady,  List<DiscoveredDevice> discoveredDevices)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionState() when $default != null:
return $default(_that.device,_that.notifyCharacteristic,_that.writeCharacteristic,_that.status,_that.isScanning,_that.isConnecting,_that.bluetoothReady,_that.discoveredDevices);case _:
  return null;

}
}

}

/// @nodoc


class _ConnectionState implements ConnectionState {
  const _ConnectionState({this.device, this.notifyCharacteristic, this.writeCharacteristic, this.status = 'Initializing Bluetooth...', this.isScanning = false, this.isConnecting = false, this.bluetoothReady = false, final  List<DiscoveredDevice> discoveredDevices = const []}): _discoveredDevices = discoveredDevices;
  

@override final  BluetoothDevice? device;
@override final  BluetoothCharacteristic? notifyCharacteristic;
@override final  BluetoothCharacteristic? writeCharacteristic;
@override@JsonKey() final  String status;
@override@JsonKey() final  bool isScanning;
@override@JsonKey() final  bool isConnecting;
@override@JsonKey() final  bool bluetoothReady;
 final  List<DiscoveredDevice> _discoveredDevices;
@override@JsonKey() List<DiscoveredDevice> get discoveredDevices {
  if (_discoveredDevices is EqualUnmodifiableListView) return _discoveredDevices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discoveredDevices);
}


/// Create a copy of ConnectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionStateCopyWith<_ConnectionState> get copyWith => __$ConnectionStateCopyWithImpl<_ConnectionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionState&&(identical(other.device, device) || other.device == device)&&(identical(other.notifyCharacteristic, notifyCharacteristic) || other.notifyCharacteristic == notifyCharacteristic)&&(identical(other.writeCharacteristic, writeCharacteristic) || other.writeCharacteristic == writeCharacteristic)&&(identical(other.status, status) || other.status == status)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.isConnecting, isConnecting) || other.isConnecting == isConnecting)&&(identical(other.bluetoothReady, bluetoothReady) || other.bluetoothReady == bluetoothReady)&&const DeepCollectionEquality().equals(other._discoveredDevices, _discoveredDevices));
}


@override
int get hashCode => Object.hash(runtimeType,device,notifyCharacteristic,writeCharacteristic,status,isScanning,isConnecting,bluetoothReady,const DeepCollectionEquality().hash(_discoveredDevices));

@override
String toString() {
  return 'ConnectionState(device: $device, notifyCharacteristic: $notifyCharacteristic, writeCharacteristic: $writeCharacteristic, status: $status, isScanning: $isScanning, isConnecting: $isConnecting, bluetoothReady: $bluetoothReady, discoveredDevices: $discoveredDevices)';
}


}

/// @nodoc
abstract mixin class _$ConnectionStateCopyWith<$Res> implements $ConnectionStateCopyWith<$Res> {
  factory _$ConnectionStateCopyWith(_ConnectionState value, $Res Function(_ConnectionState) _then) = __$ConnectionStateCopyWithImpl;
@override @useResult
$Res call({
 BluetoothDevice? device, BluetoothCharacteristic? notifyCharacteristic, BluetoothCharacteristic? writeCharacteristic, String status, bool isScanning, bool isConnecting, bool bluetoothReady, List<DiscoveredDevice> discoveredDevices
});




}
/// @nodoc
class __$ConnectionStateCopyWithImpl<$Res>
    implements _$ConnectionStateCopyWith<$Res> {
  __$ConnectionStateCopyWithImpl(this._self, this._then);

  final _ConnectionState _self;
  final $Res Function(_ConnectionState) _then;

/// Create a copy of ConnectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? device = freezed,Object? notifyCharacteristic = freezed,Object? writeCharacteristic = freezed,Object? status = null,Object? isScanning = null,Object? isConnecting = null,Object? bluetoothReady = null,Object? discoveredDevices = null,}) {
  return _then(_ConnectionState(
device: freezed == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as BluetoothDevice?,notifyCharacteristic: freezed == notifyCharacteristic ? _self.notifyCharacteristic : notifyCharacteristic // ignore: cast_nullable_to_non_nullable
as BluetoothCharacteristic?,writeCharacteristic: freezed == writeCharacteristic ? _self.writeCharacteristic : writeCharacteristic // ignore: cast_nullable_to_non_nullable
as BluetoothCharacteristic?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,isConnecting: null == isConnecting ? _self.isConnecting : isConnecting // ignore: cast_nullable_to_non_nullable
as bool,bluetoothReady: null == bluetoothReady ? _self.bluetoothReady : bluetoothReady // ignore: cast_nullable_to_non_nullable
as bool,discoveredDevices: null == discoveredDevices ? _self._discoveredDevices : discoveredDevices // ignore: cast_nullable_to_non_nullable
as List<DiscoveredDevice>,
  ));
}


}

/// @nodoc
mixin _$ProgressorState {

 ConnectionState get connection; DeviceInfo get deviceInfo; MeasurementState get measurement; PerformanceMetrics get performance; String? get errorMessage;
/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressorStateCopyWith<ProgressorState> get copyWith => _$ProgressorStateCopyWithImpl<ProgressorState>(this as ProgressorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressorState&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.measurement, measurement) || other.measurement == measurement)&&(identical(other.performance, performance) || other.performance == performance)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,connection,deviceInfo,measurement,performance,errorMessage);

@override
String toString() {
  return 'ProgressorState(connection: $connection, deviceInfo: $deviceInfo, measurement: $measurement, performance: $performance, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ProgressorStateCopyWith<$Res>  {
  factory $ProgressorStateCopyWith(ProgressorState value, $Res Function(ProgressorState) _then) = _$ProgressorStateCopyWithImpl;
@useResult
$Res call({
 ConnectionState connection, DeviceInfo deviceInfo, MeasurementState measurement, PerformanceMetrics performance, String? errorMessage
});


$ConnectionStateCopyWith<$Res> get connection;$DeviceInfoCopyWith<$Res> get deviceInfo;$MeasurementStateCopyWith<$Res> get measurement;$PerformanceMetricsCopyWith<$Res> get performance;

}
/// @nodoc
class _$ProgressorStateCopyWithImpl<$Res>
    implements $ProgressorStateCopyWith<$Res> {
  _$ProgressorStateCopyWithImpl(this._self, this._then);

  final ProgressorState _self;
  final $Res Function(ProgressorState) _then;

/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? connection = null,Object? deviceInfo = null,Object? measurement = null,Object? performance = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ConnectionState,deviceInfo: null == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as DeviceInfo,measurement: null == measurement ? _self.measurement : measurement // ignore: cast_nullable_to_non_nullable
as MeasurementState,performance: null == performance ? _self.performance : performance // ignore: cast_nullable_to_non_nullable
as PerformanceMetrics,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionStateCopyWith<$Res> get connection {
  
  return $ConnectionStateCopyWith<$Res>(_self.connection, (value) {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConnectionState connection,  DeviceInfo deviceInfo,  MeasurementState measurement,  PerformanceMetrics performance,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgressorState() when $default != null:
return $default(_that.connection,_that.deviceInfo,_that.measurement,_that.performance,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConnectionState connection,  DeviceInfo deviceInfo,  MeasurementState measurement,  PerformanceMetrics performance,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ProgressorState():
return $default(_that.connection,_that.deviceInfo,_that.measurement,_that.performance,_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConnectionState connection,  DeviceInfo deviceInfo,  MeasurementState measurement,  PerformanceMetrics performance,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ProgressorState() when $default != null:
return $default(_that.connection,_that.deviceInfo,_that.measurement,_that.performance,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ProgressorState implements ProgressorState {
  const _ProgressorState({this.connection = const ConnectionState(), this.deviceInfo = const DeviceInfo(), this.measurement = const MeasurementState(), this.performance = const PerformanceMetrics(), this.errorMessage});
  

@override@JsonKey() final  ConnectionState connection;
@override@JsonKey() final  DeviceInfo deviceInfo;
@override@JsonKey() final  MeasurementState measurement;
@override@JsonKey() final  PerformanceMetrics performance;
@override final  String? errorMessage;

/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressorStateCopyWith<_ProgressorState> get copyWith => __$ProgressorStateCopyWithImpl<_ProgressorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressorState&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.measurement, measurement) || other.measurement == measurement)&&(identical(other.performance, performance) || other.performance == performance)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,connection,deviceInfo,measurement,performance,errorMessage);

@override
String toString() {
  return 'ProgressorState(connection: $connection, deviceInfo: $deviceInfo, measurement: $measurement, performance: $performance, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ProgressorStateCopyWith<$Res> implements $ProgressorStateCopyWith<$Res> {
  factory _$ProgressorStateCopyWith(_ProgressorState value, $Res Function(_ProgressorState) _then) = __$ProgressorStateCopyWithImpl;
@override @useResult
$Res call({
 ConnectionState connection, DeviceInfo deviceInfo, MeasurementState measurement, PerformanceMetrics performance, String? errorMessage
});


@override $ConnectionStateCopyWith<$Res> get connection;@override $DeviceInfoCopyWith<$Res> get deviceInfo;@override $MeasurementStateCopyWith<$Res> get measurement;@override $PerformanceMetricsCopyWith<$Res> get performance;

}
/// @nodoc
class __$ProgressorStateCopyWithImpl<$Res>
    implements _$ProgressorStateCopyWith<$Res> {
  __$ProgressorStateCopyWithImpl(this._self, this._then);

  final _ProgressorState _self;
  final $Res Function(_ProgressorState) _then;

/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? connection = null,Object? deviceInfo = null,Object? measurement = null,Object? performance = null,Object? errorMessage = freezed,}) {
  return _then(_ProgressorState(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ConnectionState,deviceInfo: null == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as DeviceInfo,measurement: null == measurement ? _self.measurement : measurement // ignore: cast_nullable_to_non_nullable
as MeasurementState,performance: null == performance ? _self.performance : performance // ignore: cast_nullable_to_non_nullable
as PerformanceMetrics,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionStateCopyWith<$Res> get connection {
  
  return $ConnectionStateCopyWith<$Res>(_self.connection, (value) {
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
}
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

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

// dart format on

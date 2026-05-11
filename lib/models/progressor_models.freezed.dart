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
mixin _$ConnectionState {

 BluetoothDevice? get device; BluetoothCharacteristic? get notifyCharacteristic; BluetoothCharacteristic? get writeCharacteristic; String get status; bool get isScanning; bool get isConnecting; bool get bluetoothReady; bool get isSimulator; DeviceType get deviceType;
/// Create a copy of ConnectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionStateCopyWith<ConnectionState> get copyWith => _$ConnectionStateCopyWithImpl<ConnectionState>(this as ConnectionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionState&&(identical(other.device, device) || other.device == device)&&(identical(other.notifyCharacteristic, notifyCharacteristic) || other.notifyCharacteristic == notifyCharacteristic)&&(identical(other.writeCharacteristic, writeCharacteristic) || other.writeCharacteristic == writeCharacteristic)&&(identical(other.status, status) || other.status == status)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.isConnecting, isConnecting) || other.isConnecting == isConnecting)&&(identical(other.bluetoothReady, bluetoothReady) || other.bluetoothReady == bluetoothReady)&&(identical(other.isSimulator, isSimulator) || other.isSimulator == isSimulator)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType));
}


@override
int get hashCode => Object.hash(runtimeType,device,notifyCharacteristic,writeCharacteristic,status,isScanning,isConnecting,bluetoothReady,isSimulator,deviceType);

@override
String toString() {
  return 'ConnectionState(device: $device, notifyCharacteristic: $notifyCharacteristic, writeCharacteristic: $writeCharacteristic, status: $status, isScanning: $isScanning, isConnecting: $isConnecting, bluetoothReady: $bluetoothReady, isSimulator: $isSimulator, deviceType: $deviceType)';
}


}

/// @nodoc
abstract mixin class $ConnectionStateCopyWith<$Res>  {
  factory $ConnectionStateCopyWith(ConnectionState value, $Res Function(ConnectionState) _then) = _$ConnectionStateCopyWithImpl;
@useResult
$Res call({
 BluetoothDevice? device, BluetoothCharacteristic? notifyCharacteristic, BluetoothCharacteristic? writeCharacteristic, String status, bool isScanning, bool isConnecting, bool bluetoothReady, bool isSimulator, DeviceType deviceType
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
@pragma('vm:prefer-inline') @override $Res call({Object? device = freezed,Object? notifyCharacteristic = freezed,Object? writeCharacteristic = freezed,Object? status = null,Object? isScanning = null,Object? isConnecting = null,Object? bluetoothReady = null,Object? isSimulator = null,Object? deviceType = null,}) {
  return _then(_self.copyWith(
device: freezed == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as BluetoothDevice?,notifyCharacteristic: freezed == notifyCharacteristic ? _self.notifyCharacteristic : notifyCharacteristic // ignore: cast_nullable_to_non_nullable
as BluetoothCharacteristic?,writeCharacteristic: freezed == writeCharacteristic ? _self.writeCharacteristic : writeCharacteristic // ignore: cast_nullable_to_non_nullable
as BluetoothCharacteristic?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,isConnecting: null == isConnecting ? _self.isConnecting : isConnecting // ignore: cast_nullable_to_non_nullable
as bool,bluetoothReady: null == bluetoothReady ? _self.bluetoothReady : bluetoothReady // ignore: cast_nullable_to_non_nullable
as bool,isSimulator: null == isSimulator ? _self.isSimulator : isSimulator // ignore: cast_nullable_to_non_nullable
as bool,deviceType: null == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as DeviceType,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BluetoothDevice? device,  BluetoothCharacteristic? notifyCharacteristic,  BluetoothCharacteristic? writeCharacteristic,  String status,  bool isScanning,  bool isConnecting,  bool bluetoothReady,  bool isSimulator,  DeviceType deviceType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionState() when $default != null:
return $default(_that.device,_that.notifyCharacteristic,_that.writeCharacteristic,_that.status,_that.isScanning,_that.isConnecting,_that.bluetoothReady,_that.isSimulator,_that.deviceType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BluetoothDevice? device,  BluetoothCharacteristic? notifyCharacteristic,  BluetoothCharacteristic? writeCharacteristic,  String status,  bool isScanning,  bool isConnecting,  bool bluetoothReady,  bool isSimulator,  DeviceType deviceType)  $default,) {final _that = this;
switch (_that) {
case _ConnectionState():
return $default(_that.device,_that.notifyCharacteristic,_that.writeCharacteristic,_that.status,_that.isScanning,_that.isConnecting,_that.bluetoothReady,_that.isSimulator,_that.deviceType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BluetoothDevice? device,  BluetoothCharacteristic? notifyCharacteristic,  BluetoothCharacteristic? writeCharacteristic,  String status,  bool isScanning,  bool isConnecting,  bool bluetoothReady,  bool isSimulator,  DeviceType deviceType)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionState() when $default != null:
return $default(_that.device,_that.notifyCharacteristic,_that.writeCharacteristic,_that.status,_that.isScanning,_that.isConnecting,_that.bluetoothReady,_that.isSimulator,_that.deviceType);case _:
  return null;

}
}

}

/// @nodoc


class _ConnectionState extends ConnectionState {
  const _ConnectionState({this.device, this.notifyCharacteristic, this.writeCharacteristic, this.status = 'Scanning...', this.isScanning = false, this.isConnecting = false, this.bluetoothReady = false, this.isSimulator = false, this.deviceType = DeviceType.progressor}): super._();
  

@override final  BluetoothDevice? device;
@override final  BluetoothCharacteristic? notifyCharacteristic;
@override final  BluetoothCharacteristic? writeCharacteristic;
@override@JsonKey() final  String status;
@override@JsonKey() final  bool isScanning;
@override@JsonKey() final  bool isConnecting;
@override@JsonKey() final  bool bluetoothReady;
@override@JsonKey() final  bool isSimulator;
@override@JsonKey() final  DeviceType deviceType;

/// Create a copy of ConnectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionStateCopyWith<_ConnectionState> get copyWith => __$ConnectionStateCopyWithImpl<_ConnectionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionState&&(identical(other.device, device) || other.device == device)&&(identical(other.notifyCharacteristic, notifyCharacteristic) || other.notifyCharacteristic == notifyCharacteristic)&&(identical(other.writeCharacteristic, writeCharacteristic) || other.writeCharacteristic == writeCharacteristic)&&(identical(other.status, status) || other.status == status)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.isConnecting, isConnecting) || other.isConnecting == isConnecting)&&(identical(other.bluetoothReady, bluetoothReady) || other.bluetoothReady == bluetoothReady)&&(identical(other.isSimulator, isSimulator) || other.isSimulator == isSimulator)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType));
}


@override
int get hashCode => Object.hash(runtimeType,device,notifyCharacteristic,writeCharacteristic,status,isScanning,isConnecting,bluetoothReady,isSimulator,deviceType);

@override
String toString() {
  return 'ConnectionState(device: $device, notifyCharacteristic: $notifyCharacteristic, writeCharacteristic: $writeCharacteristic, status: $status, isScanning: $isScanning, isConnecting: $isConnecting, bluetoothReady: $bluetoothReady, isSimulator: $isSimulator, deviceType: $deviceType)';
}


}

/// @nodoc
abstract mixin class _$ConnectionStateCopyWith<$Res> implements $ConnectionStateCopyWith<$Res> {
  factory _$ConnectionStateCopyWith(_ConnectionState value, $Res Function(_ConnectionState) _then) = __$ConnectionStateCopyWithImpl;
@override @useResult
$Res call({
 BluetoothDevice? device, BluetoothCharacteristic? notifyCharacteristic, BluetoothCharacteristic? writeCharacteristic, String status, bool isScanning, bool isConnecting, bool bluetoothReady, bool isSimulator, DeviceType deviceType
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
@override @pragma('vm:prefer-inline') $Res call({Object? device = freezed,Object? notifyCharacteristic = freezed,Object? writeCharacteristic = freezed,Object? status = null,Object? isScanning = null,Object? isConnecting = null,Object? bluetoothReady = null,Object? isSimulator = null,Object? deviceType = null,}) {
  return _then(_ConnectionState(
device: freezed == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as BluetoothDevice?,notifyCharacteristic: freezed == notifyCharacteristic ? _self.notifyCharacteristic : notifyCharacteristic // ignore: cast_nullable_to_non_nullable
as BluetoothCharacteristic?,writeCharacteristic: freezed == writeCharacteristic ? _self.writeCharacteristic : writeCharacteristic // ignore: cast_nullable_to_non_nullable
as BluetoothCharacteristic?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,isConnecting: null == isConnecting ? _self.isConnecting : isConnecting // ignore: cast_nullable_to_non_nullable
as bool,bluetoothReady: null == bluetoothReady ? _self.bluetoothReady : bluetoothReady // ignore: cast_nullable_to_non_nullable
as bool,isSimulator: null == isSimulator ? _self.isSimulator : isSimulator // ignore: cast_nullable_to_non_nullable
as bool,deviceType: null == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as DeviceType,
  ));
}


}

/// @nodoc
mixin _$ProgressorState {

 ConnectionState get connection; DeviceInfo get deviceInfo; MeasurementState get measurement; PerformanceMetrics get performance; List<DiscoveredDevice> get discoveredDevices; String? get errorMessage;
/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressorStateCopyWith<ProgressorState> get copyWith => _$ProgressorStateCopyWithImpl<ProgressorState>(this as ProgressorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressorState&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.measurement, measurement) || other.measurement == measurement)&&(identical(other.performance, performance) || other.performance == performance)&&const DeepCollectionEquality().equals(other.discoveredDevices, discoveredDevices)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,connection,deviceInfo,measurement,performance,const DeepCollectionEquality().hash(discoveredDevices),errorMessage);

@override
String toString() {
  return 'ProgressorState(connection: $connection, deviceInfo: $deviceInfo, measurement: $measurement, performance: $performance, discoveredDevices: $discoveredDevices, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ProgressorStateCopyWith<$Res>  {
  factory $ProgressorStateCopyWith(ProgressorState value, $Res Function(ProgressorState) _then) = _$ProgressorStateCopyWithImpl;
@useResult
$Res call({
 ConnectionState connection, DeviceInfo deviceInfo, MeasurementState measurement, PerformanceMetrics performance, List<DiscoveredDevice> discoveredDevices, String? errorMessage
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
@pragma('vm:prefer-inline') @override $Res call({Object? connection = null,Object? deviceInfo = null,Object? measurement = null,Object? performance = null,Object? discoveredDevices = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ConnectionState,deviceInfo: null == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as DeviceInfo,measurement: null == measurement ? _self.measurement : measurement // ignore: cast_nullable_to_non_nullable
as MeasurementState,performance: null == performance ? _self.performance : performance // ignore: cast_nullable_to_non_nullable
as PerformanceMetrics,discoveredDevices: null == discoveredDevices ? _self.discoveredDevices : discoveredDevices // ignore: cast_nullable_to_non_nullable
as List<DiscoveredDevice>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConnectionState connection,  DeviceInfo deviceInfo,  MeasurementState measurement,  PerformanceMetrics performance,  List<DiscoveredDevice> discoveredDevices,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgressorState() when $default != null:
return $default(_that.connection,_that.deviceInfo,_that.measurement,_that.performance,_that.discoveredDevices,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConnectionState connection,  DeviceInfo deviceInfo,  MeasurementState measurement,  PerformanceMetrics performance,  List<DiscoveredDevice> discoveredDevices,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ProgressorState():
return $default(_that.connection,_that.deviceInfo,_that.measurement,_that.performance,_that.discoveredDevices,_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConnectionState connection,  DeviceInfo deviceInfo,  MeasurementState measurement,  PerformanceMetrics performance,  List<DiscoveredDevice> discoveredDevices,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ProgressorState() when $default != null:
return $default(_that.connection,_that.deviceInfo,_that.measurement,_that.performance,_that.discoveredDevices,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ProgressorState implements ProgressorState {
  const _ProgressorState({this.connection = const ConnectionState(), this.deviceInfo = const DeviceInfo(), this.measurement = const MeasurementState(), this.performance = const PerformanceMetrics(), final  List<DiscoveredDevice> discoveredDevices = const [], this.errorMessage}): _discoveredDevices = discoveredDevices;
  

@override@JsonKey() final  ConnectionState connection;
@override@JsonKey() final  DeviceInfo deviceInfo;
@override@JsonKey() final  MeasurementState measurement;
@override@JsonKey() final  PerformanceMetrics performance;
 final  List<DiscoveredDevice> _discoveredDevices;
@override@JsonKey() List<DiscoveredDevice> get discoveredDevices {
  if (_discoveredDevices is EqualUnmodifiableListView) return _discoveredDevices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discoveredDevices);
}

@override final  String? errorMessage;

/// Create a copy of ProgressorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressorStateCopyWith<_ProgressorState> get copyWith => __$ProgressorStateCopyWithImpl<_ProgressorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressorState&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.measurement, measurement) || other.measurement == measurement)&&(identical(other.performance, performance) || other.performance == performance)&&const DeepCollectionEquality().equals(other._discoveredDevices, _discoveredDevices)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,connection,deviceInfo,measurement,performance,const DeepCollectionEquality().hash(_discoveredDevices),errorMessage);

@override
String toString() {
  return 'ProgressorState(connection: $connection, deviceInfo: $deviceInfo, measurement: $measurement, performance: $performance, discoveredDevices: $discoveredDevices, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ProgressorStateCopyWith<$Res> implements $ProgressorStateCopyWith<$Res> {
  factory _$ProgressorStateCopyWith(_ProgressorState value, $Res Function(_ProgressorState) _then) = __$ProgressorStateCopyWithImpl;
@override @useResult
$Res call({
 ConnectionState connection, DeviceInfo deviceInfo, MeasurementState measurement, PerformanceMetrics performance, List<DiscoveredDevice> discoveredDevices, String? errorMessage
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
@override @pragma('vm:prefer-inline') $Res call({Object? connection = null,Object? deviceInfo = null,Object? measurement = null,Object? performance = null,Object? discoveredDevices = null,Object? errorMessage = freezed,}) {
  return _then(_ProgressorState(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ConnectionState,deviceInfo: null == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as DeviceInfo,measurement: null == measurement ? _self.measurement : measurement // ignore: cast_nullable_to_non_nullable
as MeasurementState,performance: null == performance ? _self.performance : performance // ignore: cast_nullable_to_non_nullable
as PerformanceMetrics,discoveredDevices: null == discoveredDevices ? _self._discoveredDevices : discoveredDevices // ignore: cast_nullable_to_non_nullable
as List<DiscoveredDevice>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
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

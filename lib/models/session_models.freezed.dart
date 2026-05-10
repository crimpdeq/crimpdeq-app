// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetConfig {

 int get hangDurationSec; int get restDurationSec; int get repsPerSet;
/// Create a copy of SetConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetConfigCopyWith<SetConfig> get copyWith => _$SetConfigCopyWithImpl<SetConfig>(this as SetConfig, _$identity);

  /// Serializes this SetConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetConfig&&(identical(other.hangDurationSec, hangDurationSec) || other.hangDurationSec == hangDurationSec)&&(identical(other.restDurationSec, restDurationSec) || other.restDurationSec == restDurationSec)&&(identical(other.repsPerSet, repsPerSet) || other.repsPerSet == repsPerSet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hangDurationSec,restDurationSec,repsPerSet);

@override
String toString() {
  return 'SetConfig(hangDurationSec: $hangDurationSec, restDurationSec: $restDurationSec, repsPerSet: $repsPerSet)';
}


}

/// @nodoc
abstract mixin class $SetConfigCopyWith<$Res>  {
  factory $SetConfigCopyWith(SetConfig value, $Res Function(SetConfig) _then) = _$SetConfigCopyWithImpl;
@useResult
$Res call({
 int hangDurationSec, int restDurationSec, int repsPerSet
});




}
/// @nodoc
class _$SetConfigCopyWithImpl<$Res>
    implements $SetConfigCopyWith<$Res> {
  _$SetConfigCopyWithImpl(this._self, this._then);

  final SetConfig _self;
  final $Res Function(SetConfig) _then;

/// Create a copy of SetConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hangDurationSec = null,Object? restDurationSec = null,Object? repsPerSet = null,}) {
  return _then(_self.copyWith(
hangDurationSec: null == hangDurationSec ? _self.hangDurationSec : hangDurationSec // ignore: cast_nullable_to_non_nullable
as int,restDurationSec: null == restDurationSec ? _self.restDurationSec : restDurationSec // ignore: cast_nullable_to_non_nullable
as int,repsPerSet: null == repsPerSet ? _self.repsPerSet : repsPerSet // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SetConfig].
extension SetConfigPatterns on SetConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetConfig value)  $default,){
final _that = this;
switch (_that) {
case _SetConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SetConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int hangDurationSec,  int restDurationSec,  int repsPerSet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetConfig() when $default != null:
return $default(_that.hangDurationSec,_that.restDurationSec,_that.repsPerSet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int hangDurationSec,  int restDurationSec,  int repsPerSet)  $default,) {final _that = this;
switch (_that) {
case _SetConfig():
return $default(_that.hangDurationSec,_that.restDurationSec,_that.repsPerSet);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int hangDurationSec,  int restDurationSec,  int repsPerSet)?  $default,) {final _that = this;
switch (_that) {
case _SetConfig() when $default != null:
return $default(_that.hangDurationSec,_that.restDurationSec,_that.repsPerSet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetConfig implements SetConfig {
  const _SetConfig({this.hangDurationSec = 7, this.restDurationSec = 3, this.repsPerSet = 1});
  factory _SetConfig.fromJson(Map<String, dynamic> json) => _$SetConfigFromJson(json);

@override@JsonKey() final  int hangDurationSec;
@override@JsonKey() final  int restDurationSec;
@override@JsonKey() final  int repsPerSet;

/// Create a copy of SetConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetConfigCopyWith<_SetConfig> get copyWith => __$SetConfigCopyWithImpl<_SetConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetConfig&&(identical(other.hangDurationSec, hangDurationSec) || other.hangDurationSec == hangDurationSec)&&(identical(other.restDurationSec, restDurationSec) || other.restDurationSec == restDurationSec)&&(identical(other.repsPerSet, repsPerSet) || other.repsPerSet == repsPerSet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hangDurationSec,restDurationSec,repsPerSet);

@override
String toString() {
  return 'SetConfig(hangDurationSec: $hangDurationSec, restDurationSec: $restDurationSec, repsPerSet: $repsPerSet)';
}


}

/// @nodoc
abstract mixin class _$SetConfigCopyWith<$Res> implements $SetConfigCopyWith<$Res> {
  factory _$SetConfigCopyWith(_SetConfig value, $Res Function(_SetConfig) _then) = __$SetConfigCopyWithImpl;
@override @useResult
$Res call({
 int hangDurationSec, int restDurationSec, int repsPerSet
});




}
/// @nodoc
class __$SetConfigCopyWithImpl<$Res>
    implements _$SetConfigCopyWith<$Res> {
  __$SetConfigCopyWithImpl(this._self, this._then);

  final _SetConfig _self;
  final $Res Function(_SetConfig) _then;

/// Create a copy of SetConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hangDurationSec = null,Object? restDurationSec = null,Object? repsPerSet = null,}) {
  return _then(_SetConfig(
hangDurationSec: null == hangDurationSec ? _self.hangDurationSec : hangDurationSec // ignore: cast_nullable_to_non_nullable
as int,restDurationSec: null == restDurationSec ? _self.restDurationSec : restDurationSec // ignore: cast_nullable_to_non_nullable
as int,repsPerSet: null == repsPerSet ? _self.repsPerSet : repsPerSet // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ProtocolConfig {

 ProtocolType get type; int get hangDurationSec; int get restDurationSec; int get sets; int get repsPerSet; int get restBetweenSetsSec; double get targetWeightKg; double get hangThresholdKg; String? get gripId; HandMode get handMode; List<SetConfig>? get setConfigs;
/// Create a copy of ProtocolConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProtocolConfigCopyWith<ProtocolConfig> get copyWith => _$ProtocolConfigCopyWithImpl<ProtocolConfig>(this as ProtocolConfig, _$identity);

  /// Serializes this ProtocolConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProtocolConfig&&(identical(other.type, type) || other.type == type)&&(identical(other.hangDurationSec, hangDurationSec) || other.hangDurationSec == hangDurationSec)&&(identical(other.restDurationSec, restDurationSec) || other.restDurationSec == restDurationSec)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.repsPerSet, repsPerSet) || other.repsPerSet == repsPerSet)&&(identical(other.restBetweenSetsSec, restBetweenSetsSec) || other.restBetweenSetsSec == restBetweenSetsSec)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.hangThresholdKg, hangThresholdKg) || other.hangThresholdKg == hangThresholdKg)&&(identical(other.gripId, gripId) || other.gripId == gripId)&&(identical(other.handMode, handMode) || other.handMode == handMode)&&const DeepCollectionEquality().equals(other.setConfigs, setConfigs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,hangDurationSec,restDurationSec,sets,repsPerSet,restBetweenSetsSec,targetWeightKg,hangThresholdKg,gripId,handMode,const DeepCollectionEquality().hash(setConfigs));

@override
String toString() {
  return 'ProtocolConfig(type: $type, hangDurationSec: $hangDurationSec, restDurationSec: $restDurationSec, sets: $sets, repsPerSet: $repsPerSet, restBetweenSetsSec: $restBetweenSetsSec, targetWeightKg: $targetWeightKg, hangThresholdKg: $hangThresholdKg, gripId: $gripId, handMode: $handMode, setConfigs: $setConfigs)';
}


}

/// @nodoc
abstract mixin class $ProtocolConfigCopyWith<$Res>  {
  factory $ProtocolConfigCopyWith(ProtocolConfig value, $Res Function(ProtocolConfig) _then) = _$ProtocolConfigCopyWithImpl;
@useResult
$Res call({
 ProtocolType type, int hangDurationSec, int restDurationSec, int sets, int repsPerSet, int restBetweenSetsSec, double targetWeightKg, double hangThresholdKg, String? gripId, HandMode handMode, List<SetConfig>? setConfigs
});




}
/// @nodoc
class _$ProtocolConfigCopyWithImpl<$Res>
    implements $ProtocolConfigCopyWith<$Res> {
  _$ProtocolConfigCopyWithImpl(this._self, this._then);

  final ProtocolConfig _self;
  final $Res Function(ProtocolConfig) _then;

/// Create a copy of ProtocolConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? hangDurationSec = null,Object? restDurationSec = null,Object? sets = null,Object? repsPerSet = null,Object? restBetweenSetsSec = null,Object? targetWeightKg = null,Object? hangThresholdKg = null,Object? gripId = freezed,Object? handMode = null,Object? setConfigs = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProtocolType,hangDurationSec: null == hangDurationSec ? _self.hangDurationSec : hangDurationSec // ignore: cast_nullable_to_non_nullable
as int,restDurationSec: null == restDurationSec ? _self.restDurationSec : restDurationSec // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,repsPerSet: null == repsPerSet ? _self.repsPerSet : repsPerSet // ignore: cast_nullable_to_non_nullable
as int,restBetweenSetsSec: null == restBetweenSetsSec ? _self.restBetweenSetsSec : restBetweenSetsSec // ignore: cast_nullable_to_non_nullable
as int,targetWeightKg: null == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double,hangThresholdKg: null == hangThresholdKg ? _self.hangThresholdKg : hangThresholdKg // ignore: cast_nullable_to_non_nullable
as double,gripId: freezed == gripId ? _self.gripId : gripId // ignore: cast_nullable_to_non_nullable
as String?,handMode: null == handMode ? _self.handMode : handMode // ignore: cast_nullable_to_non_nullable
as HandMode,setConfigs: freezed == setConfigs ? _self.setConfigs : setConfigs // ignore: cast_nullable_to_non_nullable
as List<SetConfig>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProtocolConfig].
extension ProtocolConfigPatterns on ProtocolConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProtocolConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProtocolConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProtocolConfig value)  $default,){
final _that = this;
switch (_that) {
case _ProtocolConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProtocolConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ProtocolConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProtocolType type,  int hangDurationSec,  int restDurationSec,  int sets,  int repsPerSet,  int restBetweenSetsSec,  double targetWeightKg,  double hangThresholdKg,  String? gripId,  HandMode handMode,  List<SetConfig>? setConfigs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProtocolConfig() when $default != null:
return $default(_that.type,_that.hangDurationSec,_that.restDurationSec,_that.sets,_that.repsPerSet,_that.restBetweenSetsSec,_that.targetWeightKg,_that.hangThresholdKg,_that.gripId,_that.handMode,_that.setConfigs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProtocolType type,  int hangDurationSec,  int restDurationSec,  int sets,  int repsPerSet,  int restBetweenSetsSec,  double targetWeightKg,  double hangThresholdKg,  String? gripId,  HandMode handMode,  List<SetConfig>? setConfigs)  $default,) {final _that = this;
switch (_that) {
case _ProtocolConfig():
return $default(_that.type,_that.hangDurationSec,_that.restDurationSec,_that.sets,_that.repsPerSet,_that.restBetweenSetsSec,_that.targetWeightKg,_that.hangThresholdKg,_that.gripId,_that.handMode,_that.setConfigs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProtocolType type,  int hangDurationSec,  int restDurationSec,  int sets,  int repsPerSet,  int restBetweenSetsSec,  double targetWeightKg,  double hangThresholdKg,  String? gripId,  HandMode handMode,  List<SetConfig>? setConfigs)?  $default,) {final _that = this;
switch (_that) {
case _ProtocolConfig() when $default != null:
return $default(_that.type,_that.hangDurationSec,_that.restDurationSec,_that.sets,_that.repsPerSet,_that.restBetweenSetsSec,_that.targetWeightKg,_that.hangThresholdKg,_that.gripId,_that.handMode,_that.setConfigs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProtocolConfig extends ProtocolConfig {
  const _ProtocolConfig({required this.type, this.hangDurationSec = 7, this.restDurationSec = 3, this.sets = 3, this.repsPerSet = 1, this.restBetweenSetsSec = 180, this.targetWeightKg = 0.0, this.hangThresholdKg = 2.0, this.gripId, this.handMode = HandMode.alternatePerRep, final  List<SetConfig>? setConfigs = null}): _setConfigs = setConfigs,super._();
  factory _ProtocolConfig.fromJson(Map<String, dynamic> json) => _$ProtocolConfigFromJson(json);

@override final  ProtocolType type;
@override@JsonKey() final  int hangDurationSec;
@override@JsonKey() final  int restDurationSec;
@override@JsonKey() final  int sets;
@override@JsonKey() final  int repsPerSet;
@override@JsonKey() final  int restBetweenSetsSec;
@override@JsonKey() final  double targetWeightKg;
@override@JsonKey() final  double hangThresholdKg;
@override final  String? gripId;
@override@JsonKey() final  HandMode handMode;
 final  List<SetConfig>? _setConfigs;
@override@JsonKey() List<SetConfig>? get setConfigs {
  final value = _setConfigs;
  if (value == null) return null;
  if (_setConfigs is EqualUnmodifiableListView) return _setConfigs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ProtocolConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProtocolConfigCopyWith<_ProtocolConfig> get copyWith => __$ProtocolConfigCopyWithImpl<_ProtocolConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProtocolConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProtocolConfig&&(identical(other.type, type) || other.type == type)&&(identical(other.hangDurationSec, hangDurationSec) || other.hangDurationSec == hangDurationSec)&&(identical(other.restDurationSec, restDurationSec) || other.restDurationSec == restDurationSec)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.repsPerSet, repsPerSet) || other.repsPerSet == repsPerSet)&&(identical(other.restBetweenSetsSec, restBetweenSetsSec) || other.restBetweenSetsSec == restBetweenSetsSec)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.hangThresholdKg, hangThresholdKg) || other.hangThresholdKg == hangThresholdKg)&&(identical(other.gripId, gripId) || other.gripId == gripId)&&(identical(other.handMode, handMode) || other.handMode == handMode)&&const DeepCollectionEquality().equals(other._setConfigs, _setConfigs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,hangDurationSec,restDurationSec,sets,repsPerSet,restBetweenSetsSec,targetWeightKg,hangThresholdKg,gripId,handMode,const DeepCollectionEquality().hash(_setConfigs));

@override
String toString() {
  return 'ProtocolConfig(type: $type, hangDurationSec: $hangDurationSec, restDurationSec: $restDurationSec, sets: $sets, repsPerSet: $repsPerSet, restBetweenSetsSec: $restBetweenSetsSec, targetWeightKg: $targetWeightKg, hangThresholdKg: $hangThresholdKg, gripId: $gripId, handMode: $handMode, setConfigs: $setConfigs)';
}


}

/// @nodoc
abstract mixin class _$ProtocolConfigCopyWith<$Res> implements $ProtocolConfigCopyWith<$Res> {
  factory _$ProtocolConfigCopyWith(_ProtocolConfig value, $Res Function(_ProtocolConfig) _then) = __$ProtocolConfigCopyWithImpl;
@override @useResult
$Res call({
 ProtocolType type, int hangDurationSec, int restDurationSec, int sets, int repsPerSet, int restBetweenSetsSec, double targetWeightKg, double hangThresholdKg, String? gripId, HandMode handMode, List<SetConfig>? setConfigs
});




}
/// @nodoc
class __$ProtocolConfigCopyWithImpl<$Res>
    implements _$ProtocolConfigCopyWith<$Res> {
  __$ProtocolConfigCopyWithImpl(this._self, this._then);

  final _ProtocolConfig _self;
  final $Res Function(_ProtocolConfig) _then;

/// Create a copy of ProtocolConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? hangDurationSec = null,Object? restDurationSec = null,Object? sets = null,Object? repsPerSet = null,Object? restBetweenSetsSec = null,Object? targetWeightKg = null,Object? hangThresholdKg = null,Object? gripId = freezed,Object? handMode = null,Object? setConfigs = freezed,}) {
  return _then(_ProtocolConfig(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProtocolType,hangDurationSec: null == hangDurationSec ? _self.hangDurationSec : hangDurationSec // ignore: cast_nullable_to_non_nullable
as int,restDurationSec: null == restDurationSec ? _self.restDurationSec : restDurationSec // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,repsPerSet: null == repsPerSet ? _self.repsPerSet : repsPerSet // ignore: cast_nullable_to_non_nullable
as int,restBetweenSetsSec: null == restBetweenSetsSec ? _self.restBetweenSetsSec : restBetweenSetsSec // ignore: cast_nullable_to_non_nullable
as int,targetWeightKg: null == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double,hangThresholdKg: null == hangThresholdKg ? _self.hangThresholdKg : hangThresholdKg // ignore: cast_nullable_to_non_nullable
as double,gripId: freezed == gripId ? _self.gripId : gripId // ignore: cast_nullable_to_non_nullable
as String?,handMode: null == handMode ? _self.handMode : handMode // ignore: cast_nullable_to_non_nullable
as HandMode,setConfigs: freezed == setConfigs ? _self._setConfigs : setConfigs // ignore: cast_nullable_to_non_nullable
as List<SetConfig>?,
  ));
}


}


/// @nodoc
mixin _$WeightSample {

 double get weight; int get timestampMs;
/// Create a copy of WeightSample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeightSampleCopyWith<WeightSample> get copyWith => _$WeightSampleCopyWithImpl<WeightSample>(this as WeightSample, _$identity);

  /// Serializes this WeightSample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeightSample&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.timestampMs, timestampMs) || other.timestampMs == timestampMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weight,timestampMs);

@override
String toString() {
  return 'WeightSample(weight: $weight, timestampMs: $timestampMs)';
}


}

/// @nodoc
abstract mixin class $WeightSampleCopyWith<$Res>  {
  factory $WeightSampleCopyWith(WeightSample value, $Res Function(WeightSample) _then) = _$WeightSampleCopyWithImpl;
@useResult
$Res call({
 double weight, int timestampMs
});




}
/// @nodoc
class _$WeightSampleCopyWithImpl<$Res>
    implements $WeightSampleCopyWith<$Res> {
  _$WeightSampleCopyWithImpl(this._self, this._then);

  final WeightSample _self;
  final $Res Function(WeightSample) _then;

/// Create a copy of WeightSample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weight = null,Object? timestampMs = null,}) {
  return _then(_self.copyWith(
weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,timestampMs: null == timestampMs ? _self.timestampMs : timestampMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WeightSample].
extension WeightSamplePatterns on WeightSample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeightSample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeightSample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeightSample value)  $default,){
final _that = this;
switch (_that) {
case _WeightSample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeightSample value)?  $default,){
final _that = this;
switch (_that) {
case _WeightSample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double weight,  int timestampMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeightSample() when $default != null:
return $default(_that.weight,_that.timestampMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double weight,  int timestampMs)  $default,) {final _that = this;
switch (_that) {
case _WeightSample():
return $default(_that.weight,_that.timestampMs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double weight,  int timestampMs)?  $default,) {final _that = this;
switch (_that) {
case _WeightSample() when $default != null:
return $default(_that.weight,_that.timestampMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeightSample implements WeightSample {
  const _WeightSample({required this.weight, required this.timestampMs});
  factory _WeightSample.fromJson(Map<String, dynamic> json) => _$WeightSampleFromJson(json);

@override final  double weight;
@override final  int timestampMs;

/// Create a copy of WeightSample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeightSampleCopyWith<_WeightSample> get copyWith => __$WeightSampleCopyWithImpl<_WeightSample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeightSampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeightSample&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.timestampMs, timestampMs) || other.timestampMs == timestampMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weight,timestampMs);

@override
String toString() {
  return 'WeightSample(weight: $weight, timestampMs: $timestampMs)';
}


}

/// @nodoc
abstract mixin class _$WeightSampleCopyWith<$Res> implements $WeightSampleCopyWith<$Res> {
  factory _$WeightSampleCopyWith(_WeightSample value, $Res Function(_WeightSample) _then) = __$WeightSampleCopyWithImpl;
@override @useResult
$Res call({
 double weight, int timestampMs
});




}
/// @nodoc
class __$WeightSampleCopyWithImpl<$Res>
    implements _$WeightSampleCopyWith<$Res> {
  __$WeightSampleCopyWithImpl(this._self, this._then);

  final _WeightSample _self;
  final $Res Function(_WeightSample) _then;

/// Create a copy of WeightSample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weight = null,Object? timestampMs = null,}) {
  return _then(_WeightSample(
weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,timestampMs: null == timestampMs ? _self.timestampMs : timestampMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Rep {

 double get peakForceKg; double get avgForceKg; int get durationMs; int get startTimestampMs; List<WeightSample> get weightSamples;
/// Create a copy of Rep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepCopyWith<Rep> get copyWith => _$RepCopyWithImpl<Rep>(this as Rep, _$identity);

  /// Serializes this Rep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Rep&&(identical(other.peakForceKg, peakForceKg) || other.peakForceKg == peakForceKg)&&(identical(other.avgForceKg, avgForceKg) || other.avgForceKg == avgForceKg)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.startTimestampMs, startTimestampMs) || other.startTimestampMs == startTimestampMs)&&const DeepCollectionEquality().equals(other.weightSamples, weightSamples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,peakForceKg,avgForceKg,durationMs,startTimestampMs,const DeepCollectionEquality().hash(weightSamples));

@override
String toString() {
  return 'Rep(peakForceKg: $peakForceKg, avgForceKg: $avgForceKg, durationMs: $durationMs, startTimestampMs: $startTimestampMs, weightSamples: $weightSamples)';
}


}

/// @nodoc
abstract mixin class $RepCopyWith<$Res>  {
  factory $RepCopyWith(Rep value, $Res Function(Rep) _then) = _$RepCopyWithImpl;
@useResult
$Res call({
 double peakForceKg, double avgForceKg, int durationMs, int startTimestampMs, List<WeightSample> weightSamples
});




}
/// @nodoc
class _$RepCopyWithImpl<$Res>
    implements $RepCopyWith<$Res> {
  _$RepCopyWithImpl(this._self, this._then);

  final Rep _self;
  final $Res Function(Rep) _then;

/// Create a copy of Rep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? peakForceKg = null,Object? avgForceKg = null,Object? durationMs = null,Object? startTimestampMs = null,Object? weightSamples = null,}) {
  return _then(_self.copyWith(
peakForceKg: null == peakForceKg ? _self.peakForceKg : peakForceKg // ignore: cast_nullable_to_non_nullable
as double,avgForceKg: null == avgForceKg ? _self.avgForceKg : avgForceKg // ignore: cast_nullable_to_non_nullable
as double,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,startTimestampMs: null == startTimestampMs ? _self.startTimestampMs : startTimestampMs // ignore: cast_nullable_to_non_nullable
as int,weightSamples: null == weightSamples ? _self.weightSamples : weightSamples // ignore: cast_nullable_to_non_nullable
as List<WeightSample>,
  ));
}

}


/// Adds pattern-matching-related methods to [Rep].
extension RepPatterns on Rep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Rep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Rep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Rep value)  $default,){
final _that = this;
switch (_that) {
case _Rep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Rep value)?  $default,){
final _that = this;
switch (_that) {
case _Rep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double peakForceKg,  double avgForceKg,  int durationMs,  int startTimestampMs,  List<WeightSample> weightSamples)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Rep() when $default != null:
return $default(_that.peakForceKg,_that.avgForceKg,_that.durationMs,_that.startTimestampMs,_that.weightSamples);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double peakForceKg,  double avgForceKg,  int durationMs,  int startTimestampMs,  List<WeightSample> weightSamples)  $default,) {final _that = this;
switch (_that) {
case _Rep():
return $default(_that.peakForceKg,_that.avgForceKg,_that.durationMs,_that.startTimestampMs,_that.weightSamples);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double peakForceKg,  double avgForceKg,  int durationMs,  int startTimestampMs,  List<WeightSample> weightSamples)?  $default,) {final _that = this;
switch (_that) {
case _Rep() when $default != null:
return $default(_that.peakForceKg,_that.avgForceKg,_that.durationMs,_that.startTimestampMs,_that.weightSamples);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Rep implements Rep {
  const _Rep({required this.peakForceKg, required this.avgForceKg, required this.durationMs, required this.startTimestampMs, final  List<WeightSample> weightSamples = const []}): _weightSamples = weightSamples;
  factory _Rep.fromJson(Map<String, dynamic> json) => _$RepFromJson(json);

@override final  double peakForceKg;
@override final  double avgForceKg;
@override final  int durationMs;
@override final  int startTimestampMs;
 final  List<WeightSample> _weightSamples;
@override@JsonKey() List<WeightSample> get weightSamples {
  if (_weightSamples is EqualUnmodifiableListView) return _weightSamples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weightSamples);
}


/// Create a copy of Rep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepCopyWith<_Rep> get copyWith => __$RepCopyWithImpl<_Rep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Rep&&(identical(other.peakForceKg, peakForceKg) || other.peakForceKg == peakForceKg)&&(identical(other.avgForceKg, avgForceKg) || other.avgForceKg == avgForceKg)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.startTimestampMs, startTimestampMs) || other.startTimestampMs == startTimestampMs)&&const DeepCollectionEquality().equals(other._weightSamples, _weightSamples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,peakForceKg,avgForceKg,durationMs,startTimestampMs,const DeepCollectionEquality().hash(_weightSamples));

@override
String toString() {
  return 'Rep(peakForceKg: $peakForceKg, avgForceKg: $avgForceKg, durationMs: $durationMs, startTimestampMs: $startTimestampMs, weightSamples: $weightSamples)';
}


}

/// @nodoc
abstract mixin class _$RepCopyWith<$Res> implements $RepCopyWith<$Res> {
  factory _$RepCopyWith(_Rep value, $Res Function(_Rep) _then) = __$RepCopyWithImpl;
@override @useResult
$Res call({
 double peakForceKg, double avgForceKg, int durationMs, int startTimestampMs, List<WeightSample> weightSamples
});




}
/// @nodoc
class __$RepCopyWithImpl<$Res>
    implements _$RepCopyWith<$Res> {
  __$RepCopyWithImpl(this._self, this._then);

  final _Rep _self;
  final $Res Function(_Rep) _then;

/// Create a copy of Rep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? peakForceKg = null,Object? avgForceKg = null,Object? durationMs = null,Object? startTimestampMs = null,Object? weightSamples = null,}) {
  return _then(_Rep(
peakForceKg: null == peakForceKg ? _self.peakForceKg : peakForceKg // ignore: cast_nullable_to_non_nullable
as double,avgForceKg: null == avgForceKg ? _self.avgForceKg : avgForceKg // ignore: cast_nullable_to_non_nullable
as double,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,startTimestampMs: null == startTimestampMs ? _self.startTimestampMs : startTimestampMs // ignore: cast_nullable_to_non_nullable
as int,weightSamples: null == weightSamples ? _self._weightSamples : weightSamples // ignore: cast_nullable_to_non_nullable
as List<WeightSample>,
  ));
}


}


/// @nodoc
mixin _$TrainingSet {

 List<Rep> get reps; int get restDurationMs;
/// Create a copy of TrainingSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingSetCopyWith<TrainingSet> get copyWith => _$TrainingSetCopyWithImpl<TrainingSet>(this as TrainingSet, _$identity);

  /// Serializes this TrainingSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingSet&&const DeepCollectionEquality().equals(other.reps, reps)&&(identical(other.restDurationMs, restDurationMs) || other.restDurationMs == restDurationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(reps),restDurationMs);

@override
String toString() {
  return 'TrainingSet(reps: $reps, restDurationMs: $restDurationMs)';
}


}

/// @nodoc
abstract mixin class $TrainingSetCopyWith<$Res>  {
  factory $TrainingSetCopyWith(TrainingSet value, $Res Function(TrainingSet) _then) = _$TrainingSetCopyWithImpl;
@useResult
$Res call({
 List<Rep> reps, int restDurationMs
});




}
/// @nodoc
class _$TrainingSetCopyWithImpl<$Res>
    implements $TrainingSetCopyWith<$Res> {
  _$TrainingSetCopyWithImpl(this._self, this._then);

  final TrainingSet _self;
  final $Res Function(TrainingSet) _then;

/// Create a copy of TrainingSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reps = null,Object? restDurationMs = null,}) {
  return _then(_self.copyWith(
reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as List<Rep>,restDurationMs: null == restDurationMs ? _self.restDurationMs : restDurationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainingSet].
extension TrainingSetPatterns on TrainingSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingSet value)  $default,){
final _that = this;
switch (_that) {
case _TrainingSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingSet value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Rep> reps,  int restDurationMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingSet() when $default != null:
return $default(_that.reps,_that.restDurationMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Rep> reps,  int restDurationMs)  $default,) {final _that = this;
switch (_that) {
case _TrainingSet():
return $default(_that.reps,_that.restDurationMs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Rep> reps,  int restDurationMs)?  $default,) {final _that = this;
switch (_that) {
case _TrainingSet() when $default != null:
return $default(_that.reps,_that.restDurationMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainingSet implements TrainingSet {
  const _TrainingSet({final  List<Rep> reps = const [], this.restDurationMs = 0}): _reps = reps;
  factory _TrainingSet.fromJson(Map<String, dynamic> json) => _$TrainingSetFromJson(json);

 final  List<Rep> _reps;
@override@JsonKey() List<Rep> get reps {
  if (_reps is EqualUnmodifiableListView) return _reps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reps);
}

@override@JsonKey() final  int restDurationMs;

/// Create a copy of TrainingSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingSetCopyWith<_TrainingSet> get copyWith => __$TrainingSetCopyWithImpl<_TrainingSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainingSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingSet&&const DeepCollectionEquality().equals(other._reps, _reps)&&(identical(other.restDurationMs, restDurationMs) || other.restDurationMs == restDurationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_reps),restDurationMs);

@override
String toString() {
  return 'TrainingSet(reps: $reps, restDurationMs: $restDurationMs)';
}


}

/// @nodoc
abstract mixin class _$TrainingSetCopyWith<$Res> implements $TrainingSetCopyWith<$Res> {
  factory _$TrainingSetCopyWith(_TrainingSet value, $Res Function(_TrainingSet) _then) = __$TrainingSetCopyWithImpl;
@override @useResult
$Res call({
 List<Rep> reps, int restDurationMs
});




}
/// @nodoc
class __$TrainingSetCopyWithImpl<$Res>
    implements _$TrainingSetCopyWith<$Res> {
  __$TrainingSetCopyWithImpl(this._self, this._then);

  final _TrainingSet _self;
  final $Res Function(_TrainingSet) _then;

/// Create a copy of TrainingSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reps = null,Object? restDurationMs = null,}) {
  return _then(_TrainingSet(
reps: null == reps ? _self._reps : reps // ignore: cast_nullable_to_non_nullable
as List<Rep>,restDurationMs: null == restDurationMs ? _self.restDurationMs : restDurationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Session {

 String get id; ProtocolType get protocolType; ProtocolConfig get protocolConfig; List<TrainingSet> get sets; DateTime get startedAt; DateTime? get endedAt; double get peakForceKg; double get avgPeakForceKg; String get notes;
/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionCopyWith<Session> get copyWith => _$SessionCopyWithImpl<Session>(this as Session, _$identity);

  /// Serializes this Session to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Session&&(identical(other.id, id) || other.id == id)&&(identical(other.protocolType, protocolType) || other.protocolType == protocolType)&&(identical(other.protocolConfig, protocolConfig) || other.protocolConfig == protocolConfig)&&const DeepCollectionEquality().equals(other.sets, sets)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.peakForceKg, peakForceKg) || other.peakForceKg == peakForceKg)&&(identical(other.avgPeakForceKg, avgPeakForceKg) || other.avgPeakForceKg == avgPeakForceKg)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,protocolType,protocolConfig,const DeepCollectionEquality().hash(sets),startedAt,endedAt,peakForceKg,avgPeakForceKg,notes);

@override
String toString() {
  return 'Session(id: $id, protocolType: $protocolType, protocolConfig: $protocolConfig, sets: $sets, startedAt: $startedAt, endedAt: $endedAt, peakForceKg: $peakForceKg, avgPeakForceKg: $avgPeakForceKg, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $SessionCopyWith<$Res>  {
  factory $SessionCopyWith(Session value, $Res Function(Session) _then) = _$SessionCopyWithImpl;
@useResult
$Res call({
 String id, ProtocolType protocolType, ProtocolConfig protocolConfig, List<TrainingSet> sets, DateTime startedAt, DateTime? endedAt, double peakForceKg, double avgPeakForceKg, String notes
});


$ProtocolConfigCopyWith<$Res> get protocolConfig;

}
/// @nodoc
class _$SessionCopyWithImpl<$Res>
    implements $SessionCopyWith<$Res> {
  _$SessionCopyWithImpl(this._self, this._then);

  final Session _self;
  final $Res Function(Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? protocolType = null,Object? protocolConfig = null,Object? sets = null,Object? startedAt = null,Object? endedAt = freezed,Object? peakForceKg = null,Object? avgPeakForceKg = null,Object? notes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,protocolType: null == protocolType ? _self.protocolType : protocolType // ignore: cast_nullable_to_non_nullable
as ProtocolType,protocolConfig: null == protocolConfig ? _self.protocolConfig : protocolConfig // ignore: cast_nullable_to_non_nullable
as ProtocolConfig,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<TrainingSet>,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,peakForceKg: null == peakForceKg ? _self.peakForceKg : peakForceKg // ignore: cast_nullable_to_non_nullable
as double,avgPeakForceKg: null == avgPeakForceKg ? _self.avgPeakForceKg : avgPeakForceKg // ignore: cast_nullable_to_non_nullable
as double,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProtocolConfigCopyWith<$Res> get protocolConfig {
  
  return $ProtocolConfigCopyWith<$Res>(_self.protocolConfig, (value) {
    return _then(_self.copyWith(protocolConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [Session].
extension SessionPatterns on Session {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Session value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Session value)  $default,){
final _that = this;
switch (_that) {
case _Session():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Session value)?  $default,){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ProtocolType protocolType,  ProtocolConfig protocolConfig,  List<TrainingSet> sets,  DateTime startedAt,  DateTime? endedAt,  double peakForceKg,  double avgPeakForceKg,  String notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.id,_that.protocolType,_that.protocolConfig,_that.sets,_that.startedAt,_that.endedAt,_that.peakForceKg,_that.avgPeakForceKg,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ProtocolType protocolType,  ProtocolConfig protocolConfig,  List<TrainingSet> sets,  DateTime startedAt,  DateTime? endedAt,  double peakForceKg,  double avgPeakForceKg,  String notes)  $default,) {final _that = this;
switch (_that) {
case _Session():
return $default(_that.id,_that.protocolType,_that.protocolConfig,_that.sets,_that.startedAt,_that.endedAt,_that.peakForceKg,_that.avgPeakForceKg,_that.notes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ProtocolType protocolType,  ProtocolConfig protocolConfig,  List<TrainingSet> sets,  DateTime startedAt,  DateTime? endedAt,  double peakForceKg,  double avgPeakForceKg,  String notes)?  $default,) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.id,_that.protocolType,_that.protocolConfig,_that.sets,_that.startedAt,_that.endedAt,_that.peakForceKg,_that.avgPeakForceKg,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Session implements Session {
  const _Session({required this.id, required this.protocolType, required this.protocolConfig, final  List<TrainingSet> sets = const [], required this.startedAt, this.endedAt, this.peakForceKg = 0.0, this.avgPeakForceKg = 0.0, this.notes = ''}): _sets = sets;
  factory _Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

@override final  String id;
@override final  ProtocolType protocolType;
@override final  ProtocolConfig protocolConfig;
 final  List<TrainingSet> _sets;
@override@JsonKey() List<TrainingSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

@override final  DateTime startedAt;
@override final  DateTime? endedAt;
@override@JsonKey() final  double peakForceKg;
@override@JsonKey() final  double avgPeakForceKg;
@override@JsonKey() final  String notes;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionCopyWith<_Session> get copyWith => __$SessionCopyWithImpl<_Session>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Session&&(identical(other.id, id) || other.id == id)&&(identical(other.protocolType, protocolType) || other.protocolType == protocolType)&&(identical(other.protocolConfig, protocolConfig) || other.protocolConfig == protocolConfig)&&const DeepCollectionEquality().equals(other._sets, _sets)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.peakForceKg, peakForceKg) || other.peakForceKg == peakForceKg)&&(identical(other.avgPeakForceKg, avgPeakForceKg) || other.avgPeakForceKg == avgPeakForceKg)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,protocolType,protocolConfig,const DeepCollectionEquality().hash(_sets),startedAt,endedAt,peakForceKg,avgPeakForceKg,notes);

@override
String toString() {
  return 'Session(id: $id, protocolType: $protocolType, protocolConfig: $protocolConfig, sets: $sets, startedAt: $startedAt, endedAt: $endedAt, peakForceKg: $peakForceKg, avgPeakForceKg: $avgPeakForceKg, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$SessionCopyWith<$Res> implements $SessionCopyWith<$Res> {
  factory _$SessionCopyWith(_Session value, $Res Function(_Session) _then) = __$SessionCopyWithImpl;
@override @useResult
$Res call({
 String id, ProtocolType protocolType, ProtocolConfig protocolConfig, List<TrainingSet> sets, DateTime startedAt, DateTime? endedAt, double peakForceKg, double avgPeakForceKg, String notes
});


@override $ProtocolConfigCopyWith<$Res> get protocolConfig;

}
/// @nodoc
class __$SessionCopyWithImpl<$Res>
    implements _$SessionCopyWith<$Res> {
  __$SessionCopyWithImpl(this._self, this._then);

  final _Session _self;
  final $Res Function(_Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? protocolType = null,Object? protocolConfig = null,Object? sets = null,Object? startedAt = null,Object? endedAt = freezed,Object? peakForceKg = null,Object? avgPeakForceKg = null,Object? notes = null,}) {
  return _then(_Session(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,protocolType: null == protocolType ? _self.protocolType : protocolType // ignore: cast_nullable_to_non_nullable
as ProtocolType,protocolConfig: null == protocolConfig ? _self.protocolConfig : protocolConfig // ignore: cast_nullable_to_non_nullable
as ProtocolConfig,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<TrainingSet>,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,peakForceKg: null == peakForceKg ? _self.peakForceKg : peakForceKg // ignore: cast_nullable_to_non_nullable
as double,avgPeakForceKg: null == avgPeakForceKg ? _self.avgPeakForceKg : avgPeakForceKg // ignore: cast_nullable_to_non_nullable
as double,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProtocolConfigCopyWith<$Res> get protocolConfig {
  
  return $ProtocolConfigCopyWith<$Res>(_self.protocolConfig, (value) {
    return _then(_self.copyWith(protocolConfig: value));
  });
}
}

/// @nodoc
mixin _$ActiveSessionState {

 ProtocolConfig get protocol; int get currentSetIndex; SessionPhase get phase; int get phaseRemainingMs; int get phaseElapsedMs; int get phaseDeadlineMs; int get phaseStartMs; Rep? get currentRep; List<TrainingSet> get completedSets; List<Rep> get currentSetReps; double get liveWeightKg; double get peakWeightKg; List<WeightSample> get liveWeightHistory; bool get isPaused; int get currentHandIndex;// 0 = left, 1 = right
// Timer is frozen until weight crosses hangThresholdKg
 bool get waitingForThreshold;
/// Create a copy of ActiveSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActiveSessionStateCopyWith<ActiveSessionState> get copyWith => _$ActiveSessionStateCopyWithImpl<ActiveSessionState>(this as ActiveSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActiveSessionState&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.currentSetIndex, currentSetIndex) || other.currentSetIndex == currentSetIndex)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.phaseRemainingMs, phaseRemainingMs) || other.phaseRemainingMs == phaseRemainingMs)&&(identical(other.phaseElapsedMs, phaseElapsedMs) || other.phaseElapsedMs == phaseElapsedMs)&&(identical(other.phaseDeadlineMs, phaseDeadlineMs) || other.phaseDeadlineMs == phaseDeadlineMs)&&(identical(other.phaseStartMs, phaseStartMs) || other.phaseStartMs == phaseStartMs)&&(identical(other.currentRep, currentRep) || other.currentRep == currentRep)&&const DeepCollectionEquality().equals(other.completedSets, completedSets)&&const DeepCollectionEquality().equals(other.currentSetReps, currentSetReps)&&(identical(other.liveWeightKg, liveWeightKg) || other.liveWeightKg == liveWeightKg)&&(identical(other.peakWeightKg, peakWeightKg) || other.peakWeightKg == peakWeightKg)&&const DeepCollectionEquality().equals(other.liveWeightHistory, liveWeightHistory)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.currentHandIndex, currentHandIndex) || other.currentHandIndex == currentHandIndex)&&(identical(other.waitingForThreshold, waitingForThreshold) || other.waitingForThreshold == waitingForThreshold));
}


@override
int get hashCode => Object.hash(runtimeType,protocol,currentSetIndex,phase,phaseRemainingMs,phaseElapsedMs,phaseDeadlineMs,phaseStartMs,currentRep,const DeepCollectionEquality().hash(completedSets),const DeepCollectionEquality().hash(currentSetReps),liveWeightKg,peakWeightKg,const DeepCollectionEquality().hash(liveWeightHistory),isPaused,currentHandIndex,waitingForThreshold);

@override
String toString() {
  return 'ActiveSessionState(protocol: $protocol, currentSetIndex: $currentSetIndex, phase: $phase, phaseRemainingMs: $phaseRemainingMs, phaseElapsedMs: $phaseElapsedMs, phaseDeadlineMs: $phaseDeadlineMs, phaseStartMs: $phaseStartMs, currentRep: $currentRep, completedSets: $completedSets, currentSetReps: $currentSetReps, liveWeightKg: $liveWeightKg, peakWeightKg: $peakWeightKg, liveWeightHistory: $liveWeightHistory, isPaused: $isPaused, currentHandIndex: $currentHandIndex, waitingForThreshold: $waitingForThreshold)';
}


}

/// @nodoc
abstract mixin class $ActiveSessionStateCopyWith<$Res>  {
  factory $ActiveSessionStateCopyWith(ActiveSessionState value, $Res Function(ActiveSessionState) _then) = _$ActiveSessionStateCopyWithImpl;
@useResult
$Res call({
 ProtocolConfig protocol, int currentSetIndex, SessionPhase phase, int phaseRemainingMs, int phaseElapsedMs, int phaseDeadlineMs, int phaseStartMs, Rep? currentRep, List<TrainingSet> completedSets, List<Rep> currentSetReps, double liveWeightKg, double peakWeightKg, List<WeightSample> liveWeightHistory, bool isPaused, int currentHandIndex, bool waitingForThreshold
});


$ProtocolConfigCopyWith<$Res> get protocol;$RepCopyWith<$Res>? get currentRep;

}
/// @nodoc
class _$ActiveSessionStateCopyWithImpl<$Res>
    implements $ActiveSessionStateCopyWith<$Res> {
  _$ActiveSessionStateCopyWithImpl(this._self, this._then);

  final ActiveSessionState _self;
  final $Res Function(ActiveSessionState) _then;

/// Create a copy of ActiveSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? protocol = null,Object? currentSetIndex = null,Object? phase = null,Object? phaseRemainingMs = null,Object? phaseElapsedMs = null,Object? phaseDeadlineMs = null,Object? phaseStartMs = null,Object? currentRep = freezed,Object? completedSets = null,Object? currentSetReps = null,Object? liveWeightKg = null,Object? peakWeightKg = null,Object? liveWeightHistory = null,Object? isPaused = null,Object? currentHandIndex = null,Object? waitingForThreshold = null,}) {
  return _then(_self.copyWith(
protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as ProtocolConfig,currentSetIndex: null == currentSetIndex ? _self.currentSetIndex : currentSetIndex // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SessionPhase,phaseRemainingMs: null == phaseRemainingMs ? _self.phaseRemainingMs : phaseRemainingMs // ignore: cast_nullable_to_non_nullable
as int,phaseElapsedMs: null == phaseElapsedMs ? _self.phaseElapsedMs : phaseElapsedMs // ignore: cast_nullable_to_non_nullable
as int,phaseDeadlineMs: null == phaseDeadlineMs ? _self.phaseDeadlineMs : phaseDeadlineMs // ignore: cast_nullable_to_non_nullable
as int,phaseStartMs: null == phaseStartMs ? _self.phaseStartMs : phaseStartMs // ignore: cast_nullable_to_non_nullable
as int,currentRep: freezed == currentRep ? _self.currentRep : currentRep // ignore: cast_nullable_to_non_nullable
as Rep?,completedSets: null == completedSets ? _self.completedSets : completedSets // ignore: cast_nullable_to_non_nullable
as List<TrainingSet>,currentSetReps: null == currentSetReps ? _self.currentSetReps : currentSetReps // ignore: cast_nullable_to_non_nullable
as List<Rep>,liveWeightKg: null == liveWeightKg ? _self.liveWeightKg : liveWeightKg // ignore: cast_nullable_to_non_nullable
as double,peakWeightKg: null == peakWeightKg ? _self.peakWeightKg : peakWeightKg // ignore: cast_nullable_to_non_nullable
as double,liveWeightHistory: null == liveWeightHistory ? _self.liveWeightHistory : liveWeightHistory // ignore: cast_nullable_to_non_nullable
as List<WeightSample>,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,currentHandIndex: null == currentHandIndex ? _self.currentHandIndex : currentHandIndex // ignore: cast_nullable_to_non_nullable
as int,waitingForThreshold: null == waitingForThreshold ? _self.waitingForThreshold : waitingForThreshold // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ActiveSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProtocolConfigCopyWith<$Res> get protocol {
  
  return $ProtocolConfigCopyWith<$Res>(_self.protocol, (value) {
    return _then(_self.copyWith(protocol: value));
  });
}/// Create a copy of ActiveSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepCopyWith<$Res>? get currentRep {
    if (_self.currentRep == null) {
    return null;
  }

  return $RepCopyWith<$Res>(_self.currentRep!, (value) {
    return _then(_self.copyWith(currentRep: value));
  });
}
}


/// Adds pattern-matching-related methods to [ActiveSessionState].
extension ActiveSessionStatePatterns on ActiveSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActiveSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActiveSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActiveSessionState value)  $default,){
final _that = this;
switch (_that) {
case _ActiveSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActiveSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _ActiveSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProtocolConfig protocol,  int currentSetIndex,  SessionPhase phase,  int phaseRemainingMs,  int phaseElapsedMs,  int phaseDeadlineMs,  int phaseStartMs,  Rep? currentRep,  List<TrainingSet> completedSets,  List<Rep> currentSetReps,  double liveWeightKg,  double peakWeightKg,  List<WeightSample> liveWeightHistory,  bool isPaused,  int currentHandIndex,  bool waitingForThreshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActiveSessionState() when $default != null:
return $default(_that.protocol,_that.currentSetIndex,_that.phase,_that.phaseRemainingMs,_that.phaseElapsedMs,_that.phaseDeadlineMs,_that.phaseStartMs,_that.currentRep,_that.completedSets,_that.currentSetReps,_that.liveWeightKg,_that.peakWeightKg,_that.liveWeightHistory,_that.isPaused,_that.currentHandIndex,_that.waitingForThreshold);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProtocolConfig protocol,  int currentSetIndex,  SessionPhase phase,  int phaseRemainingMs,  int phaseElapsedMs,  int phaseDeadlineMs,  int phaseStartMs,  Rep? currentRep,  List<TrainingSet> completedSets,  List<Rep> currentSetReps,  double liveWeightKg,  double peakWeightKg,  List<WeightSample> liveWeightHistory,  bool isPaused,  int currentHandIndex,  bool waitingForThreshold)  $default,) {final _that = this;
switch (_that) {
case _ActiveSessionState():
return $default(_that.protocol,_that.currentSetIndex,_that.phase,_that.phaseRemainingMs,_that.phaseElapsedMs,_that.phaseDeadlineMs,_that.phaseStartMs,_that.currentRep,_that.completedSets,_that.currentSetReps,_that.liveWeightKg,_that.peakWeightKg,_that.liveWeightHistory,_that.isPaused,_that.currentHandIndex,_that.waitingForThreshold);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProtocolConfig protocol,  int currentSetIndex,  SessionPhase phase,  int phaseRemainingMs,  int phaseElapsedMs,  int phaseDeadlineMs,  int phaseStartMs,  Rep? currentRep,  List<TrainingSet> completedSets,  List<Rep> currentSetReps,  double liveWeightKg,  double peakWeightKg,  List<WeightSample> liveWeightHistory,  bool isPaused,  int currentHandIndex,  bool waitingForThreshold)?  $default,) {final _that = this;
switch (_that) {
case _ActiveSessionState() when $default != null:
return $default(_that.protocol,_that.currentSetIndex,_that.phase,_that.phaseRemainingMs,_that.phaseElapsedMs,_that.phaseDeadlineMs,_that.phaseStartMs,_that.currentRep,_that.completedSets,_that.currentSetReps,_that.liveWeightKg,_that.peakWeightKg,_that.liveWeightHistory,_that.isPaused,_that.currentHandIndex,_that.waitingForThreshold);case _:
  return null;

}
}

}

/// @nodoc


class _ActiveSessionState implements ActiveSessionState {
  const _ActiveSessionState({required this.protocol, this.currentSetIndex = 0, this.phase = SessionPhase.idle, this.phaseRemainingMs = 0, this.phaseElapsedMs = 0, this.phaseDeadlineMs = 0, this.phaseStartMs = 0, this.currentRep, final  List<TrainingSet> completedSets = const [], final  List<Rep> currentSetReps = const [], this.liveWeightKg = 0.0, this.peakWeightKg = 0.0, final  List<WeightSample> liveWeightHistory = const [], this.isPaused = false, this.currentHandIndex = 0, this.waitingForThreshold = false}): _completedSets = completedSets,_currentSetReps = currentSetReps,_liveWeightHistory = liveWeightHistory;
  

@override final  ProtocolConfig protocol;
@override@JsonKey() final  int currentSetIndex;
@override@JsonKey() final  SessionPhase phase;
@override@JsonKey() final  int phaseRemainingMs;
@override@JsonKey() final  int phaseElapsedMs;
@override@JsonKey() final  int phaseDeadlineMs;
@override@JsonKey() final  int phaseStartMs;
@override final  Rep? currentRep;
 final  List<TrainingSet> _completedSets;
@override@JsonKey() List<TrainingSet> get completedSets {
  if (_completedSets is EqualUnmodifiableListView) return _completedSets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedSets);
}

 final  List<Rep> _currentSetReps;
@override@JsonKey() List<Rep> get currentSetReps {
  if (_currentSetReps is EqualUnmodifiableListView) return _currentSetReps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_currentSetReps);
}

@override@JsonKey() final  double liveWeightKg;
@override@JsonKey() final  double peakWeightKg;
 final  List<WeightSample> _liveWeightHistory;
@override@JsonKey() List<WeightSample> get liveWeightHistory {
  if (_liveWeightHistory is EqualUnmodifiableListView) return _liveWeightHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_liveWeightHistory);
}

@override@JsonKey() final  bool isPaused;
@override@JsonKey() final  int currentHandIndex;
// 0 = left, 1 = right
// Timer is frozen until weight crosses hangThresholdKg
@override@JsonKey() final  bool waitingForThreshold;

/// Create a copy of ActiveSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActiveSessionStateCopyWith<_ActiveSessionState> get copyWith => __$ActiveSessionStateCopyWithImpl<_ActiveSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActiveSessionState&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.currentSetIndex, currentSetIndex) || other.currentSetIndex == currentSetIndex)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.phaseRemainingMs, phaseRemainingMs) || other.phaseRemainingMs == phaseRemainingMs)&&(identical(other.phaseElapsedMs, phaseElapsedMs) || other.phaseElapsedMs == phaseElapsedMs)&&(identical(other.phaseDeadlineMs, phaseDeadlineMs) || other.phaseDeadlineMs == phaseDeadlineMs)&&(identical(other.phaseStartMs, phaseStartMs) || other.phaseStartMs == phaseStartMs)&&(identical(other.currentRep, currentRep) || other.currentRep == currentRep)&&const DeepCollectionEquality().equals(other._completedSets, _completedSets)&&const DeepCollectionEquality().equals(other._currentSetReps, _currentSetReps)&&(identical(other.liveWeightKg, liveWeightKg) || other.liveWeightKg == liveWeightKg)&&(identical(other.peakWeightKg, peakWeightKg) || other.peakWeightKg == peakWeightKg)&&const DeepCollectionEquality().equals(other._liveWeightHistory, _liveWeightHistory)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.currentHandIndex, currentHandIndex) || other.currentHandIndex == currentHandIndex)&&(identical(other.waitingForThreshold, waitingForThreshold) || other.waitingForThreshold == waitingForThreshold));
}


@override
int get hashCode => Object.hash(runtimeType,protocol,currentSetIndex,phase,phaseRemainingMs,phaseElapsedMs,phaseDeadlineMs,phaseStartMs,currentRep,const DeepCollectionEquality().hash(_completedSets),const DeepCollectionEquality().hash(_currentSetReps),liveWeightKg,peakWeightKg,const DeepCollectionEquality().hash(_liveWeightHistory),isPaused,currentHandIndex,waitingForThreshold);

@override
String toString() {
  return 'ActiveSessionState(protocol: $protocol, currentSetIndex: $currentSetIndex, phase: $phase, phaseRemainingMs: $phaseRemainingMs, phaseElapsedMs: $phaseElapsedMs, phaseDeadlineMs: $phaseDeadlineMs, phaseStartMs: $phaseStartMs, currentRep: $currentRep, completedSets: $completedSets, currentSetReps: $currentSetReps, liveWeightKg: $liveWeightKg, peakWeightKg: $peakWeightKg, liveWeightHistory: $liveWeightHistory, isPaused: $isPaused, currentHandIndex: $currentHandIndex, waitingForThreshold: $waitingForThreshold)';
}


}

/// @nodoc
abstract mixin class _$ActiveSessionStateCopyWith<$Res> implements $ActiveSessionStateCopyWith<$Res> {
  factory _$ActiveSessionStateCopyWith(_ActiveSessionState value, $Res Function(_ActiveSessionState) _then) = __$ActiveSessionStateCopyWithImpl;
@override @useResult
$Res call({
 ProtocolConfig protocol, int currentSetIndex, SessionPhase phase, int phaseRemainingMs, int phaseElapsedMs, int phaseDeadlineMs, int phaseStartMs, Rep? currentRep, List<TrainingSet> completedSets, List<Rep> currentSetReps, double liveWeightKg, double peakWeightKg, List<WeightSample> liveWeightHistory, bool isPaused, int currentHandIndex, bool waitingForThreshold
});


@override $ProtocolConfigCopyWith<$Res> get protocol;@override $RepCopyWith<$Res>? get currentRep;

}
/// @nodoc
class __$ActiveSessionStateCopyWithImpl<$Res>
    implements _$ActiveSessionStateCopyWith<$Res> {
  __$ActiveSessionStateCopyWithImpl(this._self, this._then);

  final _ActiveSessionState _self;
  final $Res Function(_ActiveSessionState) _then;

/// Create a copy of ActiveSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? protocol = null,Object? currentSetIndex = null,Object? phase = null,Object? phaseRemainingMs = null,Object? phaseElapsedMs = null,Object? phaseDeadlineMs = null,Object? phaseStartMs = null,Object? currentRep = freezed,Object? completedSets = null,Object? currentSetReps = null,Object? liveWeightKg = null,Object? peakWeightKg = null,Object? liveWeightHistory = null,Object? isPaused = null,Object? currentHandIndex = null,Object? waitingForThreshold = null,}) {
  return _then(_ActiveSessionState(
protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as ProtocolConfig,currentSetIndex: null == currentSetIndex ? _self.currentSetIndex : currentSetIndex // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SessionPhase,phaseRemainingMs: null == phaseRemainingMs ? _self.phaseRemainingMs : phaseRemainingMs // ignore: cast_nullable_to_non_nullable
as int,phaseElapsedMs: null == phaseElapsedMs ? _self.phaseElapsedMs : phaseElapsedMs // ignore: cast_nullable_to_non_nullable
as int,phaseDeadlineMs: null == phaseDeadlineMs ? _self.phaseDeadlineMs : phaseDeadlineMs // ignore: cast_nullable_to_non_nullable
as int,phaseStartMs: null == phaseStartMs ? _self.phaseStartMs : phaseStartMs // ignore: cast_nullable_to_non_nullable
as int,currentRep: freezed == currentRep ? _self.currentRep : currentRep // ignore: cast_nullable_to_non_nullable
as Rep?,completedSets: null == completedSets ? _self._completedSets : completedSets // ignore: cast_nullable_to_non_nullable
as List<TrainingSet>,currentSetReps: null == currentSetReps ? _self._currentSetReps : currentSetReps // ignore: cast_nullable_to_non_nullable
as List<Rep>,liveWeightKg: null == liveWeightKg ? _self.liveWeightKg : liveWeightKg // ignore: cast_nullable_to_non_nullable
as double,peakWeightKg: null == peakWeightKg ? _self.peakWeightKg : peakWeightKg // ignore: cast_nullable_to_non_nullable
as double,liveWeightHistory: null == liveWeightHistory ? _self._liveWeightHistory : liveWeightHistory // ignore: cast_nullable_to_non_nullable
as List<WeightSample>,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,currentHandIndex: null == currentHandIndex ? _self.currentHandIndex : currentHandIndex // ignore: cast_nullable_to_non_nullable
as int,waitingForThreshold: null == waitingForThreshold ? _self.waitingForThreshold : waitingForThreshold // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ActiveSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProtocolConfigCopyWith<$Res> get protocol {
  
  return $ProtocolConfigCopyWith<$Res>(_self.protocol, (value) {
    return _then(_self.copyWith(protocol: value));
  });
}/// Create a copy of ActiveSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepCopyWith<$Res>? get currentRep {
    if (_self.currentRep == null) {
    return null;
  }

  return $RepCopyWith<$Res>(_self.currentRep!, (value) {
    return _then(_self.copyWith(currentRep: value));
  });
}
}

// dart format on

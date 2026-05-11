// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grip_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Grip {

 String get id; String get name; double get edgeDepthMm; Set<Finger> get fingers; GripType get gripType; ContractionType get contractionType; DateTime get createdAt;
/// Create a copy of Grip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GripCopyWith<Grip> get copyWith => _$GripCopyWithImpl<Grip>(this as Grip, _$identity);

  /// Serializes this Grip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Grip&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.edgeDepthMm, edgeDepthMm) || other.edgeDepthMm == edgeDepthMm)&&const DeepCollectionEquality().equals(other.fingers, fingers)&&(identical(other.gripType, gripType) || other.gripType == gripType)&&(identical(other.contractionType, contractionType) || other.contractionType == contractionType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,edgeDepthMm,const DeepCollectionEquality().hash(fingers),gripType,contractionType,createdAt);

@override
String toString() {
  return 'Grip(id: $id, name: $name, edgeDepthMm: $edgeDepthMm, fingers: $fingers, gripType: $gripType, contractionType: $contractionType, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GripCopyWith<$Res>  {
  factory $GripCopyWith(Grip value, $Res Function(Grip) _then) = _$GripCopyWithImpl;
@useResult
$Res call({
 String id, String name, double edgeDepthMm, Set<Finger> fingers, GripType gripType, ContractionType contractionType, DateTime createdAt
});




}
/// @nodoc
class _$GripCopyWithImpl<$Res>
    implements $GripCopyWith<$Res> {
  _$GripCopyWithImpl(this._self, this._then);

  final Grip _self;
  final $Res Function(Grip) _then;

/// Create a copy of Grip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? edgeDepthMm = null,Object? fingers = null,Object? gripType = null,Object? contractionType = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,edgeDepthMm: null == edgeDepthMm ? _self.edgeDepthMm : edgeDepthMm // ignore: cast_nullable_to_non_nullable
as double,fingers: null == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as Set<Finger>,gripType: null == gripType ? _self.gripType : gripType // ignore: cast_nullable_to_non_nullable
as GripType,contractionType: null == contractionType ? _self.contractionType : contractionType // ignore: cast_nullable_to_non_nullable
as ContractionType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Grip].
extension GripPatterns on Grip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Grip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Grip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Grip value)  $default,){
final _that = this;
switch (_that) {
case _Grip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Grip value)?  $default,){
final _that = this;
switch (_that) {
case _Grip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double edgeDepthMm,  Set<Finger> fingers,  GripType gripType,  ContractionType contractionType,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Grip() when $default != null:
return $default(_that.id,_that.name,_that.edgeDepthMm,_that.fingers,_that.gripType,_that.contractionType,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double edgeDepthMm,  Set<Finger> fingers,  GripType gripType,  ContractionType contractionType,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Grip():
return $default(_that.id,_that.name,_that.edgeDepthMm,_that.fingers,_that.gripType,_that.contractionType,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double edgeDepthMm,  Set<Finger> fingers,  GripType gripType,  ContractionType contractionType,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Grip() when $default != null:
return $default(_that.id,_that.name,_that.edgeDepthMm,_that.fingers,_that.gripType,_that.contractionType,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Grip extends Grip {
  const _Grip({required this.id, required this.name, required this.edgeDepthMm, required final  Set<Finger> fingers, required this.gripType, required this.contractionType, required this.createdAt}): _fingers = fingers,super._();
  factory _Grip.fromJson(Map<String, dynamic> json) => _$GripFromJson(json);

@override final  String id;
@override final  String name;
@override final  double edgeDepthMm;
 final  Set<Finger> _fingers;
@override Set<Finger> get fingers {
  if (_fingers is EqualUnmodifiableSetView) return _fingers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_fingers);
}

@override final  GripType gripType;
@override final  ContractionType contractionType;
@override final  DateTime createdAt;

/// Create a copy of Grip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GripCopyWith<_Grip> get copyWith => __$GripCopyWithImpl<_Grip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GripToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Grip&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.edgeDepthMm, edgeDepthMm) || other.edgeDepthMm == edgeDepthMm)&&const DeepCollectionEquality().equals(other._fingers, _fingers)&&(identical(other.gripType, gripType) || other.gripType == gripType)&&(identical(other.contractionType, contractionType) || other.contractionType == contractionType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,edgeDepthMm,const DeepCollectionEquality().hash(_fingers),gripType,contractionType,createdAt);

@override
String toString() {
  return 'Grip(id: $id, name: $name, edgeDepthMm: $edgeDepthMm, fingers: $fingers, gripType: $gripType, contractionType: $contractionType, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GripCopyWith<$Res> implements $GripCopyWith<$Res> {
  factory _$GripCopyWith(_Grip value, $Res Function(_Grip) _then) = __$GripCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double edgeDepthMm, Set<Finger> fingers, GripType gripType, ContractionType contractionType, DateTime createdAt
});




}
/// @nodoc
class __$GripCopyWithImpl<$Res>
    implements _$GripCopyWith<$Res> {
  __$GripCopyWithImpl(this._self, this._then);

  final _Grip _self;
  final $Res Function(_Grip) _then;

/// Create a copy of Grip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? edgeDepthMm = null,Object? fingers = null,Object? gripType = null,Object? contractionType = null,Object? createdAt = null,}) {
  return _then(_Grip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,edgeDepthMm: null == edgeDepthMm ? _self.edgeDepthMm : edgeDepthMm // ignore: cast_nullable_to_non_nullable
as double,fingers: null == fingers ? _self._fingers : fingers // ignore: cast_nullable_to_non_nullable
as Set<Finger>,gripType: null == gripType ? _self.gripType : gripType // ignore: cast_nullable_to_non_nullable
as GripType,contractionType: null == contractionType ? _self.contractionType : contractionType // ignore: cast_nullable_to_non_nullable
as ContractionType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

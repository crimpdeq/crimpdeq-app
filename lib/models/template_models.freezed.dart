// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionTemplate {

 String get id; String get name; ProtocolConfig get protocolConfig; DateTime get createdAt;
/// Create a copy of SessionTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionTemplateCopyWith<SessionTemplate> get copyWith => _$SessionTemplateCopyWithImpl<SessionTemplate>(this as SessionTemplate, _$identity);

  /// Serializes this SessionTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.protocolConfig, protocolConfig) || other.protocolConfig == protocolConfig)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,protocolConfig,createdAt);

@override
String toString() {
  return 'SessionTemplate(id: $id, name: $name, protocolConfig: $protocolConfig, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SessionTemplateCopyWith<$Res>  {
  factory $SessionTemplateCopyWith(SessionTemplate value, $Res Function(SessionTemplate) _then) = _$SessionTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, ProtocolConfig protocolConfig, DateTime createdAt
});


$ProtocolConfigCopyWith<$Res> get protocolConfig;

}
/// @nodoc
class _$SessionTemplateCopyWithImpl<$Res>
    implements $SessionTemplateCopyWith<$Res> {
  _$SessionTemplateCopyWithImpl(this._self, this._then);

  final SessionTemplate _self;
  final $Res Function(SessionTemplate) _then;

/// Create a copy of SessionTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? protocolConfig = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,protocolConfig: null == protocolConfig ? _self.protocolConfig : protocolConfig // ignore: cast_nullable_to_non_nullable
as ProtocolConfig,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of SessionTemplate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProtocolConfigCopyWith<$Res> get protocolConfig {
  
  return $ProtocolConfigCopyWith<$Res>(_self.protocolConfig, (value) {
    return _then(_self.copyWith(protocolConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [SessionTemplate].
extension SessionTemplatePatterns on SessionTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionTemplate value)  $default,){
final _that = this;
switch (_that) {
case _SessionTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _SessionTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  ProtocolConfig protocolConfig,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionTemplate() when $default != null:
return $default(_that.id,_that.name,_that.protocolConfig,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  ProtocolConfig protocolConfig,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SessionTemplate():
return $default(_that.id,_that.name,_that.protocolConfig,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  ProtocolConfig protocolConfig,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionTemplate() when $default != null:
return $default(_that.id,_that.name,_that.protocolConfig,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionTemplate implements SessionTemplate {
  const _SessionTemplate({required this.id, required this.name, required this.protocolConfig, required this.createdAt});
  factory _SessionTemplate.fromJson(Map<String, dynamic> json) => _$SessionTemplateFromJson(json);

@override final  String id;
@override final  String name;
@override final  ProtocolConfig protocolConfig;
@override final  DateTime createdAt;

/// Create a copy of SessionTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionTemplateCopyWith<_SessionTemplate> get copyWith => __$SessionTemplateCopyWithImpl<_SessionTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.protocolConfig, protocolConfig) || other.protocolConfig == protocolConfig)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,protocolConfig,createdAt);

@override
String toString() {
  return 'SessionTemplate(id: $id, name: $name, protocolConfig: $protocolConfig, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SessionTemplateCopyWith<$Res> implements $SessionTemplateCopyWith<$Res> {
  factory _$SessionTemplateCopyWith(_SessionTemplate value, $Res Function(_SessionTemplate) _then) = __$SessionTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, ProtocolConfig protocolConfig, DateTime createdAt
});


@override $ProtocolConfigCopyWith<$Res> get protocolConfig;

}
/// @nodoc
class __$SessionTemplateCopyWithImpl<$Res>
    implements _$SessionTemplateCopyWith<$Res> {
  __$SessionTemplateCopyWithImpl(this._self, this._then);

  final _SessionTemplate _self;
  final $Res Function(_SessionTemplate) _then;

/// Create a copy of SessionTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? protocolConfig = null,Object? createdAt = null,}) {
  return _then(_SessionTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,protocolConfig: null == protocolConfig ? _self.protocolConfig : protocolConfig // ignore: cast_nullable_to_non_nullable
as ProtocolConfig,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of SessionTemplate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProtocolConfigCopyWith<$Res> get protocolConfig {
  
  return $ProtocolConfigCopyWith<$Res>(_self.protocolConfig, (value) {
    return _then(_self.copyWith(protocolConfig: value));
  });
}
}

// dart format on

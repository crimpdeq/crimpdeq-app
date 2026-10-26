// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkoutPlan {

 String get tool; Hand get hand; CurveSection get section; double get benchmarkKg; int get firstHangSeconds; int get reps; int get restSeconds;/// Null follows the section's rep ratios.
 EnergySystems? get energySystems;
/// Create a copy of WorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutPlanCopyWith<WorkoutPlan> get copyWith => _$WorkoutPlanCopyWithImpl<WorkoutPlan>(this as WorkoutPlan, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkoutPlan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutPlan&&(identical(other.tool, _this.tool) || other.tool == _this.tool)&&(identical(other.hand, _this.hand) || other.hand == _this.hand)&&(identical(other.section, _this.section) || other.section == _this.section)&&(identical(other.benchmarkKg, _this.benchmarkKg) || other.benchmarkKg == _this.benchmarkKg)&&(identical(other.firstHangSeconds, _this.firstHangSeconds) || other.firstHangSeconds == _this.firstHangSeconds)&&(identical(other.reps, _this.reps) || other.reps == _this.reps)&&(identical(other.restSeconds, _this.restSeconds) || other.restSeconds == _this.restSeconds)&&(identical(other.energySystems, _this.energySystems) || other.energySystems == _this.energySystems));
}


@override
int get hashCode {
  final _this = this as WorkoutPlan;
  return Object.hash(runtimeType,_this.tool,_this.hand,_this.section,_this.benchmarkKg,_this.firstHangSeconds,_this.reps,_this.restSeconds,_this.energySystems);
}

@override
String toString() {
  final _this = this as WorkoutPlan;
  return 'WorkoutPlan(tool: ${_this.tool}, hand: ${_this.hand}, section: ${_this.section}, benchmarkKg: ${_this.benchmarkKg}, firstHangSeconds: ${_this.firstHangSeconds}, reps: ${_this.reps}, restSeconds: ${_this.restSeconds}, energySystems: ${_this.energySystems})';
}


}

/// @nodoc
abstract mixin class $WorkoutPlanCopyWith<$Res>  {
  factory $WorkoutPlanCopyWith(WorkoutPlan value, $Res Function(WorkoutPlan) _then) = _$WorkoutPlanCopyWithImpl;
@useResult
$Res call({
 String tool, Hand hand, CurveSection section, double benchmarkKg, int firstHangSeconds, int reps, int restSeconds, EnergySystems? energySystems
});




}
/// @nodoc
class _$WorkoutPlanCopyWithImpl<$Res>
    implements $WorkoutPlanCopyWith<$Res> {
  _$WorkoutPlanCopyWithImpl(this._self, this._then);

  final WorkoutPlan _self;
  final $Res Function(WorkoutPlan) _then;

/// Create a copy of WorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tool = null,Object? hand = null,Object? section = null,Object? benchmarkKg = null,Object? firstHangSeconds = null,Object? reps = null,Object? restSeconds = null,Object? energySystems = freezed,}) {
  return _then(WorkoutPlan(
tool: null == tool ? _self.tool : tool // ignore: cast_nullable_to_non_nullable
as String,hand: null == hand ? _self.hand : hand // ignore: cast_nullable_to_non_nullable
as Hand,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as CurveSection,benchmarkKg: null == benchmarkKg ? _self.benchmarkKg : benchmarkKg // ignore: cast_nullable_to_non_nullable
as double,firstHangSeconds: null == firstHangSeconds ? _self.firstHangSeconds : firstHangSeconds // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,energySystems: freezed == energySystems ? _self.energySystems : energySystems // ignore: cast_nullable_to_non_nullable
as EnergySystems?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutPlan].
extension WorkoutPlanPatterns on WorkoutPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutPlan value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutPlan value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tool,  Hand hand,  CurveSection section,  double benchmarkKg,  int firstHangSeconds,  int reps,  int restSeconds,  EnergySystems? energySystems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutPlan() when $default != null:
return $default(_that.tool,_that.hand,_that.section,_that.benchmarkKg,_that.firstHangSeconds,_that.reps,_that.restSeconds,_that.energySystems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tool,  Hand hand,  CurveSection section,  double benchmarkKg,  int firstHangSeconds,  int reps,  int restSeconds,  EnergySystems? energySystems)  $default,) {final _that = this;
switch (_that) {
case _WorkoutPlan():
return $default(_that.tool,_that.hand,_that.section,_that.benchmarkKg,_that.firstHangSeconds,_that.reps,_that.restSeconds,_that.energySystems);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tool,  Hand hand,  CurveSection section,  double benchmarkKg,  int firstHangSeconds,  int reps,  int restSeconds,  EnergySystems? energySystems)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutPlan() when $default != null:
return $default(_that.tool,_that.hand,_that.section,_that.benchmarkKg,_that.firstHangSeconds,_that.reps,_that.restSeconds,_that.energySystems);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutPlan extends WorkoutPlan {
  const _WorkoutPlan({required this.tool, required this.hand, required this.section, required this.benchmarkKg, required this.firstHangSeconds, required this.reps, required this.restSeconds, this.energySystems}): super._();
  

@override final  String tool;
@override final  Hand hand;
@override final  CurveSection section;
@override final  double benchmarkKg;
@override final  int firstHangSeconds;
@override final  int reps;
@override final  int restSeconds;
/// Null follows the section's rep ratios.
@override final  EnergySystems? energySystems;

/// Create a copy of WorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutPlanCopyWith<_WorkoutPlan> get copyWith => __$WorkoutPlanCopyWithImpl<_WorkoutPlan>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutPlan&&(identical(other.tool, tool) || other.tool == tool)&&(identical(other.hand, hand) || other.hand == hand)&&(identical(other.section, section) || other.section == section)&&(identical(other.benchmarkKg, benchmarkKg) || other.benchmarkKg == benchmarkKg)&&(identical(other.firstHangSeconds, firstHangSeconds) || other.firstHangSeconds == firstHangSeconds)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.energySystems, energySystems) || other.energySystems == energySystems));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tool,hand,section,benchmarkKg,firstHangSeconds,reps,restSeconds,energySystems);
}

@override
String toString() {
    return 'WorkoutPlan(tool: $tool, hand: $hand, section: $section, benchmarkKg: $benchmarkKg, firstHangSeconds: $firstHangSeconds, reps: $reps, restSeconds: $restSeconds, energySystems: $energySystems)';
}


}

/// @nodoc
abstract mixin class _$WorkoutPlanCopyWith<$Res> implements $WorkoutPlanCopyWith<$Res> {
  factory _$WorkoutPlanCopyWith(_WorkoutPlan value, $Res Function(_WorkoutPlan) _then) = __$WorkoutPlanCopyWithImpl;
@override @useResult
$Res call({
 String tool, Hand hand, CurveSection section, double benchmarkKg, int firstHangSeconds, int reps, int restSeconds, EnergySystems? energySystems
});




}
/// @nodoc
class __$WorkoutPlanCopyWithImpl<$Res>
    implements _$WorkoutPlanCopyWith<$Res> {
  __$WorkoutPlanCopyWithImpl(this._self, this._then);

  final _WorkoutPlan _self;
  final $Res Function(_WorkoutPlan) _then;

/// Create a copy of WorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tool = null,Object? hand = null,Object? section = null,Object? benchmarkKg = null,Object? firstHangSeconds = null,Object? reps = null,Object? restSeconds = null,Object? energySystems = freezed,}) {
  return _then(_WorkoutPlan(
tool: null == tool ? _self.tool : tool // ignore: cast_nullable_to_non_nullable
as String,hand: null == hand ? _self.hand : hand // ignore: cast_nullable_to_non_nullable
as Hand,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as CurveSection,benchmarkKg: null == benchmarkKg ? _self.benchmarkKg : benchmarkKg // ignore: cast_nullable_to_non_nullable
as double,firstHangSeconds: null == firstHangSeconds ? _self.firstHangSeconds : firstHangSeconds // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,energySystems: freezed == energySystems ? _self.energySystems : energySystems // ignore: cast_nullable_to_non_nullable
as EnergySystems?,
  ));
}


}

/// @nodoc
mixin _$WorkoutSetup {

 String? get tool; Hand? get hand; CurveSection? get section; WorkoutPlan? get plan;
/// Create a copy of WorkoutSetup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSetupCopyWith<WorkoutSetup> get copyWith => _$WorkoutSetupCopyWithImpl<WorkoutSetup>(this as WorkoutSetup, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkoutSetup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSetup&&(identical(other.tool, _this.tool) || other.tool == _this.tool)&&(identical(other.hand, _this.hand) || other.hand == _this.hand)&&(identical(other.section, _this.section) || other.section == _this.section)&&(identical(other.plan, _this.plan) || other.plan == _this.plan));
}


@override
int get hashCode {
  final _this = this as WorkoutSetup;
  return Object.hash(runtimeType,_this.tool,_this.hand,_this.section,_this.plan);
}

@override
String toString() {
  final _this = this as WorkoutSetup;
  return 'WorkoutSetup(tool: ${_this.tool}, hand: ${_this.hand}, section: ${_this.section}, plan: ${_this.plan})';
}


}

/// @nodoc
abstract mixin class $WorkoutSetupCopyWith<$Res>  {
  factory $WorkoutSetupCopyWith(WorkoutSetup value, $Res Function(WorkoutSetup) _then) = _$WorkoutSetupCopyWithImpl;
@useResult
$Res call({
 String? tool, Hand? hand, CurveSection? section, WorkoutPlan? plan
});


$WorkoutPlanCopyWith<$Res>? get plan;

}
/// @nodoc
class _$WorkoutSetupCopyWithImpl<$Res>
    implements $WorkoutSetupCopyWith<$Res> {
  _$WorkoutSetupCopyWithImpl(this._self, this._then);

  final WorkoutSetup _self;
  final $Res Function(WorkoutSetup) _then;

/// Create a copy of WorkoutSetup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tool = freezed,Object? hand = freezed,Object? section = freezed,Object? plan = freezed,}) {
  return _then(WorkoutSetup(
tool: freezed == tool ? _self.tool : tool // ignore: cast_nullable_to_non_nullable
as String?,hand: freezed == hand ? _self.hand : hand // ignore: cast_nullable_to_non_nullable
as Hand?,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as CurveSection?,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as WorkoutPlan?,
  ));
}
/// Create a copy of WorkoutSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutPlanCopyWith<$Res>? get plan {
    if (_self.plan == null) {
    return null;
  }

  return $WorkoutPlanCopyWith<$Res>(_self.plan!, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkoutSetup].
extension WorkoutSetupPatterns on WorkoutSetup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSetup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSetup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSetup value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSetup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSetup value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSetup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? tool,  Hand? hand,  CurveSection? section,  WorkoutPlan? plan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSetup() when $default != null:
return $default(_that.tool,_that.hand,_that.section,_that.plan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? tool,  Hand? hand,  CurveSection? section,  WorkoutPlan? plan)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSetup():
return $default(_that.tool,_that.hand,_that.section,_that.plan);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? tool,  Hand? hand,  CurveSection? section,  WorkoutPlan? plan)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSetup() when $default != null:
return $default(_that.tool,_that.hand,_that.section,_that.plan);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutSetup implements WorkoutSetup {
  const _WorkoutSetup({this.tool, this.hand, this.section, this.plan});
  

@override final  String? tool;
@override final  Hand? hand;
@override final  CurveSection? section;
@override final  WorkoutPlan? plan;

/// Create a copy of WorkoutSetup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSetupCopyWith<_WorkoutSetup> get copyWith => __$WorkoutSetupCopyWithImpl<_WorkoutSetup>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSetup&&(identical(other.tool, tool) || other.tool == tool)&&(identical(other.hand, hand) || other.hand == hand)&&(identical(other.section, section) || other.section == section)&&(identical(other.plan, plan) || other.plan == plan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tool,hand,section,plan);
}

@override
String toString() {
    return 'WorkoutSetup(tool: $tool, hand: $hand, section: $section, plan: $plan)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSetupCopyWith<$Res> implements $WorkoutSetupCopyWith<$Res> {
  factory _$WorkoutSetupCopyWith(_WorkoutSetup value, $Res Function(_WorkoutSetup) _then) = __$WorkoutSetupCopyWithImpl;
@override @useResult
$Res call({
 String? tool, Hand? hand, CurveSection? section, WorkoutPlan? plan
});


@override $WorkoutPlanCopyWith<$Res>? get plan;

}
/// @nodoc
class __$WorkoutSetupCopyWithImpl<$Res>
    implements _$WorkoutSetupCopyWith<$Res> {
  __$WorkoutSetupCopyWithImpl(this._self, this._then);

  final _WorkoutSetup _self;
  final $Res Function(_WorkoutSetup) _then;

/// Create a copy of WorkoutSetup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tool = freezed,Object? hand = freezed,Object? section = freezed,Object? plan = freezed,}) {
  return _then(_WorkoutSetup(
tool: freezed == tool ? _self.tool : tool // ignore: cast_nullable_to_non_nullable
as String?,hand: freezed == hand ? _self.hand : hand // ignore: cast_nullable_to_non_nullable
as Hand?,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as CurveSection?,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as WorkoutPlan?,
  ));
}

/// Create a copy of WorkoutSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutPlanCopyWith<$Res>? get plan {
    if (_self.plan == null) {
    return null;
  }

  return $WorkoutPlanCopyWith<$Res>(_self.plan!, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}

/// @nodoc
mixin _$WorkoutState {

 WorkoutPlan? get plan; WorkoutPhase get phase;/// Current rep, or the last one during a rest. 1-based.
 int get rep; int get restRemainingSeconds; bool get paused;/// The force reached the target in the current rep.
 bool get holding; double get heldSeconds;/// Force of the current rep over the seconds since its first sample, a
/// mean point every 0.1 s.
 List<FlSpot> get forceTrace; List<double> get actualSeconds;/// Mean force of each rep, null for a rep not held.
 List<double?> get repForcesKg; bool get saved;/// The device disconnected before the last rep.
 bool get disconnected;
/// Create a copy of WorkoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutStateCopyWith<WorkoutState> get copyWith => _$WorkoutStateCopyWithImpl<WorkoutState>(this as WorkoutState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkoutState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutState&&(identical(other.plan, _this.plan) || other.plan == _this.plan)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.rep, _this.rep) || other.rep == _this.rep)&&(identical(other.restRemainingSeconds, _this.restRemainingSeconds) || other.restRemainingSeconds == _this.restRemainingSeconds)&&(identical(other.paused, _this.paused) || other.paused == _this.paused)&&(identical(other.holding, _this.holding) || other.holding == _this.holding)&&(identical(other.heldSeconds, _this.heldSeconds) || other.heldSeconds == _this.heldSeconds)&&const DeepCollectionEquality().equals(other.forceTrace, _this.forceTrace)&&const DeepCollectionEquality().equals(other.actualSeconds, _this.actualSeconds)&&const DeepCollectionEquality().equals(other.repForcesKg, _this.repForcesKg)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.disconnected, _this.disconnected) || other.disconnected == _this.disconnected));
}


@override
int get hashCode {
  final _this = this as WorkoutState;
  return Object.hash(runtimeType,_this.plan,_this.phase,_this.rep,_this.restRemainingSeconds,_this.paused,_this.holding,_this.heldSeconds,const DeepCollectionEquality().hash(_this.forceTrace),const DeepCollectionEquality().hash(_this.actualSeconds),const DeepCollectionEquality().hash(_this.repForcesKg),_this.saved,_this.disconnected);
}

@override
String toString() {
  final _this = this as WorkoutState;
  return 'WorkoutState(plan: ${_this.plan}, phase: ${_this.phase}, rep: ${_this.rep}, restRemainingSeconds: ${_this.restRemainingSeconds}, paused: ${_this.paused}, holding: ${_this.holding}, heldSeconds: ${_this.heldSeconds}, forceTrace: ${_this.forceTrace}, actualSeconds: ${_this.actualSeconds}, repForcesKg: ${_this.repForcesKg}, saved: ${_this.saved}, disconnected: ${_this.disconnected})';
}


}

/// @nodoc
abstract mixin class $WorkoutStateCopyWith<$Res>  {
  factory $WorkoutStateCopyWith(WorkoutState value, $Res Function(WorkoutState) _then) = _$WorkoutStateCopyWithImpl;
@useResult
$Res call({
 WorkoutPlan? plan, WorkoutPhase phase, int rep, int restRemainingSeconds, bool paused, bool holding, double heldSeconds, List<FlSpot> forceTrace, List<double> actualSeconds, List<double?> repForcesKg, bool saved, bool disconnected
});


$WorkoutPlanCopyWith<$Res>? get plan;

}
/// @nodoc
class _$WorkoutStateCopyWithImpl<$Res>
    implements $WorkoutStateCopyWith<$Res> {
  _$WorkoutStateCopyWithImpl(this._self, this._then);

  final WorkoutState _self;
  final $Res Function(WorkoutState) _then;

/// Create a copy of WorkoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plan = freezed,Object? phase = null,Object? rep = null,Object? restRemainingSeconds = null,Object? paused = null,Object? holding = null,Object? heldSeconds = null,Object? forceTrace = null,Object? actualSeconds = null,Object? repForcesKg = null,Object? saved = null,Object? disconnected = null,}) {
  return _then(WorkoutState(
plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as WorkoutPlan?,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as WorkoutPhase,rep: null == rep ? _self.rep : rep // ignore: cast_nullable_to_non_nullable
as int,restRemainingSeconds: null == restRemainingSeconds ? _self.restRemainingSeconds : restRemainingSeconds // ignore: cast_nullable_to_non_nullable
as int,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,holding: null == holding ? _self.holding : holding // ignore: cast_nullable_to_non_nullable
as bool,heldSeconds: null == heldSeconds ? _self.heldSeconds : heldSeconds // ignore: cast_nullable_to_non_nullable
as double,forceTrace: null == forceTrace ? _self.forceTrace : forceTrace // ignore: cast_nullable_to_non_nullable
as List<FlSpot>,actualSeconds: null == actualSeconds ? _self.actualSeconds : actualSeconds // ignore: cast_nullable_to_non_nullable
as List<double>,repForcesKg: null == repForcesKg ? _self.repForcesKg : repForcesKg // ignore: cast_nullable_to_non_nullable
as List<double?>,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,disconnected: null == disconnected ? _self.disconnected : disconnected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of WorkoutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutPlanCopyWith<$Res>? get plan {
    if (_self.plan == null) {
    return null;
  }

  return $WorkoutPlanCopyWith<$Res>(_self.plan!, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkoutState].
extension WorkoutStatePatterns on WorkoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutState value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutState value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WorkoutPlan? plan,  WorkoutPhase phase,  int rep,  int restRemainingSeconds,  bool paused,  bool holding,  double heldSeconds,  List<FlSpot> forceTrace,  List<double> actualSeconds,  List<double?> repForcesKg,  bool saved,  bool disconnected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutState() when $default != null:
return $default(_that.plan,_that.phase,_that.rep,_that.restRemainingSeconds,_that.paused,_that.holding,_that.heldSeconds,_that.forceTrace,_that.actualSeconds,_that.repForcesKg,_that.saved,_that.disconnected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WorkoutPlan? plan,  WorkoutPhase phase,  int rep,  int restRemainingSeconds,  bool paused,  bool holding,  double heldSeconds,  List<FlSpot> forceTrace,  List<double> actualSeconds,  List<double?> repForcesKg,  bool saved,  bool disconnected)  $default,) {final _that = this;
switch (_that) {
case _WorkoutState():
return $default(_that.plan,_that.phase,_that.rep,_that.restRemainingSeconds,_that.paused,_that.holding,_that.heldSeconds,_that.forceTrace,_that.actualSeconds,_that.repForcesKg,_that.saved,_that.disconnected);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WorkoutPlan? plan,  WorkoutPhase phase,  int rep,  int restRemainingSeconds,  bool paused,  bool holding,  double heldSeconds,  List<FlSpot> forceTrace,  List<double> actualSeconds,  List<double?> repForcesKg,  bool saved,  bool disconnected)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutState() when $default != null:
return $default(_that.plan,_that.phase,_that.rep,_that.restRemainingSeconds,_that.paused,_that.holding,_that.heldSeconds,_that.forceTrace,_that.actualSeconds,_that.repForcesKg,_that.saved,_that.disconnected);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutState extends WorkoutState {
  const _WorkoutState({this.plan, this.phase = WorkoutPhase.idle, this.rep = 1, this.restRemainingSeconds = 0, this.paused = false, this.holding = false, this.heldSeconds = 0.0,  List<FlSpot> forceTrace = const [],  List<double> actualSeconds = const [],  List<double?> repForcesKg = const [], this.saved = false, this.disconnected = false}): _forceTrace = forceTrace,_actualSeconds = actualSeconds,_repForcesKg = repForcesKg,super._();
  

@override final  WorkoutPlan? plan;
@override@JsonKey() final  WorkoutPhase phase;
/// Current rep, or the last one during a rest. 1-based.
@override@JsonKey() final  int rep;
@override@JsonKey() final  int restRemainingSeconds;
@override@JsonKey() final  bool paused;
/// The force reached the target in the current rep.
@override@JsonKey() final  bool holding;
@override@JsonKey() final  double heldSeconds;
/// Force of the current rep over the seconds since its first sample, a
/// mean point every 0.1 s.
 final  List<FlSpot> _forceTrace;
/// Force of the current rep over the seconds since its first sample, a
/// mean point every 0.1 s.
@override@JsonKey() List<FlSpot> get forceTrace {
  if (_forceTrace is EqualUnmodifiableListView) return _forceTrace;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_forceTrace);
}

 final  List<double> _actualSeconds;
@override@JsonKey() List<double> get actualSeconds {
  if (_actualSeconds is EqualUnmodifiableListView) return _actualSeconds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actualSeconds);
}

/// Mean force of each rep, null for a rep not held.
 final  List<double?> _repForcesKg;
/// Mean force of each rep, null for a rep not held.
@override@JsonKey() List<double?> get repForcesKg {
  if (_repForcesKg is EqualUnmodifiableListView) return _repForcesKg;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_repForcesKg);
}

@override@JsonKey() final  bool saved;
/// The device disconnected before the last rep.
@override@JsonKey() final  bool disconnected;

/// Create a copy of WorkoutState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutStateCopyWith<_WorkoutState> get copyWith => __$WorkoutStateCopyWithImpl<_WorkoutState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutState&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.rep, rep) || other.rep == rep)&&(identical(other.restRemainingSeconds, restRemainingSeconds) || other.restRemainingSeconds == restRemainingSeconds)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.holding, holding) || other.holding == holding)&&(identical(other.heldSeconds, heldSeconds) || other.heldSeconds == heldSeconds)&&const DeepCollectionEquality().equals(other.forceTrace, _forceTrace)&&const DeepCollectionEquality().equals(other.actualSeconds, _actualSeconds)&&const DeepCollectionEquality().equals(other.repForcesKg, _repForcesKg)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.disconnected, disconnected) || other.disconnected == disconnected));
}


@override
int get hashCode {
    return Object.hash(runtimeType,plan,phase,rep,restRemainingSeconds,paused,holding,heldSeconds,const DeepCollectionEquality().hash(_forceTrace),const DeepCollectionEquality().hash(_actualSeconds),const DeepCollectionEquality().hash(_repForcesKg),saved,disconnected);
}

@override
String toString() {
    return 'WorkoutState(plan: $plan, phase: $phase, rep: $rep, restRemainingSeconds: $restRemainingSeconds, paused: $paused, holding: $holding, heldSeconds: $heldSeconds, forceTrace: $forceTrace, actualSeconds: $actualSeconds, repForcesKg: $repForcesKg, saved: $saved, disconnected: $disconnected)';
}


}

/// @nodoc
abstract mixin class _$WorkoutStateCopyWith<$Res> implements $WorkoutStateCopyWith<$Res> {
  factory _$WorkoutStateCopyWith(_WorkoutState value, $Res Function(_WorkoutState) _then) = __$WorkoutStateCopyWithImpl;
@override @useResult
$Res call({
 WorkoutPlan? plan, WorkoutPhase phase, int rep, int restRemainingSeconds, bool paused, bool holding, double heldSeconds, List<FlSpot> forceTrace, List<double> actualSeconds, List<double?> repForcesKg, bool saved, bool disconnected
});


@override $WorkoutPlanCopyWith<$Res>? get plan;

}
/// @nodoc
class __$WorkoutStateCopyWithImpl<$Res>
    implements _$WorkoutStateCopyWith<$Res> {
  __$WorkoutStateCopyWithImpl(this._self, this._then);

  final _WorkoutState _self;
  final $Res Function(_WorkoutState) _then;

/// Create a copy of WorkoutState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plan = freezed,Object? phase = null,Object? rep = null,Object? restRemainingSeconds = null,Object? paused = null,Object? holding = null,Object? heldSeconds = null,Object? forceTrace = null,Object? actualSeconds = null,Object? repForcesKg = null,Object? saved = null,Object? disconnected = null,}) {
  return _then(_WorkoutState(
plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as WorkoutPlan?,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as WorkoutPhase,rep: null == rep ? _self.rep : rep // ignore: cast_nullable_to_non_nullable
as int,restRemainingSeconds: null == restRemainingSeconds ? _self.restRemainingSeconds : restRemainingSeconds // ignore: cast_nullable_to_non_nullable
as int,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,holding: null == holding ? _self.holding : holding // ignore: cast_nullable_to_non_nullable
as bool,heldSeconds: null == heldSeconds ? _self.heldSeconds : heldSeconds // ignore: cast_nullable_to_non_nullable
as double,forceTrace: null == forceTrace ? _self._forceTrace : forceTrace // ignore: cast_nullable_to_non_nullable
as List<FlSpot>,actualSeconds: null == actualSeconds ? _self._actualSeconds : actualSeconds // ignore: cast_nullable_to_non_nullable
as List<double>,repForcesKg: null == repForcesKg ? _self._repForcesKg : repForcesKg // ignore: cast_nullable_to_non_nullable
as List<double?>,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,disconnected: null == disconnected ? _self.disconnected : disconnected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of WorkoutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutPlanCopyWith<$Res>? get plan {
    if (_self.plan == null) {
    return null;
  }

  return $WorkoutPlanCopyWith<$Res>(_self.plan!, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}

// dart format on

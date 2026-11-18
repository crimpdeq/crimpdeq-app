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

 String? get tool; Hand? get hand; WorkoutHands get hands; CurveSection? get section; WorkoutPlan? get plan;
/// Create a copy of WorkoutSetup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSetupCopyWith<WorkoutSetup> get copyWith => _$WorkoutSetupCopyWithImpl<WorkoutSetup>(this as WorkoutSetup, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkoutSetup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSetup&&(identical(other.tool, _this.tool) || other.tool == _this.tool)&&(identical(other.hand, _this.hand) || other.hand == _this.hand)&&(identical(other.hands, _this.hands) || other.hands == _this.hands)&&(identical(other.section, _this.section) || other.section == _this.section)&&(identical(other.plan, _this.plan) || other.plan == _this.plan));
}


@override
int get hashCode {
  final _this = this as WorkoutSetup;
  return Object.hash(runtimeType,_this.tool,_this.hand,_this.hands,_this.section,_this.plan);
}

@override
String toString() {
  final _this = this as WorkoutSetup;
  return 'WorkoutSetup(tool: ${_this.tool}, hand: ${_this.hand}, hands: ${_this.hands}, section: ${_this.section}, plan: ${_this.plan})';
}


}

/// @nodoc
abstract mixin class $WorkoutSetupCopyWith<$Res>  {
  factory $WorkoutSetupCopyWith(WorkoutSetup value, $Res Function(WorkoutSetup) _then) = _$WorkoutSetupCopyWithImpl;
@useResult
$Res call({
 String? tool, Hand? hand, WorkoutHands hands, CurveSection? section, WorkoutPlan? plan
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
@pragma('vm:prefer-inline') @override $Res call({Object? tool = freezed,Object? hand = freezed,Object? hands = null,Object? section = freezed,Object? plan = freezed,}) {
  return _then(WorkoutSetup(
tool: freezed == tool ? _self.tool : tool // ignore: cast_nullable_to_non_nullable
as String?,hand: freezed == hand ? _self.hand : hand // ignore: cast_nullable_to_non_nullable
as Hand?,hands: null == hands ? _self.hands : hands // ignore: cast_nullable_to_non_nullable
as WorkoutHands,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? tool,  Hand? hand,  WorkoutHands hands,  CurveSection? section,  WorkoutPlan? plan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSetup() when $default != null:
return $default(_that.tool,_that.hand,_that.hands,_that.section,_that.plan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? tool,  Hand? hand,  WorkoutHands hands,  CurveSection? section,  WorkoutPlan? plan)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSetup():
return $default(_that.tool,_that.hand,_that.hands,_that.section,_that.plan);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? tool,  Hand? hand,  WorkoutHands hands,  CurveSection? section,  WorkoutPlan? plan)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSetup() when $default != null:
return $default(_that.tool,_that.hand,_that.hands,_that.section,_that.plan);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutSetup implements WorkoutSetup {
  const _WorkoutSetup({this.tool, this.hand, this.hands = WorkoutHands.one, this.section, this.plan});
  

@override final  String? tool;
@override final  Hand? hand;
@override@JsonKey() final  WorkoutHands hands;
@override final  CurveSection? section;
@override final  WorkoutPlan? plan;

/// Create a copy of WorkoutSetup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSetupCopyWith<_WorkoutSetup> get copyWith => __$WorkoutSetupCopyWithImpl<_WorkoutSetup>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSetup&&(identical(other.tool, tool) || other.tool == tool)&&(identical(other.hand, hand) || other.hand == hand)&&(identical(other.hands, hands) || other.hands == hands)&&(identical(other.section, section) || other.section == section)&&(identical(other.plan, plan) || other.plan == plan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tool,hand,hands,section,plan);
}

@override
String toString() {
    return 'WorkoutSetup(tool: $tool, hand: $hand, hands: $hands, section: $section, plan: $plan)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSetupCopyWith<$Res> implements $WorkoutSetupCopyWith<$Res> {
  factory _$WorkoutSetupCopyWith(_WorkoutSetup value, $Res Function(_WorkoutSetup) _then) = __$WorkoutSetupCopyWithImpl;
@override @useResult
$Res call({
 String? tool, Hand? hand, WorkoutHands hands, CurveSection? section, WorkoutPlan? plan
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
@override @pragma('vm:prefer-inline') $Res call({Object? tool = freezed,Object? hand = freezed,Object? hands = null,Object? section = freezed,Object? plan = freezed,}) {
  return _then(_WorkoutSetup(
tool: freezed == tool ? _self.tool : tool // ignore: cast_nullable_to_non_nullable
as String?,hand: freezed == hand ? _self.hand : hand // ignore: cast_nullable_to_non_nullable
as Hand?,hands: null == hands ? _self.hands : hands // ignore: cast_nullable_to_non_nullable
as WorkoutHands,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
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
mixin _$WarmupState {

 WarmupKind? get kind; List<WarmupStep> get steps; WorkoutPhase get phase;/// Current step, or the next one during its hand's rest. 0-based.
 int get step;/// The rest of the step's hand, or once a training warm-up is done, the
/// rest before the workout.
 int get restRemainingSeconds; bool get paused; bool get holding; bool get waitingForRelease; double get heldSeconds;/// The hold pulls well over its target force.
 bool get overshooting; List<FlSpot> get forceTrace;/// Best 5 s of each step done, null for a hold at a force or a maximal
/// pull under 5 s.
 List<double?> get bestKg;/// The readiness check is stored in the training log.
 bool get saved; WorkoutEnd? get endedEarly;
/// Create a copy of WarmupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarmupStateCopyWith<WarmupState> get copyWith => _$WarmupStateCopyWithImpl<WarmupState>(this as WarmupState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WarmupState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WarmupState&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&const DeepCollectionEquality().equals(other.steps, _this.steps)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.restRemainingSeconds, _this.restRemainingSeconds) || other.restRemainingSeconds == _this.restRemainingSeconds)&&(identical(other.paused, _this.paused) || other.paused == _this.paused)&&(identical(other.holding, _this.holding) || other.holding == _this.holding)&&(identical(other.waitingForRelease, _this.waitingForRelease) || other.waitingForRelease == _this.waitingForRelease)&&(identical(other.heldSeconds, _this.heldSeconds) || other.heldSeconds == _this.heldSeconds)&&(identical(other.overshooting, _this.overshooting) || other.overshooting == _this.overshooting)&&const DeepCollectionEquality().equals(other.forceTrace, _this.forceTrace)&&const DeepCollectionEquality().equals(other.bestKg, _this.bestKg)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.endedEarly, _this.endedEarly) || other.endedEarly == _this.endedEarly));
}


@override
int get hashCode {
  final _this = this as WarmupState;
  return Object.hash(runtimeType,_this.kind,const DeepCollectionEquality().hash(_this.steps),_this.phase,_this.step,_this.restRemainingSeconds,_this.paused,_this.holding,_this.waitingForRelease,_this.heldSeconds,_this.overshooting,const DeepCollectionEquality().hash(_this.forceTrace),const DeepCollectionEquality().hash(_this.bestKg),_this.saved,_this.endedEarly);
}

@override
String toString() {
  final _this = this as WarmupState;
  return 'WarmupState(kind: ${_this.kind}, steps: ${_this.steps}, phase: ${_this.phase}, step: ${_this.step}, restRemainingSeconds: ${_this.restRemainingSeconds}, paused: ${_this.paused}, holding: ${_this.holding}, waitingForRelease: ${_this.waitingForRelease}, heldSeconds: ${_this.heldSeconds}, overshooting: ${_this.overshooting}, forceTrace: ${_this.forceTrace}, bestKg: ${_this.bestKg}, saved: ${_this.saved}, endedEarly: ${_this.endedEarly})';
}


}

/// @nodoc
abstract mixin class $WarmupStateCopyWith<$Res>  {
  factory $WarmupStateCopyWith(WarmupState value, $Res Function(WarmupState) _then) = _$WarmupStateCopyWithImpl;
@useResult
$Res call({
 WarmupKind? kind, List<WarmupStep> steps, WorkoutPhase phase, int step, int restRemainingSeconds, bool paused, bool holding, bool waitingForRelease, double heldSeconds, bool overshooting, List<FlSpot> forceTrace, List<double?> bestKg, bool saved, WorkoutEnd? endedEarly
});




}
/// @nodoc
class _$WarmupStateCopyWithImpl<$Res>
    implements $WarmupStateCopyWith<$Res> {
  _$WarmupStateCopyWithImpl(this._self, this._then);

  final WarmupState _self;
  final $Res Function(WarmupState) _then;

/// Create a copy of WarmupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = freezed,Object? steps = null,Object? phase = null,Object? step = null,Object? restRemainingSeconds = null,Object? paused = null,Object? holding = null,Object? waitingForRelease = null,Object? heldSeconds = null,Object? overshooting = null,Object? forceTrace = null,Object? bestKg = null,Object? saved = null,Object? endedEarly = freezed,}) {
  return _then(WarmupState(
kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as WarmupKind?,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<WarmupStep>,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as WorkoutPhase,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,restRemainingSeconds: null == restRemainingSeconds ? _self.restRemainingSeconds : restRemainingSeconds // ignore: cast_nullable_to_non_nullable
as int,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,holding: null == holding ? _self.holding : holding // ignore: cast_nullable_to_non_nullable
as bool,waitingForRelease: null == waitingForRelease ? _self.waitingForRelease : waitingForRelease // ignore: cast_nullable_to_non_nullable
as bool,heldSeconds: null == heldSeconds ? _self.heldSeconds : heldSeconds // ignore: cast_nullable_to_non_nullable
as double,overshooting: null == overshooting ? _self.overshooting : overshooting // ignore: cast_nullable_to_non_nullable
as bool,forceTrace: null == forceTrace ? _self.forceTrace : forceTrace // ignore: cast_nullable_to_non_nullable
as List<FlSpot>,bestKg: null == bestKg ? _self.bestKg : bestKg // ignore: cast_nullable_to_non_nullable
as List<double?>,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,endedEarly: freezed == endedEarly ? _self.endedEarly : endedEarly // ignore: cast_nullable_to_non_nullable
as WorkoutEnd?,
  ));
}

}


/// Adds pattern-matching-related methods to [WarmupState].
extension WarmupStatePatterns on WarmupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WarmupState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WarmupState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WarmupState value)  $default,){
final _that = this;
switch (_that) {
case _WarmupState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WarmupState value)?  $default,){
final _that = this;
switch (_that) {
case _WarmupState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WarmupKind? kind,  List<WarmupStep> steps,  WorkoutPhase phase,  int step,  int restRemainingSeconds,  bool paused,  bool holding,  bool waitingForRelease,  double heldSeconds,  bool overshooting,  List<FlSpot> forceTrace,  List<double?> bestKg,  bool saved,  WorkoutEnd? endedEarly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WarmupState() when $default != null:
return $default(_that.kind,_that.steps,_that.phase,_that.step,_that.restRemainingSeconds,_that.paused,_that.holding,_that.waitingForRelease,_that.heldSeconds,_that.overshooting,_that.forceTrace,_that.bestKg,_that.saved,_that.endedEarly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WarmupKind? kind,  List<WarmupStep> steps,  WorkoutPhase phase,  int step,  int restRemainingSeconds,  bool paused,  bool holding,  bool waitingForRelease,  double heldSeconds,  bool overshooting,  List<FlSpot> forceTrace,  List<double?> bestKg,  bool saved,  WorkoutEnd? endedEarly)  $default,) {final _that = this;
switch (_that) {
case _WarmupState():
return $default(_that.kind,_that.steps,_that.phase,_that.step,_that.restRemainingSeconds,_that.paused,_that.holding,_that.waitingForRelease,_that.heldSeconds,_that.overshooting,_that.forceTrace,_that.bestKg,_that.saved,_that.endedEarly);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WarmupKind? kind,  List<WarmupStep> steps,  WorkoutPhase phase,  int step,  int restRemainingSeconds,  bool paused,  bool holding,  bool waitingForRelease,  double heldSeconds,  bool overshooting,  List<FlSpot> forceTrace,  List<double?> bestKg,  bool saved,  WorkoutEnd? endedEarly)?  $default,) {final _that = this;
switch (_that) {
case _WarmupState() when $default != null:
return $default(_that.kind,_that.steps,_that.phase,_that.step,_that.restRemainingSeconds,_that.paused,_that.holding,_that.waitingForRelease,_that.heldSeconds,_that.overshooting,_that.forceTrace,_that.bestKg,_that.saved,_that.endedEarly);case _:
  return null;

}
}

}

/// @nodoc


class _WarmupState extends WarmupState {
  const _WarmupState({this.kind,  List<WarmupStep> steps = const [], this.phase = WorkoutPhase.idle, this.step = 0, this.restRemainingSeconds = 0, this.paused = false, this.holding = false, this.waitingForRelease = false, this.heldSeconds = 0.0, this.overshooting = false,  List<FlSpot> forceTrace = const [],  List<double?> bestKg = const [], this.saved = false, this.endedEarly}): _steps = steps,_forceTrace = forceTrace,_bestKg = bestKg,super._();
  

@override final  WarmupKind? kind;
 final  List<WarmupStep> _steps;
@override@JsonKey() List<WarmupStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

@override@JsonKey() final  WorkoutPhase phase;
/// Current step, or the next one during its hand's rest. 0-based.
@override@JsonKey() final  int step;
/// The rest of the step's hand, or once a training warm-up is done, the
/// rest before the workout.
@override@JsonKey() final  int restRemainingSeconds;
@override@JsonKey() final  bool paused;
@override@JsonKey() final  bool holding;
@override@JsonKey() final  bool waitingForRelease;
@override@JsonKey() final  double heldSeconds;
/// The hold pulls well over its target force.
@override@JsonKey() final  bool overshooting;
 final  List<FlSpot> _forceTrace;
@override@JsonKey() List<FlSpot> get forceTrace {
  if (_forceTrace is EqualUnmodifiableListView) return _forceTrace;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_forceTrace);
}

/// Best 5 s of each step done, null for a hold at a force or a maximal
/// pull under 5 s.
 final  List<double?> _bestKg;
/// Best 5 s of each step done, null for a hold at a force or a maximal
/// pull under 5 s.
@override@JsonKey() List<double?> get bestKg {
  if (_bestKg is EqualUnmodifiableListView) return _bestKg;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bestKg);
}

/// The readiness check is stored in the training log.
@override@JsonKey() final  bool saved;
@override final  WorkoutEnd? endedEarly;

/// Create a copy of WarmupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarmupStateCopyWith<_WarmupState> get copyWith => __$WarmupStateCopyWithImpl<_WarmupState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WarmupState&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.steps, _steps)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.step, step) || other.step == step)&&(identical(other.restRemainingSeconds, restRemainingSeconds) || other.restRemainingSeconds == restRemainingSeconds)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.holding, holding) || other.holding == holding)&&(identical(other.waitingForRelease, waitingForRelease) || other.waitingForRelease == waitingForRelease)&&(identical(other.heldSeconds, heldSeconds) || other.heldSeconds == heldSeconds)&&(identical(other.overshooting, overshooting) || other.overshooting == overshooting)&&const DeepCollectionEquality().equals(other.forceTrace, _forceTrace)&&const DeepCollectionEquality().equals(other.bestKg, _bestKg)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.endedEarly, endedEarly) || other.endedEarly == endedEarly));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind,const DeepCollectionEquality().hash(_steps),phase,step,restRemainingSeconds,paused,holding,waitingForRelease,heldSeconds,overshooting,const DeepCollectionEquality().hash(_forceTrace),const DeepCollectionEquality().hash(_bestKg),saved,endedEarly);
}

@override
String toString() {
    return 'WarmupState(kind: $kind, steps: $steps, phase: $phase, step: $step, restRemainingSeconds: $restRemainingSeconds, paused: $paused, holding: $holding, waitingForRelease: $waitingForRelease, heldSeconds: $heldSeconds, overshooting: $overshooting, forceTrace: $forceTrace, bestKg: $bestKg, saved: $saved, endedEarly: $endedEarly)';
}


}

/// @nodoc
abstract mixin class _$WarmupStateCopyWith<$Res> implements $WarmupStateCopyWith<$Res> {
  factory _$WarmupStateCopyWith(_WarmupState value, $Res Function(_WarmupState) _then) = __$WarmupStateCopyWithImpl;
@override @useResult
$Res call({
 WarmupKind? kind, List<WarmupStep> steps, WorkoutPhase phase, int step, int restRemainingSeconds, bool paused, bool holding, bool waitingForRelease, double heldSeconds, bool overshooting, List<FlSpot> forceTrace, List<double?> bestKg, bool saved, WorkoutEnd? endedEarly
});




}
/// @nodoc
class __$WarmupStateCopyWithImpl<$Res>
    implements _$WarmupStateCopyWith<$Res> {
  __$WarmupStateCopyWithImpl(this._self, this._then);

  final _WarmupState _self;
  final $Res Function(_WarmupState) _then;

/// Create a copy of WarmupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = freezed,Object? steps = null,Object? phase = null,Object? step = null,Object? restRemainingSeconds = null,Object? paused = null,Object? holding = null,Object? waitingForRelease = null,Object? heldSeconds = null,Object? overshooting = null,Object? forceTrace = null,Object? bestKg = null,Object? saved = null,Object? endedEarly = freezed,}) {
  return _then(_WarmupState(
kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as WarmupKind?,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<WarmupStep>,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as WorkoutPhase,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,restRemainingSeconds: null == restRemainingSeconds ? _self.restRemainingSeconds : restRemainingSeconds // ignore: cast_nullable_to_non_nullable
as int,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,holding: null == holding ? _self.holding : holding // ignore: cast_nullable_to_non_nullable
as bool,waitingForRelease: null == waitingForRelease ? _self.waitingForRelease : waitingForRelease // ignore: cast_nullable_to_non_nullable
as bool,heldSeconds: null == heldSeconds ? _self.heldSeconds : heldSeconds // ignore: cast_nullable_to_non_nullable
as double,overshooting: null == overshooting ? _self.overshooting : overshooting // ignore: cast_nullable_to_non_nullable
as bool,forceTrace: null == forceTrace ? _self._forceTrace : forceTrace // ignore: cast_nullable_to_non_nullable
as List<FlSpot>,bestKg: null == bestKg ? _self._bestKg : bestKg // ignore: cast_nullable_to_non_nullable
as List<double?>,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,endedEarly: freezed == endedEarly ? _self.endedEarly : endedEarly // ignore: cast_nullable_to_non_nullable
as WorkoutEnd?,
  ));
}


}

/// @nodoc
mixin _$WorkoutState {

/// One plan per hand, in the order of their first reps.
 List<WorkoutPlan> get plans;/// The hands take turns rep by rep, instead of plan by plan.
 bool get alternating; WorkoutPhase get phase;/// The rest the current rep's hand still needs.
 int get restRemainingSeconds; bool get paused;/// The pull passed the threshold, so the current hold counts.
 bool get holding;/// The current rep waits for a load left on to drop.
 bool get waitingForRelease; double get heldSeconds;/// The latest force of the workout, through the holds and rests.
 List<FlSpot> get forceTrace;/// Time held in each rep done, in the [schedule] order.
 List<double> get actualSeconds;/// Mean force of each rep done, null for a rep not held.
 List<double?> get repForcesKg; bool get saved;/// Set when the workout ended before its last rep.
 WorkoutEnd? get endedEarly;
/// Create a copy of WorkoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutStateCopyWith<WorkoutState> get copyWith => _$WorkoutStateCopyWithImpl<WorkoutState>(this as WorkoutState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkoutState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutState&&const DeepCollectionEquality().equals(other.plans, _this.plans)&&(identical(other.alternating, _this.alternating) || other.alternating == _this.alternating)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.restRemainingSeconds, _this.restRemainingSeconds) || other.restRemainingSeconds == _this.restRemainingSeconds)&&(identical(other.paused, _this.paused) || other.paused == _this.paused)&&(identical(other.holding, _this.holding) || other.holding == _this.holding)&&(identical(other.waitingForRelease, _this.waitingForRelease) || other.waitingForRelease == _this.waitingForRelease)&&(identical(other.heldSeconds, _this.heldSeconds) || other.heldSeconds == _this.heldSeconds)&&const DeepCollectionEquality().equals(other.forceTrace, _this.forceTrace)&&const DeepCollectionEquality().equals(other.actualSeconds, _this.actualSeconds)&&const DeepCollectionEquality().equals(other.repForcesKg, _this.repForcesKg)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.endedEarly, _this.endedEarly) || other.endedEarly == _this.endedEarly));
}


@override
int get hashCode {
  final _this = this as WorkoutState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.plans),_this.alternating,_this.phase,_this.restRemainingSeconds,_this.paused,_this.holding,_this.waitingForRelease,_this.heldSeconds,const DeepCollectionEquality().hash(_this.forceTrace),const DeepCollectionEquality().hash(_this.actualSeconds),const DeepCollectionEquality().hash(_this.repForcesKg),_this.saved,_this.endedEarly);
}

@override
String toString() {
  final _this = this as WorkoutState;
  return 'WorkoutState(plans: ${_this.plans}, alternating: ${_this.alternating}, phase: ${_this.phase}, restRemainingSeconds: ${_this.restRemainingSeconds}, paused: ${_this.paused}, holding: ${_this.holding}, waitingForRelease: ${_this.waitingForRelease}, heldSeconds: ${_this.heldSeconds}, forceTrace: ${_this.forceTrace}, actualSeconds: ${_this.actualSeconds}, repForcesKg: ${_this.repForcesKg}, saved: ${_this.saved}, endedEarly: ${_this.endedEarly})';
}


}

/// @nodoc
abstract mixin class $WorkoutStateCopyWith<$Res>  {
  factory $WorkoutStateCopyWith(WorkoutState value, $Res Function(WorkoutState) _then) = _$WorkoutStateCopyWithImpl;
@useResult
$Res call({
 List<WorkoutPlan> plans, bool alternating, WorkoutPhase phase, int restRemainingSeconds, bool paused, bool holding, bool waitingForRelease, double heldSeconds, List<FlSpot> forceTrace, List<double> actualSeconds, List<double?> repForcesKg, bool saved, WorkoutEnd? endedEarly
});




}
/// @nodoc
class _$WorkoutStateCopyWithImpl<$Res>
    implements $WorkoutStateCopyWith<$Res> {
  _$WorkoutStateCopyWithImpl(this._self, this._then);

  final WorkoutState _self;
  final $Res Function(WorkoutState) _then;

/// Create a copy of WorkoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plans = null,Object? alternating = null,Object? phase = null,Object? restRemainingSeconds = null,Object? paused = null,Object? holding = null,Object? waitingForRelease = null,Object? heldSeconds = null,Object? forceTrace = null,Object? actualSeconds = null,Object? repForcesKg = null,Object? saved = null,Object? endedEarly = freezed,}) {
  return _then(WorkoutState(
plans: null == plans ? _self.plans : plans // ignore: cast_nullable_to_non_nullable
as List<WorkoutPlan>,alternating: null == alternating ? _self.alternating : alternating // ignore: cast_nullable_to_non_nullable
as bool,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as WorkoutPhase,restRemainingSeconds: null == restRemainingSeconds ? _self.restRemainingSeconds : restRemainingSeconds // ignore: cast_nullable_to_non_nullable
as int,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,holding: null == holding ? _self.holding : holding // ignore: cast_nullable_to_non_nullable
as bool,waitingForRelease: null == waitingForRelease ? _self.waitingForRelease : waitingForRelease // ignore: cast_nullable_to_non_nullable
as bool,heldSeconds: null == heldSeconds ? _self.heldSeconds : heldSeconds // ignore: cast_nullable_to_non_nullable
as double,forceTrace: null == forceTrace ? _self.forceTrace : forceTrace // ignore: cast_nullable_to_non_nullable
as List<FlSpot>,actualSeconds: null == actualSeconds ? _self.actualSeconds : actualSeconds // ignore: cast_nullable_to_non_nullable
as List<double>,repForcesKg: null == repForcesKg ? _self.repForcesKg : repForcesKg // ignore: cast_nullable_to_non_nullable
as List<double?>,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,endedEarly: freezed == endedEarly ? _self.endedEarly : endedEarly // ignore: cast_nullable_to_non_nullable
as WorkoutEnd?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<WorkoutPlan> plans,  bool alternating,  WorkoutPhase phase,  int restRemainingSeconds,  bool paused,  bool holding,  bool waitingForRelease,  double heldSeconds,  List<FlSpot> forceTrace,  List<double> actualSeconds,  List<double?> repForcesKg,  bool saved,  WorkoutEnd? endedEarly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutState() when $default != null:
return $default(_that.plans,_that.alternating,_that.phase,_that.restRemainingSeconds,_that.paused,_that.holding,_that.waitingForRelease,_that.heldSeconds,_that.forceTrace,_that.actualSeconds,_that.repForcesKg,_that.saved,_that.endedEarly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<WorkoutPlan> plans,  bool alternating,  WorkoutPhase phase,  int restRemainingSeconds,  bool paused,  bool holding,  bool waitingForRelease,  double heldSeconds,  List<FlSpot> forceTrace,  List<double> actualSeconds,  List<double?> repForcesKg,  bool saved,  WorkoutEnd? endedEarly)  $default,) {final _that = this;
switch (_that) {
case _WorkoutState():
return $default(_that.plans,_that.alternating,_that.phase,_that.restRemainingSeconds,_that.paused,_that.holding,_that.waitingForRelease,_that.heldSeconds,_that.forceTrace,_that.actualSeconds,_that.repForcesKg,_that.saved,_that.endedEarly);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<WorkoutPlan> plans,  bool alternating,  WorkoutPhase phase,  int restRemainingSeconds,  bool paused,  bool holding,  bool waitingForRelease,  double heldSeconds,  List<FlSpot> forceTrace,  List<double> actualSeconds,  List<double?> repForcesKg,  bool saved,  WorkoutEnd? endedEarly)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutState() when $default != null:
return $default(_that.plans,_that.alternating,_that.phase,_that.restRemainingSeconds,_that.paused,_that.holding,_that.waitingForRelease,_that.heldSeconds,_that.forceTrace,_that.actualSeconds,_that.repForcesKg,_that.saved,_that.endedEarly);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutState extends WorkoutState {
  const _WorkoutState({ List<WorkoutPlan> plans = const [], this.alternating = false, this.phase = WorkoutPhase.idle, this.restRemainingSeconds = 0, this.paused = false, this.holding = false, this.waitingForRelease = false, this.heldSeconds = 0.0,  List<FlSpot> forceTrace = const [],  List<double> actualSeconds = const [],  List<double?> repForcesKg = const [], this.saved = false, this.endedEarly}): _plans = plans,_forceTrace = forceTrace,_actualSeconds = actualSeconds,_repForcesKg = repForcesKg,super._();
  

/// One plan per hand, in the order of their first reps.
 final  List<WorkoutPlan> _plans;
/// One plan per hand, in the order of their first reps.
@override@JsonKey() List<WorkoutPlan> get plans {
  if (_plans is EqualUnmodifiableListView) return _plans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plans);
}

/// The hands take turns rep by rep, instead of plan by plan.
@override@JsonKey() final  bool alternating;
@override@JsonKey() final  WorkoutPhase phase;
/// The rest the current rep's hand still needs.
@override@JsonKey() final  int restRemainingSeconds;
@override@JsonKey() final  bool paused;
/// The pull passed the threshold, so the current hold counts.
@override@JsonKey() final  bool holding;
/// The current rep waits for a load left on to drop.
@override@JsonKey() final  bool waitingForRelease;
@override@JsonKey() final  double heldSeconds;
/// The latest force of the workout, through the holds and rests.
 final  List<FlSpot> _forceTrace;
/// The latest force of the workout, through the holds and rests.
@override@JsonKey() List<FlSpot> get forceTrace {
  if (_forceTrace is EqualUnmodifiableListView) return _forceTrace;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_forceTrace);
}

/// Time held in each rep done, in the [schedule] order.
 final  List<double> _actualSeconds;
/// Time held in each rep done, in the [schedule] order.
@override@JsonKey() List<double> get actualSeconds {
  if (_actualSeconds is EqualUnmodifiableListView) return _actualSeconds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actualSeconds);
}

/// Mean force of each rep done, null for a rep not held.
 final  List<double?> _repForcesKg;
/// Mean force of each rep done, null for a rep not held.
@override@JsonKey() List<double?> get repForcesKg {
  if (_repForcesKg is EqualUnmodifiableListView) return _repForcesKg;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_repForcesKg);
}

@override@JsonKey() final  bool saved;
/// Set when the workout ended before its last rep.
@override final  WorkoutEnd? endedEarly;

/// Create a copy of WorkoutState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutStateCopyWith<_WorkoutState> get copyWith => __$WorkoutStateCopyWithImpl<_WorkoutState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutState&&const DeepCollectionEquality().equals(other.plans, _plans)&&(identical(other.alternating, alternating) || other.alternating == alternating)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.restRemainingSeconds, restRemainingSeconds) || other.restRemainingSeconds == restRemainingSeconds)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.holding, holding) || other.holding == holding)&&(identical(other.waitingForRelease, waitingForRelease) || other.waitingForRelease == waitingForRelease)&&(identical(other.heldSeconds, heldSeconds) || other.heldSeconds == heldSeconds)&&const DeepCollectionEquality().equals(other.forceTrace, _forceTrace)&&const DeepCollectionEquality().equals(other.actualSeconds, _actualSeconds)&&const DeepCollectionEquality().equals(other.repForcesKg, _repForcesKg)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.endedEarly, endedEarly) || other.endedEarly == endedEarly));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_plans),alternating,phase,restRemainingSeconds,paused,holding,waitingForRelease,heldSeconds,const DeepCollectionEquality().hash(_forceTrace),const DeepCollectionEquality().hash(_actualSeconds),const DeepCollectionEquality().hash(_repForcesKg),saved,endedEarly);
}

@override
String toString() {
    return 'WorkoutState(plans: $plans, alternating: $alternating, phase: $phase, restRemainingSeconds: $restRemainingSeconds, paused: $paused, holding: $holding, waitingForRelease: $waitingForRelease, heldSeconds: $heldSeconds, forceTrace: $forceTrace, actualSeconds: $actualSeconds, repForcesKg: $repForcesKg, saved: $saved, endedEarly: $endedEarly)';
}


}

/// @nodoc
abstract mixin class _$WorkoutStateCopyWith<$Res> implements $WorkoutStateCopyWith<$Res> {
  factory _$WorkoutStateCopyWith(_WorkoutState value, $Res Function(_WorkoutState) _then) = __$WorkoutStateCopyWithImpl;
@override @useResult
$Res call({
 List<WorkoutPlan> plans, bool alternating, WorkoutPhase phase, int restRemainingSeconds, bool paused, bool holding, bool waitingForRelease, double heldSeconds, List<FlSpot> forceTrace, List<double> actualSeconds, List<double?> repForcesKg, bool saved, WorkoutEnd? endedEarly
});




}
/// @nodoc
class __$WorkoutStateCopyWithImpl<$Res>
    implements _$WorkoutStateCopyWith<$Res> {
  __$WorkoutStateCopyWithImpl(this._self, this._then);

  final _WorkoutState _self;
  final $Res Function(_WorkoutState) _then;

/// Create a copy of WorkoutState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plans = null,Object? alternating = null,Object? phase = null,Object? restRemainingSeconds = null,Object? paused = null,Object? holding = null,Object? waitingForRelease = null,Object? heldSeconds = null,Object? forceTrace = null,Object? actualSeconds = null,Object? repForcesKg = null,Object? saved = null,Object? endedEarly = freezed,}) {
  return _then(_WorkoutState(
plans: null == plans ? _self._plans : plans // ignore: cast_nullable_to_non_nullable
as List<WorkoutPlan>,alternating: null == alternating ? _self.alternating : alternating // ignore: cast_nullable_to_non_nullable
as bool,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as WorkoutPhase,restRemainingSeconds: null == restRemainingSeconds ? _self.restRemainingSeconds : restRemainingSeconds // ignore: cast_nullable_to_non_nullable
as int,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,holding: null == holding ? _self.holding : holding // ignore: cast_nullable_to_non_nullable
as bool,waitingForRelease: null == waitingForRelease ? _self.waitingForRelease : waitingForRelease // ignore: cast_nullable_to_non_nullable
as bool,heldSeconds: null == heldSeconds ? _self.heldSeconds : heldSeconds // ignore: cast_nullable_to_non_nullable
as double,forceTrace: null == forceTrace ? _self._forceTrace : forceTrace // ignore: cast_nullable_to_non_nullable
as List<FlSpot>,actualSeconds: null == actualSeconds ? _self._actualSeconds : actualSeconds // ignore: cast_nullable_to_non_nullable
as List<double>,repForcesKg: null == repForcesKg ? _self._repForcesKg : repForcesKg // ignore: cast_nullable_to_non_nullable
as List<double?>,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,endedEarly: freezed == endedEarly ? _self.endedEarly : endedEarly // ignore: cast_nullable_to_non_nullable
as WorkoutEnd?,
  ));
}


}

// dart format on
